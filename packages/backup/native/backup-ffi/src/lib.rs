// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

extern crate core;

#[macro_use]
extern crate log;

use bdk::bitcoin;
use bdk::bitcoin::hashes::hex::FromHex;
use bdk::bitcoin::hashes::hex::ToHex;
use bdk::keys::bip39;
use serde::{Deserialize, Serialize};
use std::ffi::{CStr, CString};
use std::io::Read;
use std::os::raw::c_char;
use std::{fs, io, ptr};

use curve25519_parser::StaticSecret;

use mla::config::ArchiveWriterConfig;
use mla::ArchiveWriter;

use mla::config::ArchiveReaderConfig;
use mla::ArchiveReader;

use crate::bitcoin::hashes::Hash;
use bdk::keys::bip39::Mnemonic;
use lazy_static::lazy_static;
use reqwest::Response;
use tokio::runtime::{Builder, Runtime};
use tokio::sync::broadcast::{Receiver, Sender};

mod error;

#[no_mangle]
pub unsafe extern "C" fn backup_last_error_message() -> *const c_char {
    let last_error = match error::take_last_error() {
        Some(err) => err,
        None => return CString::new("").unwrap().into_raw(),
    };

    let error_message = last_error.to_string();
    CString::new(error_message).unwrap().into_raw()
}

macro_rules! unwrap_or_return {
    ($a:expr,$b:expr) => {
        match $a {
            Ok(x) => x,
            Err(e) => {
                error::update_last_error(e);
                return $b;
            }
        }
    };
}

#[derive(Deserialize)]
pub struct ChallengeResponse {
    challenge: effort::Challenge,
    timestamp: u64,
    signature: String,
}

#[derive(Serialize)]
pub struct BackupRequest {
    challenge: effort::Challenge,
    solution: effort::Solution,
    timestamp: u64,
    signature: String,
    hash: String,
    backup: String,
}

#[derive(Deserialize)]
pub struct GetBackupResponse {
    backup: String,
}

lazy_static! {
    static ref RUNTIME: io::Result<Runtime> = Builder::new_multi_thread().enable_all().build();
}

#[repr(C)]
pub struct BackupPayload {
    keys_nr: u8,
    data: *const *const c_char,
}

#[no_mangle]
pub unsafe extern "C" fn backup_perform(
    payload: BackupPayload,
    seed_words: *const c_char,
    server_url: *const c_char,
    proxy_port: i32,
) -> bool {
    let backup_data = extract_backup_data(payload);
    let seed_words = unwrap_or_return!(CStr::from_ptr(seed_words).to_str(), false);
    let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes());

    let server_url = CStr::from_ptr(server_url).to_str().unwrap();

    let password = unwrap_or_return!(get_static_secret(seed_words), false);
    let encrypted = encrypt_backup(backup_data, &password);

    let rt = RUNTIME.as_ref().unwrap();
    rt.block_on(async move {
        let (tx, mut _rx): (Sender<u128>, Receiver<u128>) = tokio::sync::broadcast::channel(4);

        let challenge = match get_challenge_async(server_url, proxy_port).await {
            None => {
                return false;
            }
            Some(c) => c,
        };

        let solution = effort::solve_challenge(&challenge.challenge, &tx).await;
        post_backup_async(
            server_url,
            proxy_port,
            challenge,
            solution,
            hash.to_hex(),
            encrypted,
        )
        .await
    })
}

unsafe fn extract_backup_data(payload: BackupPayload) -> Vec<(&'static str, &'static str)> {
    let mut backup_data: Vec<(&str, &str)> = vec![];

    for i in (0..payload.keys_nr * 2).step_by(2) {
        let key = CStr::from_ptr(*payload.data.offset(i as isize))
            .to_str()
            .unwrap();
        let value = CStr::from_ptr(*payload.data.offset((i + 1) as isize))
            .to_str()
            .unwrap();
        backup_data.push((key, value));
    }
    backup_data
}

#[no_mangle]
pub unsafe extern "C" fn backup_perform_offline(
    payload: BackupPayload,
    seed_words: *const c_char,
    path: *const c_char,
) -> bool {
    let backup_data = extract_backup_data(payload);
    let seed_words = unwrap_or_return!(CStr::from_ptr(seed_words).to_str(), false);
    let password = unwrap_or_return!(get_static_secret(seed_words), false);
    let encrypted = encrypt_backup(backup_data, &password);

    let rt = RUNTIME.as_ref().unwrap();

    // We are doing an offline backup, store the data at path
    let path = CStr::from_ptr(path).to_str().unwrap();
    rt.block_on(async move { tokio::fs::write(path, encrypted).await.unwrap() });
    true
}

fn get_static_secret(seed_words: &str) -> Result<StaticSecret, bip39::Error> {
    let mnemonic = Mnemonic::parse(seed_words)?;
    let entropy = mnemonic.to_entropy_array().0;
    let entropy_32: [u8; 32] = entropy[0..32].try_into().unwrap();
    Ok(StaticSecret::from(entropy_32))
}

#[no_mangle]
pub unsafe extern "C" fn backup_get(
    seed_words: *const c_char,
    server_url: *const c_char,
    proxy_port: i32,
) -> BackupPayload {
    let err_ret = BackupPayload {
        keys_nr: 0,
        data: ptr::null(),
    };

    let seed_words = CStr::from_ptr(seed_words).to_str().unwrap();
    let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes());

    let password = unwrap_or_return!(get_static_secret(seed_words), err_ret);

    let server_url = CStr::from_ptr(server_url).to_str().unwrap();

    let rt = RUNTIME.as_ref().unwrap();

    let response =
        rt.block_on(async move { get_backup_async(server_url, proxy_port, hash.to_hex()).await });

    let payload = unwrap_or_return!(response, err_ret);
    let parsed: Vec<u8> = unwrap_or_return!(FromHex::from_hex(&payload.backup), err_ret);

    let data = unwrap_or_return!(decrypt_backup(parsed, password), err_ret);
    extract_kv_data(data)
}

unsafe fn extract_kv_data(data: Vec<(String, String)>) -> BackupPayload {
    let mut ret = vec![];
    for (k, v) in data.iter() {
        ret.push(CString::new(k.to_string()).unwrap().into_raw() as *const c_char);
        ret.push(CString::new(v.to_string()).unwrap().into_raw() as *const c_char);
    }

    let ret_ptr = ret.as_ptr();
    std::mem::forget(ret);

    BackupPayload {
        keys_nr: data.len() as u8,
        data: ret_ptr,
    }
}

#[no_mangle]
pub unsafe extern "C" fn backup_get_offline(
    seed_words: *const c_char,
    file_path: *const c_char,
) -> BackupPayload {
    let err_ret = BackupPayload {
        keys_nr: 0,
        data: ptr::null(),
    };

    let seed_words = CStr::from_ptr(seed_words).to_str().unwrap();
    let password = unwrap_or_return!(get_static_secret(seed_words), err_ret);

    let file_path = CStr::from_ptr(file_path).to_str().unwrap();
    let file_data = fs::read(file_path).unwrap();

    let data = unwrap_or_return!(decrypt_backup(file_data, password), err_ret);
    extract_kv_data(data)
}

fn encrypt_backup(files: Vec<(&str, &str)>, secret: &StaticSecret) -> Vec<u8> {
    // Create an MLA Archive - Output only needs the Write trait
    let mut buf = Vec::new();
    // Default is Compression + Encryption, to avoid mistakes
    let mut config = ArchiveWriterConfig::default();
    // The use of multiple public keys is supported
    config.add_public_keys(&vec![secret.into()]);
    {
        // Create the Writer
        let mut mla = ArchiveWriter::from_config(&mut buf, config).unwrap();

        // Add a file
        for (name, data) in files {
            mla.add_file(name, data.len() as u64, data.as_bytes())
                .unwrap();
        }

        // Complete the archive
        mla.finalize().unwrap();
    }

    buf
}

#[no_mangle]
pub unsafe extern "C" fn backup_delete(
    seed_words: *const c_char,
    server_url: *const c_char,
    proxy_port: i32,
) -> u16 {
    let seed_words = CStr::from_ptr(seed_words).to_str().unwrap();
    let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes());
    let server_url = CStr::from_ptr(server_url).to_str().unwrap();

    let rt = RUNTIME.as_ref().unwrap();

    let response = rt
        .block_on(async move { delete_backup_async(server_url, proxy_port, hash.to_hex()).await });

    unwrap_or_return!(response, 0).status().as_u16()
}

fn decrypt_backup(
    data: Vec<u8>,
    secret: StaticSecret,
) -> Result<Vec<(String, String)>, mla::errors::Error> {
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

fn _get_challenge(server_url: &str, proxy_port: i32) -> ChallengeResponse {
    let client = if proxy_port > 0 {
        let proxy = reqwest::Proxy::all("socks5://127.0.0.1:".to_owned() + &proxy_port.to_string())
            .unwrap();
        reqwest::blocking::Client::builder()
            .proxy(proxy)
            .build()
            .unwrap()
    } else {
        reqwest::blocking::Client::builder().build().unwrap()
    };

    let response = client
        .get(server_url.to_owned() + "/backup/challenge")
        .send()
        .unwrap();

    response.json().unwrap()
}

async fn get_challenge_async(server_url: &str, proxy_port: i32) -> Option<ChallengeResponse> {
    let client = get_reqwest_client(proxy_port);
    let response = client
        .get(server_url.to_owned() + "/backup/challenge")
        .send()
        .await;

    match response {
        Ok(r) => match r.json::<ChallengeResponse>().await {
            Ok(r) => Some(r),
            Err(_) => None,
        },
        Err(_) => {
            return None;
        }
    }
}

async fn post_backup_async(
    server_url: &str,
    proxy_port: i32,
    server_response: ChallengeResponse,
    solution: effort::Solution,
    hash: String,
    payload: Vec<u8>,
) -> bool {
    let client = get_reqwest_client(proxy_port);
    match client
        .post(server_url.to_owned() + "/backup")
        .json(&BackupRequest {
            challenge: server_response.challenge,
            solution,
            timestamp: server_response.timestamp,
            signature: server_response.signature,
            hash: hash.parse().unwrap(),
            backup: payload.to_hex(),
        })
        .send()
        .await
    {
        Ok(r) => {
            println!("Post backup success: {r:?}");
            true
        }
        Err(e) => {
            println!("Post backup failure: {e:?}");
            false
        }
    }
}

async fn get_backup_async(
    server_url: &str,
    proxy_port: i32,
    hash: String,
) -> Result<GetBackupResponse, reqwest::Error> {
    let client = get_reqwest_client(proxy_port);
    let response = client
        .get(server_url.to_owned() + "/backup?key=" + &*hash)
        .send()
        .await?;

    response.json().await
}

async fn delete_backup_async(
    server_url: &str,
    proxy_port: i32,
    hash: String,
) -> Result<Response, reqwest::Error> {
    let client = get_reqwest_client(proxy_port);
    let response = client
        .delete(server_url.to_owned() + "/backup?key=" + &*hash)
        .send()
        .await?;

    Ok(response)
}

fn get_reqwest_client(proxy_port: i32) -> reqwest::Client {
    if proxy_port > 0 {
        let proxy = reqwest::Proxy::all("socks5://127.0.0.1:".to_owned() + &proxy_port.to_string())
            .unwrap();
        reqwest::Client::builder().proxy(proxy).build().unwrap()
    } else {
        reqwest::Client::builder().build().unwrap()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tokio::sync::broadcast::{Receiver, Sender};

    #[tokio::test]
    async fn test_get_and_solve_challenge() {
        let server_url = "https://envoy.foundationdevices.com";
        let challenge = get_challenge_async(server_url, -1).await.unwrap();
        let (tx, _rx): (Sender<u128>, Receiver<u128>) = tokio::sync::broadcast::channel(4);

        let solution = effort::solve_challenge(&challenge.challenge, &tx).await;

        post_backup_async(
            server_url,
            -1,
            challenge,
            solution,
            "hey".to_owned(),
            vec![0, 1, 2],
        )
        .await;
    }

    #[test]
    fn test_compress_backup() {
        let mnemonic = Mnemonic::parse(
            "copper december enlist body dove discover cross help evidence fall rich clean",
        )
        .unwrap();
        let entropy = mnemonic.to_entropy_array().0;
        let entropy_32: [u8; 32] = entropy[0..32].try_into().unwrap();

        let encrypted = encrypt_backup(vec![("hello", "there")], &StaticSecret::from(entropy_32));
        let decrypted = decrypt_backup(encrypted, StaticSecret::from(entropy_32));

        assert_eq!(
            decrypted.unwrap(),
            [("hello".to_owned(), "there".to_owned())]
        );
    }

    #[test]
    fn test_create_hash_from_seed() {
        let seed_words =
            "copper december enlist body dove discover cross help evidence fall rich clean";
        let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes()).to_hex();

        assert_eq!(
            hash,
            "fbf05d44bf48541e2fb0ab36e86611d1236368ec3a223135c2aeb2c9bd2fa66a"
        );
    }
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn backup_hello() {
    println!("HELLO THERE");
}
