// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:wallet/wallet.dart' as wallet;

class EnvoyStorage {
  String dbName = 'envoy.db';
  late Database db;

  StoreRef<String, String> txNotesStore = StoreRef<String, String>.main();
  StoreRef aztecoPendingTxStore = StoreRef.main();

  static final EnvoyStorage _instance = EnvoyStorage._();

  EnvoyStorage._() {
    _init();
  }

  factory EnvoyStorage() {
    return _instance;
  }

  void _init() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    final appDocumentDir = await getApplicationDocumentsDirectory();
    db = await dbFactory.openDatabase(join(appDocumentDir.path, dbName));
  }

  Future addAztecoTx(
      String address, String accountId, DateTime timestamp) async {
    await aztecoPendingTxStore.record(address).put(db,
        {'account': accountId, 'timestamp': timestamp.millisecondsSinceEpoch});
    return true;
  }

  Future<List<wallet.Transaction>> getAztecoTxs(String accountId) async {
    var finder = Finder(filter: Filter.equals('account', accountId));
    var records = await aztecoPendingTxStore.find(db, finder: finder);

    return records
        .map((e) => wallet.Transaction(
            e["address"] as String,
            "",
            DateTime.fromMillisecondsSinceEpoch(e["timestamp"] as int),
            0,
            0,
            0,
            0,
            type: wallet.TransactionType.azteco))
        .toList();
  }

  Future<bool> deleteAztecoTx(String address) async {
    if (await aztecoPendingTxStore.record(address).exists(db)) {
      await aztecoPendingTxStore.record(address).delete(db);
      return true;
    }
    return false;
  }

  Future addTxNote(String note, String txId) async {
    txNotesStore.record(txId).put(db, note);
    return true;
  }

  Future<String?> getTxNote(String txId) async {
    if (await txNotesStore.record(txId).exists(db))
      return txNotesStore.record(txId).get(db);
    else
      return null;
  }

  Future<bool> deleteTxNote(String note, String txId) async {
    if (await txNotesStore.record(txId).exists(db)) {
      await txNotesStore.record(txId).delete(db);
      return true;
    }
    return false;
  }
}
