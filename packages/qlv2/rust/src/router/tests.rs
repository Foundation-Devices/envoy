// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use super::*;
use ql_codec::Encode;
use ql_router::protocol::{self, AttachChallenge, AttachRecord, PacketKind};
use ql_wire::{
    generate_identity, HandshakeId, IkHandshake, QlHandshakeRecord, RecordType, RouteHeader,
    SessionKey, TransportParams,
};
use tokio::{io::AsyncWriteExt, net::TcpListener, task::JoinSet};

#[tokio::test]
async fn shares_one_connection_and_reattaches_after_tcp_loss() {
    timeout(Duration::from_secs(15), async {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap().to_string();
        let router_identity = generate_identity(&SoftwareCrypto, "router");
        let router_bundle = router_identity.bundle();
        let alice = generate_identity(&SoftwareCrypto, "alice");
        let bob = generate_identity(&SoftwareCrypto, "bob");
        let (router, records) = QlRouter::new(Handle::current());
        let mut tasks = JoinSet::new();
        let (writes_a, reads_a) = mpsc::channel(2);
        let (writes_b, reads_b) = mpsc::channel(2);
        let mut peers = Vec::new();
        let mut attach_signals = Vec::new();
        let (events, mut received) = mpsc::channel(8);
        for (identity, mut reads, writes) in
            [(alice, reads_a, &writes_a), (bob, reads_b, &writes_b)]
        {
            let attach = Arc::new(Notify::new());
            let old = router.register(identity.bundle(), writes.downgrade(), attach.clone());
            let peer = router.register(identity.bundle(), writes.downgrade(), attach.clone());
            // dropping an old registration must not remove its replacement
            drop(old);
            let weak = Arc::downgrade(&peer);
            peers.push(peer);
            attach_signals.push(attach.clone());
            let router = router.clone();
            let router_bundle = router_bundle.clone();
            let events = events.clone();
            tasks.spawn(async move {
                let mut handshake = None;
                let mut handshake_id = 0;
                loop {
                    tokio::select! {
                        _ = attach.notified() => {
                            handshake_id += 1;
                            let route = RouteHeader { sender: identity.qid, recipient: router_bundle.qid };
                            let mut pending = IkHandshake::new_ik_initiator(
                                &SoftwareCrypto,
                                identity.clone(),
                                router_bundle.clone(),
                                TransportParams::default(),
                            );
                            let request = pending.write_1(&SoftwareCrypto, HandshakeId(handshake_id)).unwrap();
                            let request = ql_wire::encode_record_vec(
                                RecordHeader::new(route, RecordType::Handshake),
                                &AttachRecord::Initiate(request),
                            );
                            router.send(&weak.upgrade().unwrap(), request).unwrap();
                            handshake = Some(pending);
                        }
                        Some(mut write) = reads.recv() => {
                            write.notify_status(true);
                            let record = write.payload;
                            let header = RecordHeader::decode_bytes(record.as_slice()).unwrap();
                            assert_eq!(header.route.recipient, identity.qid);
                            if header.route.sender == router_bundle.qid {
                                let (_, AttachRecord::Challenge(AttachChallenge {
                                    handshake: response,
                                    cookie,
                                })) = protocol::decode_attach(&record).unwrap()
                                else { panic!("expected attachment response") };
                                let mut pending = handshake.take().unwrap();
                                pending.read_2(&SoftwareCrypto, header.route, &response).unwrap();
                                let finalized = pending.finalize(&SoftwareCrypto).unwrap();
                                let confirmation = protocol::confirm_cookie(
                                    &SoftwareCrypto,
                                    &finalized.tx_key,
                                    cookie,
                                );
                                let confirmation = ql_wire::encode_record_vec(
                                    RecordHeader::new(
                                        RouteHeader {
                                            sender: identity.qid,
                                            recipient: router_bundle.qid,
                                        },
                                        RecordType::Handshake,
                                    ),
                                    &AttachRecord::Confirm(confirmation),
                                );
                                router.send(&weak.upgrade().unwrap(), confirmation).unwrap();
                                events.send((identity.qid, None)).await.unwrap();
                            } else {
                                events.send((identity.qid, Some(record))).await.unwrap();
                            }
                        }
                        else => break,
                    }
                }
            });
        }
        let commands = router.commands.clone();
        let server = tokio::spawn(async move {
            let cookie_key = SessionKey([7; SessionKey::SIZE]);
            for round in 0..2 {
                let (mut tcp, _) = listener.accept().await.unwrap();
                let request = protocol::read_frame(&mut tcp).await.unwrap().unwrap();
                let (header, request) =
                    ql_wire::decode_record::<QlHandshakeRecord, _>(request.payload()).unwrap();
                let QlHandshakeRecord::Ik1(request) = request else {
                    panic!("expected transport handshake")
                };
                let mut handshake = IkHandshake::new_ik_responder(
                    &SoftwareCrypto,
                    &router_identity,
                    None,
                    TransportParams::default(),
                );
                handshake
                    .read_1(&SoftwareCrypto, header.route, &request)
                    .unwrap();
                let response = handshake
                    .write_2(&SoftwareCrypto, request.handshake_id)
                    .unwrap();
                let session = handshake.finalize(&SoftwareCrypto).unwrap();
                protocol::write_frame(
                    &mut tcp,
                    &protocol::TransportResponse {
                        header: RecordHeader::new(
                            RouteHeader {
                                sender: router_identity.qid,
                                recipient: header.route.sender,
                            },
                            RecordType::Handshake,
                        ),
                        handshake: QlHandshakeRecord::Ik2(response),
                    }
                    .encode_vec(),
                )
                .await
                .unwrap();
                let confirm = protocol::read_frame(&mut tcp).await.unwrap().unwrap();
                assert_eq!(
                    protocol::open_packet(&SoftwareCrypto, &session.rx_key, 0, confirm.as_bytes())
                        .unwrap()
                        .kind,
                    PacketKind::Confirm
                );
                let mut rx_counter = 1;
                let mut tx_counter = 0;
                let mut attached = 0;
                while attached < 2 {
                    let frame = protocol::read_frame(&mut tcp).await.unwrap().unwrap();
                    let attach = protocol::open_packet(
                        &SoftwareCrypto,
                        &session.rx_key,
                        rx_counter,
                        frame.as_bytes(),
                    )
                    .unwrap();
                    rx_counter += 1;
                    assert_eq!(attach.kind, PacketKind::Attach);
                    let (header, attach) = protocol::decode_attach(attach.payload).unwrap();
                    match attach {
                        AttachRecord::Initiate(request) => {
                            let mut pending = IkHandshake::new_ik_responder(
                                &SoftwareCrypto,
                                &router_identity,
                                None,
                                TransportParams::default(),
                            );
                            pending.read_1(&SoftwareCrypto, header.route, &request).unwrap();
                            let response = pending
                                .write_2(&SoftwareCrypto, request.handshake_id)
                                .unwrap();
                            let finalized = pending.finalize(&SoftwareCrypto).unwrap();
                            let cookie = protocol::seal_cookie(
                                &SoftwareCrypto,
                                &cookie_key,
                                finalized.remote_bundle.qid,
                                finalized.rx_key,
                                round,
                                1,
                            );
                            let response = ql_wire::encode_record_vec(
                                RecordHeader::new(
                                    RouteHeader {
                                        sender: router_identity.qid,
                                        recipient: header.route.sender,
                                    },
                                    RecordType::Handshake,
                                ),
                                &AttachRecord::Challenge(AttachChallenge {
                                    handshake: response,
                                    cookie,
                                }),
                            );
                            let packet = protocol::seal_packet(
                                &SoftwareCrypto,
                                &session.tx_key,
                                PacketKind::Attach,
                                tx_counter,
                                &response,
                            )
                            .unwrap();
                            tx_counter += 1;
                            protocol::write_packet(&mut tcp, &packet).await.unwrap();
                        }
                        AttachRecord::Confirm(confirmation) => {
                            let qid = protocol::open_confirmation(
                                &SoftwareCrypto,
                                &cookie_key,
                                round,
                                0,
                                &confirmation,
                            )
                            .unwrap();
                            assert_eq!(header.route.sender, qid);
                            attached += 1;
                        }
                        AttachRecord::Challenge(_) => panic!("unexpected attachment challenge"),
                    }
                }
                for _ in 0..2 {
                    let frame = protocol::read_frame(&mut tcp).await.unwrap().unwrap();
                    let record = protocol::open_packet(
                        &SoftwareCrypto,
                        &session.rx_key,
                        rx_counter,
                        frame.as_bytes(),
                    )
                    .unwrap();
                    rx_counter += 1;
                    assert_eq!(record.kind, PacketKind::Record);
                    let packet = protocol::seal_packet(
                        &SoftwareCrypto,
                        &session.tx_key,
                        PacketKind::Record,
                        tx_counter,
                        record.payload,
                    )
                    .unwrap();
                    tx_counter += 1;
                    tcp.write_all(&packet[..3]).await.unwrap();
                    commands
                        .send(Command::Remove(router_identity.qid, u64::MAX))
                        .await
                        .unwrap();
                    tokio::task::yield_now().await;
                    tcp.write_all(&packet[3..]).await.unwrap();
                }
                if round == 1 {
                    assert!(protocol::read_frame(&mut tcp).await.unwrap().is_none());
                }
            }
        });
        let task = router.clone();
        tasks.spawn(async move { task.run(&address, router_bundle, records).await });
        for _ in 0..2 {
            let first = received.recv().await.unwrap();
            let second = received.recv().await.unwrap();
            assert!(first.1.is_none() && second.1.is_none());
            assert_ne!(first.0, second.0);
            for (sender, recipient) in [(&peers[0], &peers[1]), (&peers[1], &peers[0])] {
                let mut record = RecordHeader::new(
                    RouteHeader {
                        sender: sender.bundle.qid,
                        recipient: recipient.bundle.qid,
                    },
                    RecordType::Session,
                )
                .encode_vec();
                record.extend_from_slice(&[42; 1024]);
                assert!(router.send(recipient, record.clone()).is_err());
                let mut oversized = record.clone();
                oversized.resize(ql_router::MAX_RECORD_SIZE + 1, 0);
                assert!(router.send(sender, oversized).is_err());
                router.send(sender, record.clone()).unwrap();
                assert_eq!(
                    received.recv().await.unwrap(),
                    (recipient.bundle.qid, Some(record))
                );
            }
        }
        peers.clear();
        server.await.unwrap();
        assert_eq!(writes_a.strong_count(), 1);
        assert_eq!(writes_b.strong_count(), 1);
        tasks.shutdown().await;
    })
    .await
    .unwrap();
}

#[test]
fn embedded_router_bundle_is_valid() {
    PeerBundle::decode_bytes(BUNDLE_BYTES)
        .unwrap()
        .validate(&SoftwareCrypto)
        .unwrap();
}

#[tokio::test]
async fn drop_waits_for_queue_space_outside_runtime() {
    let (router, mut commands) = QlRouter::new(Handle::current());
    let (write, _reads) = mpsc::channel(1);
    let attach = Arc::new(Notify::new());
    let peer = router.register(
        generate_identity(&SoftwareCrypto, "device").bundle(),
        write.downgrade(),
        attach,
    );
    assert!(matches!(commands.recv().await, Some(Command::Register(_))));
    let qid = peer.bundle.qid;
    let id = peer.id;
    for _ in 0..16 {
        assert!(router
            .commands
            .try_send(Command::Remove(qid, u64::MAX))
            .is_ok());
    }
    assert!(router
        .commands
        .try_send(Command::Remove(qid, u64::MAX))
        .is_err());
    std::thread::spawn(move || drop(peer)).join().unwrap();
    for _ in 0..16 {
        commands.recv().await.unwrap();
    }
    assert!(matches!(
        timeout(Duration::from_secs(1), commands.recv()).await.unwrap(),
        Some(Command::Remove(removed_qid, removed_id)) if removed_qid == qid && removed_id == id
    ));
}
