// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/legacy/legacy_account.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class MigrationProgress {
  int total = 0;
  int completed = 0;

  MigrationProgress({this.total = 0, this.completed = 0});

  double get progress => completed / total;

  bool indeterminate() {
    return total == 0;
  }
}

class LegacyUnifiedAccounts {
  List<LegacyAccount> accounts;
  String network;
  bool isUnified;
  String fingerprint;

  LegacyUnifiedAccounts(
      {required this.accounts,
      required this.network,
      this.isUnified = true,
      required this.fingerprint});
}

class MigrationManager {
  // Singleton instance
  static final MigrationManager _instance = MigrationManager._internal();
  static const String v1accountsPrefKey = "accounts";

  //deprecated,this will be removed in future, double based versioning will be used instead
  static String migrationPrefs = "envoy_v2_migration";

  //deprecated,this will be removed in future, double based versioning will be used instead
  static String migrationVersion = "v2.1";

  //from v2.1 will be using double based versioning for migrations
  static String migrationCodePrefs = "envoy_migration_version_code";

  //current migration code. if existing value is less than this, run migration
  static double migrationVersionCode = 2.26;

  //adds to preferences to indicate that the user has migrated to testnet4
  static String migratedToTestnet4 = "migrated_to_testnet4";
  static String migratedToSignetGlobal = "migrated_to_signet_global";
  static String migratedToUnifiedAccounts = "migrated_to_unified_accounts";

  // Private constructor
  MigrationManager._internal();

  // Factory constructor to return the singleton instance
  factory MigrationManager() {
    return _instance;
  }

  VoidCallback? _onMigrationFinished;
  VoidCallback? _onMigrationError;

  MigrationManager onMigrationFinished(VoidCallback onMigrationFinished) {
    _onMigrationFinished = onMigrationFinished;
    return this;
  }

  MigrationManager onMigrationError(VoidCallback onMigrationError) {
    _onMigrationError = onMigrationError;
    return this;
  }

  Function(MigrationProgress progress)? onProgressListener;

  final LocalStorage _ls = LocalStorage();
  static String legacyWalletDirectory =
      "${LocalStorage().appDocumentsDir.path}/wallets/";
  List<EnvoyAccountHandler> accounts = [];

  final StreamController<MigrationProgress> _streamController =
      StreamController<MigrationProgress>.broadcast();

  Stream<MigrationProgress> get migrationProgress =>
      _streamController.stream.asBroadcastStream();

  dispose() {
    _streamController.close();
  }

  void addMigrationEvent(
    MigrationProgress migrationProgress,
  ) {
    _streamController.sink.add(migrationProgress);
  }

  Future migrate() async {
    final currentMigrationVersion = await getCurrentMigrationVersion();
    kPrint("Migration version: $currentMigrationVersion");
    if (currentMigrationVersion != null &&
        currentMigrationVersion < migrationVersionCode) {
      try {
        await mergeWithFingerPrint();
        await Future.delayed(const Duration(milliseconds: 50));
        await sanityCheck();
        await Future.delayed(const Duration(milliseconds: 50));
        _onMigrationFinished?.call();
      } catch (e, stack) {
        EnvoyReport().log("Migration", "Error migrating accounts: $e",
            stackTrace: stack);
        _onMigrationError?.call();
      }
    } else if (currentMigrationVersion == null) {
      try {
        await migrateToV2();
        await Future.delayed(const Duration(milliseconds: 50));
        await sanityCheck();
        _onMigrationFinished?.call();
      } catch (e, stack) {
        EnvoyReport()
            .log("Migration", "Migration v2 error: $e", stackTrace: stack);
        _onMigrationError?.call();
      }
    } else {
      _onMigrationFinished?.call();
    }
  }

  //2.0
  Future migrateToV2() async {
    final newWalletDirectory = NgAccountManager.walletsDirectory;
    //clean directory for new wallets
    if (await Directory(newWalletDirectory).exists()) {
      await Directory(newWalletDirectory).delete(recursive: true);
    }
    if (_ls.prefs.containsKey(NgAccountManager.v1AccountsPrefKey)) {
      List<dynamic> accountsJson =
          jsonDecode(_ls.prefs.getString(NgAccountManager.v1AccountsPrefKey)!)
              .toList();
      final List<LegacyAccount> legacyAccounts = await loadLegacyAccounts();

      EnvoyReport().log(
        "Migration",
        "Total accounts found: ${legacyAccounts.length} ",
      );
      List<LegacyUnifiedAccounts> unifiedLegacyAccounts = unify(legacyAccounts);
      addMigrationEvent(
          MigrationProgress(total: unifiedLegacyAccounts.length, completed: 0));

      final accounts = await createAccounts(unifiedLegacyAccounts);
      if (accounts.isEmpty) {
        return;
      }
      try {
        try {
          for (var account in accounts) {
            try {
              await migrateMeta(account, legacyAccounts);
            } catch (e) {
              EnvoyReport().log("Migration", "Error migrating meta: $e");
            }
            await Future.delayed(const Duration(milliseconds: 100));
            addMigrationEvent(MigrationProgress(
                total: accounts.length,
                completed: accounts.indexOf(account) + 1));
          }
        } catch (e) {
          EnvoyReport().log("Migration", "Error migrating meta: $e");
        }

        for (var account in accounts) {
          account.dispose();
        }
        //restore will reload all accounts and start normal sync
        final v1backupFile =
            File("${LocalStorage().appDocumentsDir.path}/v1_accounts.json");
        await v1backupFile.create(recursive: true);
        await v1backupFile.writeAsString(jsonEncode(accountsJson));
      } catch (e, stack) {
        EnvoyReport().log("Migration", "Error migrating accounts: $e",
            stackTrace: stack);
        rethrow;
      }
      //   //Load accounts to account manager
    } else {
      EnvoyReport().log("Migration", "No accounts found");
    }
  }

  //2.2
  //move accounts with same fingerprint to new directory
  //the directory name will be {deviceSerial}_{network}_{xfp}_acc_{index}
  Future mergeWithFingerPrint() async {
    EnvoyReport().log("Migration", "Merging with fingerprint");
    final newWalletDirectory = NgAccountManager.walletsDirectory;
    final walletDirectory = Directory(newWalletDirectory);
    List<LegacyAccount> legacyAccounts = await loadLegacyAccounts();
    List<LegacyUnifiedAccounts> unifiedLegacyAccounts = unify(legacyAccounts);
    final dirs = await walletDirectory.list().toList();
    // Track all accounts that are opened after merge, this will be used to dispose
    final List<EnvoyAccountHandler> accounts = [];
    try {
      Map<(String, Network, int), List<EnvoyAccountHandler>> needsMerges = {};
      for (var dir in dirs) {
        if (dir is Directory) {
          try {
            final accountHandler =
                await EnvoyAccountHandler.openAccount(dbPath: dir.path);
            final state = await accountHandler.state();
            if (needsMerges
                .containsKey((state.xfp, state.network, state.index))) {
              needsMerges[(state.xfp, state.network, state.index)]!
                  .add(accountHandler);
            } else {
              needsMerges[(state.xfp, state.network, state.index)] = [
                accountHandler
              ];
            }
            accounts.add(accountHandler);
          } catch (e, stack) {
            EnvoyReport().log("Migration", "Error opening wallet: $e",
                stackTrace: stack);
          }
        }
      }

      //for debugging purposes
      String mergeStrategy = "";
      for (var (xfp, network, index) in needsMerges.keys) {
        List<EnvoyAccount>? states = await Future.wait(
            needsMerges[(xfp, network, index)]!.map((e) => e.state()).toList());
        mergeStrategy += "( $xfp $network $index ) -> ${needsMerges[(
          xfp,
          network,
          index
        )]!.length} | ${states.map((e) => " [${e.name} - ${e.deviceSerial}] ").join(",")} \n";
      }
      EnvoyReport()
          .log("Migration", "XFP merge : merge strategy\n$mergeStrategy");

      for (var (xfp, network, index) in needsMerges.keys) {
        final accounts = needsMerges[(xfp, network, index)]!;
        //needs merge
        if (accounts.length == 2) {
          await mergeTwoAccounts(accounts.first, accounts.last);
        } else {
          // relocate and check missing descriptors
          if (accounts.length == 1) {
            final firstAccount = accounts.first;
            final firstAccountState = await accounts.first.state();
            final addressTypes = firstAccountState.descriptors
                .map((e) => e.addressType)
                .toList();
            //if an existing account missing any descriptors, during 2.0  migration
            //based legacy account type, if this account finger print matches any other legacy account
            // and if they have more descriptors, then add the missing descriptors and to the parent account
            final v1Accounts =
                legacyAccounts.where((e) => e.extractFingerprint() == xfp);
            if (v1Accounts.length == 2) {
              LegacyAccount accountOne = v1Accounts.first;
              LegacyAccount accountTwo = v1Accounts.last;
              LegacyAccount? missingAccount;
              if (!addressTypes.contains(AddressType.p2Tr)) {
                if (accountOne.wallet.type == "taproot") {
                  missingAccount = accountTwo;
                }
                if (accountTwo.wallet.type == "taproot") {
                  missingAccount = accountTwo;
                }
              }
              if (!addressTypes.contains(AddressType.p2Wpkh)) {
                if (accountOne.wallet.type == "witnessPublicKeyHash") {
                  missingAccount = accountTwo;
                }
                if (accountTwo.wallet.type == "witnessPublicKeyHash") {
                  missingAccount = accountTwo;
                }
              }
              if (missingAccount != null) {
                EnvoyReport().log("Migration",
                    "Missing descriptor found for ${firstAccountState.name} adding ${missingAccount.wallet.type}");
                final ngDescriptor = NgDescriptor(
                  addressType: missingAccount.wallet.type == "taproot"
                      ? AddressType.p2Tr
                      : AddressType.p2Wpkh,
                  internal: missingAccount.wallet.internalDescriptor!,
                  external_: missingAccount.wallet.externalDescriptor,
                );
                await firstAccount.addDescriptor(ngDescriptor: ngDescriptor);
                await Future.delayed(const Duration(milliseconds: 400));
                EnvoyReport().log("Migration",
                    "Descriptor added for ${firstAccountState.name} ${missingAccount.wallet.type}");
              }
            }
            await relocateAccount(firstAccount, firstAccountState);
          } else {
            for (var account in accounts) {
              await relocateAccount(account, await account.state());
            }
          }
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      //add missing legacy accounts
      for (var legacyAccount in unifiedLegacyAccounts) {
        if (legacyAccount.accounts.isEmpty) {
          continue;
        }
        LegacyAccount account = legacyAccount.accounts.first;
        final dir = NgAccountManager.getAccountDirectory(
            deviceSerial: legacyAccount.accounts.first.deviceSerial,
            network: legacyAccount.accounts.first.wallet.network.toLowerCase(),
            fingerprint: legacyAccount.fingerprint,
            number: legacyAccount.accounts.first.number);
        if (!await dir.exists()) {
          if (legacyAccount.accounts.first.deviceSerial == "envoy") {
            final existingEnvoyWallet = dirs.firstWhereOrNull((e) => e.path
                .contains("envoy_${account.wallet.network.toLowerCase()}"));
            if (existingEnvoyWallet != null) {
              continue;
            }
          }
          final missingAccounts = await createAccounts([legacyAccount]);
          for (var account in missingAccounts) {
            await migrateMeta(account, legacyAccounts);
            accounts.add(account);
          }
        }
      }
      addMigrationEvent(
          MigrationProgress(total: dirs.length, completed: dirs.length));
      await Future.delayed(const Duration(milliseconds: 300));

      await cleanupMalformedDirectories();
      return;
    } catch (e, stack) {
      EnvoyReport()
          .log("Migration", "Error migrating accounts: $e", stackTrace: stack);
    } finally {
      //make sure all accounts are disposed
      for (var account in accounts) {
        if (!account.isDisposed) {
          kPrint("Disposing account after merge ${account.id()}");
          account.dispose();
          // Wait for each disposal to complete
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
    return;
  }

  Future<void> copyDirectory(Directory source, Directory destination) async {
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        var newDirectory =
            Directory(join(destination.absolute.path, basename(entity.path)));
        await newDirectory.create();
        await copyDirectory(entity.absolute, newDirectory);
      } else if (entity is File) {
        await entity.copy(join(destination.path, basename(entity.path)));
      }
    }
  }

  Future<List<EnvoyAccountHandler>> createAccounts(
      List<LegacyUnifiedAccounts> unifiedLegacyAccounts) async {
    final List<EnvoyAccountHandler> handlers = [];
    final accountOrder =
        LocalStorage().prefs.getString(NgAccountManager.ACCOUNT_ORDER);
    List<String> walletOrder =
        List<String>.from(jsonDecode(accountOrder ?? "[]"));

    bool taprootEnabled = Settings().taprootEnabled();
    bool showTestnet = Settings().showTestnetAccounts();
    bool showSignet = Settings().showSignetAccounts();
    bool isTaprootEnabled = Settings().taprootEnabled();

    for (LegacyUnifiedAccounts unified in unifiedLegacyAccounts) {
      //use externalDescriptor and internalDescriptor
      final legacyAccount = unified.accounts.first;

      String? descriptor = legacyAccount.wallet.internalDescriptor ??
          legacyAccount.wallet.externalDescriptor;
      final fingerprint = NgAccountManager.getFingerprint(
          legacyAccount.wallet.internalDescriptor ?? "");

      //probably hot wallet that does have descriptors
      if (fingerprint == null || descriptor == null) {
        throw Exception(
            "Failed to get fingerprint for account ${legacyAccount.name} ${legacyAccount.wallet.externalDescriptor} ${legacyAccount.wallet.internalDescriptor}");
      }

      Directory newAccountDir = NgAccountManager.getAccountDirectory(
          deviceSerial: legacyAccount.deviceSerial,
          network: legacyAccount.wallet.network.toLowerCase(),
          fingerprint: fingerprint,
          number: legacyAccount.number);

      if (!newAccountDir.existsSync()) {
        await newAccountDir.create(recursive: true);
      }
      await Future.delayed(const Duration(milliseconds: 100));

      var network = Network.bitcoin;
      if (legacyAccount.wallet.network.toLowerCase() == "testnet") {
        if (showTestnet) {
          LocalStorage().prefs.setBool(migratedToTestnet4, true);
          await Settings().setShowTestnetAccounts(false);
        }
        network = Network.testnet4;
      } else if (legacyAccount.wallet.network.toLowerCase() == "signet") {
        if (showSignet) {
          LocalStorage().prefs.setBool(migratedToSignetGlobal, true);
          await Settings().setShowSignetAccounts(false);
        }
        network = Network.signet;
      }
      if (isTaprootEnabled) {
        LocalStorage().prefs.setBool(migratedToUnifiedAccounts, true);
      }

      List<Directory> oldWalletDirPaths = [];
      for (var account in unified.accounts) {
        final dir = Directory("$legacyWalletDirectory${account.wallet.name}");
        if (dir.existsSync()) {
          oldWalletDirPaths.add(dir);
        }
      }
      final descriptors = unified.accounts.map((account) {
        AddressType addressType = AddressType.p2Wpkh;
        if (account.wallet.type == "taproot") {
          addressType = AddressType.p2Tr;
        }
        return NgDescriptor(
          addressType: addressType,
          internal: account.wallet.internalDescriptor!,
          external_: account.wallet.externalDescriptor,
        );
      }).toList();

      //default to first address type as the preferred address type
      var addressType = descriptors.first.addressType;
      if (descriptors.length != 1) {
        //  if the user already has a taproot enabled use taproot as preferred
        addressType = taprootEnabled ? AddressType.p2Tr : AddressType.p2Wpkh;
      }
      final newId = Uuid().v4();
      addressType = descriptors.first.addressType;
      EnvoyReport().log(
          "Migration",
          "Migrating account ${descriptors.map((e) => e.addressType)} "
              "$addressType ${legacyAccount.name} ${legacyAccount.wallet.network.toLowerCase()}");

      final envoyAccount = await EnvoyAccountHandler.migrate(
          name: legacyAccount.name,
          color: colorToHex(getAccountColor(legacyAccount)),
          deviceSerial: legacyAccount.deviceSerial,
          dateAdded: legacyAccount.dateAdded,
          addressType: addressType,
          descriptors: descriptors,
          index: legacyAccount.number,
          network: network,
          id: newId,
          dbPath: newAccountDir.path,
          legacySledDbPath: oldWalletDirPaths
              .map(
                (e) => e.path,
              )
              .toList());
      handlers.add(envoyAccount);
      walletOrder.add(newId);
    }
    await NgAccountManager().updateAccountOrder(walletOrder);
    return handlers;
  }

  static List<LegacyUnifiedAccounts> unify(List<LegacyAccount> legacyAccount) {
    final unifiedId =
        legacyAccount.map((item) => item.getUnificationId()).toSet().toList();

    List<LegacyUnifiedAccounts> unifiedWallets = [];
    for (var id in unifiedId) {
      final accounts =
          legacyAccount.where((item) => item.getUnificationId() == id).toList();

      if (accounts.length <= 2) {
        EnvoyReport().log(
          "Migration",
          "Unifying accounts with id ${accounts.map((item) => item.name)} ${accounts.first.extractFingerprint()} ${accounts.first.wallet.network.toLowerCase()} ",
        );
        final fingerprint = accounts.first.extractFingerprint();
        if (fingerprint == null) {
          EnvoyReport().log(
            "Migration",
            "unify,Failed to get fingerprint for account ${accounts.first.name}  ",
          );
          continue;
        }
        unifiedWallets.add(LegacyUnifiedAccounts(
            accounts: accounts,
            network: accounts.first.wallet.network.toLowerCase(),
            fingerprint: fingerprint));
      } else {
        EnvoyReport().log(
          "Migration",
          "Will treat as single accounts ::  ${accounts.map((item) => item.name)}"
              " ${accounts.map((item) => "${item.wallet.internalDescriptor}:${item.extractFingerprint()}")} ",
        );
        final Map<AddressType, LegacyAccount> unifiedSet = {};
        for (var account in accounts) {
          AddressType addressType = AddressType.p2Wpkh;
          if (account.wallet.type == "taproot") {
            addressType = AddressType.p2Tr;
          }
          if (unifiedSet.containsKey(addressType)) {
            continue;
          }
          unifiedSet[addressType] = account;
        }
        //SFT-5217, duplicated accounts with similar device serial and account number
        //to properly migrate without conflict,adding account id as part of the device serial
        LegacyAccount accountWithUniqueId = unifiedSet.values.first;
        final fingerprint = accountWithUniqueId.extractFingerprint();
        if (fingerprint == null) {
          EnvoyReport().log(
            "Migration",
            "unify,Failed to get fingerprint for account ${accounts.first.name}  ",
          );
          continue;
        }
        unifiedWallets.add(LegacyUnifiedAccounts(
            accounts: unifiedSet.values.toList(),
            isUnified: false,
            fingerprint: fingerprint,
            network: unifiedSet.values.first.wallet.network.toLowerCase()));
      }
    }
    return unifiedWallets;
  }

  //migrate notes to new db.
  static Future migrateMeta(
      EnvoyAccountHandler handler, List<LegacyAccount> legacyAccounts) async {
    try {
      final state = await handler.state();
      for (var legacyAccount in legacyAccounts) {
        bool matchWithHotWallet = (state.isHot &&
            state.network
                .toString()
                .toLowerCase()
                .contains(legacyAccount.wallet.network.toLowerCase()));
        if (!matchWithHotWallet) {
          matchWithHotWallet = legacyAccount.extractFingerprint() == state.xfp;
        }
        kPrint(
            "Migrating meta for ${legacyAccount.name} ${legacyAccount.wallet.network.toLowerCase()}");
        for (var descriptor in state.descriptors) {
          bool matchWithDescriptor =
              descriptor.internal == legacyAccount.wallet.internalDescriptor;
          if (matchWithDescriptor || matchWithHotWallet) {
            kPrint(
                "Found descriptor ${legacyAccount.name} ${descriptor.addressType}");
            List<String> blockedCoins =
                await CoinRepository().getBlockedCoins();
            Map<String, String> tagsMap =
                await CoinRepository().getTagMap(accountId: legacyAccount.id);
            Map<String, String> notes = await EnvoyStorage().getAllNotes();
            Map<String, bool> doNotSpendMap = {};
            for (var blocked in blockedCoins) {
              doNotSpendMap[blocked] = true;
            }
            await handler.migrateMeta(
                notes: notes, tags: tagsMap, doNotSpend: doNotSpendMap);
          }
        }
      }
    } catch (e, stack) {
      EnvoyReport()
          .log("Migration", "Error migrating meta: $e", stackTrace: stack);
    }
  }

  //Performs a sanity check to ensure all legacy accounts have been properly migrated.
  Future sanityCheck() async {
    final legacyAccounts = await loadLegacyAccounts();
    final unifiedAccounts = unify(legacyAccounts);
    final newWalletDirectory = Directory(NgAccountManager.walletsDirectory);
    final dirs = await newWalletDirectory.list().toList();
    for (var dir in dirs) {
      if (dir is Directory) {
        try {
          final accountHandler =
              await EnvoyAccountHandler.openAccount(dbPath: dir.path);
          accountHandler.dispose();
        } catch (e, stack) {
          EnvoyReport()
              .log("Migration", "Error opening wallet: $e", stackTrace: stack);
        }
      }
    }
    if (legacyAccounts.isEmpty) {
      EnvoyReport().log("Migration", "SanityCheck: No legacy accounts found");
      return;
    }
    try {
      String logBuffer = "";
      for (var unified in unifiedAccounts) {
        final firstAccount = unified.accounts.first;
        logBuffer += "\n\nChecking SuperWallet : \"${firstAccount.name}\" \n";

        final accountDir = NgAccountManager.getAccountDirectory(
            deviceSerial: firstAccount.deviceSerial,
            network: unified.network,
            fingerprint: unified.fingerprint,
            number: firstAccount.number);

        logBuffer += "Account directory: ${accountDir.path}\n";

        if (!await accountDir.exists()) {
          logBuffer +=
              "Account directory does not exist: ${accountDir.path} ❌\n";
          continue;
        }

        final files = await accountDir.list().toList();
        logBuffer += "Found ${files.length} files in directory\n";

        bool allAccountsValid = true;

        for (var account in unified.accounts) {
          logBuffer +=
              "-----\nValidating account Type (${account.wallet.type})";

          final fileNames = files.map((f) => f.path.toLowerCase()).toList();
          bool hasP2tr = fileNames.any((name) => name.endsWith('_p2tr.sqlite'));
          bool hasP2wpkh =
              fileNames.any((name) => name.endsWith('_p2wpkh.sqlite'));

          String status = "";
          if (account.wallet.type == "taproot") {
            status = hasP2tr ? "✅" : "❌ Missing *_P2tr.sqlite file";
            if (!hasP2tr) allAccountsValid = false;
          } else if (account.wallet.type == "witnessPublicKeyHash") {
            status = hasP2wpkh ? "✅" : "❌ Missing *_P2wpkh.sqlite file";
            if (!hasP2wpkh) allAccountsValid = false;
          } else {
            status = "✅"; // Other types are valid by default
          }

          logBuffer +=
              "\nAccount \"${account.name}\" (${account.wallet.type}): $status\n-----\n";
        }

        logBuffer +=
            "Overall status for ${firstAccount.name}: ${allAccountsValid ? '✅' : '❌'}\n\n";
      }
      EnvoyReport().log("Migration:SanityCheck", logBuffer);
    } catch (e) {
      //ignore
    }
  }

  static Future<double?> getCurrentMigrationVersion() async {
    final migrationVersion = (await EnvoyStorage()
        .getNoBackUpPreference(MigrationManager.migrationPrefs));

    double? migrationVersionCode = (await EnvoyStorage()
        .getNoBackUpPreference<double>(MigrationManager.migrationCodePrefs));

    if (migrationVersion is String && migrationVersionCode == null) {
      try {
        migrationVersionCode =
            double.parse(migrationVersion.replaceAll("v", ""));
      } catch (e) {
        //ignore
      }
    }
    return migrationVersionCode;
  }

  Future<List<LegacyAccount>> loadLegacyAccounts() async {
    List<LegacyAccount> legacyAccounts = [];
    final v1backupFile =
        File("${LocalStorage().appDocumentsDir.path}/v1_accounts.json");
    if (await v1backupFile.exists()) {
      try {
        List<dynamic> data = jsonDecode(await v1backupFile.readAsString());
        legacyAccounts
            .addAll(data.map((json) => LegacyAccount.fromJson(json)).toList());
      } catch (e, stack) {
        EnvoyReport().log("Migration", "Error loading legacy accounts: $e",
            stackTrace: stack);
      }
    } else if (_ls.prefs.containsKey(NgAccountManager.v1AccountsPrefKey)) {
      List<dynamic> accountsJson =
          jsonDecode(_ls.prefs.getString(NgAccountManager.v1AccountsPrefKey)!)
              .toList();
      legacyAccounts.addAll(
          accountsJson.map((json) => LegacyAccount.fromJson(json)).toList());
    }
    return legacyAccounts;
  }

  //merges two accounts with same xfp,network,index
  Future mergeTwoAccounts(
      EnvoyAccountHandler first, EnvoyAccountHandler last) async {
    final state = await first.state();
    final network = state.network.toString();
    final directory = NgAccountManager.getAccountDirectory(
        deviceSerial: state.deviceSerial ?? "envoy",
        network: network,
        number: state.index,
        fingerprint: state.xfp.toLowerCase());
    final accountOne = first;
    final accountTwo = last;
    try {
      final accountOneState = await accountOne.state();
      final accountTwoState = await accountTwo.state();

      EnvoyReport().log("Migration",
          "Accounts Needs merge ${accountOneState.name} ${accountTwoState.name}");

      final accountOnePath = _getCurrentWalletPath(accountOneState);
      final accountTwoPath = _getCurrentWalletPath(accountTwoState);

      if (await directory.exists()) {
        kPrint("About to delete ${directory.path}");
        await directory.delete(recursive: true);
      }
      await directory.create(recursive: true);
      kPrint("Created directory ${directory.path}");
      kPrint("Created directory existsSync${directory.existsSync()}");

      List<NgDescriptor> descriptors = [];
      descriptors.addAll(accountOneState.descriptors);
      descriptors.addAll(accountTwoState.descriptors);
      final taprootEnabled = Settings().taprootEnabled();
      kPrint(
          "Descriptors: ${descriptors.map((e) => e.addressType).join(",")} ");

      final envoyAccountHandler = await EnvoyAccountHandler.migrate(
          name: accountOneState.name,
          color: accountOneState.color,
          deviceSerial: accountOneState.deviceSerial,
          dateAdded: accountOneState.dateAdded,
          addressType:
              taprootEnabled == true ? AddressType.p2Tr : AddressType.p2Wpkh,
          descriptors: descriptors,
          index: accountOneState.index,
          network: accountTwoState.network,
          id: accountOneState.id,
          dbPath: directory.path,
          legacySledDbPath: []);
      try {
        final backup1 = jsonDecode(await accountOne.getAccountBackup());
        final backup2 = jsonDecode(await accountTwo.getAccountBackup());

        final notes = Map<String, String>.from(backup1["notes"] ?? {})
          ..addAll(Map<String, String>.from(backup2["notes"] ?? {}));
        final tags = Map<String, String>.from(backup1["tags"] ?? {})
          ..addAll(Map<String, String>.from(backup2["tags"] ?? {}));

        final doNotSpend = Map<String, bool>.from(backup1["do_not_spend"] ?? {})
          ..addAll(Map<String, bool>.from(backup2["do_not_spend"] ?? {}));

        kPrint("MigrationV2.1 meta for ${accountOneState.name}");
        await envoyAccountHandler.migrateMeta(
            notes: notes, tags: tags, doNotSpend: doNotSpend);
      } catch (e) {
        EnvoyReport().log("MigrationV2.1", "Error migrating meta: $e");
      }
      await LocalStorage()
          .prefs
          .setAccountScanStatus(accountOneState.id, AddressType.p2Pkh, false);
      await LocalStorage()
          .prefs
          .setAccountScanStatus(accountOneState.id, AddressType.p2Tr, false);

      accountTwo.dispose();
      envoyAccountHandler.dispose();
      accountOne.dispose();
      await Future.delayed(const Duration(milliseconds: 100));
      kPrint("Deleting old wallet paths");
      await accountOnePath.delete(recursive: true);
      await accountTwoPath.delete(recursive: true);

      kPrint("Deleting old wallet paths successful");
      EnvoyReport().log("Migration",
          "Accounts merged ${accountOneState.name} ${accountTwoState.name}  ");
      kPrint("Migrated ");
    } catch (e, stack) {
      if (!accountOne.isDisposed) accountOne.dispose();
      if (!accountTwo.isDisposed) accountTwo.dispose();
      kPrint("Error opening wallet: $e", stackTrace: stack);
    }
  }

  //relocates an account to a xfp based directory
  Future relocateAccount(
      EnvoyAccountHandler account, EnvoyAccount state) async {
    final network = state.network.toString();
    //get old wallet directory. this doesn't include xfp
    final currentPath = _getCurrentWalletPath(state);
    final dir = NgAccountManager.getAccountDirectory(
        deviceSerial: state.deviceSerial ?? "envoy",
        network: network,
        number: state.index,
        fingerprint: state.xfp.toLowerCase());
    if (dir.path == currentPath.path) {
      return;
    }
    try {
      await dir.create(recursive: true);
      EnvoyReport().log("Migration",
          "Relocating account ${state.name} (${state.network}) ${state.walletPath} to ${dir.path}");
      await account.updateWalletPath(walletPath: dir.path);
      account.dispose();
      await Future.delayed(const Duration(milliseconds: 600));
      await copyDirectory(currentPath, dir);
      EnvoyReport().log("Migration",
          "Relocated account ${state.name} ${dir.path}, and deleting old path ${currentPath.path}");
      await currentPath.delete(recursive: true);
      kPrint("Deleted old wallet path");
    } catch (e, stack) {
      EnvoyReport()
          .log("Migration", "Error relocating account: $e", stackTrace: stack);
    }
  }

  Future cleanupMalformedDirectories() async {
    final newWalletDirectory = NgAccountManager.walletsDirectory;
    final walletDirectory = Directory(newWalletDirectory);
    final walletDirs = await walletDirectory.list().toList();
    try {
      for (var dir in walletDirs) {
        if (dir is Directory) {
          //regex that checks the dir patter {deviceSerial}_{network}_{xfp}_acc_{index}
          final regex = RegExp(r'^[\w-]+_\w+_[a-f0-9]+_acc_\d+$');
          final dirName = dir.path.split(Platform.pathSeparator).last;
          final match = regex.hasMatch(dirName.toLowerCase());
          if (!match) {
            dir.delete(recursive: true);
            kPrint("Deleted dangling account: $dirName");
          }
        }
      }
    } catch (e) {
      //ignore
    }
  }

  Future<bool> isMigrationRequired() async {
    final walletDirectdory = Directory(NgAccountManager.walletsDirectory);

    EnvoyReport().log("Migration", "walletDirectdory ${walletDirectdory.path}");
    // check if user has legacy accounts
    bool hasAccounts =
        LocalStorage().prefs.containsKey(NgAccountManager.v1AccountsPrefKey);
    if (hasAccounts) {
      try {
        hasAccounts = jsonDecode(LocalStorage()
                    .prefs
                    .getString(NgAccountManager.v1AccountsPrefKey) ??
                "[]")
            .isNotEmpty;
      } catch (e) {
        hasAccounts = false;
      }
    }
    kPrint("Has accounts: $hasAccounts");

    // get current migration version
    double? currentMigrationVersion = await EnvoyStorage()
        .getNoBackUpPreference<double>(MigrationManager.migrationCodePrefs);

    kPrint("Current migration version from prefs: $currentMigrationVersion");
    // handle legacy string-based version, TOOD: remove in v2.5
    if (currentMigrationVersion == null) {
      final legacyVersion = await EnvoyStorage()
          .getNoBackUpPreference(MigrationManager.migrationPrefs);
      if (legacyVersion is String) {
        try {
          currentMigrationVersion =
              double.parse(legacyVersion.replaceAll("v", ""));
        } catch (e) {
          currentMigrationVersion = 0.0; // Treat as unmigrated
        }
      }
    }

    currentMigrationVersion ??= 0.0;

    bool requiresMigration = hasAccounts &&
        (currentMigrationVersion < MigrationManager.migrationVersionCode);

    final newWalletDirectory = NgAccountManager.walletsDirectory;
    final legacyWalletDirectory =
        Directory(MigrationManager.legacyWalletDirectory);
    final walletDirectory = Directory(newWalletDirectory);

    int legacyWallets = 0;
    int ngWallets = 0;

    if (currentMigrationVersion < 2) {
      if (await legacyWalletDirectory.exists()) {
        legacyWallets = await legacyWalletDirectory.list().length;
      }
      if (await walletDirectory.exists()) {
        ngWallets = await walletDirectory.list().length;
      }
      kPrint("Legacy wallets: $legacyWallets, NG wallets: $ngWallets");
      if (legacyWallets != 0 || ngWallets != 0) {
        kPrint("Legacy wallets: requiresMigration");
        requiresMigration = true;
      } else {
        requiresMigration = false;
      }
    }

    // Update version if no migration needed
    if (!requiresMigration) {
      await resetMigrationPrefs();
    }
    final a = await PackageInfo.fromPlatform();

    EnvoyReport().log(
        "Migration",
        "Current migration version: $currentMigrationVersion,"
            " Required: ${MigrationManager.migrationVersionCode},"
            " Requires migration: $requiresMigration\n"
            " App version: ${a.version}  (${a.buildNumber})  ");

    return requiresMigration;
  }

  //[IOS] state.walletPath needs to be prefixed with
  // NgAccountManager.walletsDirectory
  //v2.0.2 wont be needed since xfp based directory is used
  Directory _getCurrentWalletPath(EnvoyAccount state) {
    final walletPath = state.walletPath!;
    final target = walletPath.split('wallets_v2/').last;
    return Directory(join(
      NgAccountManager.walletsDirectory,
      target,
    ));
  }

  Future resetMigrationPrefs() async {
    try {
      await EnvoyStorage().setNoBackUpPreference(
          MigrationManager.migrationCodePrefs,
          MigrationManager.migrationVersionCode);
    } catch (_) {
      //ignore
    }
  }
}

Color getAccountColor(
  LegacyAccount account,
) {
  // Postmix accounts are pure red
  if (account.number == 2147483646) {
    return Colors.red;
  }
  final wallet = account.wallet;
  int colorIndex = (wallet.hot ? account.number + 1 : account.number) %
      (EnvoyColors.listAccountTileColors.length);
  return EnvoyColors.listAccountTileColors[colorIndex];
}

String colorToHex(Color color) {
  // Convert double values to int (0-255 range)
  int r = (color.r * 255).round();
  int g = (color.g * 255).round();
  int b = (color.b * 255).round();

  return '#${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}
