// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::future::Future;
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

use crate::api::rpc_macros::rpc_request;
use crate::router::{Peer, BUNDLE_BYTES, ROUTER};
use crate::{
    api::{
        btp::{get_decoder, BtpDechunker},
        platform::{Channels, LinkPlatform},
        rpc::{InboundRpc, RouterState},
        rust_log::setup_log_to_console,
    },
    frb_generated::StreamSink,
};
use anyhow::{anyhow, ensure};
use ql_api::PeerPermissionsParams;
use ql_codec::{Decode, Encode};
use ql_common::StreamInfo;
use ql_common::QID;
use ql_fsm::PairingInvite;
use ql_keyos::PeerPermissions;
use ql_rpc::Router;
use ql_runtime::{QlStream, RuntimeConfig, RuntimeHandle};
use ql_wire::{PairingToken, PeerBundle, QlIdentity};
use sha2::{Digest, Sha256};
use tokio::sync::{mpsc, oneshot, Notify};

const MAX_BENCHMARK_BYTES: u32 = 16 * 1024 * 1024;
const MAX_BENCHMARK_WINDOW: u32 = 1024 * 1024;

pub struct PassportEchoResult {
    pub message: String,
    pub milliseconds: f64,
}

pub struct PassportBenchmarkResult {
    pub bytes: u32,
    pub seconds: f64,
    pub mib_per_second: f64,
}

#[derive(Clone, Copy)]
struct TokioSendSpawner;

impl ql_rpc::Spawner for TokioSendSpawner {
    type Handle = tokio::task::JoinHandle<()>;
}

impl ql_rpc::SendSpawner for TokioSendSpawner {
    fn spawn<F>(&self, future: F) -> Self::Handle
    where
        F: Future<Output = ()> + Send + 'static,
    {
        tokio::spawn(future)
    }
}

// Re-export platform types so frb_generated.rs paths stay stable
pub use crate::api::platform::{ConnectionStatus, OutBoundWrite, PeerStatusEvent};

// ─── Bootstrap ────────────────────────────────────────────────────────────────

#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello from QL v2, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    setup_default_user_utils();
}

/// Setup defaults that is usually useful for a new project.
/// Surely, you are free to customize everything.
pub fn setup_default_user_utils() {
    // setup log before others, such that we can see logs in other setup functions
    setup_log_to_console();
    setup_backtrace();
}

fn setup_backtrace() {
    #[cfg(not(target_family = "wasm"))]
    if std::env::var("RUST_BACKTRACE").err() == Some(std::env::VarError::NotPresent) {
        std::env::set_var("RUST_BACKTRACE", "1");
    } else {
        log::debug!("Skip setup RUST_BACKTRACE because there is already environment variable");
    }
    flutter_rust_bridge::PanicBacktrace::setup();
}

// ─── QLSession ────────────────────────────────────────────────────────────────

/// Holds all state needed to run the QL v2 protocol session.
pub struct QLSession {
    pub(crate) handle: RuntimeHandle,
    _runtime_lifetime: oneshot::Sender<()>,
    xid: [u8; 16],
    own_identity: Vec<u8>,
    own_bundle: Vec<u8>,
    channels: Arc<Channels>,
    dechunker: Mutex<BtpDechunker>,
    peer_status_rx: Mutex<Option<mpsc::Receiver<PeerStatusEvent>>>,
    inbound_rx: Mutex<Option<mpsc::Receiver<(StreamInfo, QlStream)>>>,
    write_rx: Mutex<Option<mpsc::Receiver<OutBoundWrite>>>,
    inbound_byte_writer: mpsc::Sender<Vec<u8>>,
    router_attach: Arc<Notify>,
    router_peer: Mutex<Option<Arc<Peer>>>,
    #[cfg(test)]
    runtime_stopped: Mutex<Option<std::sync::mpsc::Receiver<()>>>,
}

impl Default for QLSession {
    fn default() -> Self {
        Self::new()
    }
}

impl QLSession {
    pub async fn request_passport_echo(
        &self,
        message: String,
    ) -> anyhow::Result<PassportEchoResult> {
        ensure!(
            !message.is_empty() && message.len() <= 64 * 1024,
            "Enter an echo payload of 1-65536 bytes"
        );
        let started = Instant::now();
        let response = tokio::time::timeout(
            Duration::from_secs(15),
            self.handle.rpc().request::<ql_api::RequestPassportEcho>(
                &ql_api::EchoParams { message },
                Default::default(),
            ),
        )
        .await
        .map_err(|_| anyhow!("Passport echo timed out"))??;
        Ok(PassportEchoResult {
            message: response.message,
            milliseconds: started.elapsed().as_secs_f64() * 1000.0,
        })
    }

    pub async fn download_passport_benchmark(
        &self,
        bytes: u32,
        receive_window: u32,
    ) -> anyhow::Result<PassportBenchmarkResult> {
        validate_benchmark(bytes, receive_window)?;
        tokio::time::timeout(
            Duration::from_secs(120),
            run_passport_benchmark(&self.handle, bytes, receive_window),
        )
        .await
        .map_err(|_| anyhow!("Passport benchmark timed out"))?
    }

    pub async fn provision_router(&self) -> anyhow::Result<()> {
        let response = self
            .handle
            .rpc()
            .request::<ql_api::RequestInstallPeerBundles>(
                &ql_api::InstallPeerBundlesParams {
                    router: BUNDLE_BYTES.to_vec(),
                    peers: Vec::new(),
                },
                Default::default(),
            )
            .await?;
        anyhow::ensure!(
            response == ql_api::InstallPeerBundlesResponse::Installed,
            "Passport rejected the router bundle"
        );
        Ok(())
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn set_router_enabled(&self, enabled: bool) -> anyhow::Result<()> {
        let peer = if enabled {
            let bundle = self
                .channels
                .peer_bundle
                .lock()
                .unwrap()
                .clone()
                .ok_or_else(|| anyhow!("Passport is not paired"))?;
            Some(ROUTER.register(
                bundle,
                self.channels.write_tx.downgrade(),
                self.router_attach.clone(),
            ))
        } else {
            None
        };
        *self.router_peer.lock().unwrap() = peer;
        Ok(())
    }

    pub fn new() -> Self {
        Self::initialize(None)
    }

    pub fn new_from_identity(identity_bytes: Vec<u8>) -> anyhow::Result<Self> {
        let identity = QlIdentity::decode_bytes(identity_bytes.as_slice())
            .map_err(|e| anyhow!("invalid QL identity: {e:?}"))?;
        Ok(Self::initialize(Some(identity)))
    }

    pub async fn request_permissions(&self) -> anyhow::Result<ql_api::PeerPermissionsResponse> {
        use ql_api::app_id as app;

        let peermetadata = PeerPermissions {
            app_ids: vec![
                app::SYSTEM,
                app::ONBOARDING,
                app::BACKUP,
                app::UPDATE,
                app::BITCOIN,
                app::DEBUG,
            ],
        };
        self.request_peer_permissions(PeerPermissionsParams(peermetadata))
            .await
    }

    fn initialize(identity: Option<QlIdentity>) -> Self {
        log::info!("creating new instance");

        let (peer_status_tx, peer_status_rx) = mpsc::channel(64);
        let (inbound_tx, inbound_rx) = mpsc::channel(64);
        let (write_tx, write_rx) = mpsc::channel::<OutBoundWrite>(2);
        let (inbound_byte_tx, inbound_byte_rx) = mpsc::channel::<Vec<u8>>(2);
        let router_attach = Arc::new(Notify::new());
        let (runtime_lifetime, runtime_shutdown) = oneshot::channel();
        #[cfg(test)]
        let (runtime_stopped_tx, runtime_stopped_rx) = std::sync::mpsc::channel();

        let channels = Arc::new(Channels {
            peer_bundle: Mutex::new(None),
            peer_status_tx,
            inbound_tx,
            write_tx,
        });

        let platform = LinkPlatform {
            channels: channels.clone(),
            inbound_channel: Some(inbound_byte_rx),
        };
        let identity = identity.unwrap_or_else(|| ql_wire::generate_identity(&platform, "Envoy"));
        let xid_arr = identity.qid.0;
        let own_identity = identity.encode_vec();
        let own_bundle = identity.bundle().encode_vec();

        let (runtime, handle) = ql_runtime::new_runtime(
            identity,
            platform,
            RuntimeConfig {
                fsm: ql_fsm::QlFsmConfig {
                    handshake_timeout: Duration::from_secs(60),
                    ..Default::default()
                },
                max_concurrent_message_writes: 2,
            },
        );
        log::info!("spawning runtime");

        let attach_handle = handle.clone();
        let attach_notify = router_attach.clone();
        std::thread::spawn(move || {
            log::info!("starting.. spawning runtime");
            tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .unwrap()
                .block_on(async move {
                    let attach = async move {
                        loop {
                            attach_notify.notified().await;
                            let response = attach_handle
                                .rpc()
                                .request::<ql_api::RequestAttachRouter>(
                                    &ql_api::Empty {},
                                    Default::default(),
                                )
                                .await;
                            if !matches!(response, Ok(ql_api::AttachRouterResponse::Started)) {
                                log::warn!("Passport rejected router attachment");
                            }
                        }
                    };
                    let attach_task = tokio::spawn(async move {
                        tokio::select! {
                            _ = attach => {}
                            _ = runtime_shutdown => {}
                        }
                    });
                    runtime.run().await;
                    attach_task.abort();
                });
            log::info!("Runtime has completed");
            #[cfg(test)]
            let _ = runtime_stopped_tx.send(());
        });

        Self {
            handle,
            _runtime_lifetime: runtime_lifetime,
            xid: xid_arr,
            own_identity,
            own_bundle,
            channels,
            dechunker: Mutex::new(get_decoder()),
            peer_status_rx: Mutex::new(Some(peer_status_rx)),
            inbound_rx: Mutex::new(Some(inbound_rx)),
            write_rx: Mutex::new(Some(write_rx)),
            inbound_byte_writer: inbound_byte_tx,
            router_attach,
            router_peer: Mutex::new(None),
            #[cfg(test)]
            runtime_stopped: Mutex::new(Some(runtime_stopped_rx)),
        }
    }

    /// Generates a random 16-byte XID.
    #[flutter_rust_bridge::frb(sync)]
    pub fn generate_xid() -> Vec<u8> {
        let mut xid = [0u8; 16];
        rand::fill(&mut xid);
        xid.to_vec()
    }

    /// Returns own PeerBundle as wire bytes. Share this with the remote peer so they
    /// can call `bind_peer()` with it before initiating the handshake.
    pub fn own_bundle(&self) -> Vec<u8> {
        self.own_bundle.clone()
    }

    /// Returns the full local QL identity as wire bytes. Persist this to restore the
    /// same QL v2 peer identity across app restarts.
    pub fn own_identity(&self) -> Vec<u8> {
        self.own_identity.clone()
    }

    pub async fn set_up_router(&self, sink: StreamSink<InboundRpc>) {
        let mut inbound = self
            .inbound_rx
            .lock()
            .unwrap()
            .take()
            .expect("Router called once");
        let state = RouterState {
            inner: Arc::new(sink),
        };
        let router =
            Router::<ql_api::ServiceRouteKey, _, ql_runtime::QlStream, TokioSendSpawner>::builder_send(
                TokioSendSpawner,
            )
            .request::<ql_api::RequestEcho>()
            .request::<ql_api::RequestListApps>()
            .download::<ql_api::DownloadApp>()
            .request::<ql_api::RequestTimezone>()
            .request::<ql_api::RequestCurrentTime>()
            .duplex::<ql_api::RunSecurityCheck>()
            .request::<ql_api::RequestCheckFirmwareUpdate>()
            .download::<ql_api::DownloadFirmware>()
            .subscription::<ql_api::SubscribeExchangeRate>()
            .request::<ql_api::RequestExchangeRateHistory>()
            .request::<ql_api::RequestBroadcastTransaction>()
            .request::<ql_api::RequestBackupShard>()
            .request::<ql_api::RequestRestoreShard>()
            .request::<ql_api::RequestPassportMagicBackupStatus>()
            .upload::<ql_api::UploadMagicBackup>()
            .download::<ql_api::DownloadMagicBackup>()
            .download::<ql_api::DownloadBenchmark>()
            .build(state);

        tokio::spawn(async move {
            while let Some((info, stream)) = inbound.recv().await {
                if let Some(_future) = router.handle(info, stream) {
                    // log::info!("received incoming request on route ${route:?}");
                }
            }
        });
    }

    //TODO: timeouts
    pub async fn arm_pairing(&self) -> Vec<u8> {
        let mut token = PairingToken([0; 16]);
        rand::fill(&mut token.0);
        self.handle.arm_pairing(token);
        PairingInvite {
            version: PairingInvite::VERSION,
            qid: QID(self.xid),
            token,
        }
        .encode_vec()
    }

    /// Registers the remote peer's PeerBundle with the FSM.
    /// Must be called before `connect()`.
    pub fn bind_peer(&self, peer_bundle_bytes: Vec<u8>) -> anyhow::Result<()> {
        let bundle = PeerBundle::decode_bytes(peer_bundle_bytes.as_slice())
            .map_err(|error| anyhow!("invalid peer bundle: {error:?}"))?;
        self.handle.bind_peer(bundle);
        Ok(())
    }

    /// Sends a connect command to the runtime.
    pub fn connect(&self) {
        self.handle.connect();
    }

    /// Sends a pairing command to the runtime with a serialized pairing invite.
    pub fn pair(&self, invite: Vec<u8>) -> anyhow::Result<()> {
        let invite = PairingInvite::decode_bytes(invite.as_slice())
            .map_err(|error| anyhow!("invalid QL v2 pairing invite: {error:?}"))?;
        anyhow::ensure!(
            invite.version == PairingInvite::VERSION,
            "unsupported QL v2 pairing invite version: {}",
            invite.version
        );
        self.handle.start_pairing(invite);
        Ok(())
    }

    /// Delivers one incoming BTP chunk (a single BLE notification) into the runtime.
    /// Reassembles frames via the session's BtpDechunker; only forwards to the runtime
    /// when a complete message has been received.
    pub async fn send_incoming(&self, chunk: Vec<u8>) -> anyhow::Result<()> {
        use crate::api::btp::decode;
        let result = {
            let mut dechunker = self.dechunker.lock().unwrap();
            decode(chunk, &mut dechunker)
        };
        match result {
            Ok(status) => {
                if let Some(payload) = status.payload {
                    let header = ql_wire::RecordHeader::decode_bytes(payload.as_slice())?;
                    if header.route.recipient == QID(self.xid) {
                        self.inbound_byte_writer
                            .send(payload)
                            .await
                            .map_err(|_| anyhow!("Send_incoming: Channel closed"))?;
                    } else if let Some(peer) = self.router_peer.lock().unwrap().as_ref() {
                        ROUTER.send(peer, payload)?;
                    }
                }
            }
            Err(e) => {
                log::warn!("BTP decode error: {e}");
            }
        }
        Ok(())
    }

    pub async fn send_incoming_ws(&self, payload: Vec<u8>) -> anyhow::Result<()> {
        self.inbound_byte_writer
            .send(payload)
            .await
            .map_err(|_| anyhow!("Send_incoming: Channel closed"))
    }
    /// Returns the 16-byte XID for this device.
    pub fn xid(&self) -> Vec<u8> {
        self.xid.to_vec()
    }

    /// Returns the persisted peer bundle as raw wire bytes, if one exists.
    pub fn get_persisted_peer(&self) -> Option<Vec<u8>> {
        let guard = self.channels.peer_bundle.lock().unwrap();
        guard.as_ref().map(|p| p.encode_vec())
    }

    /// Pre-loads a peer bundle from raw wire bytes (e.g. restored from device storage).
    pub fn set_persisted_peer(&self, bytes: Vec<u8>) -> anyhow::Result<()> {
        let peer = PeerBundle::decode_bytes(bytes.as_slice())
            .map_err(|error| anyhow!("invalid persisted peer bundle: {error:?}"))?;
        *self.channels.peer_bundle.lock().unwrap() = Some(peer);
        Ok(())
    }

    /// Stream of peer-status change events. Call once and `.listen()` in Dart.
    pub async fn stream_peer_status(&self, sink: StreamSink<PeerStatusEvent>) {
        let mut rx = self
            .peer_status_rx
            .lock()
            .unwrap()
            .take()
            .expect("stream_peer_status already consumed");
        tokio::spawn(async move {
            while let Some(event) = rx.recv().await {
                if sink.add(event).is_err() {
                    break;
                }
            }
        });
    }

    /// Stream of outgoing BLE messages enqueued by the runtime. Call once and `.listen()` in Dart.
    pub async fn stream_outgoing_messages(&self, sink: StreamSink<OutBoundWrite>) {
        let mut rx = self
            .write_rx
            .lock()
            .unwrap()
            .take()
            .expect("stream_outgoing_messages already consumed");
        tokio::spawn(async move {
            while let Some(write_reuqest) = rx.recv().await {
                if sink.add(write_reuqest).is_err() {
                    break;
                }
            }
        });
    }
}

fn validate_benchmark(bytes: u32, receive_window: u32) -> anyhow::Result<()> {
    ensure!(
        (1..=MAX_BENCHMARK_BYTES).contains(&bytes),
        "Choose 1-16384 KiB of benchmark data"
    );
    ensure!(
        (1024..=MAX_BENCHMARK_WINDOW).contains(&receive_window),
        "Choose a receive window of 1-1024 KiB"
    );
    Ok(())
}

async fn run_passport_benchmark(
    handle: &RuntimeHandle,
    bytes: u32,
    receive_window: u32,
) -> anyhow::Result<PassportBenchmarkResult> {
    let call = handle
        .rpc()
        .download::<ql_api::DownloadPassportBenchmark>(
            &ql_api::DownloadBenchmarkParams {
                length: bytes.into(),
            },
            ql_runtime::StreamOptions {
                receive_window: Some(receive_window),
                ..Default::default()
            },
        )
        .await?;
    let (header, mut parts) = call.start().await?;
    let started = Instant::now();
    let mut received = 0usize;
    let mut hash = Sha256::new();
    while let Some((_, mut part)) = parts.next_part().await? {
        loop {
            let chunk = part.read_chunk().await?;
            if chunk.is_empty() {
                break;
            }
            received += chunk.len();
            ensure!(received <= bytes as usize, "Benchmark returned excess data");
            hash.update(&chunk);
        }
    }
    ensure!(received == bytes as usize, "Benchmark length mismatch");
    ensure!(
        hash.finalize().as_slice() == header.hash.as_slice(),
        "Benchmark hash mismatch"
    );
    let seconds = started.elapsed().as_secs_f64().max(f64::EPSILON);
    Ok(PassportBenchmarkResult {
        bytes,
        seconds,
        mib_per_second: f64::from(bytes) / (1024.0 * 1024.0) / seconds,
    })
}

rpc_request!(
    RequestPeerPermissions,
    direction = outbound,
    route = RequestPeerPermissions,
    params = ql_api::PeerPermissionsParams,
    response = ql_api::PeerPermissionsResponse
);

#[cfg(test)]
mod tests {
    use super::{validate_benchmark, PairingInvite, QLSession};
    use ql_codec::{Decode, Encode};
    use ql_wire::QlIdentity;
    use std::time::Duration;

    #[test]
    fn dropping_session_stops_runtime_thread() {
        let session = QLSession::new();
        let runtime_stopped = session.runtime_stopped.lock().unwrap().take().unwrap();

        drop(session);

        runtime_stopped
            .recv_timeout(Duration::from_secs(2))
            .expect("QL runtime thread did not stop");
    }

    #[tokio::test]
    async fn only_local_records_reach_the_local_runtime() {
        use ql_common::QID;
        use ql_wire::{RecordHeader, RecordType, RouteHeader};

        let mut session = QLSession::new();
        let (incoming, mut records) = tokio::sync::mpsc::channel(2);
        session.inbound_byte_writer = incoming;
        for recipient in [QID(session.xid), QID([9; 16])] {
            let mut record = RecordHeader::new(
                RouteHeader {
                    sender: QID([1; 16]),
                    recipient,
                },
                RecordType::Session,
            )
            .encode_vec();
            record.extend_from_slice(&[7; 1024]);
            for chunk in crate::api::btp::encode(&record) {
                session.send_incoming(chunk).await.unwrap();
            }
            if recipient == QID(session.xid) {
                assert_eq!(records.try_recv().unwrap(), record);
            } else {
                assert!(records.try_recv().is_err());
            }
        }
    }

    #[test]
    fn fresh_identity_can_be_restored() {
        let fresh_session = QLSession::new();
        let identity = fresh_session.own_identity();
        let bundle = fresh_session.own_bundle();

        assert!(!identity.is_empty());
        assert!(!bundle.is_empty());
        assert_eq!(
            QlIdentity::decode_bytes(identity.as_slice()).unwrap().name,
            "Envoy"
        );

        let restored_session = QLSession::new_from_identity(identity.clone()).unwrap();

        assert_eq!(restored_session.own_identity(), identity);
        assert_eq!(restored_session.own_bundle(), bundle);
    }

    #[test]
    fn pairing_invite_uses_current_wire_version() {
        let session = QLSession::new();
        let invite_bytes = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap()
            .block_on(session.arm_pairing());
        let invite = PairingInvite::decode_bytes(invite_bytes.as_slice()).unwrap();

        assert_eq!(invite.version, PairingInvite::VERSION);
    }

    #[test]
    fn malformed_pairing_invite_is_rejected() {
        let session = QLSession::new();

        assert!(session.pair(Vec::new()).is_err());
    }

    #[test]
    fn unsupported_pairing_invite_version_is_rejected() {
        let session = QLSession::new();
        let invite_bytes = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap()
            .block_on(session.arm_pairing());
        let mut invite = PairingInvite::decode_bytes(invite_bytes.as_slice()).unwrap();
        invite.version = PairingInvite::VERSION.saturating_add(1);

        assert!(session.pair(invite.encode_vec()).is_err());
    }

    #[test]
    fn benchmark_limits_are_validated() {
        assert!(validate_benchmark(1024, 1024).is_ok());
        assert!(validate_benchmark(0, 1024).is_err());
        assert!(validate_benchmark(16 * 1024 * 1024 + 1, 1024).is_err());
        assert!(validate_benchmark(1024, 1023).is_err());
        assert!(validate_benchmark(1024, 1024 * 1024 + 1).is_err());
    }
}
