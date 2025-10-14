// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use anyhow::anyhow;
use anyhow::Context;
use anyhow::Result;
use bc_components::ARID;
use bc_envelope::prelude::CBOREncodable;
use bc_envelope::{Envelope, Expression};
use bc_ur::prelude::{CBORCase, CBOR};
use bc_xid::XIDDocument;
use btp::{chunk, Chunk, MasterDechunker};
use flutter_rust_bridge::frb;
use foundation_api::firmware::{split_update_into_chunks, FirmwareFetchEvent};
use foundation_api::message::{EnvoyMessage, PassportMessage, QuantumLinkMessage};
use foundation_api::quantum_link::{ARIDCache, QuantumLink, QuantumLinkIdentity};
use gstp::SealedEvent;
use log::debug;

#[frb(opaque)]
pub struct EnvoyMasterDechunker {
    inner: MasterDechunker<10>,
}

pub async fn get_decoder() -> EnvoyMasterDechunker {
    EnvoyMasterDechunker {
        inner: MasterDechunker::default(),
    }
}

pub struct DecoderStatus {
    pub progress: f64,
    pub payload: Option<PassportMessage>,
}

#[frb(opaque)]
pub struct EnvoyARIDCache {
    inner: ARIDCache,
}

pub fn get_arid_cache() -> EnvoyARIDCache {
    EnvoyARIDCache{
        inner: ARIDCache::default()
    }
}

pub async fn serialize_xid(quantum_link_identity: &QuantumLinkIdentity) -> Vec<u8> {
    quantum_link_identity
        .clone()
        .xid_document
        .to_unsigned_envelope()
        .to_cbor_data()
}

pub fn serialize_xid_document(xid_document: &XIDDocument) -> Result<Vec<u8>> {
    let envelope = xid_document.to_unsigned_envelope();
    let cbor_data = envelope.to_cbor_data();
    Ok(cbor_data)
}

pub fn deserialize_xid(data: Vec<u8>) -> Result<XIDDocument> {
    match Envelope::try_from_cbor_data(data) {
        Ok(envelope) => {
            let xid_doc = XIDDocument::from_unsigned_envelope(&envelope)?;
            Ok(xid_doc)
        }
        Err(e) => Err(anyhow!("Failed to decode XIDDocument: {:?}", e)),
    }
}

pub async fn serialize_ql_identity(quantum_link_identity: &QuantumLinkIdentity) -> Result<Vec<u8>> {
    let mut map = bc_envelope::prelude::Map::new();
    map.insert(
        CBOR::from("xid_document"),
        quantum_link_identity.clone().xid_document,
    );
    map.insert(
        CBOR::from("private_keys"),
        quantum_link_identity.clone().private_keys.unwrap(),
    );
    Ok(CBOR::from(map).to_cbor_data())
}

pub fn deserialize_ql_identity(data: Vec<u8>) -> Result<QuantumLinkIdentity> {
    let cbor = CBOR::try_from_data(data)
        .ok()
        .ok_or_else(|| anyhow::anyhow!("Invalid CBOR"))?;
    let case = cbor.into_case();

    let CBORCase::Map(map) = case else {
        return Err(anyhow::anyhow!("Invalid CBOR case"));
    };

    Ok(QuantumLinkIdentity {
        xid_document: map
            .get("xid_document")
            .ok_or_else(|| anyhow::anyhow!("xid_document not found"))?,
        private_keys: Some(
            map.get("private_keys")
                .ok_or_else(|| anyhow::anyhow!("private_keys not found"))?,
        ),
    })
}

pub async fn decode(
    data: Vec<u8>,
    decoder: &mut EnvoyMasterDechunker,
    quantum_link_identity: &QuantumLinkIdentity,
    mut arid_cache: EnvoyARIDCache,
) -> Result<DecoderStatus> {
    let chunk = Chunk::decode(&data)?;

    let m = chunk.header.index;
    let n = chunk.header.total_chunks;
    let msg_id = chunk.header.message_id;

    debug!("receiving data id: {msg_id} {m}/{n}");
    //debug!("DECHUNKER: {:?}", decoder.inner);

    match decoder.inner.insert_chunk(chunk) {
        None => {
            let dechunker = decoder.inner.get_dechunker(msg_id).unwrap();
            let progress = dechunker.progress() as f64;

            //debug!("DECHUNKER: {dechunker:?}");
            //debug!("MASTER DECHUNKER: {:?}", decoder.inner);

            Ok(DecoderStatus {
                progress,
                payload: None,
            })
        }
        Some(data) => {
            debug!("Trying to get envelope...");
            let envelope = match Envelope::try_from_cbor_data(data) {
                Ok(env) => env,
                Err(e) => {
                    debug!("Failed to decode CBOR: {:?}", e);
                    return Ok(DecoderStatus {
                        progress: 0.0,
                        payload: None,
                    });
                }
            };
            debug!("Unsealing envelope...");

            let (passport_message, _) = PassportMessage::unseal_passport_message_with_replay_check(
                &envelope,
                &quantum_link_identity.clone().private_keys.unwrap(),
                &mut arid_cache.inner,
            )
            .context("failed to unseal passport message")?;

            Ok(DecoderStatus {
                progress: 1.0,
                payload: Some(passport_message),
            })
        }
    }
}

pub async fn split_fw_update_into_chunks(
    patch_index: u8,
    total_patches: u8,
    patch_bytes: &[u8],
    chunk_size: usize,
) -> Vec<QuantumLinkMessage> {
    split_update_into_chunks(patch_index, total_patches, patch_bytes, chunk_size)
        .map(|chunk| QuantumLinkMessage::FirmwareFetchEvent(FirmwareFetchEvent::Chunk(chunk)))
        .collect()
}

pub async fn encode(
    message: EnvoyMessage,
    sender: &QuantumLinkIdentity,
    recipient: &XIDDocument,
) -> Vec<Vec<u8>> {
    debug!("SENDER: {:?}", sender.xid_document);
    debug!("RECEIVER: {:?}", recipient);

    let expression = QuantumLink::encode(&message);
    let event: SealedEvent<Expression> =
        SealedEvent::new(expression, ARID::new(), sender.clone().xid_document);

    let envelope = event
        .to_envelope(
            None,
            Some(&sender.clone().private_keys.unwrap()),
            Some(recipient),
        )
        .unwrap();

    let cbor = envelope.to_cbor_data();

    let mut chunks = Vec::new();
    for chunk in chunk(&cbor) {
        chunks.push(chunk.to_vec());
    }

    chunks
}

pub async fn generate_ql_identity() -> QuantumLinkIdentity {
    debug!("Generating identity");
    let identity = QuantumLinkIdentity::generate();
    debug!("{:?}", identity);
    identity
}

#[cfg(test)]
mod tests {
    use super::*;
    use anyhow::Result;
    use tokio::test;

    #[test]
    async fn test_generate_identity() -> Result<()> {
        let identity = QuantumLinkIdentity::generate();
        println!("{:?}", identity);

        Ok(())
    }
    #[tokio::test]
    async fn test_serialize_and_deserialize_xid() -> Result<()> {
        let identity = generate_ql_identity().await;
        let original_xid = identity.clone().xid_document;

        let serialized = serialize_xid(&identity).await;
        let deserialized = deserialize_xid(serialized)?;

        let original_cbor = original_xid.to_unsigned_envelope().to_cbor_data();
        let deserialized_cbor = deserialized.to_unsigned_envelope().to_cbor_data();

        assert_eq!(
            original_cbor, deserialized_cbor,
            "CBOR mismatch after serialization/deserialization"
        );

        Ok(())
    }
}
