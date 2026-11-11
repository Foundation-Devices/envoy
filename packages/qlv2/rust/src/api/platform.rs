// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::{
    future::Future,
    pin::Pin,
    sync::{Arc, Mutex},
    task::{Context, Poll},
    time::Duration,
};

use flutter_rust_bridge::frb;
use libcrux_aesgcm::AesGcm256Key;
use libcrux_ml_kem::mlkem1024;
use ql_api::PeerPermissionsResponse;
use ql_common::{StreamInfo, QID};
use ql_fsm::PeerStatus;
use ql_runtime::{QlInbound, QlPlatform, QlStream, QlTimer};
use ql_wire::{
    MlKemCiphertext, MlKemKeyPair, MlKemPrivateKey, MlKemPublicKey, Nonce, PeerBundle, QlAead,
    QlHash, QlKem, QlRandom, SessionKey,
};
use sha2::{Digest, Sha256};
use tokio::sync::mpsc;
use tokio::sync::oneshot;

// ─── Public types exposed to Flutter ──────────────────────────────────────────

/// Mirror of `PeerStatus`
pub enum ConnectionStatus {
    Disconnected,
    Unpair,
    Initiator,
    Connected,
}

/// A peer-status change event delivered to Flutter.
pub struct PeerStatusEvent {
    /// 16-byte XID of the peer.
    pub xid: Option<Vec<u8>>,
    pub status: ConnectionStatus,
    /// Permission negotiation result for the current connected session.
    pub permission_status: Option<PeerPermissionsResponse>,
}

#[frb(opaque)]
pub struct OutBoundWrite {
    pub payload: Vec<u8>,
    #[frb(ignore)]
    pub notify: Option<oneshot::Sender<bool>>,
}

impl OutBoundWrite {
    pub fn notify_status(&mut self, status: bool) {
        if !status {
            log::warn!(
                "QL platform outbound write notify_status failed: bytes={}",
                self.payload.len()
            );
        }
        if let Some(tx) = self.notify.take() {
            let _ = tx.send(status);
        }
    }

    pub fn chunks(&self) -> Vec<Vec<u8>> {
        super::btp::encode(&self.payload)
    }
}

// ─── Internal channel glue ────────────────────────────────────────────────────

pub(crate) struct Channels {
    pub(crate) peer_bundle: Mutex<Option<PeerBundle>>,
    pub(crate) peer_status_tx: tokio::sync::mpsc::Sender<PeerStatusEvent>,
    pub(crate) inbound_tx: tokio::sync::mpsc::Sender<(StreamInfo, QlStream)>,
    pub(crate) write_tx: tokio::sync::mpsc::Sender<OutBoundWrite>,
}

// ─── LinkPlatform ─────────────────────────────────────────────────────────────

pub(crate) struct LinkPlatform {
    pub(crate) channels: Arc<Channels>,
    pub(crate) inbound_channel: Option<mpsc::Receiver<Vec<u8>>>,
}

impl LinkPlatform {
    fn random_array<const L: usize>(&self) -> [u8; L] {
        let mut out = [0u8; L];
        self.fill_random_bytes(&mut out);
        out
    }
}

impl QlPlatform for LinkPlatform {
    type Crypto = Self;
    type Timer = TokioTimer;
    type WriteMessageFut<'a> = Pin<Box<dyn Future<Output = bool> + Send + 'a>>;

    fn crypto(&self) -> &Self::Crypto {
        self
    }

    fn write_message(&self, message: Vec<u8>) -> Self::WriteMessageFut<'_> {
        let message_len = message.len();
        let (tx, rx) = oneshot::channel();
        let send = self.channels.write_tx.send(OutBoundWrite {
            payload: message,
            notify: Some(tx),
        });
        Box::pin(async move {
            let _ = send.await;
            match rx.await {
                Ok(status) => {
                    if !status {
                        log::warn!(
                            "QL platform write_message failed status received: bytes={message_len}"
                        );
                    }
                    status
                }
                Err(_) => {
                    // log::warn!(
                    //     "QL platform write_message status dropped before ack: bytes={message_len}"
                    // );
                    false
                }
            }
        })
    }

    fn timer(&self) -> Self::Timer {
        TokioTimer::new()
    }

    fn persist_peer(&self, peer: PeerBundle) {
        *self.channels.peer_bundle.lock().unwrap() = Some(peer);
    }

    fn handle_peer_status(&self, peer: Option<QID>, status: PeerStatus) {
        let _ = self.channels.peer_status_tx.try_send(PeerStatusEvent {
            xid: peer.map(|peer| peer.0.to_vec()),
            status: match status {
                PeerStatus::Unpaired => ConnectionStatus::Unpair,
                PeerStatus::Disconnected => ConnectionStatus::Disconnected,
                PeerStatus::Initiator => ConnectionStatus::Initiator,
                PeerStatus::Connected => ConnectionStatus::Connected,
            },
            permission_status: None,
        });
    }

    fn handle_inbound(&self, info: StreamInfo, stream: QlStream) {
        if self.channels.inbound_tx.try_send((info, stream)).is_err() {
            log::warn!("QL inbound RPC queue rejected a stream");
        }
    }

    fn handle_recv_error(&self, error: ql_fsm::ReceiveError) {
        log::warn!("QL platform receive error: {error:?}");
    }

    type Inbound = PlatformInbound;

    fn inbound(&mut self) -> Self::Inbound {
        Self::Inbound {
            channel: self.inbound_channel.take().unwrap(),
        }
    }
}

pub struct PlatformInbound {
    channel: tokio::sync::mpsc::Receiver<Vec<u8>>,
}

impl QlInbound for PlatformInbound {
    fn poll_recv(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Vec<u8>> {
        match self.channel.poll_recv(cx) {
            Poll::Ready(Some(data)) => Poll::Ready(data),
            Poll::Ready(None) => Poll::Pending,
            Poll::Pending => Poll::Pending,
        }
    }
}

// ─── TokioTimer ───────────────────────────────────────────────────────────────

pub(crate) struct TokioTimer {
    sleep: Pin<Box<tokio::time::Sleep>>,
}

fn parked_deadline() -> tokio::time::Instant {
    tokio::time::Instant::now() + Duration::from_secs(60 * 60 * 24 * 365 * 100)
}

impl TokioTimer {
    pub(crate) fn new() -> Self {
        Self {
            sleep: Box::pin(tokio::time::sleep_until(parked_deadline())),
        }
    }
}

impl QlTimer for TokioTimer {
    fn set_deadline(mut self: Pin<&mut Self>, deadline: Option<std::time::Instant>) {
        let deadline = deadline.map_or_else(parked_deadline, tokio::time::Instant::from_std);
        self.sleep.as_mut().reset(deadline);
    }

    fn poll_wait(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        self.sleep.as_mut().poll(cx)
    }
}

// ─── Crypto impls ─────────────────────────────────────────────────────────────

impl QlRandom for LinkPlatform {
    fn fill_random_bytes(&self, data: &mut [u8]) {
        rand::fill(data)
    }
}

impl QlHash for LinkPlatform {
    fn sha256(&self, parts: &[&[u8]]) -> [u8; 32] {
        let mut hasher = Sha256::new();
        for part in parts {
            hasher.update(part);
        }
        hasher.finalize().into()
    }
}

impl QlAead for LinkPlatform {
    fn aes256_gcm_encrypt(
        &self,
        key: &SessionKey,
        nonce: &Nonce,
        aad: &[u8],
        buffer: &mut [u8],
    ) -> [u8; ql_wire::ENCRYPTED_MESSAGE_AUTH_SIZE] {
        let key: AesGcm256Key = (*key.as_bytes()).into();
        let plaintext = buffer.to_vec();
        let mut auth = [0u8; ql_wire::ENCRYPTED_MESSAGE_AUTH_SIZE];
        key.encrypt(
            buffer,
            (&mut auth).into(),
            (&nonce.0).into(),
            aad,
            &plaintext,
        )
        .unwrap();
        auth
    }

    fn aes256_gcm_decrypt(
        &self,
        key: &SessionKey,
        nonce: &Nonce,
        aad: &[u8],
        buffer: &mut [u8],
        auth_tag: &[u8; ql_wire::ENCRYPTED_MESSAGE_AUTH_SIZE],
    ) -> bool {
        let key: AesGcm256Key = (*key.as_bytes()).into();
        let ciphertext = buffer.to_vec();
        key.decrypt(buffer, (&nonce.0).into(), aad, &ciphertext, auth_tag.into())
            .is_ok()
    }
}

impl QlKem for LinkPlatform {
    fn mlkem_generate_keypair(&self) -> MlKemKeyPair {
        let key_pair = mlkem1024::generate_key_pair(self.random_array());
        let mut public = [0u8; MlKemPublicKey::SIZE];
        public.copy_from_slice(key_pair.pk());
        let mut private = [0u8; MlKemPrivateKey::SIZE];
        private.copy_from_slice(key_pair.sk());

        MlKemKeyPair {
            private: MlKemPrivateKey::new(Box::new(private)),
            public: MlKemPublicKey::new(Box::new(public)),
        }
    }

    fn mlkem_encapsulate(&self, public_key: &MlKemPublicKey) -> (MlKemCiphertext, SessionKey) {
        let public_key = public_key.as_bytes().into();
        let (ciphertext_value, shared_value) =
            mlkem1024::encapsulate(&public_key, self.random_array());
        let mut ciphertext = [0u8; MlKemCiphertext::SIZE];
        ciphertext.copy_from_slice(ciphertext_value.as_slice());
        let mut shared = [0u8; SessionKey::SIZE];
        shared.copy_from_slice(shared_value.as_slice());
        (
            MlKemCiphertext::new(Box::new(ciphertext)),
            SessionKey(shared),
        )
    }

    fn mlkem_decapsulate(
        &self,
        private_key: &MlKemPrivateKey,
        ciphertext: &MlKemCiphertext,
    ) -> SessionKey {
        let private_key = private_key.as_bytes().into();
        let ciphertext = ciphertext.as_bytes().into();
        let shared = mlkem1024::decapsulate(&private_key, &ciphertext);
        let mut out = [0u8; SessionKey::SIZE];
        out.copy_from_slice(shared.as_slice());
        SessionKey(out)
    }
}
