// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/src/type.dart';
import 'package:wallet/wallet.dart' as wallet;

final aztecoTxStreamProvider =
    StreamProvider.family<List<wallet.Transaction>, String?>(
        (ref, account) => EnvoyStorage().getAztecoTxsSteam(account));

class EnvoyStorage {
  String dbName = 'envoy.db';
  late Database _db;

  StoreRef<String, String> txNotesStore = StoreRef<String, String>.main();
  StoreRef aztecoPendingTxStore = StoreRef.main();
  StoreRef dismissedPromptsStore = StoreRef.main();

  static final EnvoyStorage _instance = EnvoyStorage._();

  EnvoyStorage._() {}

  factory EnvoyStorage() {
    return _instance;
  }

  Future init() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    final appDocumentDir = await getApplicationDocumentsDirectory();
    _db = await dbFactory.openDatabase(join(appDocumentDir.path, dbName));
  }

  Future addDismissedPrompt(DismissablePrompt prompt) async {
    await dismissedPromptsStore.record(prompt).put(db, true);
    return true;
  }

  Future<bool> isPromptDismissed(DismissablePrompt prompt) async {
    final res = await dismissedPromptsStore.findFirst(db,
        finder: Finder(filter: Filter.equals(prompt as String, true)));
    return res != null;
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
    return transformAztecoTxRecords(records);
  }

  List<wallet.Transaction> transformAztecoTxRecords(
      List<RecordSnapshot<Key?, Value?>> records) {
    return records
        .map((e) => wallet.Transaction(
            e.key as String,
            "",
            DateTime.fromMillisecondsSinceEpoch(e["timestamp"] as int),
            0,
            0,
            0,
            0,
            type: wallet.TransactionType.azteco))
        .toList();
  }

  //returns a stream of azteco transactions that stored in the database
  Stream<List<wallet.Transaction>> getAztecoTxsSteam(String? accountId) {
    var finder = Finder(filter: Filter.equals('account', accountId));
    return EnvoyStorage()
        .aztecoPendingTxStore
        .query(finder: finder)
        .onSnapshots(db)
        .map((records) {
      return transformAztecoTxRecords(records);
    });
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
