// SPDX-FileCopyrightText: 2025 Foundation Devices Inc
//
// SPDX-License-Identifier: GPL-3.0-or-later

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo

use backup_shard::Shard;
use flutter_rust_bridge::for_generated::anyhow;
use flutter_rust_bridge::for_generated::anyhow::{anyhow, Context};
use minicbor::decode;
use minicbor_derive::{Decode, Encode};
use std::fs::File;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Encode, Decode)]
#[cbor(map)] // You need to specify encoding format
pub struct ShardBackUp {
    #[n(0)]
    pub fingerprint: [u8; 32],
    #[n(1)]
    pub timestamp: u64,
    #[n(2)]
    pub shard: Vec<u8>,
}

impl ShardBackUp {
    pub fn add_new_shard(shard: Vec<u8>, file_path: String) -> anyhow::Result<()> {
        if !std::path::Path::new(&file_path).exists() {
            File::create(file_path.clone()).context("Failed to create file")?;
        }

        // Parse the shard from CBOR
        let shard = Shard::decode(&*shard).context("Failed to decode shard")?;

        let mut shards: Vec<ShardBackUp> = Self::get_all_shards(file_path.clone());

        if shards
            .iter()
            .any(|s| s.fingerprint == *shard.seed_fingerprint())
        {
            anyhow::bail!(
                "Shard with identifier '{:?}' already exists",
                shard.seed_fingerprint()
            );
        }
        // Add new shard
        let new_shard = ShardBackUp::new(
            *shard.seed_fingerprint(),
            shard.encode(),
        );

        shards.push(new_shard);

        // Encode and write back
        let encoded_data =
            minicbor::to_vec(&shards).context("Failed to encode shard data")?;

        std::fs::write(&file_path, encoded_data).context("Failed to write file")?;

        Ok(())
    }

    pub fn get_all_shards(file_path: String) -> Vec<ShardBackUp> {
        match std::fs::read(&file_path).map_err(|e| format!("Failed to read file: {:?}", e)) {
            Ok(file_data) => decode(&file_data)
                .map_err(|e| format!("Failed to decode shard data: {:?}", e))
                .unwrap_or_else(|_| Vec::new()),
            Err(_) => {
                // If the file does not exist or is empty, return an empty vector
                Vec::new()
            }
        }
    }

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

    pub fn to_bytes(&self) -> anyhow::Result<Vec<u8>, anyhow::Error> {
        minicbor::to_vec(self).map_err(|e| anyhow!("Failed to encode ShardBackUp: {:?}", e))
    }

    pub fn from_bytes(data: &[u8]) -> Result<Self, decode::Error> {
        decode(data)
    }
}
