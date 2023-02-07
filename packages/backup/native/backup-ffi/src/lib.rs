// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

extern crate core;

#[macro_use]
extern crate log;

use std::ffi::{CStr, CString};
use std::io;
use std::io::Read;
use std::os::raw::c_char;
use serde::{Deserialize, Serialize};

// TODO: Some other way to do this?
use curve25519_parser::{parse_openssl_25519_pubkey, StaticSecret};
use curve25519_parser::parse_openssl_25519_privkey;

use mla::config::ArchiveWriterConfig;
use mla::ArchiveWriter;

use mla::config::ArchiveReaderConfig;
use mla::ArchiveReader;

use bdk::keys::bip39::Mnemonic;

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
    let seed_words = CStr::from_ptr(seed_words).to_str().unwrap();

    // Compress files
    let mnemonic = Mnemonic::parse(seed_words).unwrap();
    let entropy = mnemonic.to_entropy_array().0;
    let entropy_32: [u8; 32] = entropy[0..32].try_into().unwrap();
    let password = StaticSecret::from(entropy_32);


    // Ask for challenge


    // Push solution + file
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
            mla.add_file(name, data.len() as u64, data.as_bytes()).unwrap();
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

/*    // Get a file
    let mut file = mla_read
        .get_file("simple".to_string())
        .unwrap() // An error can be raised (I/O, decryption, etc.)
        .unwrap(); // Option(file), as the file might not exist in the archive

    // Get back its filename, size, and data
    println!("{} ({} bytes)", file.filename, file.size);*/


    //let mut output = Vec::new();
    //std::io::copy(&mut file.data, &mut output).unwrap();

    // Get back the list of files in the archive:
    // for fname in mla_read.list_files().unwrap() {
    //     println!("{}", fname);
    // }


    let files: Vec<String> = mla_read.list_files().unwrap().cloned().collect();

    //let mut file = mla_read.get_file("what".to_string()).unwrap().unwrap().data;


    files.iter().map(|name|{
        let mut file = mla_read.get_file(name.clone()).unwrap().unwrap().data;
        let mut content = String::new();

        file.read_to_string(&mut content).unwrap();

        println!("{content}");

        (name.to_owned(), content)
    }).collect()

    //vec![("".to_owned(), "".to_owned())]


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
        let mnemonic = Mnemonic::parse("copper december enlist body dove discover cross help evidence fall rich clean").unwrap();
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


