// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::{
    collections::HashMap,
    sync::{
        atomic::{AtomicU64, Ordering},
        Arc, LazyLock, Weak,
    },
    time::Duration,
};

use anyhow::{anyhow, ensure, Context};
use ql_codec::Decode;
use ql_common::QID;
use ql_wire::{PeerBundle, RecordHeader, SoftwareCrypto, QL_WIRE_VERSION};
use tokio::{
    runtime::Handle,
    sync::{mpsc, Notify},
    task::JoinHandle,
    time::{sleep_until, timeout, Instant},
};

use crate::api::platform::OutBoundWrite;

pub const BUNDLE_BYTES: &[u8] = include_bytes!("../../../bundle.bin");
const ADDRESS: &str = "router.foundation.xyz:7447";
const IO_TIMEOUT: Duration = Duration::from_secs(10);

pub static ROUTER: LazyLock<Arc<QlRouter>> = LazyLock::new(|| {
    let runtime = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .expect("router runtime");
    let (router, commands) = QlRouter::new(runtime.handle().clone());
    let task = router.clone();
    std::thread::spawn(move || {
        let router = PeerBundle::decode_bytes(BUNDLE_BYTES).expect("embedded router bundle");
        router
            .validate(&SoftwareCrypto)
            .expect("valid router bundle");
        runtime.block_on(task.run(ADDRESS, router, commands));
    });
    router
});

pub struct QlRouter {
    commands: mpsc::Sender<Command>,
    runtime: Handle,
    next_id: AtomicU64,
}

impl QlRouter {
    pub fn register(
        &self,
        bundle: PeerBundle,
        write: mpsc::WeakSender<OutBoundWrite>,
        attach: Arc<Notify>,
    ) -> Arc<Peer> {
        let peer = Arc::new(Peer {
            bundle,
            write,
            attach,
            id: self.next_id.fetch_add(1, Ordering::Relaxed),
            commands: self.commands.clone(),
            runtime: self.runtime.clone(),
        });
        let commands = self.commands.clone();
        let registration = Arc::downgrade(&peer);
        self.runtime.spawn(async move {
            let _ = commands.send(Command::Register(registration)).await;
        });
        peer
    }

    pub fn send(&self, peer: &Arc<Peer>, record: Vec<u8>) -> anyhow::Result<()> {
        let header = RecordHeader::decode_bytes(record.as_slice())?;
        ensure!(header.version == QL_WIRE_VERSION, "invalid record version");
        ensure!(
            header.route.sender == peer.bundle.qid,
            "router sender does not match Passport"
        );
        ensure!(
            record.len() <= ql_router::MAX_RECORD_SIZE,
            "router record exceeds size limit"
        );
        self.commands
            .try_send(Command::Send(peer.bundle.qid, peer.id, record))
            .map_err(|_| anyhow!("router queue unavailable"))
    }

    fn new(runtime: Handle) -> (Arc<Self>, mpsc::Receiver<Command>) {
        let (commands, receiver) = mpsc::channel(16);
        (
            Arc::new(Self {
                commands,
                runtime,
                next_id: AtomicU64::new(0),
            }),
            receiver,
        )
    }

    async fn run(&self, address: &str, router: PeerBundle, mut commands: mpsc::Receiver<Command>) {
        let mut peers = HashMap::<QID, Registration>::new();
        let mut connection: Option<Connection> = None;
        let mut backoff = Duration::from_secs(1);
        let mut retry_at = Instant::now();

        loop {
            let result: anyhow::Result<()> = async {
                tokio::select! {
                    // session commands update the map or forward a record
                    Some(command) = commands.recv() => match command {
                        Command::Register(peer) => {
                            if let Some(current) = peer.upgrade() {
                                // spawned registrations can arrive out of order
                                if peers.get(&current.bundle.qid).is_some_and(|entry| entry.id > current.id) {
                                    return Ok(());
                                }
                                peers.insert(current.bundle.qid, Registration {
                                    peer, id: current.id,
                                });
                                if connection.is_some() {
                                    current.attach.notify_one();
                                }
                            }
                        }
                        Command::Remove(qid, id) => {
                            if let std::collections::hash_map::Entry::Occupied(entry) = peers.entry(qid) {
                                if entry.get().id == id {
                                    entry.remove();
                                }
                            }
                        }
                        Command::Send(qid, id, record) => {
                            let (Some(connection), Some(entry)) = (&mut connection, peers.get(&qid)) else {
                                return Ok(())
                            };
                            let header = RecordHeader::decode_bytes(record.as_slice())?;
                            if entry.id != id {
                                return Ok(())
                            }
                            if header.route.recipient == router.qid {
                                timeout(IO_TIMEOUT, ql_router::send_attach(&mut connection.writer, &record)).await??;
                            } else {
                                timeout(IO_TIMEOUT, ql_router::send(&mut connection.writer, &record)).await??;
                            }
                        }
                    },
                    // completed records go to the recipient's BLE writer
                    record = async { connection.as_mut().unwrap().received.recv().await }, if connection.is_some() => {
                        let (_, record) = record.context("router reader stopped")?;
                        let header = RecordHeader::decode_bytes(record.as_slice())?;
                        let Some(entry) = peers.get_mut(&header.route.recipient) else { return Ok(()) };
                        let Some(peer) = entry.peer.upgrade() else { return Ok(()) };
                        let Some(write) = peer.write.upgrade() else { return Ok(()) };
                        tokio::spawn(async move {
                            let _ = write.send(OutBoundWrite { payload: record, notify: None }).await;
                        });
                    }
                    _ = sleep_until(retry_at), if !peers.is_empty() && connection.is_none() => {
                        let (mut reader, writer) = timeout(IO_TIMEOUT, ql_router::connect(address, &router)).await??;
                        backoff = Duration::from_secs(1);
                        let (incoming, receiver) = mpsc::channel(2);
                        // receive is not cancellation safe so keep it in its own task
                        let reader = tokio::spawn(async move {
                            while let Some(record) = ql_router::receive_packet(&mut reader).await? {
                                incoming.send(record).await?;
                            }
                            Ok::<_, anyhow::Error>(())
                        });
                        connection = Some(Connection { writer, received: receiver, reader });
                        for entry in peers.values().filter_map(|entry| entry.peer.upgrade()) {
                            entry.attach.notify_one();
                        }
                    }
                }
                Ok(())
            }.await;

            if result.is_err() || peers.is_empty() {
                if let Some(connection) = connection.take() {
                    connection.reader.abort();
                }
                if let Err(error) = result {
                    log::warn!("router connection interrupted: {error}");
                    retry_at = Instant::now() + backoff;
                    backoff = (backoff * 2).min(Duration::from_secs(30));
                } else {
                    retry_at = Instant::now();
                }
            }
        }
    }
}

pub struct Peer {
    pub bundle: PeerBundle,
    write: mpsc::WeakSender<OutBoundWrite>,
    attach: Arc<Notify>,
    id: u64,
    commands: mpsc::Sender<Command>,
    runtime: Handle,
}

impl Drop for Peer {
    fn drop(&mut self) {
        let commands = self.commands.clone();
        let removal = Command::Remove(self.bundle.qid, self.id);
        self.runtime.spawn(async move {
            let _ = commands.send(removal).await;
        });
    }
}

enum Command {
    Register(Weak<Peer>),
    Remove(QID, u64),
    Send(QID, u64, Vec<u8>),
}

struct Registration {
    peer: Weak<Peer>,
    id: u64,
}

struct Connection {
    writer: ql_router::Sender,
    received: mpsc::Receiver<(ql_router::protocol::PacketKind, Vec<u8>)>,
    reader: JoinHandle<anyhow::Result<()>>,
}

#[cfg(test)]
mod tests;
