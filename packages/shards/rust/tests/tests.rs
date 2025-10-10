// SPDX-FileCopyrightText: 2025 Foundation Devices Inc
//
// SPDX-License-Identifier: GPL-3.0-or-later

use rust_lib_shards::api::shard::ShardBackUp;
use std::fs;

#[test]
fn test_shard_backup_encode_decode() {
    let backup = ShardBackUp::new(
        [
            0x41, 0x42, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43,
            0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43, 0x43,
            0x43, 0x43, 0x43, 0x43,
        ],
        vec![0xDE, 0xAD, 0xBE, 0xEF],
    );

    // Test encoding
    let encoded = backup.to_bytes().expect("Failed to encode");
    assert!(!encoded.is_empty());

    // Test decoding
    let decoded = ShardBackUp::from_bytes(&encoded).expect("Failed to decode");

    assert_eq!(decoded.fingerprint, backup.fingerprint);
    assert_eq!(decoded.timestamp, backup.timestamp);
    assert_eq!(decoded.shard, backup.shard);
}

#[test]
fn test_adding_shard() {
    let file_path = "serializing_test.cbor";

    let original_shard_data = vec![
        0x82, 0x0, 0x85, 0x58, 0x20, 0x4a, 0xcb, 0x4e, 0x8f, 0xb4, 0x3, 0xef, 0x3, 0xab, 0x86,
        0x72, 0x7a, 0x22, 0x19, 0xc8, 0x88, 0x57, 0xf9, 0x1d, 0x52, 0xa7, 0x7b, 0xf2, 0x64, 0xb4,
        0xb3, 0x67, 0x3e, 0xed, 0xbe, 0x74, 0xff, 0x58, 0x20, 0xe7, 0x6d, 0xd0, 0xcc, 0xc9, 0x6f,
        0x4e, 0xd5, 0x6c, 0x25, 0x86, 0xd, 0x59, 0x30, 0x85, 0x40, 0xd5, 0x69, 0xed, 0x8f, 0x2b,
        0x6a, 0x78, 0x9a, 0x17, 0xbc, 0x67, 0x7b, 0xc3, 0x63, 0xd2, 0x14, 0x90, 0x18, 0x52, 0x18,
        0xde, 0x18, 0xe1, 0x18, 0x8d, 0x18, 0xf9, 0x18, 0xcd, 0x18, 0x5b, 0x18, 0xe9, 0x18, 0x59,
        0x18, 0xdc, 0x18, 0xf2, 0x15, 0x18, 0x18, 0x18, 0x3d, 0x18, 0x19, 0x18, 0x9f, 0x2, 0xf5,
        0x58, 0x20, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
        0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
    ];

    // Add the shard
    let add_result = ShardBackUp::add_new_shard(original_shard_data.clone(), file_path.to_string());

    assert!(add_result.is_ok(), "Failed to add shard: {:?}", add_result);

    // Read back and verify
    let retrieved_shards: Vec<ShardBackUp> = ShardBackUp::get_all_shards(file_path.to_string());

    // Should have exactly one shard
    assert_eq!(
        retrieved_shards.len(),
        1,
        "Expected exactly one shard in file"
    );

    let retrieved_shard = &retrieved_shards[0];

    // Verify all fields match exactly
    assert_eq!(
        retrieved_shard.shard, original_shard_data,
        "Shard data mismatch"
    );
    assert!(retrieved_shard.timestamp > 0, "Timestamp should be set");

    // Cleanup
    let _ = fs::remove_file(file_path);
}

#[test]
#[ignore] // TODO: figure this one out
fn add_multiple_shards() {
    let file_path = "multiple_test.cbor";

    for index in 0..5 {
        // Add the shard
        let add_result =
            ShardBackUp::add_new_shard(index.to_string().into_bytes(), file_path.to_string());
        assert!(add_result.is_ok(), "Failed to add shard: {:?}", add_result);
    }

    // Read back and verify
    let retrieved_shards: Vec<ShardBackUp> = ShardBackUp::get_all_shards(file_path.to_string());

    assert_eq!(
        retrieved_shards.len(),
        5,
        "Expected exactly 5 shard in file"
    );

    // Verify all fields match exactly
    for (index, shard) in retrieved_shards.iter().enumerate() {
        assert_eq!(
            shard.shard,
            index.to_string().into_bytes(),
            "Shard data mismatch for index {}",
            index
        );
        assert!(shard.timestamp > 0, "Timestamp should be set");
    }

    // Cleanup
    let _ = fs::remove_file(file_path);
}
