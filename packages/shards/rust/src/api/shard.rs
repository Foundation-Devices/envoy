// SPDX-FileCopyrightText: 2025 Foundation Devices Inc
//
// SPDX-License-Identifier: GPL-3.0-or-later

#[flutter_rust_bridge::frb(sync)]
use backup_shard::Shard;
use flutter_rust_bridge::for_generated::anyhow::{self, Context};
use minicbor::decode;
use minicbor_derive::{Decode, Encode};
use std::collections::BTreeMap;
use std::fs::File;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Encode, Decode, Default)]
pub struct ShardBackupFile {
    #[n(0)]
    pub shards: BTreeMap<[u8; 32], ShardBackup>,
}

impl ShardBackupFile {
    pub fn new() -> Self {
        Self {
            shards: BTreeMap::new(),
        }
    }

    pub fn add_new_shard(shard: Vec<u8>, file_path: String) -> anyhow::Result<()> {
        if !std::path::Path::new(&file_path).exists() {
            File::create(&file_path).context("Failed to create file")?;
        }
        let shard = Shard::decode(&shard).context("decode shard")?;
        let mut backup_file = Self::load(file_path.clone());
        let new_shard = ShardBackup::new(*shard.seed_fingerprint(), shard.encode());
        backup_file
            .shards
            .insert(*shard.seed_fingerprint(), new_shard);
        backup_file.save(&file_path)?;
        Ok(())
    }

    pub fn load(file_path: String) -> Self {
        (|| {
            let file_data = std::fs::read(file_path)
                .inspect_err(|e| log::warn!("failed to read shard backup file {e:?}"))
                .ok()?;
            let backup_file: ShardBackupFile = decode(&file_data)
                .inspect_err(|e| log::warn!("failed to decode shard data {e:?}"))
                .ok()?;
            Some(backup_file)
        })()
        .unwrap_or_default()
    }

    pub fn save(&self, file_path: &str) -> anyhow::Result<()> {
        let encoded_data = minicbor::to_vec(self).context("encode shard data")?;
        std::fs::write(file_path, encoded_data).context("Failed to write file")?;
        Ok(())
    }

    pub fn get_shard_by_fingerprint(fingerprint: [u8; 32], file_path: String) -> Option<Vec<u8>> {
        let backup_file = Self::load(file_path);
        backup_file
            .shards
            .get(&fingerprint)
            .map(|s| s.shard.clone())
    }

    pub fn to_bytes(&self) -> anyhow::Result<Vec<u8>> {
        minicbor::to_vec(&self.shards).context("failed to encode ShardBackupFile")
    }

    pub fn from_bytes(data: &[u8]) -> Result<Self, decode::Error> {
        let shards: BTreeMap<[u8; 32], ShardBackup> = decode(data)?;
        Ok(Self { shards })
    }
}

/// single shard backup entry
#[derive(Encode, Decode, Clone)]
#[cbor(map)]
pub struct ShardBackup {
    #[n(0)]
    pub fingerprint: [u8; 32],
    #[n(1)]
    pub timestamp: u64,
    #[n(2)]
    pub shard: Vec<u8>,
}

impl ShardBackup {
    pub fn new(fingerprint: [u8; 32], shard: Vec<u8>) -> Self {
        Self {
            fingerprint,
            timestamp: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            shard,
        }
    }

    pub fn to_bytes(&self) -> anyhow::Result<Vec<u8>> {
        minicbor::to_vec(self).context("failed to encode ShardBackup")
    }

    pub fn from_bytes(data: &[u8]) -> Result<Self, decode::Error> {
        decode(data)
    }
}
