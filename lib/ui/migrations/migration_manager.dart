// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  LegacyUnifiedAccounts(
      {required this.accounts, required this.network, this.isUnified = true});
}

class MigrationManager {
  // Singleton instance
  static final MigrationManager _instance = MigrationManager._internal();
  static const String v1accountsPrefKey = "accounts";

  //deprecated
  static String migrationPrefs = "envoy_v2_migration";

  //deprecated
  static String migrationVersion = "v2.1";

  //from v2.1 will be using double based versioning for migrations
  static String migrationCodePrefs = "envoy_migration_version_code";

  //current migration code. if existing value is less than this, run migration
  static double migrationVersionCode = 2.2;

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
    if (currentMigrationVersion == 2.0 || currentMigrationVersion == 2.1) {
      await mergeWithFingerPrint();
      await Future.delayed(const Duration(milliseconds: 50));
      await sanityCheck();
      await Future.delayed(const Duration(milliseconds: 50));
      _onMigrationFinished?.call();
    } else if (currentMigrationVersion == null) {
      await migrateToV2();
      await Future.delayed(const Duration(milliseconds: 50));
      await sanityCheck();
    } else {
      _onMigrationFinished?.call();
    }
  }

  Future migrateToV2() async {
    final newWalletDirectory = NgAccountManager.walletsDirectory;
    //clean directory for new wallets
    if (await Directory(newWalletDirectory).exists()) {
      await Directory(newWalletDirectory).delete(recursive: true);
    }
    final walletOrder = List<String>.empty(growable: true);
    if (_ls.prefs.containsKey(NgAccountManager.v1AccountsPrefKey)) {
      List<dynamic> accountsJson =
          jsonDecode(_ls.prefs.getString(NgAccountManager.v1AccountsPrefKey)!)
              .toList();
      List<LegacyAccount> legacyAccounts =
          accountsJson.map((json) => LegacyAccount.fromJson(json)).toList();

      EnvoyReport().log(
        "Migration",
        "Total accounts found: ${legacyAccounts.length} ",
      );
      List<LegacyUnifiedAccounts> unifiedLegacyAccounts = unify(legacyAccounts);
      addMigrationEvent(
          MigrationProgress(total: unifiedLegacyAccounts.length, completed: 0));

      final accounts = await createAccounts(unifiedLegacyAccounts);
      if (accounts.isEmpty) {
        _onMigrationFinished?.call();
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
        await NgAccountManager().updateAccountOrder(walletOrder);
        for (var account in accounts) {
          account.dispose();
        }
        //restore will reload all accounts and start normal sync
        final v1backupFile =
            File("${LocalStorage().appDocumentsDir.path}/v1_accounts.json");
        await v1backupFile.create(recursive: true);
        await v1backupFile.writeAsString(jsonEncode(accountsJson));
        _onMigrationFinished?.call();
      } catch (e) {
        _onMigrationError?.call();
        EnvoyReport().log("Migration", "Error migrating accounts: $e");
      }
      //   //Load accounts to account manager
    } else {
      EnvoyReport().log("Migration", "No accounts found");
      _onMigrationFinished?.call();
    }
  }

  Future mergeWithFingerPrint() async {
    EnvoyReport().log("Migration", "Merging with fingerprint");
    final newWalletDirectory = NgAccountManager.walletsDirectory;
    final walletDirectory = Directory(newWalletDirectory);
    final dirs = await walletDirectory.list().toList();
    // Track all accounts that are opened after merge, this will be used to dispose
    final List<EnvoyAccountHandler> accounts = [];
    try {
      List<EnvoyAccountHandler> needsMerge = [];
      List<EnvoyAccountHandler> needsDirectoryChange = [];
      addMigrationEvent(MigrationProgress(total: dirs.length, completed: 1));
      for (var dir in dirs) {
        if (dir is Directory) {
          //version 2.0.1 and 2.0 will have account directory that ends with 8 characters
          //these will need to be merged and moved to fingerprint based directory
          final RegExp lastEightCharsRegex = RegExp(r'_([a-f0-9]{8})$');
          if (lastEightCharsRegex.hasMatch(dir.path)) {
            try {
              final accountHandler =
                  await EnvoyAccountHandler.openAccount(dbPath: dir.path);
              needsMerge.add(accountHandler);
              accounts.add(accountHandler);
            } catch (e) {
              kPrint("Error opening wallet: $e");
            }
          } else {
            final accountHandler =
                await EnvoyAccountHandler.openAccount(dbPath: dir.path);
            accounts.add(accountHandler);
            needsDirectoryChange.add(accountHandler);
          }
        }
      }

      EnvoyReport()
          .log("Migration", "Accounts Needs merge ${needsMerge.length}");
      if (needsMerge.isNotEmpty) {
        Map<String, List<EnvoyAccountHandler>> unified = {};

        for (var account in needsMerge) {
          final state = await account.state();
          final network = state.network.toString();
          final fingerprint = NgAccountManager.getFingerprint(
              state.externalPublicDescriptors.first.$2);
          if (fingerprint == null) {
            throw Exception(
                "Failed to get fingerprint for account ${state.name} ${state.descriptors.map((e) => "${e.external_} | ${e.internal}")}");
          }
          final dir = NgAccountManager.getAccountDirectory(
              deviceSerial: state.deviceSerial ?? "envoy",
              network: network,
              number: state.index,
              fingerprint: fingerprint);
          if (!unified.containsKey(dir.path)) {
            unified[dir.path] = [];
          }
          unified[dir.path]!.add(account);
        }

        for (var directory in unified.keys) {
          final accountHandlers = unified[directory]!;
          if (accountHandlers.length == 2) {
            final accountOne = accountHandlers.first;
            final accountTwo = accountHandlers.last;
            try {
              final accountOneState = await accountOne.state();
              final accountTwoState = await accountTwo.state();
              final accountOnePath = Directory(accountOneState.walletPath!);
              final accountTwoPath = Directory(accountTwoState.walletPath!);

              final dir = Directory(directory);
              if (await dir.exists()) {
                await dir.delete(recursive: true);
              }
              await dir.create(recursive: true);

              List<NgDescriptor> descriptors = [];
              descriptors.addAll(accountOneState.descriptors);
              descriptors.addAll(accountTwoState.descriptors);
              final taprootEnabled = Settings().taprootEnabled();

              final envoyAccountHandler = await EnvoyAccountHandler.migrate(
                  name: accountOneState.name,
                  color: accountOneState.color,
                  deviceSerial: accountOneState.deviceSerial,
                  dateAdded: accountOneState.dateAdded,
                  addressType: taprootEnabled == true
                      ? AddressType.p2Tr
                      : AddressType.p2Wpkh,
                  descriptors: descriptors,
                  index: accountOneState.index,
                  network: accountTwoState.network,
                  id: accountOneState.id,
                  dbPath: dir.path,
                  legacySledDbPath: []);

              try {
                final backup1 = jsonDecode(await accountOne.getAccountBackup());
                final backup2 = jsonDecode(await accountTwo.getAccountBackup());

                final notes = Map<String, String>.from(backup1["notes"] ?? {})
                  ..addAll(Map<String, String>.from(backup2["notes"] ?? {}));
                final tags = Map<String, String>.from(backup1["tags"] ?? {})
                  ..addAll(Map<String, String>.from(backup2["tags"] ?? {}));

                final doNotSpend = Map<String, bool>.from(
                    backup1["do_not_spend"] ?? {})
                  ..addAll(
                      Map<String, bool>.from(backup2["do_not_spend"] ?? {}));

                kPrint("MigrationV2.1 meta for ${accountOneState.name}");
                await envoyAccountHandler.migrateMeta(
                    notes: notes, tags: tags, doNotSpend: doNotSpend);
              } catch (e) {
                EnvoyReport().log("MigrationV2.1", "Error migrating meta: $e");
              }
              await LocalStorage().prefs.setAccountScanStatus(
                  accountOneState.id, AddressType.p2Pkh, false);
              await LocalStorage().prefs.setAccountScanStatus(
                  accountOneState.id, AddressType.p2Tr, false);
              accountTwo.dispose();
              envoyAccountHandler.dispose();
              accountOne.dispose();
              await Future.delayed(const Duration(milliseconds: 100));
              await accountOnePath.delete(recursive: true);
              await accountTwoPath.delete(recursive: true);
              kPrint("Migrated ");
            } catch (e) {
              if (!accountOne.isDisposed) accountOne.dispose();
              if (!accountTwo.isDisposed) accountTwo.dispose();
              kPrint("Error opening wallet: $e");
            }
          }
        }
      }
      EnvoyReport().log("Migration",
          "Accounts Needs directory change ${needsDirectoryChange.length}");
      if (needsDirectoryChange.isNotEmpty) {
        for (var account in needsDirectoryChange) {
          try {
            final state = await account.state();
            final currentPath = Directory(state.walletPath!);
            final network = state.network.toString();
            final fingerprint = NgAccountManager.getFingerprint(
                state.externalPublicDescriptors.first.$2);
            if (fingerprint == null) {
              throw Exception(
                  "Failed to get fingerprint for account ${state.name} ${state.descriptors.map((e) => "${e.external_} | ${e.internal}")}");
            }
            final dir = NgAccountManager.getAccountDirectory(
                deviceSerial: state.deviceSerial ?? "envoy",
                network: network,
                number: state.index,
                fingerprint: fingerprint);
            if (await dir.exists() && (await dir.list().toList()).isNotEmpty) {
              EnvoyReport().log("Migration",
                  "${state.name} | ${state.network} directory exists, skipping");
              continue;
            }
            await dir.create(recursive: true);
            await account.updateWalletPath(walletPath: dir.path);
            account.dispose();
            if (await currentPath.exists()) {
              await for (var entity in currentPath.list(recursive: true)) {
                if (entity is File) {
                  final relativePath =
                      entity.path.substring(currentPath.path.length + 1);
                  final newFile = File('${dir.path}/$relativePath');
                  await newFile.parent.create(recursive: true);
                  await entity.copy(newFile.path);
                }
              }
              await currentPath.delete(recursive: true);
              kPrint("Deleted old wallet path");
            }
          } catch (e, s) {
            EnvoyReport().log("Migration",
                "Error processing directory change for account: $e",
                stackTrace: s);
            if (!account.isDisposed) account.dispose();
          }
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
      addMigrationEvent(
          MigrationProgress(total: dirs.length, completed: dirs.length));
    } catch (e, stack) {
      EnvoyReport()
          .log("Migration", "Error migrating accounts: $e", stackTrace: stack);
    } finally {
      //make sure all accounts are disposed
      for (var account in accounts) {
        if (!account.isDisposed) {
          kPrint("Disposing account ${account.id}");
          account.dispose();
        }
      }
    }
    await Future.delayed(const Duration(milliseconds: 300));
    return;
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
      if (fingerprint == null || descriptor == null) {
        throw Exception(
            "Failed to get fingerprint for account ${legacyAccount.name} ${legacyAccount.wallet.externalDescriptor} ${legacyAccount.wallet.internalDescriptor}");
      }
      Directory newAccountDir = NgAccountManager.getAccountDirectory(
          deviceSerial: legacyAccount.deviceSerial,
          network: legacyAccount.wallet.network,
          fingerprint: fingerprint,
          number: legacyAccount.number);

      if (!newAccountDir.existsSync()) {
        await newAccountDir.create(recursive: true);
      }

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

    await _ls.prefs
        .setString(NgAccountManager.ACCOUNT_ORDER, jsonEncode(walletOrder));
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
          "Unifying accounts with id ${accounts.map((item) => item.name)} ",
        );
        unifiedWallets.add(LegacyUnifiedAccounts(
            accounts: accounts, network: accounts.first.wallet.network));
      } else {
        EnvoyReport().log(
          "Migration",
          "Will treat as single accounts ::  ${accounts.map((item) => item.name)} ",
        );
        //SFT-5217, duplicated accounts with similar device serial and account number
        //to properly migrate without conflict,adding account id as part of the device serial
        for (var account in accounts) {
          LegacyAccount accountWithUniqueId = account;
          unifiedWallets.add(LegacyUnifiedAccounts(
              accounts: [accountWithUniqueId],
              isUnified: false,
              network: account.wallet.network));
        }
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
            legacyAccount.wallet.hot &&
            state.network
                .toString()
                .toLowerCase()
                .contains(legacyAccount.wallet.network.toLowerCase()));

        kPrint(
            "Migrating meta for ${legacyAccount.name} ${legacyAccount.wallet.network}");
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
    } catch (e) {
      EnvoyReport().log("Migration", "Error migrating meta: $e");
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

  //Performs a sanity check to ensure all legacy accounts have been properly migrated.
  //sanityCheck reads the v1 backup file and verifies that all legacy accounts
  //have corresponding migrated account directories. If any accounts are missing,
  //it triggers the migration process for those accounts.
  Future sanityCheck() async {
    final v1backupFile =
        File("${LocalStorage().appDocumentsDir.path}/v1_accounts.json");
    if (await v1backupFile.exists()) {
      try {
        List<dynamic> data = jsonDecode(await v1backupFile.readAsString());
        List<LegacyAccount> legacyAccounts =
            data.map((json) => LegacyAccount.fromJson(json)).toList();
        EnvoyReport().log(
          "Migration",
          "Total accounts found: ${legacyAccounts.length} ",
        );
        List<LegacyUnifiedAccounts> unifiedLegacyAccounts =
            unify(legacyAccounts);
        for (var unified in unifiedLegacyAccounts) {
          final legacyAccount = unified.accounts.first;
          String? descriptor = legacyAccount.wallet.internalDescriptor ??
              legacyAccount.wallet.externalDescriptor;
          final fingerprint = NgAccountManager.getFingerprint(
              legacyAccount.wallet.internalDescriptor ?? "");
          if (fingerprint == null || descriptor == null) {
            throw Exception(
                "Failed to get fingerprint for account ${legacyAccount.name} ${legacyAccount.wallet.externalDescriptor} ${legacyAccount.wallet.internalDescriptor}");
          }
          Directory newAccountDir = NgAccountManager.getAccountDirectory(
              deviceSerial: legacyAccount.deviceSerial,
              network: legacyAccount.wallet.network,
              fingerprint: fingerprint,
              number: legacyAccount.number);
          if (!(await newAccountDir.exists())) {
            EnvoyReport().log("Migration",
                "Sanity check, Found account that needs migration ${legacyAccount.name} ${legacyAccount.wallet.network} ${legacyAccount.number} ");
            final handlers = await createAccounts(
                List<LegacyUnifiedAccounts>.from([unified]));
            EnvoyReport().log("Migration",
                "Sanity check, Migrated account ${legacyAccount.name} ${legacyAccount.wallet.network} ${legacyAccount.number} ");
            for (var handler in handlers) {
              handler.dispose();
            }
          }
        }
      } catch (e, stack) {
        EnvoyReport().log("Migration", "Error sanity checking accounts: $e",
            stackTrace: stack);
      }
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
