// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'package:backup/backup.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/services.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:file_saver/file_saver.dart';

const String SEED_KEY = "seed";
const String WALLET_DERIVED_PREFS = "wallet_derived";
const String LAST_BACKUP_PREFS = "last_backup";
const String LOCAL_SECRET_FILE_NAME = "local.secret";
const String LOCAL_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME =
    LOCAL_SECRET_FILE_NAME + ".backup_timestamp";

const int SECRET_LENGTH_BYTES = 16;

class EnvoySeed {
  // 12 words == 128 + 4 == 132 (4 bits are checksum)
  // 128 bits == 16 bytes
  // Checksum is first 4 bits of SHA-256 of 16 bytes

  static const _platform = MethodChannel('envoy');

  static String encryptedBackupFileExtension = "mla";
  static String encryptedBackupFileName = "envoy_backup";
  static String encryptedBackupFilePath = LocalStorage().appDocumentsDir.path +
      "/" +
      encryptedBackupFileName +
      "." +
      encryptedBackupFileExtension;

  static String HOT_WALLET_MAINNET_PATH = "m/84'/0'/0'";
  static String HOT_WALLET_TESTNET_PATH = "m/84'/1'/0'";

  List<String> preferencesKeysToBackUp = [
    Settings.SETTINGS_PREFS,
    AccountManager.ACCOUNTS_PREFS,
    Devices.DEVICES_PREFS,
    // Notifications.NOTIFICATIONS_PREFS,
    // UpdatesManager.LATEST_FIRMWARE_FILE_PATH_PREFS,
    // UpdatesManager.LATEST_FIRMWARE_VERSION_PREFS,
    // ScvServer.SCV_CHALLENGE_PREFS,
    // Fees.FEE_RATE_PREFS,
  ];

  Future generate() async {
    final generatedSeed = Wallet.generateSeed();
    return await deriveAndAddWallets(generatedSeed);
  }

  Future<bool> create(List<String> seedList, {String? passphrase}) async {
    String seed = seedList.join(" ");
    return await deriveAndAddWallets(seed, passphrase: passphrase);
  }

  Future<bool> deriveAndAddWallets(String seed, {String? passphrase}) async {
    if (AccountManager()
        .checkIfWalletFromSeedExists(seed, passphrase: passphrase)) {
      return true;
    }

    await store(seed);

    try {
      var mainnet = Wallet.deriveWallet(seed, HOT_WALLET_MAINNET_PATH,
          AccountManager.walletsDirectory, Network.Mainnet,
          privateKey: true, passphrase: passphrase);
      var testnet = Wallet.deriveWallet(seed, HOT_WALLET_TESTNET_PATH,
          AccountManager.walletsDirectory, Network.Testnet,
          privateKey: true, passphrase: passphrase);

      AccountManager().addHotWalletAccount(mainnet);
      AccountManager().addHotWalletAccount(testnet);

      LocalStorage().prefs.setBool(WALLET_DERIVED_PREFS, true);

      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  bool walletDerived() {
    final derived = LocalStorage().prefs.getBool(WALLET_DERIVED_PREFS);
    if (derived == null) {
      return false;
    }

    return derived;
  }

  Future<void> store(String seed) async {
    if (Settings().syncToCloud) {
      await _saveNonSecure(seed, LOCAL_SECRET_FILE_NAME);
      if (!Platform.isLinux) {
        _platform.invokeMethod('data_changed');
      }
    }

    await LocalStorage().saveSecure(SEED_KEY, seed);
  }

  Future<void> backupData({bool cloud = true}) async {
    // Make sure we don't accidentally backup to Cloud
    if (Settings().syncToCloud == false) {
      cloud = false;
    }

    final seed = await get();
    if (seed == null) {
      return;
    }

    Map<String, String> backupData = {};
    for (var key in preferencesKeysToBackUp) {
      if (LocalStorage().prefs.containsKey(key)) {
        backupData[key] = LocalStorage().prefs.getString(key)!;
      }
    }

    // Add sembast DB
    backupData[EnvoyStorage().dbName] = await EnvoyStorage().export();

    // Strip keys from hot wallets
    if (backupData.containsKey(AccountManager.ACCOUNTS_PREFS)) {
      var json = jsonDecode(backupData[AccountManager.ACCOUNTS_PREFS]!);

      for (var account in json) {
        Wallet wallet = Wallet.fromJson(account["wallet"]);

        if (wallet.hot) {
          wallet.externalDescriptor = null;
          wallet.internalDescriptor = null;
          wallet.publicExternalDescriptor = null;
          wallet.publicInternalDescriptor = null;
        }

        account["wallet"] = wallet.toJson();
      }

      backupData[AccountManager.ACCOUNTS_PREFS] = jsonEncode(json);
    }

    return Backup.perform(
            backupData, seed, Settings().envoyServerAddress, Tor(),
            path: encryptedBackupFilePath, cloud: cloud)
        .then((success) {
      if (cloud && success) {
        LocalStorage()
            .prefs
            .setString(LAST_BACKUP_PREFS, DateTime.now().toIso8601String());
      }
    });
  }

  Future<bool> delete() async {
    final seed = await get();

    AccountManager().deleteHotWalletAccounts();
    LocalStorage().prefs.setBool(WALLET_DERIVED_PREFS, false);
    Settings().syncToCloud = false;

    removeSeedFromNonSecure();
    removeSeedFromSecure();

    return Backup.delete(seed!, Settings().envoyServerAddress, Tor());
  }

  Future<bool> restoreData({String? seed = null, String? filePath}) async {
    // Try to get seed from device
    try {
      if (seed == null) {
        seed = await get();
        if (seed == null) {
          throw SeedNotFound();
        }
      }
    } catch (e) {
      throw SeedNotFound();
    }

    if (filePath == null) {
      try {
        return Backup.restore(seed, Settings().envoyServerAddress, Tor())
            .then((data) {
          return _processRecoveryData(seed!, data);
        });
      } catch (e) {
        throw e;
      }
    } else {
      try {
        var data = Backup.restoreOffline(seed, filePath);
        return _processRecoveryData(seed, data);
      } on Exception catch (ex) {
        throw ex;
      }
    }
  }

  bool _processRecoveryData(String seed, Map<String, String>? data) {
    bool success = data != null;
    if (success) {
      if (data.containsKey(AccountManager.ACCOUNTS_PREFS)) {
        var json = jsonDecode(data[AccountManager.ACCOUNTS_PREFS]!);

        for (var account in json) {
          Wallet wallet = Wallet.fromJson(account["wallet"]);
          if (wallet.hot) {
            var derived = Wallet.deriveWallet(
                seed,
                wallet.network == Network.Mainnet
                    ? HOT_WALLET_MAINNET_PATH
                    : HOT_WALLET_TESTNET_PATH,
                AccountManager.walletsDirectory,
                wallet.network,
                privateKey: true,
                passphrase: null,
                initWallet: false);

            wallet.internalDescriptor = derived.internalDescriptor;
            wallet.externalDescriptor = derived.externalDescriptor;
            wallet.publicInternalDescriptor = derived.publicInternalDescriptor;
            wallet.publicExternalDescriptor = derived.publicExternalDescriptor;

            account["wallet"] = wallet.toJson();
          }
        }

        data[AccountManager.ACCOUNTS_PREFS] = jsonEncode(json);
      }

      data.forEach((key, value) {
        LocalStorage().prefs.setString(key, value);
      });

      // Restore the database
      if (data.containsKey(EnvoyStorage().dbName)) {
        EnvoyStorage().restore(data[EnvoyStorage().dbName]!);
      }

      _restoreSingletons();
    }
    return success;
  }

  _restoreSingletons() {
    LocalStorage().prefs.setBool(WALLET_DERIVED_PREFS, true);

    Settings.restore();
    Devices().restore();
    AccountManager().restore();
  }

  DateTime? getLastBackupTime() {
    final string = LocalStorage().prefs.getString(LAST_BACKUP_PREFS);
    if (string == null) {
      return null;
    }

    return DateTime.parse(string);
  }

  Future<void> saveOfflineData() async {
    await backupData(cloud: false);
    final backupBytes = File(encryptedBackupFilePath).readAsBytesSync();

    try {
      FileSaver.instance.saveAs(encryptedBackupFileName, backupBytes,
          encryptedBackupFileExtension, MimeType.TEXT);
    } catch (e) {
      print(e);
    }
  }

  Future<String?> get() async {
    String? secure = await _getSecure();
    String? nonSecure = await _getNonSecure();

    if (secure != null && nonSecure != null) {
      return secure;

      // TODO: show a warning to user
      // If we're syncing then the two being different is something to be handled
      // if (secure != nonSecure) {
      //   throw Exception("Different seed in secure and non-secure!");
      // }
    }

    if (secure != null) {
      return secure;
    }

    if (nonSecure != null) {
      return nonSecure;
    }

    return null;
  }

  Wallet? getWallet() {
    return AccountManager().getHotWalletAccount(testnet: false)?.wallet;
  }

  Future<String?> _getSecure() async {
    if (!await LocalStorage().containsSecure(SEED_KEY)) {
      return null;
    }

    final seed = await LocalStorage().readSecure(SEED_KEY);
    return seed!;
  }

  Future<File> _saveNonSecure(String data, String name) async {
    return LocalStorage().saveFile(name, data);
  }

  Future<String?> _restoreNonSecure(String name) async {
    if (!await LocalStorage().fileExists(name)) {
      return null;
    }

    return await LocalStorage().readFile(name);
  }

  showSettingsMenu() {
    _platform.invokeMethod('show_settings');
  }

  // When manual user decides to enable Auto-Backup
  copySeedToNonSecure() {
    _getSecure().then((seed) {
      store(seed!);
    });
  }

  removeSeedFromNonSecure() {
    LocalStorage().deleteFile(LOCAL_SECRET_FILE_NAME);
  }

  removeSeedFromSecure() {
    LocalStorage().deleteSecure(SEED_KEY);
  }

  Future<String?> _getNonSecure() async {
    return await _restoreNonSecure(LOCAL_SECRET_FILE_NAME);
  }

  Future<DateTime?> getNonSecureLastBackupTimestamp() async {
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
