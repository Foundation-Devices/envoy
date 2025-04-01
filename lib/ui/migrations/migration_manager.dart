import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/legacy/legacy_account.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
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
  factory MigrationManager()  {
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

  addMigrationEvent(MigrationProgress migrationProgress,) {
    _streamController.sink.add(migrationProgress);
  }

  void migrate() async {
    kPrint("Migration: Starting");
    try {
      //clean directory for new wallets
      if (Directory(newWalletDirectory).existsSync()) {
        Directory(newWalletDirectory).deleteSync(recursive: true);
      }
      final walletOrder = List<String>.empty(growable: true);
      if (_ls.prefs.containsKey(ACCOUNTS_PREFS)) {
        List<dynamic> accountsJson =
        jsonDecode(_ls.prefs.getString(ACCOUNTS_PREFS)!).toList();

        List<LegacyAccount> legacyAccounts =
        accountsJson.map((json) => LegacyAccount.fromJson(json)).toList();

        addMigrationEvent(
            MigrationProgress(total: legacyAccounts.length, completed: 0));

        for (LegacyAccount legacyAccount in legacyAccounts) {
          //use externalDescriptor and internalDescriptor
          final newAccountDir =
          Directory("$newWalletDirectory${legacyAccount.wallet.name}");
          final oldWalletDir =
          Directory("$walletsDirectory${legacyAccount.wallet.name}");
          if (!newAccountDir.existsSync()) {
            await newAccountDir.create(recursive: true);
          }
          var network = Network.bitcoin;
          if (legacyAccount.wallet.network.toLowerCase() == "testnet") {
            network = Network.testnet;
          } else if (legacyAccount.wallet.network.toLowerCase() == "signet") {
            network = Network.signet;
          }
          var addressType = AddressType.p2Wpkh;
          if (legacyAccount.wallet.type == "taproot") {
            addressType = AddressType.p2Tr;
          }
          final envoyAccount = await EnvoyAccount.migrate(
              name: legacyAccount.name,
              color: colorToHex(getAccountColor(legacyAccount)),
              deviceSerial: legacyAccount.deviceSerial,
              dateAdded: legacyAccount.dateAdded,
              addressType: addressType,
              externalDescriptor: legacyAccount.wallet.externalDescriptor,
              internalDescriptor: legacyAccount.wallet.internalDescriptor,
              index: legacyAccount.number,
              network: network,
              sledDbPath: oldWalletDir.path,
              id: legacyAccount.id,
              dbPath: newAccountDir.path);
          envoyAccount
              .config()
              .id;
          //add dir names to
          walletOrder.add(newAccountDir.path);
          accounts.add(envoyAccount);
        }
        await _ls.prefs.setString(NgAccountManager.ACCOUNT_ORDER, jsonEncode(walletOrder));
        await syncAccounts();
        for (var account in accounts) {
          migrateNotes(account);
        }
        for (var account in accounts) {
           account.dispose();
        }
        NgAccountManager().restore();
      }
    } catch (e, stack) {
      kPrint("Migration: Error $e", stackTrace: stack);
    }
  }

  Future syncAccounts() async {
    kPrint("Migration: Scanning");
    for (EnvoyAccount account in accounts) {
      final accountConfig = account.config();
      var network = Settings.getDefaultFulcrumServers()[0];
      if (accountConfig.network == Network.testnet) {
        network = Settings.TESTNET_ELECTRUM_SERVER;
      } else if (accountConfig.network == Network.signet) {
        network = Settings.MUTINYNET_ELECTRUM_SERVER;
      }
      final scan = await account.requestScan();
      ArcMutexOptionFullScanResponseKeychainKind result =
      await EnvoyAccount.scan(scanRequest: scan, electrumServer: network);
      await account.applyUpdate(scanRequest: result);
      addMigrationEvent(MigrationProgress(
          total: accounts.length, completed: accounts.indexOf(account) + 1));
    }
    _onMigrationFinished?.call();
  }

  //migrate notes to new db.
  //this will get all notes that try to set it to account,\
  //ngwallet will only take notes that are associated with its transactions
  Future migrateNotes(EnvoyAccount envoyAccount) async {
    final storage = EnvoyStorage();
    final notes = await storage.getAllNotes();
    for (var entry in notes.entries) {
      try {
        await envoyAccount.setNote(note: entry.value, txId: entry.key);
      } catch (_) {}
    }
  }

   Color getAccountColor(LegacyAccount account,) {
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
}


