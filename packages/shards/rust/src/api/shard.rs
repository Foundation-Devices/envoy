// SPDX-FileCopyrightText: 2025 Foundation Devices Inc
//
// SPDX-License-Identifier: GPL-3.0-or-later

#[flutter_rust_bridge::frb(sync)]
use backup_shard::Shard;
use flutter_rust_bridge::for_generated::anyhow::{self, Context};
use minicbor::decode;
use minicbor_derive::{Decode, Encode};
use std::fs::File;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Encode, Decode, Default)]
pub struct ShardBackupFile {
    #[n(0)]
    pub shards: Vec<ShardBackup>,
}

impl ShardBackupFile {
    pub fn add_new_shard(shard: Vec<u8>, file_path: String) -> anyhow::Result<()> {
        if !std::path::Path::new(&file_path).exists() {
            File::create(&file_path).context("Failed to create file")?;
        }
        let shard = Shard::decode(&shard).context("decode shard")?;
        let mut backup_file = Self::load(&file_path);
        let new_shard = ShardBackup::new(*shard.seed_fingerprint(), shard.encode());
        backup_file
            .shards
            .retain(|s| s.fingerprint != new_shard.fingerprint);
        backup_file.shards.push(new_shard);
        backup_file.save(&file_path)?;
        Ok(())
    }

    pub fn get_shard_by_fingerprint(fingerprint: [u8; 32], file_path: String) -> Option<Vec<u8>> {
        let backup_file = Self::load(&file_path);
        backup_file
            .shards
            .iter()
            .find(|s| s.fingerprint == fingerprint)
            .map(|s| s.shard.clone())
    }
}

impl ShardBackupFile {
    fn load(file_path: &str) -> Self {
        (|| {
            let file_data = std::fs::read(file_path)
                .inspect_err(|e| log::warn!("failed to read shard backup file {e:?}"))
                .ok()?;
            let backup_file: ShardBackupFile = Self::from_bytes(&file_data)
                .inspect_err(|e| log::warn!("failed to decode shard data {e:?}"))
                .ok()?;
            Some(backup_file)
        })()
        .unwrap_or_default()
    }

    fn save(&self, file_path: &str) -> anyhow::Result<()> {
        let encoded_data = self.to_bytes()?;
        std::fs::write(file_path, encoded_data).context("save to file")?;
        Ok(())
    }

    fn to_bytes(&self) -> anyhow::Result<Vec<u8>> {
        minicbor::to_vec(self).context("encode ShardBackupFile")
    }

    fn from_bytes(data: &[u8]) -> Result<Self, decode::Error> {
        decode(data)
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
    fn new(fingerprint: [u8; 32], shard: Vec<u8>) -> Self {
        Self {
            fingerprint,
            timestamp: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs(),
            shard,
        }
    }
}

#[test]
fn shard_backup_encode_decode() {
    let backup = ShardBackup::new(
        [
            0x41, 0x42, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43,
            0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43,
            0x43, 0x43, 0x43, 0x43,
        ],
        vec![0xDE, 0xAD, 0xBE, 0xEF],
    );

    let encoded = minicbor::to_vec(&backup).expect("Failed to encode");
    let decoded: ShardBackup = decode(&encoded).expect("Failed to decode");

    assert_eq!(decoded.fingerprint, backup.fingerprint);
    assert_eq!(decoded.timestamp, backup.timestamp);
    assert_eq!(decoded.shard, backup.shard);
}

#[test]
fn adding_shard() {
    let file_path = "adding_shard.cbor";

    let fingerprint = [2; 32];
    let shard1 = Shard::new([1; 32], fingerprint, vec![3; 10], 2, true).encode();
    let shard2 = Shard::new([1; 32], fingerprint, vec![4; 10], 2, true).encode();

    ShardBackupFile::add_new_shard(shard1.clone(), file_path.to_string()).unwrap();

    let shard = ShardBackupFile::get_shard_by_fingerprint(fingerprint, file_path.to_string());
    assert_eq!(shard, Some(shard1));

    ShardBackupFile::add_new_shard(shard2.clone(), file_path.to_string()).unwrap();

    let shard = ShardBackupFile::get_shard_by_fingerprint(fingerprint, file_path.to_string());
    assert_eq!(shard, Some(shard2));

    let _ = std::fs::remove_file(file_path);
}
