// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backup/backup.dart' as backup_lib;
import 'package:backup/backup.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/legacy/legacy_account.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/blog_post.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/magic_backup_storage.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/updates_manager.dart';
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

const String WALLET_DERIVED_PREFS = "wallet_derived";
const String TAPROOT_WALLET_DERIVED_PREFS = "taproot_wallet_derived";

const String LAST_BACKUP_PREFS = "last_backup";

const int SECRET_LENGTH_BYTES = 16;
const magicBackupVersion = 2;

class EnvoySeed {
  static final EnvoySeed _instance = EnvoySeed._internal();

  factory EnvoySeed() {
    return _instance;
  }

  static Future<EnvoySeed> init() async {
    var singleton = EnvoySeed._instance;
    try {
      await backup_lib.RustLib.init();
    } catch (e, stack) {
      EnvoyReport().log("EnvoySeed", "$e", stackTrace: stack);
    }
    try {
      if (Platform.isIOS) {
        final storedBackupEnabled =
            await MagicBackupStorage().restoreIOSBackupEnabled(
          fallbackBackupEnabled: Settings().syncToCloud,
        );
        if (storedBackupEnabled != null &&
            storedBackupEnabled != Settings().syncToCloud) {
          Settings().setSyncToCloud(storedBackupEnabled);
        }
      } else {
        await MagicBackupStorage().upgradeV1Seed(
          backupEnabled: Settings().syncToCloud,
        );
      }
    } catch (error, stack) {
      EnvoyReport().log(
        "EnvoySeed Init",
        "Magic Backup storage initialization failed: $error",
        stackTrace: stack,
      );
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
      Network.signet: "m/84'/2'/0'",
    },
    AddressType.p2Tr: {
      Network.bitcoin: "m/86'/0'/0'",
      Network.testnet: "m/86'/1'/0'",
      Network.signet: "m/86'/2'/0'",
    },
  };

  StreamController<bool> backupCompletedStream = StreamController.broadcast();

  Future generate() async {
    final generatedSeed = await EnvoyBip39.generateSeed();
    return await deriveAndAddWallets(generatedSeed, requireScan: false);
  }

  Future<bool> create(
    List<String> seedList, {
    String? passphrase,
    bool requireScan = false,
  }) async {
    String seed = seedList.join(" ");
    return await deriveAndAddWallets(
      seed,
      passphrase: passphrase,
      requireScan: requireScan,
    );
  }

  Future<bool> deriveAndAddWalletsFromCurrentSeed({
    String? passphrase,
    Network? network,
  }) async {
    String? seed = await get();

    if (seed == null) {
      return false;
    }

    return deriveAndAddWallets(seed, passphrase: passphrase, network: network);
  }

  Future<bool> deriveAndAddWallets(
    String seed, {
    String? passphrase,
    Network? network,
    bool requireScan = true,
  }) async {
    if (await NgAccountManager().checkIfWalletFromSeedExists(
      seed,
      passphrase: passphrase,
      network: network ?? Network.bitcoin,
    )) {
      return true;
    }

    await store(seed);

    try {
      if (network == null) {
        await addEnvoyAccount(
          seed,
          Network.bitcoin,
          passphrase,
          requireScan: requireScan,
        );
        // Always derive testnet and signet wallets too
        await addEnvoyAccount(
          seed,
          Network.testnet4,
          passphrase,
          requireScan: requireScan,
        );
        await addEnvoyAccount(
          seed,
          Network.signet,
          passphrase,
          requireScan: requireScan,
        );
      } else {
        await addEnvoyAccount(
          seed,
          network,
          passphrase,
          requireScan: requireScan,
        );
      }
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        if (requireScan) SyncManager().initiateFullScan();
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
        EnvoyReport().log(
          "EnvoySeed",
          "Error initiating full scan: ${e.toString()}",
        );
      }
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future addEnvoyAccount(
    String seed,
    Network network,
    String? passphrase, {
    bool requireScan = false,
  }) async {
    final derivations = await EnvoyBip39.deriveDescriptorFromSeed(
      seedWords: seed,
      network: network,
      passphrase: passphrase,
    );

    final descriptors = derivations
        .where(
          (element) =>
              element.addressType == AddressType.p2Wpkh ||
              element.addressType == AddressType.p2Tr,
        )
        .map(
          (element) => NgDescriptor(
            internal: element.internalDescriptor,
            external_: element.externalDescriptor,
            addressType: element.addressType,
          ),
        )
        .toList();

    final fingerprint = NgAccountManager.getFingerprint(
      derivations.first.externalPubDescriptor,
    );

    if (fingerprint == null) {
      throw Exception("Failed to get fingerprint");
    }

    Directory newAccountDir = NgAccountManager.getAccountDirectory(
      deviceSerial: "envoy",
      network: network.toString(),
      number: 0,
      fingerprint: fingerprint,
    );
    if (!(await newAccountDir.exists())) {
      newAccountDir.create(recursive: true);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    if (descriptors.isEmpty || descriptors.length != 2) {
      EnvoyReport().log(
        "EnvoySeed",
        "Error creating account from descriptor: descriptors.length ${descriptors.length}",
      );
      return false;
    }
    try {
      AddressType addressType = descriptors.first.addressType;
      final taprootEnabled = Settings().taprootEnabled();
      if (descriptors.firstWhereOrNull(
                (element) => element.addressType == AddressType.p2Tr,
              ) !=
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
        seedHasPassphrase: passphrase != null,
        network: network,
        id: Uuid().v4(),
      );
      final state = await handler.state();
      for (var element in descriptors) {
        kPrint("Skipping scan for ${element.addressType} $requireScan");
        //set accounts as scanned. descriptors created by envoy doesn't need scanning
        await LocalStorage().prefs.setAccountScanStatus(
              state.id,
              element.addressType,
              !requireScan,
            );
      }
      await NgAccountManager().addAccount(state, handler);
      return true;
    } catch (e) {
      EnvoyReport().log(
        "EnvoySeed",
        "Error creating account from descriptor: ${e.toString()}",
        stackTrace: StackTrace.current,
      );
    }
  }

  bool walletDerived() {
    return NgAccountManager().hotAccountsExist();
  }

  Future<void> store(String seed) async {
    final backupEnabled = Settings().syncToCloud;
    await MagicBackupStorage().storeSeed(
      seed,
      backupEnabled: backupEnabled,
    );
  }

  Future<void> backupData({bool cloud = true}) async {
    if (!NgAccountManager().hotAccountsExist()) {
      return;
    }
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
    await EnvoyReport().log("Magic Backup", "creating data backup");
    return Backup.performBackupV2(
      payload: backupData,
      seedWords: seed,
      v2ServerUrl: Settings().backupServerV2Address,
      proxyPort: Tor.instance.port,
      localBackup: encryptedBackupFilePath,
      performCloud: cloud,
    ).then((success) async {
      if (cloud && success) {
        // Only notify if we are doing an online backup
        backupCompletedStream.sink.add(true);
        await _storeLastBackupTimestamp();
      } else if (!Settings().syncToCloud && success) {
        await _storeLastBackupTimestamp();
      } else if (cloud && !success) {
        backupCompletedStream.sink.add(false);
      }
      await EnvoyReport().log(
        "Magic Backup",
        "data backup completed: $success",
      );
    });
  }

  Future<void> _storeLastBackupTimestamp() async {
    await LocalStorage().prefs.setString(
          LAST_BACKUP_PREFS,
          DateTime.now().toIso8601String(),
        );
  }

  Future<Map<String, String>> processBackupData(
    Map<String, String> backupData,
    bool isOnlineBackup,
  ) async {
    var json = jsonDecode(backupData[EnvoyStorage.dbName]!) as Map;

    List<dynamic> stores = json["stores"];
    var preferencesStores = stores
        .where((element) => element["name"] == preferencesStoreName)
        .toList();

    // If no preferences store exists, return backup data as-is
    if (preferencesStores.isEmpty) {
      return backupData;
    }

    var preferences = preferencesStores.first;

    int indexOfPreferences = stores.indexWhere(
      (element) => element["name"] == preferencesStoreName,
    );

    // Safety check - if indexOfPreferences is -1, we have a data inconsistency
    if (indexOfPreferences == -1) {
      EnvoyReport().log(
        "EnvoySeed processBackupData",
        "Data inconsistency: preferences store found by singleWhere but not by indexWhere",
      );
      return backupData;
    }

    List<String> keys = List<String>.from(preferences["keys"]);
    List<dynamic> values = preferences["values"];

    // SFT-2447: flip cloud syncing to false if we're making an offline file
    if (isOnlineBackup) {
      try {
        if (!keys.contains(Settings.SETTINGS_PREFS)) {
          return backupData;
        }
        var settings = values[keys.indexOf(Settings.SETTINGS_PREFS)];
        var jsonSettings = jsonDecode(settings);
        jsonSettings["syncToCloudSetting"] = false;
        settings = jsonEncode(jsonSettings);
        json["stores"][indexOfPreferences]["values"][keys.indexOf(
          Settings.SETTINGS_PREFS,
        )] = settings;
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
        EnvoyReport().log(
          "EnvoySeed checking online",
          e.toString(),
          stackTrace: stack,
        );
      }
    }
    var account = List<dynamic>.from([]);
    for (var accountHandler in NgAccountManager().handlers) {
      try {
        final state = await accountHandler.state();
        final fingerprint = state.xfp;
        if (fingerprint.isEmpty) {
          throw Exception(
            "Failed to get fingerprint for account ${state.name} "
            "(id ${state.id}, account ${state.index}, ${state.network})",
          );
        }
        final dirWithId = NgAccountManager.getAccountDirectory(
          deviceSerial: state.deviceSerial ?? "envoy",
          network: state.network.toString(),
          number: state.index,
          fingerprint: fingerprint,
        );
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
    await EnvoyReport().log("Magic Backup", "deleting wallet seed");
    final seed = await get();

    bool isDeleted = false;

    if (Settings().syncToCloud) {
      try {
        if (Settings().usingTor) {
          await Tor.instance.isReady();
        }

        isDeleted = await Backup.deleteV2(
              seedWords: seed!,
              v2ServerUrl: Settings().backupServerV2Address,
              proxyPort: Tor.instance.port,
            ) ==
            202;
        // Best-effort v1 cleanup
        try {
          await Backup.delete(
            seedWords: seed,
            serverUrl: Settings().envoyServerAddress,
            proxyPort: Tor.instance.port,
          );
        } catch (_) {}
      } on Exception {
        return false;
      }
      if (!isDeleted) {
        return false;
      }
    }

    await MagicBackupStorage().deleteAllSeedData();
    await NgAccountManager().deleteHotWalletAccounts();
    await EnvoyReport().log("Magic Backup", "wallet seed deleted");
    isDeleted = true;

    //add minor delay to allow the seed to be removed from secure storage (specifically on iOS)
    await Future.delayed(const Duration(milliseconds: 500));
    return isDeleted;
  }

  Future<bool> deleteMagicBackup() async {
    final seed = await get();
    if (seed == null) {
      return false;
    }
    await EnvoyReport().log("Magic Backup", "disabling Magic Backup");
    Settings().setSyncToCloud(false);
    // Stop exporting the seed through device backup even if the server
    // deletion below has to be retried.
    await MagicBackupStorage().disableBackup();
    if (Settings().torEnabled()) {
      await Tor.instance.isReady();
    }
    // Delete from v2 server
    final v2Status = await Backup.deleteV2(
      seedWords: seed,
      v2ServerUrl: Settings().backupServerV2Address,
      proxyPort: Tor.instance.port,
    );
    // Best-effort cleanup from v1 server
    try {
      await Backup.delete(
        seedWords: seed,
        serverUrl: Settings().envoyServerAddress,
        proxyPort: Tor.instance.port,
      );
    } catch (_) {
      // v1 cleanup is best-effort
    }
    await EnvoyReport().log("Magic Backup", "Magic Backup disabled");
    return v2Status == 202;
  }

  Future<bool> restoreData({
    String? seed,
    String? filePath,
    String? passphrase,
  }) async {
    await EnvoyReport().log(
      "Magic Backup",
      filePath == null ? "starting cloud recovery" : "starting file recovery",
    );
    // Try to get seed from device
    try {
      if (seed == null) {
        seed = await get();
        if (seed == null) {
          throw GetBackupException.seedNotFound;
        }
      }
    } catch (e) {
      throw GetBackupException.seedNotFound;
    }
    if (filePath == null) {
      try {
        if (Settings().usingTor) {
          await Tor.instance.isReady();
        }
        List<(String, String)> backupPayload;
        try {
          backupPayload = await Backup.getBackupV2(
            seedWords: seed,
            v2ServerUrl: Settings().backupServerV2Address,
            proxyPort: Tor.instance.port,
          );
          await EnvoyReport().log("Magic Backup", "downloaded v2 backup");
        } on GetBackupException catch (e) {
          // Unauthorized means the v2 server has a backup blob but no sibling
          // pubkey and the client-supplied pubkey didn't match (or healing was
          // refused). Treat it like backupNotFound and fall back to v1 — that
          // way we still try the legacy server for the data.
          if (e == GetBackupException.backupNotFound ||
              e == GetBackupException.unauthorized ||
              e == GetBackupException.serverUnreachable) {
            backupPayload = await Backup.getBackup(
              seedWords: seed,
              serverUrl: Settings().envoyServerAddress,
              proxyPort: Tor.instance.port,
            );
            await EnvoyReport().log("Magic Backup", "downloaded v1 backup");
          } else {
            rethrow;
          }
        }
        final status = await processRecoveryData(
          seed,
          extractDataFromPayload(backupPayload),
          passphrase,
          isMagicBackup: true,
        );
        await EnvoyReport().log(
          "Magic Backup",
          "cloud recovery completed: $status",
        );
        return status;
      } catch (e, st) {
        debugPrintStack(stackTrace: st);
        rethrow;
      }
    } else {
      try {
        final data = await Backup.getBackupOffline(
          seedWords: seed,
          filePath: filePath,
        );
        await EnvoyReport().log("Magic Backup", "read backup file");
        bool success = await processRecoveryData(
          seed,
          extractDataFromPayload(data),
          passphrase,
        );
        await EnvoyReport().log(
          "Magic Backup",
          "file recovery completed: $success",
        );
        return success;
      } catch (e, st) {
        debugPrintStack(stackTrace: st);
        return false;
      }
    }
  }

  Future<bool> processRecoveryData(
    String seed,
    Map<String, String>? data,
    String? passphrase, {
    bool isMagicBackup = false,
  }) async {
    bool success = data != null;
    bool isLegacy = false;
    if (success) {
      migrateFromSharedPreferences(data);
      try {
        // Restore the database
        if (data.containsKey(EnvoyStorage.dbName)) {
          // get videos and blogs from current database before restore
          List<Video?> videos = await EnvoyStorage().getAllVideos() ?? [];
          List<BlogPost?> blogs = await EnvoyStorage().getAllBlogPosts() ?? [];

          await EnvoyStorage().restore(data[EnvoyStorage.dbName]!);
          UpdatesManager().fetchUpdates();

          await EnvoyStorage().insertMediaItems(videos);
          await EnvoyStorage().insertMediaItems(blogs);
          await EnvoyReport().log(
            "Magic Backup",
            "restored backup database",
          );
        }

        final bool hasExistingSetup = Devices().devices.isNotEmpty &&
            (LocalStorage().prefs.getBool(PREFS_ONBOARDED) ?? false);

        await _restoreSingletons(hasExistingSetup);

        if (Settings().usingTor) {
          try {
            if (!Tor.instance.started) {
              await Tor.instance.start();
            }
            await Tor.instance.enable();
          } catch (e) {
            EnvoyReport().log("EnvoySeed", "Unable to start Tor: $e");
          }
        }
      } catch (e) {
        EnvoyReport().log("EnvoySeed", "Error restoring database: $e");
      }
      //respect backup from previous installation
      var backupEnabled = isMagicBackup;
      try {
        backupEnabled =
            await MagicBackupStorage().getBackupEnabled() ?? isMagicBackup;
      } catch (error, stack) {
        backupEnabled = false;
        EnvoyReport().log(
          "Magic Backup",
          "native backup setting unavailable; defaulting to disabled",
          stackTrace: stack,
        );
      }
      Settings().setSyncToCloud(backupEnabled);
      await EnvoyReport().log(
        "Magic Backup",
        "set backup enabled: $backupEnabled",
      );

      // if the data does not contains v2 backup at root (NgAccountManager.accountsPrefKey) at root,
      // Data is from older backups,so we need to restore legacy wallets
      if (data.containsKey(EnvoyStorage.dbName) &&
          !data.containsKey(NgAccountManager.accountsPrefKey)) {
        List<LegacyAccount> legacyWallets = getLegacyAccountsFromMBJson(data);
        try {
          kPrint(
            "Restoring from v1 magic backups ${legacyWallets.map((e) => "${e.name} -> ${e.deviceSerial}")}",
          );
          await create(
            seed.split(" "),
            passphrase: passphrase,
            requireScan: true,
          );
          await restoreLegacyWallet(legacyWallets);
          isLegacy = true;
          await EnvoyReport().log(
            "Magic Backup",
            "restored v1 accounts",
          );
        } catch (e) {
          EnvoyReport().log(
            "EnvoySeed",
            "Error restoring legacy wallet with magic backup: $e",
          );
          rethrow;
        } finally {
          //try migrate meta (notes, tags, doNotSpend)
          for (var account in NgAccountManager().accounts) {
            //when restoring from magic backup, accounts are created with new id
            if (account.handler != null) {
              kPrint("Migrating legacy wallet meta..");
              await MigrationManager.migrateMeta(
                account.handler!,
                legacyWallets,
              );
            }
          }
        }
      } else {
        // legacy accounts restore
        // Restore wallets previously censored in censorHotWalletDescriptors,
        // magic backup wont have any xprv keys, only seed
        if (data.containsKey(NgAccountManager.accountsPrefKey)) {
          await EnvoyReport().log(
            "Magic Backup",
            "restoring v2 accounts",
          );
          await restoreAccounts(data, seed, passphrase);
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
      bool showTestnet = Settings().showTestnetAccounts();
      bool showSignet = Settings().showSignetAccounts();
      bool showTaproot = Settings().taprootEnabled();

      if (showTestnet && isLegacy) {
        await LocalStorage().prefs.setBool(
              MigrationManager.migratedToTestnet4,
              true,
            );
        Settings().setShowTestnetAccounts(false);
      }
      if (showSignet && isLegacy) {
        LocalStorage().prefs.setBool(
              MigrationManager.migratedToSignetGlobal,
              true,
            );
        await Settings().setShowSignetAccounts(false);
      }
      if (showTaproot && isLegacy) {
        LocalStorage().prefs.setBool(
              MigrationManager.migratedToUnifiedAccounts,
              true,
            );
      }

      await MigrationManager().setMigrationComplete();
    }
    return success;
  }

  /// Settings, devices and accounts used to be stored in SharedPreferences
  /// Now they are in a Sembast store so we need a migration step for old backups
  static void migrateFromSharedPreferences(Map<String, String> data) {
    List<String> preferencesKeysFormerlyBackedUp = [
      Settings.SETTINGS_PREFS,
      NgAccountManager.v1AccountsPrefKey,
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
      "values": preferencesKeysPresentInData.map((e) => data[e]).toList(),
    });

    data[EnvoyStorage.dbName] = jsonEncode(db);
  }

  Future restoreLegacyWallet(List<LegacyAccount> legacyWallets) async {
    List<LegacyUnifiedAccounts> legacy = MigrationManager.unify(
      legacyWallets.where((wallet) => !wallet.wallet.hot).toList(),
    );

    try {
      List<EnvoyAccountHandler> accountHandler =
          await MigrationManager().createAccounts(legacy);

      for (var handler in accountHandler) {
        final account = await handler.state();
        for (var element in account.descriptors) {
          await LocalStorage().prefs.setAccountScanStatus(
                account.id,
                element.addressType,
                false,
              );
        }
        await MigrationManager.migrateMeta(handler, legacyWallets);
        try {
          await NgAccountManager().addAccount(account, handler);
        } catch (e) {
          EnvoyReport().log("EnvoySeed", "Error migrating Meta: $e");
        }
      }
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      EnvoyReport().log(
        "EnvoySeed",
        "Error creating accounts from legacy wallets: ${e.toString()}",
        stackTrace: stack,
      );
    }
  }

  Future _restoreSingletons(bool hasExistingSetup) async {
    if (!hasExistingSetup) {
      await Settings.restore(fromBackup: true);
      await Settings().store();
      Notifications().restoreNotifications();
      ExchangeRate().restore();
    }

    await Devices().restore(hasExitingSetup: hasExistingSetup);
  }

  List<LegacyAccount> getLegacyAccountsFromMBJson(Map<String, String> data) {
    var json = jsonDecode(data[EnvoyStorage.dbName]!) as Map;

    List<dynamic> stores = json["stores"];
    var preferences = stores.firstWhereOrNull(
      (element) => element["name"] == preferencesStoreName,
    );

    if (preferences == null) {
      return [];
    }
    if (preferences.isEmpty) {
      return [];
    }
    List<String> keys = List<String>.from(preferences["keys"]);
    List<dynamic> values = preferences["values"];

    try {
      int accountsIndex = keys.indexOf(NgAccountManager.v1AccountsPrefKey);
      if (accountsIndex == -1 || accountsIndex >= values.length) {
        return [];
      }
      var accounts = values[accountsIndex];
      var jsonAccounts = jsonDecode(accounts);
      List<LegacyAccount> legacyWallets = [];
      for (var e in jsonAccounts) {
        try {
          final account = LegacyAccount.fromJson(e);
          legacyWallets.add(account);
        } catch (e, stack) {
          debugPrintStack(stackTrace: stack);
        }
      }
      return legacyWallets;
    } catch (e, stack) {
      EnvoyReport().log(
        "EnvoySeed",
        "Error getting legacy wallets: $e",
        stackTrace: stack,
      );
      return [];
    }
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
      if (Platform.isAndroid) {
        await _platform.invokeMethod('save_document', {
          'from': encryptedBackupFilePath,
          'mimeType': MimeType.text.type,
        });
      } else {
        await FileSaver.instance.saveAs(
          name: encryptedBackupFileName,
          bytes: backupBytes,
          fileExtension: encryptedBackupFileExtension,
          mimeType: MimeType.text,
        );
      }
    } catch (e) {
      kPrint(e);
    }
  }

  Future<String?> get() async {
    return MagicBackupStorage().retrieveSeed(
      backupEnabled: Settings().syncToCloud,
    );
  }

  EnvoyAccount? getWallet() {
    return NgAccountManager().accounts.firstWhereOrNull(
          (account) => account.isHot,
        );
  }

  void showSettingsMenu() {
    _platform.invokeMethod('show_settings');
  }

  Future<void> enableMagicBackup() async {
    final seed = await get();
    if (seed == null) {
      throw StateError("Magic Backup seed is unavailable");
    }
    await store(seed);
    await EnvoyReport().log("Magic Backup", "Magic Backup enabled");
  }

  Future<void> removeSeed() async {
    await MagicBackupStorage().deleteAllSeedData();
  }

  Future<DateTime?> getDeviceBackupTimestamp() async {
    return MagicBackupStorage().getLastBackupTimestamp();
  }

  Future restoreAccounts(
    Map<String, String> data,
    String seed,
    String? passphrase,
  ) async {
    try {
      //store seed before restoring accounts
      await store(seed);
      await EnvoyReport().log("Magic Backup", "stored recovered seed");
      List<dynamic> accounts = jsonDecode(
        data[NgAccountManager.accountsPrefKey]!,
      );
      List<NgAccountBackup> ngAccountBackups = [];
      for (var account in accounts) {
        try {
          final config = account["ng_account_config"] as Map<String, dynamic>?;
          if (config != null && !config.containsKey("archived")) {
            config["archived"] = false;
          }
          final backup = await EnvoyAccountHandler.deserializeBackup(
            backupJson: jsonEncode(account),
          );
          ngAccountBackups.add(backup);
        } catch (e, stack) {
          EnvoyReport().log(
            "EnvoySeed",
            "Error deserializing backup: $e",
            stackTrace: stack,
          );
          rethrow;
        }
      }

      for (var backup in ngAccountBackups) {
        final config = backup.ngAccountConfig;
        String fingerprint = backup.xfp;
        if (config.descriptors.isEmpty &&
            backup.publicDescriptors.isEmpty &&
            fingerprint.isEmpty) {
          //pre 2.0.1 wallets doesnt include xfp. also if descriptors are empty, derive from seed
          await deriveAndAddWallets(
            seed,
            passphrase: passphrase,
            requireScan: true,
          );
          continue;
        }
        if (fingerprint.isEmpty) {
          String? descriptor;
          if (backup.publicDescriptors.isNotEmpty) {
            descriptor = backup.publicDescriptors.first.$2;
          } else if (config.descriptors.isNotEmpty) {
            descriptor = config.descriptors.first.internal;
          } else {
            continue;
          }
          try {
            fingerprint = NgAccountManager.getFingerprint(descriptor) ?? "";
          } catch (e) {
            //ignore
          }
        }
        if (fingerprint.isEmpty) {
          continue;
        }
        Directory dir = NgAccountManager.getAccountDirectory(
          deviceSerial: config.deviceSerial ?? "envoy",
          network: config.network.toString(),
          number: config.index,
          fingerprint: fingerprint,
        );
        if (await dir.exists()) {
          bool existInAccountManager = NgAccountManager().accounts.any(
                (element) => element.getWalletDir()?.path == dir.path,
              );
          if (existInAccountManager) {
            continue;
          }
        }
        await dir.create(recursive: true);

        //both hot and cold wallets are restored from backup,
        //hot wallet descriptors will be derived from seed.
        final handler = await EnvoyAccountHandler.restoreFromBackup(
          backup: backup,
          dbPath: dir.path,
          seed: seed,
          passphrase: passphrase,
        );
        final state = await handler.state();
        await NgAccountManager().addAccount(state, handler);
      }

      if (!NgAccountManager().hotAccountsExist()) {
        //pre 2.0.1 wallets doesnt include xfp. also if descriptors are empty, derive from seed
        await deriveAndAddWallets(
          seed,
          passphrase: passphrase,
          requireScan: true,
        );
      }
      await EnvoyReport().log("Magic Backup", "restored v2 accounts");
    } catch (e, stack) {
      EnvoyReport().log(
        "EnvoySeed",
        "Error restoring accounts: $e",
        stackTrace: stack,
      );
    }
  }

  static Map<String, String> extractDataFromPayload(
    List<(String, String)> payload,
  ) {
    var data = <String, String>{};
    for (var (key, value) in payload) {
      data[key] = value;
    }
    return data;
  }

  Future<void> generateAndBackupWalletSilently() async {
    if (Settings().syncToCloud &&
        !Devices().hasNonPrimeDevices() &&
        !walletDerived()) {
      await EnvoyStorage().setBool(PREFS_ONBOARDED, true);
      await generate();
      await backupData();
    }
  }
}
