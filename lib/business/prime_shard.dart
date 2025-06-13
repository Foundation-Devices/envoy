// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/services.dart';
import 'package:shards/shards.dart';

const String LAST_BACKUP_PREFS = "last_backup_prime";
const String PRIME_SECRET = "prime.secret";
const String PRIME_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME =
    "$PRIME_SECRET.backup_timestamp";

const int SECRET_LENGTH_BYTES = 16;

class PrimeShard {
  static final PrimeShard _instance = PrimeShard._internal();
  static const _platform = MethodChannel('envoy');

  static Future<void> init() async {
    try {
      await RustLib.init();
    } catch (e) {
      EnvoyReport().log("PrimeShard", "Error initializing ShardsLib: $e");
    }
  }

  factory PrimeShard() {
    return _instance;
  }

  getPrimeSecretPath() {
    return "${LocalStorage().appSupportDir.path}/$PRIME_SECRET";
  }

  PrimeShard._internal() {
    kPrint("Instance of PrimeShard created!");
  }

  //TODO: use secure storage too ?
  Future<List<ShardBackUp>> getAllShards() async {
    return ShardBackUp.getAllShards(
      filePath: getPrimeSecretPath(),
    );
  }

  //TODO: use secure storage too ?
  Future addShard({
    required List<int> shard,
    required String shardIdentifier,
    required String deviceSerial,
  }) async {
    await ShardBackUp.addNewShard(
      deviceSerial: deviceSerial,
      shardIdentifier: shardIdentifier,
      shard: shard,
      filePath: getPrimeSecretPath(),
    );
    if (!Platform.isLinux) {
      _platform.invokeMethod('data_changed');
    }
  }

  // Future<String?> _restoreNonSecure(String name) async {
  //   if (!await LocalStorage().fileExists(name)) {
  //     return null;
  //   }
  //   return await LocalStorage().readFile(name);
  // }

  showSettingsMenu() {
    _platform.invokeMethod('show_settings');
  }

  // Future<String?> _getNonSecure() async {
  //   return await _restoreNonSecure(PRIME_SECRET);
  // }

  Future<DateTime?> getNonSecureLastBackupTimestamp() async {
    if (!await LocalStorage()
        .fileExists(PRIME_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME)) {
      return null;
    }

    String timestampString = await LocalStorage()
        .readFile(PRIME_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME);
    int timestamp =
        int.parse(timestampString.replaceAll(".", "").substring(0, 13));
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}
