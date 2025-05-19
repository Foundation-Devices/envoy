// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/legacy/legacy_account.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/local_storage.dart';
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
  static const String accountsPrefKey = "accounts";
  static String migrationPrefs = "envoy_v2_migration";

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
    if (_ls.prefs.containsKey(accountsPrefKey)) {
      List<dynamic> accountsJson =
          jsonDecode(_ls.prefs.getString(accountsPrefKey)!).toList();
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
          await migrateDoNotSpend(account);
          await migrateNotes(account);
          await migrateTags(account);
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
        await LocalStorage().prefs.remove(accountsPrefKey);
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
        network = Network.testnet;
      } else if (legacyAccount.wallet.network.toLowerCase() == "signet") {
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

      var addressType = AddressType.p2Wpkh;
      if (legacyAccount.wallet.type == "taproot") {
        addressType = AddressType.p2Tr;
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
  //this will get all notes that try to set it to account,\
  //ngwallet will only take notes that are associated with its transactions
  Future migrateNotes(EnvoyAccountHandler envoyAccount) async {
    kPrint("Migration: Migrating notes");
    final storage = EnvoyStorage();
    final notes = await storage.getAllNotes();
    try {
      for (var entry in notes.entries) {
        try {
          EnvoyReport().log(
            "Migration",
            "Migrating note ${entry.key}  with ${entry.value} -> ${envoyAccount.config().name} ${envoyAccount.config().descriptors.map(
                  (e) => " ${e.external_}\n",
                )}\n",
          );
          await envoyAccount.setNote(note: entry.value, txId: entry.key);
        } catch (_) {}
      }
    } catch (e) {
      EnvoyReport().log(
        "Migration",
        "Error migrating notes for account ${envoyAccount.config().id} $e",
      );
    }
  }

  Future migrateTags(EnvoyAccountHandler account) async {
    kPrint("Migration: Migrating tags");
    List<CoinTag> tags =
        await CoinRepository().getCoinTags(accountId: account.config().id);
    try {
      for (var tag in tags) {
        kPrint(
            "Migration: Migrating tag ${tag.name}  with ${tag.coins.length} coins");
        EnvoyReport().log(
          "Migration",
          "Migrating tag ${tag.name}  with ${tag.coins.length}  to account -->  ${account.config().name}",
        );
        for (var id in tag.coinsId) {
          final txId = id.split(":")[0];
          final vout = int.parse(id.split(":")[1]);
          await account.setTag(
              utxo: Output(
                  txId: txId,
                  vout: vout,
                  amount: BigInt.zero,
                  isConfirmed: true,
                  address: "",
                  doNotSpend: false),
              tag: tag.name);
        }
      }
    } catch (e) {
      EnvoyReport().log(
        "Migration",
        "Error migrating tags for account ${account.config().id} $e",
      );
    }
  }

  Future migrateDoNotSpend(EnvoyAccountHandler account) async {
    kPrint("Migration: Migrating do not spend");
    List<String> blockedCoins = await CoinRepository().getBlockedCoins();
    List<Output> utxos = await account.utxo();
    try {
      for (var blocked in blockedCoins) {
        for (var element
            in utxos.where((element) => element.getId() == blocked).toList()) {
          await account.setDoNotSpend(utxo: element, doNotSpend: true);
        }
      }
    } catch (e) {
      EnvoyReport().log(
        "Migration",
        "Error migrating DNSfor account ${account.config().id} $e",
      );
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
