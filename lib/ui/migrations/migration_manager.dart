// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/legacy/legacy_account.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:uuid/uuid.dart';

class MigrationProgress {
  int total = 0;
  int completed = 0;

  MigrationProgress({this.total = 0, this.completed = 0});

  double get progress => completed / total;
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
  static String migrationPrefs = "envoy_v2_migration";
  static String migrationVersion = "v2";

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
  static String walletsDirectory =
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

  void migrate() async {
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

      final accounts = await createAccounts(unifiedLegacyAccounts, walletOrder);

      try {
        for (var account in accounts) {
          final state = await account.state();
          await migrateMeta(account, accountId: state.id);
        }
        await NgAccountManager().updateAccountOrder(walletOrder);
        for (var account in accounts) {
          final state = await account.state();
          for (var descriptor in state.descriptors) {
            final scanRequest = await account.requestFullScan(
                addressType: descriptor.addressType);
            await SyncManager()
                .performFullScan(account, descriptor.addressType, scanRequest);
          }
          addMigrationEvent(MigrationProgress(
              total: accounts.length,
              completed: accounts.indexOf(account) + 1));
        }
        for (var account in accounts) {
          account.dispose();
        }
        //restore will reload all accounts and start normal sync
        await NgAccountManager().restore();
        await Future.delayed(const Duration(milliseconds: 300));
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
    }
  }

  Future<List<EnvoyAccountHandler>> createAccounts(
      List<LegacyUnifiedAccounts> unifiedLegacyAccounts,
      List<String> existingWalletOrder) async {
    final List<EnvoyAccountHandler> handlers = [];
    final walletOrder = List<String>.empty(growable: true);
    bool taprootEnabled = Settings().taprootEnabled();
    bool showTestnet = Settings().showTestnetAccounts();
    bool showSignet = Settings().showSignetAccounts();

    for (LegacyUnifiedAccounts unified in unifiedLegacyAccounts) {
      //use externalDescriptor and internalDescriptor
      final legacyAccount = unified.accounts.first;
      Directory newAccountDir = NgAccountManager.getAccountDirectory(
          deviceSerial: legacyAccount.deviceSerial,
          network: legacyAccount.wallet.network,
          accountId: !unified.isUnified ? legacyAccount.id : null,
          number: legacyAccount.number);

      if (!newAccountDir.existsSync()) {
        await newAccountDir.create(recursive: true);
      }

      var network = Network.bitcoin;
      if (legacyAccount.wallet.network.toLowerCase() == "testnet") {
        LocalStorage().prefs.setBool(migratedToTestnet4, true);
        network = Network.testnet;
      } else if (legacyAccount.wallet.network.toLowerCase() == "signet") {
        LocalStorage().prefs.setBool(migratedToSignetGlobal, true);
        network = Network.signet;
      }

      List<Directory> oldWalletDirPaths = [];
      for (var account in unified.accounts) {
        final dir = Directory("$walletsDirectory${account.wallet.name}");
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

    bool hasTestnet = unifiedLegacyAccounts.any((element) =>
        element.accounts.first.wallet.network.toLowerCase() == "testnet");
    bool hasSignet = unifiedLegacyAccounts.any((element) =>
        element.accounts.first.wallet.network.toLowerCase() == "signet");
    if (showTestnet && hasTestnet) {
      await _ls.prefs.setBool(migratedToTestnet4, true);
    }
    if (showSignet && hasSignet) {
      _ls.prefs.setBool(migratedToSignetGlobal, true);
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
        LocalStorage()
            .prefs
            .setBool(MigrationManager.migratedToUnifiedAccounts, true);
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
  static Future migrateMeta(EnvoyAccountHandler handler,
      {String? accountId}) async {
    try {
      List<String> blockedCoins = await CoinRepository().getBlockedCoins();
      Map<String, String> tagsMap = await CoinRepository().getTagMap();
      Map<String, String> notes = await EnvoyStorage().getAllNotes();
      Map<String, bool> doNotSpendMap = {};
      for (var blocked in blockedCoins) {
        doNotSpendMap[blocked] = true;
      }
      await handler.migrateMeta(
          notes: notes, tags: tagsMap, doNotSpend: doNotSpendMap);
    } catch (e) {
      EnvoyReport().log("Migration", "Error migrating meta: $e");
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
