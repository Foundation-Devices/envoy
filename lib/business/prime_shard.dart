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
import 'package:collection/collection.dart';

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

  String getPrimeSecretPath() {
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

  Future<ShardBackUp?> getShard({required Uint8List fingerprint}) async {
    final shards = await getAllShards();
    return shards.firstWhereOrNull((shard) {
      kPrint("looking for: $fingerprint");
      kPrint("got: ${Uint8List.fromList(shard.fingerprint)}");

      return ListEquality()
          .equals(Uint8List.fromList(shard.fingerprint), fingerprint);
    });
  }

  Future addShard({
    required List<int> shard,
  }) async {
    await ShardBackUp.addNewShard(
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
