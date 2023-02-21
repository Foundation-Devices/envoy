// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

extern crate core;

#[macro_use]
extern crate log;

use bdk::bitcoin;
use bdk::bitcoin::hashes::hex::ToHex;
use serde::{Deserialize, Serialize};
use std::ffi::{CStr, CString};
use std::io::Read;
use std::os::raw::c_char;
use std::{io, ptr};

use curve25519_parser::StaticSecret;

use mla::config::ArchiveWriterConfig;
use mla::ArchiveWriter;

use mla::config::ArchiveReaderConfig;
use mla::ArchiveReader;

use crate::bitcoin::hashes::Hash;
use bdk::keys::bip39::Mnemonic;
use lazy_static::lazy_static;
use tokio::runtime::{Builder, Runtime};
use tokio::sync::broadcast::{Receiver, Sender};
use tokio::task::JoinHandle;

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
pub unsafe extern "C" fn backup_perform_cancel(handle: *mut JoinHandle<()>) {
    let handle = {
        assert!(!handle.is_null());
        &mut *handle
    };

    handle.abort();
}

#[no_mangle]
pub unsafe extern "C" fn backup_perform(
    payload: BackupPayload,
    seed_words: *const c_char,
    server_url: *const c_char,
    proxy_port: i32,
    path: *const c_char,
) -> *mut JoinHandle<()> {
    let mut backup_data: Vec<(&str, &str)> = vec![];

    for i in 0..payload.keys_nr {
        let key = CStr::from_ptr(*payload.data.offset(i as isize))
            .to_str()
            .unwrap();
        let value = CStr::from_ptr(*payload.data.offset((i + 1) as isize))
            .to_str()
            .unwrap();
        backup_data.push((key, value));
    }

    let seed_words = unwrap_or_return!(CStr::from_ptr(seed_words).to_str(), ptr::null_mut());

    let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes());

    let server_url = CStr::from_ptr(server_url).to_str().unwrap();

    let password = get_static_secret(seed_words);
    let encrypted = encrypt_backup(backup_data, &password);

    let rt = RUNTIME.as_ref().unwrap();

    if !path.is_null() {
        // We are doing an offline backup, store the data at path
        let path = CStr::from_ptr(path).to_str().unwrap();

        let handle = rt.spawn(async move { tokio::fs::write(path, encrypted).await.unwrap() });

        let handle_box = Box::new(handle);
        return Box::into_raw(handle_box);
    }

    let handle = rt.spawn(async move {
        let (tx, mut _rx): (Sender<u128>, Receiver<u128>) = tokio::sync::broadcast::channel(4);

        let challenge = get_challenge_async(server_url, proxy_port).await;
        let solution = effort::solve_challenge(&challenge.challenge, &tx).await;
        post_backup_async(
            server_url,
            proxy_port,
            challenge,
            solution,
            hash.to_hex(),
            encrypted,
        )
        .await;
    });

    let handle_box = Box::new(handle);
    Box::into_raw(handle_box)
}

unsafe fn get_static_secret(seed_words: &str) -> StaticSecret {
    let mnemonic = Mnemonic::parse(seed_words).unwrap();
    let entropy = mnemonic.to_entropy_array().0;
    let entropy_32: [u8; 32] = entropy[0..32].try_into().unwrap();
    let password = StaticSecret::from(entropy_32);
    password
}

#[no_mangle]
pub unsafe extern "C" fn backup_get(
    seed_words: *const c_char,
    server_url: *const c_char,
    proxy_port: i32,
) -> BackupPayload {
    let seed_words = CStr::from_ptr(seed_words).to_str().unwrap();
    let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes());

    let password = get_static_secret(seed_words);

    let server_url = CStr::from_ptr(server_url).to_str().unwrap();

    let rt = RUNTIME.as_ref().unwrap();

    let response =
        rt.block_on(async move { get_backup_async(server_url, proxy_port, hash.to_hex()).await });

    let data = decrypt_backup(response.backup.into(), password);

    let mut ret = vec![];
    for (k, v) in data.iter() {
        ret.push(k.as_ptr() as *const c_char);
        ret.push(v.as_ptr() as *const c_char);
    }

    // TODO: std::mem::forget here?
    BackupPayload {
        keys_nr: data.len() as u8,
        data: ret.as_ptr(),
    }
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

fn decrypt_backup(data: Vec<u8>, secret: StaticSecret) -> Vec<(String, String)> {
    // Specify the key for the Reader
    let mut config = ArchiveReaderConfig::new();
    config.add_private_keys(&[secret]);

    // Read from buf, which needs Read + Seek
    let buf = io::Cursor::new(data);

    let mut mla_read = ArchiveReader::from_config(buf, config).unwrap();
    let files: Vec<String> = mla_read.list_files().unwrap().cloned().collect();

    files
        .iter()
        .map(|name| {
            let mut file = mla_read.get_file(name.clone()).unwrap().unwrap().data;
            let mut content = String::new();

            file.read_to_string(&mut content).unwrap();

            println!("{content}");

            (name.to_owned(), content)
        })
        .collect()
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

async fn get_challenge_async(server_url: &str, proxy_port: i32) -> ChallengeResponse {
    let client = get_reqwest_client(proxy_port);
    let response = client
        .get(server_url.to_owned() + "/backup/challenge")
        .send()
        .await
        .unwrap();

    response.json().await.unwrap()
}

async fn post_backup_async(
    server_url: &str,
    proxy_port: i32,
    server_response: ChallengeResponse,
    solution: effort::Solution,
    hash: String,
    payload: Vec<u8>,
) {
    let client = get_reqwest_client(proxy_port);
    let response = client
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
        .unwrap();

    println!("{response:?}");
}

async fn get_backup_async(server_url: &str, proxy_port: i32, hash: String) -> GetBackupResponse {
    let client = get_reqwest_client(proxy_port);
    let response = client
        .get(server_url.to_owned() + "/backup?key=" + &*hash)
        .send()
        .await
        .unwrap();

    response.json().await.unwrap()
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
    use tokio::runtime::Runtime;
    use tokio::sync::broadcast::{Receiver, Sender};

    #[tokio::test]
    async fn test_get_and_solve_challenge() {
        let server_url = "https://envoy.staging.foundationdevices.dev";
        let challenge = get_challenge_async(server_url, -1).await;
        let (tx, mut rx): (Sender<u128>, Receiver<u128>) = tokio::sync::broadcast::channel(4);

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
    fn test_get_challenge() {
        get_challenge("https://envoy.staging.foundationdevices.dev", -1);
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

        assert_eq!(decrypted, [("hello".to_owned(), "there".to_owned())]);
    }
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn backup_hello() {
    println!("HELLO THERE");
}
