// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
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
import 'package:envoy/ui/routes/routes.dart';

const String SEED_KEY = "seed";
const String WALLET_DERIVED_PREFS = "wallet_derived";
const String LAST_BACKUP_PREFS = "last_backup";
const String LOCAL_SECRET_FILE_NAME = "local.secret";
const String LOCAL_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME =
    LOCAL_SECRET_FILE_NAME + ".backup_timestamp";

const int SECRET_LENGTH_BYTES = 16;

class EnvoySeed {
  static final EnvoySeed _instance = EnvoySeed._internal();

  factory EnvoySeed() {
    return _instance;
  }

  static Future<EnvoySeed> init() async {
    var singleton = EnvoySeed._instance;
    return singleton;
  }

  EnvoySeed._internal() {
    print("Instance of EnvoySeed created!");
  }

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

  StreamController<bool> backupCompletedStream = StreamController.broadcast();

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

    // Add sembast DB
    backupData[EnvoyStorage.dbName] = await EnvoyStorage().export();

    if (backupData.containsKey(EnvoyStorage.dbName)) {
      backupData = processBackupData(backupData, cloud);
    }

    return Backup.perform(
            backupData, seed, Settings().envoyServerAddress, Tor.instance,
            path: encryptedBackupFilePath, cloud: cloud)
        .then((success) async {
      if (cloud && success) {
        // Only notify if we are doing an online backup
        backupCompletedStream.sink.add(true);
        await _storeLastBackupTimestamp();
      } else if (!Settings().syncToCloud && success) {
        await _storeLastBackupTimestamp();
      } else
        backupCompletedStream.sink.add(false);
    });
  }

  Future<void> _storeLastBackupTimestamp() async {
    await LocalStorage()
        .prefs
        .setString(LAST_BACKUP_PREFS, DateTime.now().toIso8601String());
  }

  Map<String, String> processBackupData(
      Map<String, String> backupData, bool isOnlineBackup) {
    var json = jsonDecode(backupData[EnvoyStorage.dbName]!) as Map;

    List<dynamic> stores = json["stores"];
    var preferences = stores
        .singleWhere((element) => element["name"] == preferencesStoreName);
    int indexOfPreferences =
        stores.indexWhere((element) => element["name"] == preferencesStoreName);

    List<String> keys = List<String>.from(preferences["keys"]);
    List<dynamic> values = preferences["values"];

    // SFT-2447: flip cloud syncing to false if we're making an offline file
    if (!isOnlineBackup) {
      var settings = values[keys.indexOf(Settings.SETTINGS_PREFS)];
      var jsonSettings = jsonDecode(settings);
      jsonSettings["syncToCloudSetting"] = false;
      settings = jsonEncode(jsonSettings);
      json["stores"][indexOfPreferences]["values"]
          [keys.indexOf(Settings.SETTINGS_PREFS)] = settings;
    }

    // Strip keys from hot wallets
    var accounts = values[keys.indexOf(AccountManager.ACCOUNTS_PREFS)];
    var jsonAccounts = jsonDecode(accounts);

    for (var account in jsonAccounts) {
      Wallet wallet = Wallet.fromJson(account["wallet"]);

      if (wallet.hot) {
        wallet.externalDescriptor = null;
        wallet.internalDescriptor = null;
        wallet.publicExternalDescriptor = null;
        wallet.publicInternalDescriptor = null;
      }

      account["wallet"] = wallet.toJson();
    }

    accounts = jsonEncode(jsonAccounts);

    json["stores"][indexOfPreferences]["values"]
        [keys.indexOf(AccountManager.ACCOUNTS_PREFS)] = accounts;

    backupData[EnvoyStorage.dbName] = jsonEncode(json);
    return backupData;
  }

  Future<bool> delete() async {
    final seed = await get();

    AccountManager().deleteHotWalletAccounts();
    LocalStorage().prefs.setBool(WALLET_DERIVED_PREFS, false);
    Settings().syncToCloud = false;

    removeSeedFromNonSecure();
    removeSeedFromSecure();

    return Backup.delete(seed!, Settings().envoyServerAddress, Tor.instance);
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
        return Backup.restore(seed, Settings().envoyServerAddress, Tor.instance)
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
      } on Exception {
        return false;
      }
    }
  }

  Future<bool> _processRecoveryData(
      String seed, Map<String, String>? data) async {
    bool success = data != null;
    if (success) {
      migrateFromSharedPreferences(data);

      // Restore wallets previously censored in censorHotWalletDescriptors
      if (data.containsKey(EnvoyStorage.dbName)) {
        data = restoreCensoredHotWallets(data, seed);
      }

      // Restore the database
      if (data.containsKey(EnvoyStorage.dbName)) {
        await EnvoyStorage().restore(data[EnvoyStorage.dbName]!);

        // This always happens after onboarding
        await EnvoyStorage().setBool(PREFS_ONBOARDED, true);
      }

      _restoreSingletons();
    }
    return success;
  }

  /// Settings, devices and accounts used to be stored in SharedPreferences
  /// Now they are in a Sembast store so we need a migration step for old backups
  static void migrateFromSharedPreferences(Map<String, String> data) {
    List<String> preferencesKeysFormerlyBackedUp = [
      Settings.SETTINGS_PREFS,
      AccountManager.ACCOUNTS_PREFS,
      Devices.DEVICES_PREFS,
    ];

    List<String> preferencesKeysPresentInData = data.keys
        .where((element) => preferencesKeysFormerlyBackedUp.contains(element))
        .toList();

    Map<String, dynamic> db = jsonDecode(data[EnvoyStorage.dbName]!);
    List<dynamic> stores = db["stores"];
    stores.add({
      "name": preferencesStoreName,
      "keys": preferencesKeysPresentInData,
      "values": preferencesKeysPresentInData.map((e) => data[e]).toList()
    });

    data[EnvoyStorage.dbName] = jsonEncode(db);
  }

  Map<String, String> restoreCensoredHotWallets(
      Map<String, String> data, String seed) {
    var json = jsonDecode(data[EnvoyStorage.dbName]!) as Map;

    List<dynamic> stores = json["stores"];
    var preferences = stores
        .singleWhere((element) => element["name"] == preferencesStoreName);
    int indexOfPreferences =
        stores.indexWhere((element) => element["name"] == preferencesStoreName);

    List<String> keys = List<String>.from(preferences["keys"]);
    List<dynamic> values = preferences["values"];

    var accounts = values[keys.indexOf(AccountManager.ACCOUNTS_PREFS)];
    var jsonAccounts = jsonDecode(accounts);

    for (var account in jsonAccounts) {
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

    accounts = jsonEncode(jsonAccounts);
    json["stores"][indexOfPreferences]["values"]
        [keys.indexOf(AccountManager.ACCOUNTS_PREFS)] = accounts;
    data[EnvoyStorage.dbName] = jsonEncode(json);
    return data;
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
