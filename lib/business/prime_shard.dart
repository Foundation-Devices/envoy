// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/services.dart';
import 'package:shards/shards.dart';

import 'package:envoy/util/bug_report_helper.dart';

const String LAST_BACKUP_PREFS = "last_backup_prime";
const String PRIME_SECRET = "prime.secret";
const String PRIME_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME =
    "$PRIME_SECRET.backup_timestamp";

const int SECRET_LENGTH_BYTES = 16;

class PrimeShard {
  static final PrimeShard _instance = PrimeShard._internal();
  static const _platform = MethodChannel('envoy');

  // iOS only: path to prime.secret inside the iCloud Documents container.
  // Cached once during init(); null on Android (uses appSupportDir instead).
  static String? _iosSharedPath;

  static Future<void> init() async {
    try {
      await RustLib.init();
      if (Platform.isIOS) {
        // Resolves the iCloud Documents path and migrates prime.secret
        // from previous locations if this is a first launch after upgrade.
        _iosSharedPath =
            await _platform.invokeMethod<String>('get_shard_path_icloud');
      }
    } catch (e) {
      EnvoyReport().log("PrimeShard", "Error initializing ShardsLib: $e");
    }
  }

  factory PrimeShard() {
    return _instance;
  }

  // iOS: returns the iCloud Documents path so Link can read the same file.
  // Android: returns the private appSupportDir path (Link reads via ContentProvider).
  String getPrimeSecretPath() {
    if (Platform.isIOS && _iosSharedPath != null) {
      return _iosSharedPath!;
    }
    return "${LocalStorage().appSupportDir.path}/$PRIME_SECRET";
  }

  PrimeShard._internal() {
    kPrint("Instance of PrimeShard created!");
  }

  Future<Uint8List?> getShard({
    required Uint8List fingerprint,
    int? timestamp,
  }) async {
    return ShardBackupFile.getShard(
      filePath: getPrimeSecretPath(),
      fingerprint: U8Array32(fingerprint),
      timestamp: timestamp,
    );
  }

  Future addShard({required List<int> shard}) async {
    await ShardBackupFile.addNewShard(
      shard: shard,
      filePath: getPrimeSecretPath(),
    );
    if (!Platform.isLinux) {
      _platform.invokeMethod('data_changed');
    }
  }

  void showSettingsMenu() {
    _platform.invokeMethod('show_settings');
  }

  Future<DateTime?> getNonSecureLastBackupTimestamp() async {
    if (!await LocalStorage().fileExists(
      PRIME_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME,
    )) {
      return null;
    }

    String timestampString = await LocalStorage().readFile(
      PRIME_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME,
    );
    int timestamp = int.parse(
      timestampString.replaceAll(".", "").substring(0, 13),
    );
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}
