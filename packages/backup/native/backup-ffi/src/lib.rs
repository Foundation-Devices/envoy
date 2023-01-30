// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

extern crate core;

use std::ffi::CString;
use std::io;
use std::os::raw::c_char;
use serde::{Deserialize, Serialize};

// TODO: Some other way to do this?
use curve25519_parser::parse_openssl_25519_pubkey;
use curve25519_parser::parse_openssl_25519_privkey;

use mla::config::ArchiveWriterConfig;
use mla::ArchiveWriter;

use mla::config::ArchiveReaderConfig;
use mla::ArchiveReader;

use std::cell::RefCell;
use std::error::Error;

use bdk::keys::bip39::{Language, Mnemonic};



thread_local! {
    static LAST_ERROR: RefCell<Option<Box<dyn Error>>> = RefCell::new(None);
}

/// Update the most recent error, clearing whatever may have been there before.
pub fn update_last_error<E: Error + 'static>(err: E) {
    error!("Setting LAST_ERROR: {}", err);

    {
        // Print a pseudo-backtrace for this error, following back each error's
        // cause until we reach the root error.
        let mut cause = err.source();
        while let Some(parent_err) = cause {
            warn!("Caused by: {}", parent_err);
            cause = parent_err.source();
        }
    }

    LAST_ERROR.with(|prev| {
        *prev.borrow_mut() = Some(Box::new(err));
    });
}

/// Retrieve the most recent error, clearing it in the process.
pub fn take_last_error() -> Option<Box<dyn Error>> {
    LAST_ERROR.with(|prev| prev.borrow_mut().take())
}

#[no_mangle]
pub unsafe extern "C" fn backup_last_error_message() -> *const c_char {
    let last_error = match take_last_error() {
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
                update_last_error(e);
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

#[no_mangle]
pub unsafe extern "C" fn backup_perform(files_nr: u8,
                                        files: *const *const c_char,
                                        seed_words: *const c_char,
                                        server_url: *const c_char,
                                        proxy_port: i32,
) {
    // Compress files
    let mnemonic = Mnemonic::parse(seed_words).unwrap();


    // Ask for challenge


    // Push solution + file
}

fn encrypt_backup(files: Vec<(&str, &str)>, password: &str) -> Vec<u8> {

    // TODO: convert seed to pubkey
    let public_key = parse_openssl_25519_pubkey(password.as_ref()).unwrap();

    // Create an MLA Archive - Output only needs the Write trait
    let mut buf = Vec::new();
    // Default is Compression + Encryption, to avoid mistakes
    let mut config = ArchiveWriterConfig::default();
    // The use of multiple public keys is supported
    config.add_public_keys(&vec![public_key]);
    {
        // Create the Writer

        let mut mla = ArchiveWriter::from_config(&mut buf, config).unwrap();

        // Add a file
        for (name, data) in files {
            mla.add_file(name, 4, data.as_bytes()).unwrap();
        }

        // Complete the archive
        mla.finalize().unwrap();
    }

    buf
}

fn decrypt_backup(data: Vec<u8>, password: &str) -> Vec<(&str, &str)> {
    // Get the private key
    let private_key = parse_openssl_25519_privkey(password.as_ref()).unwrap();

    // Specify the key for the Reader
    let mut config = ArchiveReaderConfig::new();
    config.add_private_keys(&[private_key]);

    // Read from buf, which needs Read + Seek
    let buf = io::Cursor::new(data);

    let mut mla_read = ArchiveReader::from_config(buf, config).unwrap();

    // Get a file
    let mut file = mla_read
        .get_file("simple".to_string())
        .unwrap() // An error can be raised (I/O, decryption, etc.)
        .unwrap(); // Option(file), as the file might not exist in the archive

    // Get back its filename, size, and data
    println!("{} ({} bytes)", file.filename, file.size);
    //let mut output = Vec::new();
    //std::io::copy(&mut file.data, &mut output).unwrap();

    // Get back the list of files in the archive:
    // for fname in mla_read.list_files().unwrap() {
    //     println!("{}", fname);
    // }

    vec![("", "")]


}

fn get_challenge(server_url: &str, proxy_port: i32) -> ChallengeResponse {
    let client = if proxy_port > 0 {
        let proxy =
            reqwest::Proxy::all("socks5://127.0.0.1:".to_owned() + &proxy_port.to_string()).unwrap();
        reqwest::blocking::Client::builder().proxy(proxy).build().unwrap()
    } else {
        reqwest::blocking::Client::builder().build().unwrap()
    };

    let response = client.get(server_url.to_owned() + "/backup/challenge").send().unwrap();

    response.json().unwrap()
}


async fn get_challenge_async(server_url: &str, proxy_port: i32) -> ChallengeResponse {
    let client = get_reqwest_client(proxy_port);
    let response = client.get(server_url.to_owned() + "/backup/challenge").send().await.unwrap();

    response.json().await.unwrap()
}

async fn post_backup_async(server_url: &str, proxy_port: i32, server_response: ChallengeResponse, solution: effort::Solution, password_hash: &str, payload: Vec<u8>) {
    let client = get_reqwest_client(proxy_port);
    let response = client.post(server_url.to_owned() + "/backup").json(&BackupRequest {
        challenge: server_response.challenge,
        solution,
        timestamp: server_response.timestamp,
        signature: server_response.signature,
        hash: password_hash.parse().unwrap(),
        backup: "hello world".to_string(),
    }).send().await.unwrap();

    let number = 4;

    println!("{response:?}");
}

fn get_reqwest_client(proxy_port: i32) -> reqwest::Client {
    if proxy_port > 0 {
        let proxy =
            reqwest::Proxy::all("socks5://127.0.0.1:".to_owned() + &proxy_port.to_string()).unwrap();
        reqwest::Client::builder().proxy(proxy).build().unwrap()
    } else {
        reqwest::Client::builder().build().unwrap()
    }
}

#[cfg(test)]
mod tests {
    use tokio::runtime::Runtime;
    use tokio::sync::broadcast::{Receiver, Sender};
    use super::*;

    #[tokio::test]
    async fn test_get_and_solve_challenge() {
        let server_url = "https://envoy.staging.foundationdevices.dev";
        let challenge = get_challenge_async(server_url, -1).await;
        let (tx, mut rx): (Sender<u128>, Receiver<u128>) =
            tokio::sync::broadcast::channel(4);

        let solution = effort::solve_challenge(&challenge.challenge, &tx).await;

        post_backup_async(server_url, -1, challenge, solution, "hey", vec![0, 1, 2]).await;
    }

    #[test]
    fn test_get_challenge() {
        get_challenge("https://envoy.staging.foundationdevices.dev", -1);
    }

    #[test]
    fn test_compress_backup() {
        let encrypted = encrypt_backup(vec![("hello", "there")], "password");

        let decrypted = decrypt_backup(encrypted, "password");


        assert_eq!(decrypted, [("hello", "there")]);

    }
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn backup_hello() {
    println!("HELLO THERE");
}


