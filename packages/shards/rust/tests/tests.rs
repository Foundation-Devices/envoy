use shards::api::shard::ShardBackUp;
use std::fs;

#[test]
fn test_shard_backup_encode_decode() {
    let backup = ShardBackUp::new(
        "test_device".to_string(),
        "test_shard".to_string(),
        vec![0x41, 0x42, 0x43],
    );

    // Test encoding
    let encoded = backup.to_bytes().expect("Failed to encode");
    assert!(!encoded.is_empty());

    // Test decoding
    let decoded = ShardBackUp::from_bytes(&encoded).expect("Failed to decode");

    assert_eq!(decoded.device_serial, backup.device_serial);
    assert_eq!(decoded.shard_identifier, backup.shard_identifier);
    assert_eq!(decoded.timestamp, backup.timestamp);
    assert_eq!(decoded.shard, backup.shard);
}

#[test]
fn test_adding_shard() {
    let file_path = "serializing_test.cbor";

    // Test data
    let original_device_serial = "my_test_device_12345".to_string();
    let original_shard_identifier = "unique_shard_abc123".to_string();
    let original_shard_data = vec![0xDE, 0xAD, 0xBE, 0xEF, 0x01, 0x02, 0x03];

    // Add the shard
    let add_result = ShardBackUp::add_new_shard(
        original_shard_data.clone(),
        &original_shard_identifier,
        &original_device_serial.clone(),
        file_path.to_string(),
    );

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
        retrieved_shard.device_serial, original_device_serial,
        "Device serial mismatch"
    );
    assert_eq!(
        retrieved_shard.shard_identifier, original_shard_identifier,
        "Shard identifier mismatch"
    );
    assert_eq!(
        retrieved_shard.shard, original_shard_data,
        "Shard data mismatch"
    );
    assert!(retrieved_shard.timestamp > 0, "Timestamp should be set");

    // Cleanup
    let _ = fs::remove_file(file_path);
}

#[test]
fn add_multiple_shards() {
    let file_path = "multiple_test.cbor";

    // Test data
    let original_device_serial = "prim_123".to_string();
    let original_shard_identifier = "unique_shard_abc123".to_string();

    for index in 0..5 {
        // Add the shard
        let add_result = ShardBackUp::add_new_shard(
            index.to_string().into_bytes(),
            &format!("{}-{}", original_shard_identifier, index),
            &original_device_serial,
            file_path.to_string(),
        );
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
            shard.device_serial, original_device_serial,
            "Device serial mismatch"
        );
        assert_eq!(
            shard.shard_identifier,
            format!("{}-{}", original_shard_identifier, index),
            "Shard identifier mismatch"
        );
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
