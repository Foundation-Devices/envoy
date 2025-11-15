// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use anyhow::anyhow;
use anyhow::bail;
use anyhow::Context;
use anyhow::Result;
use bc_envelope::prelude::CBOREncodable;
use bc_envelope::Envelope;
use bc_ur::prelude::{CBORCase, CBOR};
use bc_xid::XIDDocument;
use btp::{chunk, Chunk, MasterDechunker};
use flutter_rust_bridge::frb;
use foundation_api::backup::BackupChunk;
use foundation_api::backup::BackupMetadata;
use foundation_api::backup::RestoreMagicBackupEvent;
use foundation_api::backup::SeedFingerprint;
use foundation_api::firmware::{split_update_into_chunks, FirmwareFetchEvent};
use foundation_api::message::{EnvoyMessage, PassportMessage, QuantumLinkMessage};
use foundation_api::quantum_link::{ARIDCache, QuantumLink, QuantumLinkIdentity};
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
    EnvoyARIDCache {
        inner: ARIDCache::default(),
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
    arid_cache: &mut EnvoyARIDCache,
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

pub fn split_backup_into_chunks(backup: &[u8], chunk_size: usize) -> Vec<QuantumLinkMessage> {
    let chunks = backup.chunks(chunk_size);
    let total_chunks = chunks.len() as u32;
    let mut messages = Vec::with_capacity(chunks.len() + 1);

    messages.push(QuantumLinkMessage::RestoreMagicBackupEvent(
        RestoreMagicBackupEvent::Starting(BackupMetadata { total_chunks }),
    ));

    chunks
        .enumerate()
        .map(move |(chunk_index, chunk_data)| {
            QuantumLinkMessage::RestoreMagicBackupEvent(RestoreMagicBackupEvent::Chunk(
                BackupChunk {
                    chunk_index: chunk_index as u32,
                    total_chunks,
                    data: chunk_data.to_vec(),
                },
            ))
        })
        .for_each(|msg| messages.push(msg));

    messages
}

pub async fn encode(
    message: EnvoyMessage,
    sender: &QuantumLinkIdentity,
    recipient: &XIDDocument,
) -> Vec<Vec<u8>> {
    debug!("SENDER: {:?}", sender.xid_document);
    debug!("RECEIVER: {:?}", recipient);

    let envelope = QuantumLink::seal(
        &message,
        (sender.private_keys.as_ref().unwrap(), &sender.xid_document),
        recipient,
    );

    let cbor = envelope.to_cbor_data();

    let mut chunks = Vec::new();
    for chunk in chunk(&cbor) {
        chunks.push(chunk.to_vec());
    }

    chunks
}


pub async fn encode_to_file(
    payload:  &[u8],
    sender: &QuantumLinkIdentity,
    recipient: &XIDDocument,
    path: &str,
    chunk_size: usize,
    timestamp: u32,
) -> anyhow::Result<bool> {
    use std::fs::File;
    use std::io::Write;

    debug!("SENDER: {:?}", sender.xid_document);
    debug!("RECEIVER: {:?}", recipient);

    let mut file = File::create(path)?;

    let messages: Vec<EnvoyMessage> = split_backup_into_chunks(payload, chunk_size)
        .into_iter()
        .map(|msg| {
            EnvoyMessage::new(
                msg,
                timestamp
            )
        })
        .collect();

    for message in messages {
        let envelope = QuantumLink::seal(
            &message,
            (sender.private_keys.as_ref().unwrap(), &sender.xid_document),
            recipient,
        );

        let cbor = envelope.to_cbor_data();

        let message_chunks: Vec<Vec<u8>> = chunk(&cbor)
            .map(|chunk| chunk.to_vec())
            .collect();

        file.write_all(&(message_chunks.len() as u32).to_be_bytes())?;

        for chunk_data in message_chunks {
            file.write_all(&(chunk_data.len() as u32).to_be_bytes())?;
            // Write chunk bytes
            file.write_all(&chunk_data)?;
        }
    }

    file.flush()?;
    anyhow::Ok(true)
}


pub async fn generate_ql_identity() -> QuantumLinkIdentity {
    debug!("Generating identity");
    let identity = QuantumLinkIdentity::generate();
    debug!("{:?}", identity);
    identity
}

#[frb(opaque)]
pub struct CollectBackupChunks {
    pub seed_fingerprint: SeedFingerprint,
    pub total_chunks: usize,
    pub next_chunk_index: usize,
    pub data: Vec<u8>,
    pub backup_hash: [u8; 32],
}

#[frb(opaque)]
pub struct PrimeBackupFile {
    pub data: Vec<u8>,
    pub seed_fingerprint: SeedFingerprint,
}

pub fn collect_backup_chunks(
    seed_fingerprint: SeedFingerprint,
    total_chunks: u32,
    backup_hash: [u8; 32],
) -> CollectBackupChunks {
    CollectBackupChunks {
        seed_fingerprint,
        total_chunks: total_chunks as usize,
        next_chunk_index: 0,
        data: Vec::new(),
        backup_hash,
    }
}

pub fn push_backup_chunk(
    this: &mut CollectBackupChunks,
    chunk: BackupChunk,
) -> anyhow::Result<Option<PrimeBackupFile>> {
    if this.next_chunk_index == this.total_chunks {
        bail!("all chunks already received")
    }

    if this.next_chunk_index != chunk.chunk_index as usize {
        bail!(
            "invalid chunk index, expected {} got {}",
            this.next_chunk_index,
            chunk.chunk_index
        );
    }

    let is_last = chunk.is_last();

    this.data.extend(chunk.data);
    this.next_chunk_index += 1;

    if is_last {
        let hash = hash_data(&this.data);
        if this.backup_hash != hash {
            bail!("Backup hash mismatch");
        }
        Ok(Some(PrimeBackupFile {
            data: this.data.clone(),
            seed_fingerprint: this.seed_fingerprint,
        }))
    } else {
        Ok(None)
    }
}

fn hash_data(data: &[u8]) -> [u8; 32] {
    use sha2::Digest;
    use sha2::Sha256;
    let mut hasher = Sha256::new();
    hasher.update(data);
    let hash = hasher.finalize();
    hash.into()
}

#[cfg(test)]
mod tests {
    use super::*;
    use anyhow::Result;

    #[tokio::test]
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

    #[test]
    fn test_in_progress_backup_chunks() -> Result<()> {
        let seed_fp = [1u8; 32];
        let data = vec![1, 2, 3, 4, 5, 6, 7, 8, 9];
        let hash = hash_data(&data);

        let mut in_progress = collect_backup_chunks(seed_fp, 3, hash);

        let chunk1 = BackupChunk {
            chunk_index: 0,
            total_chunks: 3,
            data: vec![1, 2, 3],
        };
        assert!(push_backup_chunk(&mut in_progress, chunk1)?.is_none());
        assert_eq!(in_progress.next_chunk_index, 1);

        let chunk2 = BackupChunk {
            chunk_index: 1,
            total_chunks: 3,
            data: vec![4, 5, 6],
        };
        assert!(push_backup_chunk(&mut in_progress, chunk2)?.is_none());
        assert_eq!(in_progress.next_chunk_index, 2);

        let chunk3 = BackupChunk {
            chunk_index: 2,
            total_chunks: 3,
            data: vec![7, 8, 9],
        };
        let result = push_backup_chunk(&mut in_progress, chunk3)?;
        assert!(result.is_some());
        let file = result.unwrap();
        assert_eq!(file.data, vec![1, 2, 3, 4, 5, 6, 7, 8, 9]);
        assert_eq!(file.seed_fingerprint, seed_fp);

        Ok(())
    }

    #[test]
    fn test_in_progress_backup_chunks_wrong_index() -> Result<()> {
        let seed_fp = [1u8; 32];
        let data = vec![1, 2, 3, 4, 5, 6, 7, 8, 9];
        let hash = hash_data(&data);

        let mut in_progress = collect_backup_chunks(seed_fp, 3, hash);

        let chunk = BackupChunk {
            chunk_index: 1,
            total_chunks: 3,
            data,
        };
        assert!(push_backup_chunk(&mut in_progress, chunk).is_err());

        Ok(())
    }
}
