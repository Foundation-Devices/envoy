// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backup/backup.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/legacy/legacy_account.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/blog_post.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/migrations/migration_manager.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:tor/tor.dart';
import 'package:uuid/uuid.dart';

const String SEED_KEY = "seed";
const String WALLET_DERIVED_PREFS = "wallet_derived";
const String TAPROOT_WALLET_DERIVED_PREFS = "taproot_wallet_derived";
const String SEED_CLEAR_FLAG = "seed_cleared";

const String LAST_BACKUP_PREFS = "last_backup";
const String LOCAL_SECRET_FILE_NAME = "local.secret";
const String LOCAL_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME =
    "$LOCAL_SECRET_FILE_NAME.backup_timestamp";

const int SECRET_LENGTH_BYTES = 16;
const magicBackupVersion = 2;

class EnvoySeed {
  static final EnvoySeed _instance = EnvoySeed._internal();

  factory EnvoySeed() {
    return _instance;
  }

  static Future<EnvoySeed> init() async {
    var singleton = EnvoySeed._instance;

    // After a fresh install of Envoy following an Envoy erase,
    // the keychain may still retain the seed for a brief period.
    // To ensure the seed is fully removed, set the flag during the erase flow
    // to delete the seed upon the next installation.
    try {
      if (await LocalStorage().readSecure(SEED_CLEAR_FLAG) == "1") {
        try {
          await LocalStorage().deleteSecure(SEED_KEY);
          await LocalStorage().deleteFile(LOCAL_SECRET_FILE_NAME);
        } finally {
          await clearDeleteFlag();
        }
      }
    } catch (er) {
      EnvoyReport().log("EnvoySeed Init", er.toString());
    }
    return singleton;
  }

  EnvoySeed._internal() {
    kPrint("Instance of EnvoySeed created!");
  }

  static const _platform = MethodChannel('envoy');

  static String encryptedBackupFileExtension = "mla";
  static String encryptedBackupFileName = "envoy_backup";
  static String encryptedBackupFilePath =
      "${LocalStorage().appDocumentsDir.path}/$encryptedBackupFileName.$encryptedBackupFileExtension";

  static Map<AddressType, Map<Network, String>> hotWalletDerivationPaths = {
    AddressType.p2Wpkh: {
      Network.bitcoin: "m/84'/0'/0'",
      Network.testnet: "m/84'/1'/0'",
      Network.signet: "m/84'/2'/0'"
    },
    AddressType.p2Tr: {
      Network.bitcoin: "m/86'/0'/0'",
      Network.testnet: "m/86'/1'/0'",
      Network.signet: "m/86'/2'/0'"
    }
  };

  StreamController<bool> backupCompletedStream = StreamController.broadcast();

  Future generate() async {
    final generatedSeed = await EnvoyBip39.generateSeed();
    return await deriveAndAddWallets(generatedSeed, requireScan: false);
  }

  Future<bool> create(List<String> seedList,
      {String? passphrase, bool requireScan = false}) async {
    String seed = seedList.join(" ");
    return await deriveAndAddWallets(seed,
        passphrase: passphrase, requireScan: requireScan);
  }

  Future<bool> deriveAndAddWalletsFromCurrentSeed(
      {String? passphrase, Network? network}) async {
    String? seed = await get();

    if (seed == null) {
      return false;
    }

    return deriveAndAddWallets(seed, passphrase: passphrase, network: network);
  }

  Future<bool> deriveAndAddWallets(String seed,
      {String? passphrase, Network? network, bool requireScan = true}) async {
    await clearDeleteFlag();

    if (await NgAccountManager().checkIfWalletFromSeedExists(seed,
        passphrase: passphrase,
        type: AddressType.p2Wpkh,
        network: network ?? Network.bitcoin)) {
      return true;
    }

    await store(seed);

    try {
      if (network == null) {
        await addEnvoyAccount(seed, Network.bitcoin, passphrase,
            requireScan: requireScan);
        // Always derive testnet and signet wallets too
        await addEnvoyAccount(seed, Network.testnet4, passphrase,
            requireScan: requireScan);
        await addEnvoyAccount(seed, Network.signet, passphrase,
            requireScan: requireScan);
      } else {
        await addEnvoyAccount(seed, network, passphrase,
            requireScan: requireScan);
      }
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        if (requireScan) SyncManager().initiateFullScan();
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
        EnvoyReport()
            .log("EnvoySeed", "Error initiating full scan: ${e.toString()}");
      }
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future addEnvoyAccount(String seed, Network network, String? passphrase,
      {bool requireScan = false}) async {
    String newWalletDirectory = NgAccountManager.walletsDirectory;
    Directory newAccountDir = Directory(
        "${newWalletDirectory}envoy_${network.toString().toLowerCase()}_acc_0");

    if (!(await newAccountDir.exists())) {
      newAccountDir.create(recursive: true);
    }

    final derivations = await EnvoyBip39.deriveDescriptorFromSeed(
        seedWords: seed, network: network, passphrase: passphrase);
    final descriptors = derivations
        .where((element) =>
            element.addressType == AddressType.p2Wpkh ||
            element.addressType == AddressType.p2Tr)
        .map((element) => NgDescriptor(
              internal: element.internalDescriptor,
              external_: element.externalDescriptor,
              addressType: element.addressType,
            ))
        .toList();

    if (descriptors.isEmpty || descriptors.length != 2) {
      EnvoyReport().log("EnvoySeed",
          "Error creating account from descriptor: descriptors.length ${descriptors.length}");
      return false;
    }
    try {
      AddressType addressType = descriptors.first.addressType;
      final taprootEnabled = Settings().taprootEnabled();
      if (descriptors.firstWhereOrNull(
                  (element) => element.addressType == AddressType.p2Tr) !=
              null &&
          taprootEnabled) {
        addressType = AddressType.p2Tr;
      }

      final handler = await EnvoyAccountHandler.newFromDescriptor(
          name: S().accounts_screen_walletType_defaultName,
          deviceSerial: "envoy",
          addressType: addressType,
          color: Color(0xFF009DB9).toHex(),
          index: 0,
          descriptors: descriptors,
          dbPath: newAccountDir.path,
          network: network,
          id: Uuid().v4());
      final state = await handler.state();
      for (var element in descriptors) {
        kPrint("Skipping scan for ${element.addressType} $requireScan");
        //set accounts as scanned. descriptors created by envoy doesn't need scanning
        await LocalStorage()
            .prefs
            .setAccountScanStatus(state.id, element.addressType, !requireScan);
      }
      await NgAccountManager().addAccount(state, handler);
      return true;
    } catch (e) {
      EnvoyReport().log("EnvoySeed",
          "Error creating account from descriptor: ${e.toString()}",
          stackTrace: StackTrace.current);
    }
  }

  bool walletDerived() {
    return NgAccountManager().hotAccountsExist();
  }

  Future<void> store(String seed) async {
    if (Settings().syncToCloud) {
      await _saveNonSecure(seed, LOCAL_SECRET_FILE_NAME);
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

    //add accounts
    backupData = await processBackupData(backupData, cloud);

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
      } else if (cloud && !success) {
        backupCompletedStream.sink.add(false);
      }
    });
  }

  Future<void> _storeLastBackupTimestamp() async {
    await LocalStorage()
        .prefs
        .setString(LAST_BACKUP_PREFS, DateTime.now().toIso8601String());
  }

  Future<Map<String, String>> processBackupData(
      Map<String, String> backupData, bool isOnlineBackup) async {
    var json = jsonDecode(backupData[EnvoyStorage.dbName]!) as Map;

    List<dynamic> stores = json["stores"];
    var preferences = stores
        .singleWhere((element) => element["name"] == preferencesStoreName);
    int indexOfPreferences =
        stores.indexWhere((element) => element["name"] == preferencesStoreName);

    List<String> keys = List<String>.from(preferences["keys"]);
    List<dynamic> values = preferences["values"];

    // SFT-2447: flip cloud syncing to false if we're making an offline file
    if (isOnlineBackup) {
      try {
        var settings = values[keys.indexOf(Settings.SETTINGS_PREFS)];
        var jsonSettings = jsonDecode(settings);
        jsonSettings["syncToCloudSetting"] = false;
        settings = jsonEncode(jsonSettings);
        json["stores"][indexOfPreferences]["values"]
            [keys.indexOf(Settings.SETTINGS_PREFS)] = settings;
      } catch (e, stack) {
        EnvoyReport()
            .log("EnvoySeed checking online", e.toString(), stackTrace: stack);
      }
    }
    var account = List<dynamic>.from([]);
    for (var accountHandler in NgAccountManager().handlers) {
      try {
        final state = await accountHandler.state();
        final dirWithId = NgAccountManager.getAccountDirectory(
            deviceSerial: state.deviceSerial ?? "envoy",
            network: state.network.toString(),
            number: state.index,
            accountId: state.id);
        final jsonStr = await accountHandler.getAccountBackup();
        final json = jsonDecode(jsonStr);
        if (await dirWithId.exists()) {
          json["require_unique_path"] = true;
        }
        account.add(json);
      } catch (e, stack) {
        EnvoyReport().log(
          "EnvoySeed",
          "Error getting account backup: ${e.toString()}",
          stackTrace: stack,
        );
      }
    }
    backupData.remove("accounts");
    backupData[NgAccountManager.accountsPrefKey] = jsonEncode(account);
    backupData[EnvoyStorage.dbName] = jsonEncode(json);
    return backupData;
  }

  Future<bool> delete() async {
    final seed = await get();

    bool isDeleted = false;

    if (Settings().syncToCloud) {
      try {
        isDeleted = await Backup.delete(
            seed!, Settings().envoyServerAddress, Tor.instance);
      } on Exception {
        return false;
      }
      if (!isDeleted) {
        return false;
      }
    }

    await NgAccountManager().deleteHotWalletAccounts();

    Settings().syncToCloud = false;

    try {
      await removeSeedFromNonSecure();
      EnvoyReport().log("QA", "Removed seed from regular storage!");
    } on Exception catch (e) {
      EnvoyReport().log(
          "QA", "Couldn't remove seed from regular storage: ${e.toString()}");
    }

    await removeSeedFromSecure();
    EnvoyReport().log("QA", "Removed seed from secure storage!");
    await LocalStorage().saveSecure(SEED_CLEAR_FLAG, "1");
    isDeleted = true;

    //add minor delay to allow the seed to be removed from secure storage (specifically on iOS)
    await Future.delayed(const Duration(milliseconds: 500));
    return isDeleted;
  }

  Future<bool> deleteMagicBackup() async {
    final seed = await get();
    Settings().setSyncToCloud(false);
    return Backup.delete(seed!, Settings().envoyServerAddress, Tor.instance);
  }

  Future<bool> restoreData(
      {String? seed, String? filePath, String? passphrase}) async {
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
            .then((data) async {
          bool status = await processRecoveryData(seed!, data, passphrase);
          return status;
        }).catchError((e, st) {
          debugPrintStack(stackTrace: st);
          return false;
        });
      } catch (e, st) {
        debugPrintStack(stackTrace: st);
        rethrow;
      }
    } else {
      try {
        Map<String, String>? data = Backup.restoreOffline(seed, filePath);
        bool success = await processRecoveryData(seed, data, passphrase);
        return success;
      } catch (e, st) {
        debugPrintStack(stackTrace: st);
        return false;
      }
    }
  }

  Future<bool> processRecoveryData(
      String seed, Map<String, String>? data, String? passphrase) async {
    bool success = data != null;
    bool isLegacy = false;
    if (success) {
      migrateFromSharedPreferences(data);
      // if the data contains accountsPrefKey at root ,
      // data is from newer backup
      if (data.containsKey(EnvoyStorage.dbName) &&
          !data.containsKey(NgAccountManager.accountsPrefKey)) {
        await create(seed.split(" "), passphrase: passphrase);
        try {
          await restoreLegacyWallet(data, seed);
          isLegacy = true;
        } catch (e) {
          EnvoyReport().log("EnvoySeed",
              "Error restoring legacy wallet with magic backup: $e");
          rethrow;
        }
      } else {
        // legacy accounts restore
        // Restore wallets previously censored in censorHotWalletDescriptors,
        // magic backup wont have any xprv keys, only seed
        if (data.containsKey(NgAccountManager.accountsPrefKey)) {
          await restoreAccounts(data, seed, passphrase);
        }
      }

      // Restore the database
      if (data.containsKey(EnvoyStorage.dbName)) {
        // get videos and blogs from current database before restore
        List<Video?> videos = await EnvoyStorage().getAllVideos() ?? [];
        List<BlogPost?> blogs = await EnvoyStorage().getAllBlogPosts() ?? [];

        await EnvoyStorage().restore(data[EnvoyStorage.dbName]!);

        await EnvoyStorage().insertMediaItems(videos);
        await EnvoyStorage().insertMediaItems(blogs);

        // This always happens after onboarding
        await EnvoyStorage().setBool(PREFS_ONBOARDED, true);
      }

      _restoreSingletons();

      await Future.delayed(const Duration(milliseconds: 100));
      bool showTestnet = Settings().showTestnetAccounts();
      bool showSignet = Settings().showSignetAccounts();

      if (showTestnet && isLegacy) {
        await LocalStorage()
            .prefs
            .setBool(MigrationManager.migratedToTestnet4, true);
      }
      if (showSignet && isLegacy) {
        LocalStorage()
            .prefs
            .setBool(MigrationManager.migratedToSignetGlobal, true);
      }

      await EnvoyStorage().setNoBackUpPreference(
          MigrationManager.migrationPrefs, MigrationManager.migrationVersion);
    }
    return success;
  }

  /// Settings, devices and accounts used to be stored in SharedPreferences
  /// Now they are in a Sembast store so we need a migration step for old backups
  static void migrateFromSharedPreferences(Map<String, String> data) {
    List<String> preferencesKeysFormerlyBackedUp = [
      Settings.SETTINGS_PREFS,
      NgAccountManager.accountsPrefKey,
      Devices.DEVICES_PREFS,
    ];

    List<String> preferencesKeysPresentInData = data.keys
        .where((element) => preferencesKeysFormerlyBackedUp.contains(element))
        .toList();

    if (preferencesKeysPresentInData.isEmpty) {
      return;
    }

    Map<String, dynamic> db = jsonDecode(data[EnvoyStorage.dbName]!);
    List<dynamic> stores = db["stores"];
    stores.add({
      "name": preferencesStoreName,
      "keys": preferencesKeysPresentInData,
      "values": preferencesKeysPresentInData.map((e) => data[e]).toList()
    });

    data[EnvoyStorage.dbName] = jsonEncode(db);
  }

  Future<Map<String, String>> restoreLegacyWallet(
      Map<String, String> data, String seed) async {
    var json = jsonDecode(data[EnvoyStorage.dbName]!) as Map;

    List<dynamic> stores = json["stores"];
    var preferences = stores
        .singleWhere((element) => element["name"] == preferencesStoreName);
    List<String> keys = List<String>.from(preferences["keys"]);
    List<dynamic> values = preferences["values"];

    var accounts = values[keys.indexOf(NgAccountManager.v1AccountsPrefKey)];
    var jsonAccounts = jsonDecode(accounts);
    List<LegacyAccount> legacyWallets = [];
    for (var e in jsonAccounts) {
      try {
        final account = LegacyAccount.fromJson(e);
        if (!account.wallet.hot) {
          legacyWallets.add(account);
        }
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
      }
    }
    List<LegacyUnifiedAccounts> legacy = MigrationManager.unify(legacyWallets);

    final accountOrder =
        LocalStorage().prefs.getString(NgAccountManager.ACCOUNT_ORDER);
    List<String> order = List<String>.from(jsonDecode(accountOrder ?? "[]"));
    try {
      List<EnvoyAccountHandler> accountHandler =
          await MigrationManager().createAccounts(legacy, order);
      for (var handler in accountHandler) {
        await NgAccountManager().addAccount(
          await handler.state(),
          handler,
        );
      }
    } catch (e, stack) {
      EnvoyReport().log(
        "EnvoySeed",
        "Error creating accounts from legacy wallets: ${e.toString()}",
        stackTrace: stack,
      );
    }
    data[EnvoyStorage.dbName] = jsonEncode(json);
    return data;
  }

  _restoreSingletons() {
    Settings.restore(fromBackup: true);
    Settings().store();
    Devices().restore();
    ExchangeRate().restore();
    Notifications().restoreNotifications();
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
      FileSaver.instance.saveAs(
          name: encryptedBackupFileName,
          bytes: backupBytes,
          ext: encryptedBackupFileExtension,
          mimeType: MimeType.text);
    } catch (e) {
      kPrint(e);
    }
  }

  Future<String?> get() async {
    String? secure = await _getSecure();
    String? nonSecure = await _getNonSecure();

    if (secure != null && nonSecure != null) {
      EnvoyReport().log("QA", "Seed stored in both secure and regular storage");
      return secure;

      // TODO: show a warning to user
      // If we're syncing then the two being different is something to be handled
      // if (secure != nonSecure) {
      //   throw Exception("Different seed in secure and non-secure!");
      // }
    }

    if (secure != null) {
      EnvoyReport().log("QA", "Seed stored in secure storage");
      return secure;
    }

    if (nonSecure != null) {
      EnvoyReport().log("QA", "Seed stored in regular storage");
      return nonSecure;
    }

    return null;
  }

  EnvoyAccount? getWallet() {
    return NgAccountManager()
        .accounts
        .firstWhereOrNull((account) => account.isHot);
  }

  Future<String?> _getSecure() async {
    if (!await LocalStorage().containsSecure(SEED_KEY)) {
      return null;
    }

    return await LocalStorage().readSecure(SEED_KEY);
  }

  Future<File> _saveNonSecure(String data, String name) async {
    final file = await LocalStorage().saveFile(name, data);
    if (!Platform.isLinux) {
      _platform.invokeMethod('data_changed');
    }
    return file;
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

  removeSeedFromNonSecure() async {
    await LocalStorage().deleteFile(LOCAL_SECRET_FILE_NAME);
    if (!Platform.isLinux) {
      _platform.invokeMethod('data_changed');
    }
  }

  Future<void> removeSeedFromSecure() async {
    await LocalStorage().deleteSecure(SEED_KEY);
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

  //deletes the secure store "delete" flag
  static Future clearDeleteFlag() async {
    if (await LocalStorage().readSecure(SEED_CLEAR_FLAG) != null) {
      await LocalStorage().deleteSecure(SEED_CLEAR_FLAG);
    }
  }

  Future restoreAccounts(
      Map<String, String> data, String seed, String? passphrase) async {
    try {
      //store seed before restoring accounts
      await store(seed);
      List<dynamic> accounts =
          jsonDecode(data[NgAccountManager.accountsPrefKey]!);
      //no accounts in backup ? so derive from seed
      if (accounts.isEmpty) {
        await deriveAndAddWallets(seed,
            passphrase: passphrase, requireScan: true);
        return;
      }
      for (var account in accounts) {
        final config = EnvoyAccountHandler.getConfigFromBackup(
            backupJson: jsonEncode(account));
        Directory dir = NgAccountManager.getAccountDirectory(
          deviceSerial: config.deviceSerial ?? "envoy",
          network: config.network.toString(),
          number: config.index,
        );
        //any account that are affected by SFT-5217 issue,these require unique path
        if (account.containsKey("require_unique_path")) {
          dir = NgAccountManager.getAccountDirectory(
              deviceSerial: config.deviceSerial ?? "envoy",
              network: config.network.toString(),
              number: config.index,
              accountId: config.id);
        }
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
        await dir.create(recursive: true);

        //both hot and cold wallets are restored from backup,
        //hot wallet descriptors will be derived from seed.
        final handler = await EnvoyAccountHandler.restoreFromBackup(
            backupJson: jsonEncode(account),
            dbPath: dir.path,
            seed: seed,
            passphrase: passphrase);
        final state = await handler.state();
        await NgAccountManager().addAccount(state, handler);
      }
    } catch (e) {
      EnvoyReport().log("EnvoySeed", "Error restoring accounts: $e");
    }
  }
}
