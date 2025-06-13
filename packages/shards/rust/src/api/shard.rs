// SPDX-FileCopyrightText: 2025 Foundation Devices Inc
//
// SPDX-License-Identifier: GPL-3.0-or-later

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

use flutter_rust_bridge::for_generated::anyhow;
use flutter_rust_bridge::for_generated::anyhow::anyhow;
use minicbor::decode;
use std::fs::File;

use minicbor_derive::{Decode, Encode};

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Encode, Decode)]
#[cbor(map)] // You need to specify encoding format
pub struct ShardBackUp {
    #[n(0)]
    pub device_serial: String,
    #[n(1)]
    pub shard_identifier: String,
    #[n(2)]
    pub timestamp: u64,
    #[n(3)]
    pub shard: Vec<u8>,
}

impl ShardBackUp {
    pub fn add_new_shard(
        shard: Vec<u8>,
        shard_identifier: &str,
        device_serial: &str,
        file_path: String,
    ) -> Result<(), String> {
        if !std::path::Path::new(&file_path).exists() {
            File::create(file_path.clone())
                .map_err(|e| format!("Failed to create file: {:?}", e))?;
        }

        let mut shards: Vec<ShardBackUp> = Self::get_all_shards(file_path.clone());

        if shards
            .iter()
            .any(|s| s.shard_identifier == shard_identifier)
        {
            return Err(format!(
                "Shard with identifier '{}' already exists",
                shard_identifier
            ));
        }
        // Add new shard
        let new_shard = ShardBackUp::new(
            device_serial.to_string(), // You need to provide device_serial
            shard_identifier.to_string(),
            shard,
        );

        shards.push(new_shard);

        // Encode and write back
        let encoded_data =
            minicbor::to_vec(&shards) // Use to_vec instead of encode
                .map_err(|e| format!("Failed to encode shard data: {:?}", e))?;

        std::fs::write(&file_path, encoded_data)
            .map_err(|e| format!("Failed to write file: {:?}", e))?;

        Ok(())
    }

    pub fn get_all_shards(file_path: String) -> Vec<ShardBackUp> {
        match std::fs::read(&file_path).map_err(|e| format!("Failed to read file: {:?}", e)) {
            Ok(file_data) => decode(&file_data)
                .map_err(|e| format!("Failed to decode shard data: {:?}", e))
                .and_then(|shards: Vec<ShardBackUp>| Ok(shards))
                .unwrap_or_else(|_| Vec::new()),
            Err(_) => {
                // If the file does not exist or is empty, return an empty vector
                Vec::new()
            }
        }
    }

    pub fn new(device_serial: String, shard_identifier: String, shard: Vec<u8>) -> Self {
        Self {
            device_serial,
            shard_identifier,
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
