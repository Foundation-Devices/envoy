// SPDX-FileCopyrightText: 2025 Foundation Devices Inc
//
// SPDX-License-Identifier: GPL-3.0-or-later

use bdk::bitcoin;
use bdk::bitcoin::hashes::hex::FromHex;
use bdk::bitcoin::hashes::Hash;
use bdk::keys::bip39;
use bdk::keys::bip39::Mnemonic;
use flutter_rust_bridge::frb;
use curve25519_parser::StaticSecret;
use flutter_rust_bridge::for_generated::anyhow;
use flutter_rust_bridge::for_generated::anyhow::{anyhow, Context};
use lazy_static::lazy_static;
use mla::config::{ArchiveReaderConfig, ArchiveWriterConfig};
use mla::{ArchiveReader, ArchiveWriter};
use reqwest::Response;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::io::Read;
use std::{fs, io};
use tokio::runtime::{Builder, Runtime};
use tokio::sync::broadcast::{Receiver, Sender};

#[derive(Deserialize)]
#[frb(ignore)]
pub struct ChallengeResponse {
    pub challenge: effort::Challenge,
    pub(crate) timestamp: u64,
    pub(crate) signature: String,
}

#[repr(C)]
pub struct BackupPayload {
    pub(crate) keys_nr: u8,
    pub(crate) data: Vec<String>,
}

#[derive(Serialize)]
pub struct BackupRequest {
    pub(crate) challenge: effort::Challenge,
    pub(crate) solution: effort::Solution,
    pub(crate) timestamp: u64,
    pub(crate) signature: String,
    pub(crate) hash: String,
    pub(crate) backup: String,
}

#[derive(Deserialize)]
pub struct GetBackupResponse {
    pub backup: String,
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

lazy_static! {
    static ref RUNTIME: io::Result<Runtime> = Builder::new_multi_thread().enable_all().build();
}
pub enum GetBackupException {
    ServerUnreachable,
    SeedNotFound,
    BackupNotFound,
    InvalidSeed,
    InvalidServer,
    InvalidBackupFile,
}

pub struct Backup {}

// Implementations moved into associated/static functions on `Backup`.
impl Backup {
    pub fn get_reqwest_client(proxy_port: i32) -> reqwest::Client {
        if proxy_port > 0 {
            let proxy =
                reqwest::Proxy::all("socks5://127.0.0.1:".to_owned() + &proxy_port.to_string())
                    .unwrap();
            reqwest::Client::builder().proxy(proxy).build().unwrap()
        } else {
            reqwest::Client::builder().build().unwrap()
        }
    }

    pub async fn delete(
        seed_words: &str,
        server_url: &str,
        proxy_port: i32,
    ) -> anyhow::Result<u16> {
        if seed_words.is_empty() {
            anyhow::bail!("Seed words cannot be empty");
        }

        if server_url.is_empty() {
            anyhow::bail!("Server URL cannot be empty");
        }

        let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes());

        let response = Self::delete_backup_async(server_url, proxy_port, hash.to_string()).await;
        if response.is_err() {
            anyhow::bail!("Failed to delete backup: {}", response.err().unwrap());
        }
        Ok(response?.status().as_u16())
    }

    pub async fn delete_backup_async(
        server_url: &str,
        proxy_port: i32,
        hash: String,
    ) -> Result<Response, reqwest::Error> {
        let client = Self::get_reqwest_client(proxy_port);
        let response = client
            .delete(server_url.to_owned() + "/backup?key=" + &*hash)
            .send()
            .await?;

        Ok(response)
    }

    pub async fn perform_backup(
        payload: HashMap<String, String>,
        seed_words: &str,
        server_url: &str,
        local_backup: &str,
        proxy_port: i32,
        perform_cloud: bool,
    ) -> anyhow::Result<bool> {
        let (tx, mut _rx): (Sender<u128>, Receiver<u128>) = tokio::sync::broadcast::channel(4);

        let backup_payload = BackupPayload {
            keys_nr: payload.len() as u8,
            data: payload.into_iter().flat_map(|(k, v)| vec![k, v]).collect(),
        };
        let backup_data =
            Self::extract_backup_data(backup_payload).context("invalid backup payload")?;
        let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes());

        if seed_words.is_empty() {
            anyhow::bail!("Seed words cannot be empty");
        }
        if server_url.is_empty() {
            anyhow::bail!("Server URL cannot be empty");
        }

        let password = Self::get_static_secret(seed_words).context("invalid password")?;
        let encrypted = Self::encrypt_backup(backup_data, &password);
        let challenge = match Self::get_challenge_async(server_url, proxy_port).await {
            None => {
                anyhow::bail!("Unable to get challenge from server");
            }
            Some(c) => c,
        };
        let solution = effort::solve_challenge(&challenge.challenge, &tx).await;
        // Save local backup
        fs::write(local_backup, &encrypted).context("failed to write local backup")?;
        if !perform_cloud {
            return Ok(true);
        }
        let post_success = Self::post_backup_async(
            server_url,
            proxy_port,
            challenge,
            solution,
            hash.to_string(),
            encrypted,
        )
        .await;
        match post_success {
            Ok(success) => Ok(success),
            Err(e) => Err(anyhow!("Failed to post backup: {}", e)),
        }
    }

    pub async fn perform_prime_backup(
        server_url: &str,
        proxy_port: i32,
        seed_hash: Vec<u8>,
        payload: Vec<u8>,
    ) -> anyhow::Result<bool> {
        let (tx, mut _rx): (Sender<u128>, Receiver<u128>) = tokio::sync::broadcast::channel(4);

        if server_url.is_empty() {
            anyhow::bail!("Server URL cannot be empty");
        }
        let challenge = match Self::get_challenge_async(server_url, proxy_port).await {
            None => {
                anyhow::bail!("Unable to get challenge from server");
            }
            Some(c) => c,
        };
        let solution = effort::solve_challenge(&challenge.challenge, &tx).await;

        let hash: String = hex::encode(&seed_hash);

        let post_success = Self::post_backup_async(
            server_url,
            proxy_port,
            challenge,
            solution,
            hash,
            payload,
        )
            .await;
        match post_success {
            Ok(success) => Ok(success),
            Err(e) => Err(anyhow!("Failed to post backup: {}", e)),
        }
    }




    pub async fn get_prime_backup(
        hash: Vec<u8>,
        server_url: &str,
        proxy_port: i32,
    ) -> Result<Vec<u8>, GetBackupException> {

        if server_url.is_empty() {
            return Err(GetBackupException::InvalidServer);
        }
        let client = Self::get_reqwest_client(proxy_port);

        let hash_string: String = hex::encode(&hash);
        let url = server_url.to_owned() + "/backup?key=" + &hash_string;
        // Send request and map network errors
        let res = match client.get(url).send().await {
            Ok(r) => r,
            Err(_) => return Err(GetBackupException::ServerUnreachable),
        };

        let status = res.status();
        if status.as_u16() == 400 {
            return Err(GetBackupException::SeedNotFound);
        }
        if status.as_u16() == 404 {
            return Err(GetBackupException::BackupNotFound);
        }
        if !status.is_success() {
            return Err(GetBackupException::ServerUnreachable);
        }
        // Parse response JSON
        let response: GetBackupResponse = match res.json().await {
            Ok(r) => r,
            Err(_) => return Err(GetBackupException::ServerUnreachable),
        };

        // Decode hex and decrypt backup, mapping failures to BackupNotFound
        let parsed = match FromHex::from_hex(&response.backup) {
            Ok(p) => p,
            Err(_) => return Err(GetBackupException::BackupNotFound),
        };

        Ok(parsed)
    }


    pub fn get_backup_offline(
        seed_words: &str,
        file_path: &str,
    ) -> anyhow::Result<Vec<(String, String)>, GetBackupException> {
        let file_data = match fs::read(file_path) {
            Ok(s) => s,
            Err(_) => return Err(GetBackupException::InvalidBackupFile),
        };
        let password = match Backup::get_static_secret(seed_words) {
            Ok(s) => s,
            Err(_) => return Err(GetBackupException::InvalidSeed),
        };
        match Backup::decrypt_backup(file_data, password) {
            Ok(d) => Ok(d),
            Err(_) => Err(GetBackupException::BackupNotFound),
        }
    }

    #[frb(ignore)]
    pub async fn get_challenge_async(
        server_url: &str,
        proxy_port: i32,
    ) -> Option<ChallengeResponse> {
        let client = Self::get_reqwest_client(proxy_port);
        let response = client
            .get(server_url.to_owned() + "/backup/challenge")
            .send()
            .await;

        match response {
            Ok(r) => r.json::<ChallengeResponse>().await.ok(),
            Err(_) => None,
        }
    }

    pub fn decrypt_backup(
        data: Vec<u8>,
        secret: StaticSecret,
    ) -> anyhow::Result<Vec<(String, String)>> {
        // Specify the key for the Reader
        let mut config = ArchiveReaderConfig::new();
        config.add_private_keys(&[secret]);

        // Read from buf, which needs Read + Seek
        let buf = io::Cursor::new(data);

        let mut mla_read = ArchiveReader::from_config(buf, config)?;
        let files: Vec<String> = mla_read.list_files()?.cloned().collect();

        Ok(files
            .iter()
            .map(|name| {
                let mut file = mla_read.get_file(name.clone()).unwrap().unwrap().data;
                let mut content = String::new();

                file.read_to_string(&mut content).unwrap();
                (name.to_owned(), content)
            })
            .collect())
    }

    pub async fn perform_backup_offline(
        payload: BackupPayload,
        seed_words: &str,
        path: &str,
    ) -> anyhow::Result<bool> {
        let backup_data = Self::extract_backup_data(payload);

        if backup_data.is_err() {
            return Err(backup_data.err().unwrap());
        }
        let password = Self::get_static_secret(seed_words).context("invalid seed words")?;
        let encrypted = Self::encrypt_backup(backup_data?, &password);
        fs::write(path, encrypted)?;
        Ok(true)
    }

    pub fn extract_backup_data(payload: BackupPayload) -> anyhow::Result<Vec<(String, String)>> {
        if payload.keys_nr == 0 {
            Err(anyhow!("invalid keys_nr"))
        } else {
            let keys_nr = payload.keys_nr as usize;

            if keys_nr == 0 {
                return Err(anyhow!("invalid keys_nr"));
            }

            if payload.data.is_empty() {
                return Err(anyhow::anyhow!("payload.data is empty"));
            }

            let mut backup_data = Vec::new();

            for pair in payload.data.chunks(2) {
                let key = &pair[0];
                let value = &pair[1];
                backup_data.push((key.clone(), value.clone()));
            }
            Ok(backup_data)
        }
    }

    pub async fn get_backup(
        seed_words: &str,
        server_url: &str,
        proxy_port: i32,
    ) -> Result<Vec<(String, String)>, GetBackupException> {
        // Validate inputs
        if seed_words.is_empty() {
            return Err(GetBackupException::InvalidSeed);
        }
        if server_url.is_empty() {
            return Err(GetBackupException::InvalidServer);
        }

        let password = match Self::get_static_secret(seed_words) {
            Ok(s) => s,
            Err(_) => return Err(GetBackupException::InvalidSeed),
        };

        // Build client & request
        let client = Self::get_reqwest_client(proxy_port);
        let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes()).to_string();
        let url = server_url.to_owned() + "/backup?key=" + &*hash;

        // Send request and map network errors
        let res = match client.get(url).send().await {
            Ok(r) => r,
            Err(_) => return Err(GetBackupException::ServerUnreachable),
        };

        let status = res.status();
        if status.as_u16() == 400 {
            return Err(GetBackupException::SeedNotFound);
        }
        if status.as_u16() == 404 {
            return Err(GetBackupException::BackupNotFound);
        }
        if !status.is_success() {
            return Err(GetBackupException::ServerUnreachable);
        }
        // Parse response JSON
        let response: GetBackupResponse = match res.json().await {
            Ok(r) => r,
            Err(_) => return Err(GetBackupException::ServerUnreachable),
        };

        // Decode hex and decrypt backup, mapping failures to BackupNotFound
        let parsed = match FromHex::from_hex(&response.backup) {
            Ok(p) => p,
            Err(_) => return Err(GetBackupException::BackupNotFound),
        };

        let data = match Self::decrypt_backup(parsed, password) {
            Ok(d) => d,
            Err(_) => return Err(GetBackupException::BackupNotFound),
        };

        Ok(data)
    }

    pub fn encrypt_backup(files: Vec<(String, String)>, secret: &StaticSecret) -> Vec<u8> {
        // Create an MLA Archive - Output only needs the Write trait
        let mut buf = Vec::new();
        // Default is Compression + Encryption, to avoid mistakes
        let mut config = ArchiveWriterConfig::default();
        // The use of multiple public keys is supported
        config.add_public_keys(&[secret.into()]);
        {
            // Create the Writer
            let mut mla = ArchiveWriter::from_config(&mut buf, config).unwrap();

            // Add a file
            for (name, data) in files {
                mla.add_file(&name, data.len() as u64, data.as_bytes())
                    .context("failed to add file to archive")
                    .unwrap();
            }

            // Complete the archive
            mla.finalize().unwrap();
        }

        buf
    }

    pub fn get_static_secret(seed_words: &str) -> Result<StaticSecret, bip39::Error> {
        let mnemonic = Mnemonic::parse(seed_words)?;
        let entropy = mnemonic.to_entropy_array().0;
        let entropy_32: [u8; 32] = entropy[0..32].try_into().unwrap();
        Ok(StaticSecret::from(entropy_32))
    }

    #[frb(ignore)]
    pub async fn post_backup_async(
        server_url: &str,
        proxy_port: i32,
        server_response: ChallengeResponse,
        solution: effort::Solution,
        hash: String,
        payload: Vec<u8>,
    ) -> anyhow::Result<bool> {
        let client = Self::get_reqwest_client(proxy_port);
        let r = client
            .post(server_url.to_owned() + "/backup")
            .json(&BackupRequest {
                challenge: server_response.challenge,
                solution,
                timestamp: server_response.timestamp,
                signature: server_response.signature,
                hash: hash.parse()?,
                backup: hex::encode(&payload),
            })
            .send()
            .await;
        match r {
            Ok(response) => Ok(response.status().is_success()),
            Err(e) => Err(anyhow!("Failed to send backup: {}", e)),
        }
    }

    // fn backup_payload_to_hashmap(payload: BackupPayload) -> HashMap<String, String> {
    //     let mut result = HashMap::new();
    //
    //     // Process data in chunks of 2 (key, value)
    //     for chunk in payload.data.chunks(2) {
    //         if chunk.len() == 2 {
    //             result.insert(chunk[0].clone(), chunk[1].clone());
    //         }
    //     }
    //
    //     result
    // }
}
