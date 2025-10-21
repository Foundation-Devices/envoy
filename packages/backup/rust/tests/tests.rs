// SPDX-FileCopyrightText: 2025 Foundation Devices Inc
//
// SPDX-License-Identifier: GPL-3.0-or-later
use bdk::bitcoin;
use bdk::bitcoin::hashes::Hash;
use bdk::keys::bip39::Mnemonic;
use curve25519_parser::StaticSecret;
use rust_lib_backup::api::backup::Backup;
use std::fs::File;
use std::io::Read;
use std::path::PathBuf;
use tokio::sync::broadcast::{Receiver, Sender};

#[tokio::test]
async fn test_get_and_solve_challenge() {
    let server_url = "https://envoy-new.foundation.xyz";
    let challenge = Backup::get_challenge_async(server_url, -1).await.unwrap();
    let (tx, _rx): (Sender<u128>, Receiver<u128>) = tokio::sync::broadcast::channel(4);

    let solution = effort::solve_challenge(&challenge.challenge, &tx).await;

    Backup::post_backup_async(
        server_url,
        -1,
        challenge,
        solution,
        "hey".to_owned(),
        vec![0, 1, 2],
    )
    .await
    .unwrap();
}

#[test]
fn test_compress_backup() {
    let mnemonic = Mnemonic::parse(
        "copper december enlist body dove discover cross help evidence fall rich clean",
    )
    .unwrap();
    let entropy = mnemonic.to_entropy_array().0;
    let entropy_32: [u8; 32] = entropy[0..32].try_into().unwrap();

    let encrypted = Backup::encrypt_backup(
        vec![("hello".to_owned(), "there".to_owned())],
        &StaticSecret::from(entropy_32),
    );
    let decrypted = Backup::decrypt_backup(encrypted, StaticSecret::from(entropy_32));

    assert_eq!(
        decrypted.unwrap(),
        [("hello".to_owned(), "there".to_owned())]
    );
}

#[test]
fn test_create_hash_from_seed() {
    let seed_words =
        "copper december enlist body dove discover cross help evidence fall rich clean";
    let hash = bitcoin::hashes::sha256::Hash::hash(seed_words.as_bytes())
        .to_string()
        .to_owned();

    assert_eq!(
        hash,
        "fbf05d44bf48541e2fb0ab36e86611d1236368ec3a223135c2aeb2c9bd2fa66a"
    );
}

#[test]
fn test_decrypt_backup() {
    let mnemonic = Mnemonic::parse(
        "typical old announce muscle lazy enhance exotic assist rotate install skull rely",
    )
    .unwrap();
    let entropy = mnemonic.to_entropy_array().0;
    let entropy_32: [u8; 32] = entropy[0..32].try_into().unwrap();

    let mut path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    path.push("resources/test/backup.mla");

    // Open the file
    let mut file = match File::open(&path) {
        Err(why) => panic!("couldn't open {}: {}", path.display(), why),
        Ok(file) => file,
    };

    // Read the file contents into a string
    let mut contents = vec![];
    match file.read_to_end(&mut contents) {
        Err(why) => panic!("couldn't read {}: {}", path.display(), why),
        Ok(_) => {}
    }

    let decrypted = Backup::decrypt_backup(contents, StaticSecret::from(entropy_32));

    println!("{:?}", decrypted.unwrap());
}
