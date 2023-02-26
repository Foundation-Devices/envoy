// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'dart:io';
import 'package:backup/backup.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:flutter/services.dart';
import 'package:tor/tor.dart';

import 'package:wallet/wallet.dart';

import 'devices.dart';
import 'fees.dart';
import 'local_storage.dart';
import 'notifications.dart';

const String SEED_KEY = "seed";
const String LOCAL_SECRET_FILE_NAME = "local.secret";
const String LOCAL_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME =
    LOCAL_SECRET_FILE_NAME + ".backup_timestamp";

const int SECRET_LENGTH_BYTES = 16;

class EnvoySeed {
  // 12 words == 128 + 4 == 132 (4 bits are checksum)
  // 128 bits == 16 bytes
  // Checksum is first 4 bits of SHA-256 of 16 bytes

  static const _platform = MethodChannel('envoy');
  static String encryptedBackupFilePath =
      LocalStorage().appDocumentsDir.path + "/envoy_backup.mla";

  Future generate() async {
    final generatedSeed = Wallet.generateSeed(true);
    return await deriveAndAddWallets(generatedSeed);
  }

  Future<bool> create(List<String> seedList, {String? passphrase}) async {
    String seed = seedList.join(" ");
    return await deriveAndAddWallets(seed, passphrase: passphrase);
  }

  Future<bool> deriveAndAddWallets(String seed, {String? passphrase}) async {
    final path = "m/84'/0'/0'";

    try {
      var mainnet = Wallet.deriveWallet(
          seed, path, AccountManager.walletsDirectory, Network.Mainnet,
          privateKey: true, passphrase: passphrase);
      var testnet = Wallet.deriveWallet(
          seed, path, AccountManager.walletsDirectory, Network.Testnet,
          privateKey: true, passphrase: passphrase);

      AccountManager().addHotWalletAccount(mainnet);
      AccountManager().addHotWalletAccount(testnet);

      await store(seed);
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<void> store(String seed) async {
    await saveNonSecure(seed, LOCAL_SECRET_FILE_NAME);
    _platform.invokeMethod('data_changed');
    await LocalStorage().saveSecure(SEED_KEY, seed);
  }

  void backupData({bool offline: false}) {
    List<String> keysToBackUp = [
      Settings.SETTINGS_PREFS,
      // UpdatesManager.LATEST_FIRMWARE_FILE_PATH_PREFS,
      // UpdatesManager.LATEST_FIRMWARE_VERSION_PREFS,
      // ScvServer.SCV_CHALLENGE_PREFS,
      Fees.FEE_RATE_PREFS,
      AccountManager.ACCOUNTS_PREFS,
      Notifications.NOTIFICATIONS_PREFS,
      Devices.DEVICES_PREFS,
    ];

    Backup.perform(
        LocalStorage().prefs,
        keysToBackUp,
        "copper december enlist body dove discover cross help evidence fall rich clean",
        Settings().envoyServerAddress,
        Tor().port,
        path: offline ? encryptedBackupFilePath : null);
  }

  void saveOfflineData() {
    var argsMap = <String, dynamic>{
      "from": encryptedBackupFilePath,
      "path": ""
    };
    _platform.invokeMethod('save_file', argsMap);
  }

  Future<String?> get() async {
    String? secure = await getSecure();
    String? nonSecure = await getNonSecure();

    if (secure != null && nonSecure != null) {
      if (secure != nonSecure) {
        throw Exception("Different seed in secure and non-secure!");
      }

      return secure;
    }

    if (secure != null) {
      return secure;
    }

    if (nonSecure != null) {
      return nonSecure;
    }

    return null;
  }

  Future<String?> getSecure() async {
    if (!await LocalStorage().containsSecure(SEED_KEY)) {
      return null;
    }

    final seed = await LocalStorage().readSecure(SEED_KEY);
    return seed!;
  }

  List<int> getRandomBytes(int len) {
    var rng = new Random.secure();
    return List.generate(len, (_) => rng.nextInt(255));
  }

  List<int> xorBytes(List<int> first, List<int> second) {
    assert(first.length == second.length);
    return List.generate(first.length, (index) => first[index] ^ second[index]);
  }

  Future<File> saveNonSecure(String data, String name) async {
    return LocalStorage().saveFile(name, data);
  }

  Future<String?> restoreNonSecure(String name) async {
    if (!await LocalStorage().fileExists(name)) {
      return null;
    }

    return await LocalStorage().readFile(name);
  }

  List<int> convertFromString(String contents) {
    // Dart doesn't do nice serialization so reverse .toString() manually
    List<String> values = contents
        .substring(1, contents.length - 1) // Get rid of enclosing []
        .replaceAll(" ", "") // Get rid of spaces
        .split(",");

    return List.generate(values.length, (index) => int.parse(values[index]));
  }

  showSettingsMenu() {
    _platform.invokeMethod('show_settings');
  }

  Future<String?> getNonSecure() async {
    return await restoreNonSecure(LOCAL_SECRET_FILE_NAME);
  }

  Future<DateTime?> getLocalSecretLastBackupTimestamp() async {
    if (!await LocalStorage()
        .fileExists(LOCAL_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME)) {
      return null;
    }

    String timestampString = await LocalStorage()
        .readFile(LOCAL_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME);
    int timestamp =
        int.parse(timestampString.replaceAll(".", "").substring(0, 13));
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}
