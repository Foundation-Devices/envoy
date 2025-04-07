import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:envoy/account/legacy/legacy_account.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:ngwallet/ngwallet.dart';

class MigrationProgress {
  int total = 0;
  int completed = 0;

  MigrationProgress({this.total = 0, this.completed = 0});

  double get progress => completed / total;
}

class MigrationManager {
  // Singleton instance
  static final MigrationManager _instance = MigrationManager._internal();

  // Private constructor
  MigrationManager._internal();

  // Factory constructor to return the singleton instance
  factory MigrationManager() {
    return _instance;
  }

  VoidCallback? _onMigrationFinished;

  void onMigrationFinished(VoidCallback onMigrationFinished) {
    _onMigrationFinished = onMigrationFinished;
  }

  Function(MigrationProgress progress)? onProgressListener;

  static const String ACCOUNTS_PREFS = "accounts";
  final LocalStorage _ls = LocalStorage();
  static String walletsDirectory =
      "${LocalStorage().appDocumentsDir.path}/wallets/";
  static String newWalletDirectory =
      "${LocalStorage().appDocumentsDir.path}/wallets_new/";
  List<EnvoyAccount> accounts = [];

  final StreamController<MigrationProgress> _streamController =
      StreamController<MigrationProgress>.broadcast();

  Stream<MigrationProgress> get migrationProgress =>
      _streamController.stream.asBroadcastStream();

  dispose() {
    _streamController.close();
  }

  addMigrationEvent(
    MigrationProgress migrationProgress,
  ) {
    _streamController.sink.add(migrationProgress);
  }

  void migrate() async {
    await RustLib.init();
    try {
      //clean directory for new wallets
      if (Directory(newWalletDirectory).existsSync()) {
        Directory(newWalletDirectory).deleteSync(recursive: true);
      }
      if (_ls.prefs.containsKey(ACCOUNTS_PREFS)) {
        var storedAccounts =
            jsonDecode(_ls.prefs.getString(ACCOUNTS_PREFS)!).toList();

        addMigrationEvent(
            MigrationProgress(total: storedAccounts.length, completed: 0));

        for (Map<String, dynamic> account in storedAccounts.toList()) {
          final accountModel = LegacyAccount.fromJson(account);
          //use externalDescriptor and internalDescriptor
          final newAccountDir =
              Directory("$newWalletDirectory${accountModel.wallet.name}");
          if (!newAccountDir.existsSync()) {
            await newAccountDir.create(recursive: true);
          }
          var network = Network.bitcoin;
          if (accountModel.wallet.network.toLowerCase() == "testnet") {
            network = Network.testnet;
          } else if (accountModel.wallet.network.toLowerCase() == "signet") {
            network = Network.signet;
          }
          var addressType = AddressType.p2Wpkh;
          if (accountModel.wallet.type == "taproot") {
            addressType = AddressType.p2Tr;
          }
          final envoyAccount = await EnvoyAccount.newFromDescriptor(
              name: accountModel.name,
              color: "red",
              deviceSerial: accountModel.deviceSerial,
              dateAdded: accountModel.dateAdded,
              addressType: addressType,
              externalDescriptor: accountModel.wallet.externalDescriptor,
              internalDescriptor: accountModel.wallet.internalDescriptor,
              index: accountModel.number,
              network: network,
              dbPath: newAccountDir.path);
          accounts.add(envoyAccount);
        }
        syncAccounts();
      }
    } catch (e, stack) {
      kPrint("Migration: Error $e", stackTrace: stack);
    }
  }

  Future syncAccounts() async {
    kPrint("Migration: Scanning");
    for (EnvoyAccount account in accounts) {
      final accountConfig = await account.getConfig();
      var network = Settings.getDefaultFulcrumServers()[0];
      if (accountConfig.network == Network.testnet) {
        network = Settings.TESTNET_ELECTRUM_SERVER;
      } else if (accountConfig.network == Network.signet) {
        network = Settings.MUTINYNET_ELECTRUM_SERVER;
      }
      kPrint("Migration: Scanning Acc: ${accountConfig.name} ${network}");
      kPrint(" --- ${accountConfig.externalDescriptor}");

      final scan = await account.requestScan();
      ArcMutexOptionFullScanResponseKeychainKind result =
          await EnvoyAccount.scan(scanRequest: scan, electrumServer: network);
      await account.applyUpdate(scanRequest: result);

      kPrint("Migration: Scanning finished ${await account.balance()}");
      kPrint(
          "Migration: Scanning finished transactions size${(await account.transactions()).length}");
      kPrint(
          "Migration: Scanning finished Utxo size${(await account.utxo()).length}");
      kPrint("\n");
      addMigrationEvent(MigrationProgress(
          total: accounts.length, completed: accounts.indexOf(account) + 1));
    }
    _onMigrationFinished?.call();
  }

  //TODO
  Future migrateNotes(
      LegacyAccount accountModel, EnvoyAccount envoyAccount) async {
    final storage = EnvoyStorage();
    final notes = await storage.getAllNotes();
    notes.forEach((key, value) async {
      await envoyAccount.setNote(note: value, txId: key);
    });
  }

  //TODO
  Future migrateTags(
      LegacyAccount accountModel, EnvoyAccount envoyAccount) async {
    final storage = EnvoyStorage();
    final tags = await storage.getAllTags();
  }

  Future migrateRbf(
      LegacyAccount accountModel, EnvoyAccount envoyAccount) async {}
}
