// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/src/type.dart';
import 'package:wallet/wallet.dart' as wallet;

class FirmwareInfo {
  FirmwareInfo({
    required this.deviceID,
    required this.storedVersion,
    required this.path,
  });

  final int deviceID;
  final String storedVersion;
  final String path;
}

final pendingTxStreamProvider =
    StreamProvider.family<List<wallet.Transaction>, String?>(
        (ref, account) => EnvoyStorage().getPendingTxsSteam(account));

final firmwareStreamProvider = StreamProvider.family<FirmwareInfo?, int>(
    (ref, deviceID) => EnvoyStorage().getfirmwareSteam(deviceID));

class EnvoyStorage {
  String dbName = 'envoy.db';
  late Database _db;

  StoreRef<String, String> txNotesStore = StoreRef<String, String>.main();
  StoreRef pendingTxStore = StoreRef.main();
  StoreRef<String, bool> dismissedPromptsStore = StoreRef<String, bool>.main();
  StoreRef firmwareStore = StoreRef.main();

  StoreRef<String, bool> utxoBlockState = StoreRef("utxo_block_state");
  StoreRef<String, CoinTag> tagStore = StoreRef('tags');

  static final EnvoyStorage _instance = EnvoyStorage._();

  EnvoyStorage._() {
    init();
  }

  factory EnvoyStorage() {
    return _instance;
  }

  Future init() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    final appDocumentDir = await getApplicationDocumentsDirectory();
    _db = await dbFactory.openDatabase(join(appDocumentDir.path, dbName));
  }

  Future addPromptState(DismissiblePrompt prompt) async {
    await dismissedPromptsStore.record(prompt.toString()).add(_db, true);
    return true;
  }

  Stream<bool> isPromptDismissed(DismissiblePrompt prompt) {
    final filter = Finder(filter: Filter.byKey(prompt.toString()));
    //returns boolean stream that updates when provided key is updated
    return dismissedPromptsStore
        .query(finder: filter)
        .onSnapshot(_db)
        .map((event) => event?.value)
        .map((event) => event != null);
  }

  Future addPendingTx(String key, String accountId, DateTime timestamp,
      wallet.TransactionType type, int amount) async {
    await pendingTxStore.record(key).put(_db, {
      'account': accountId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.toString(),
      'amount': amount,
    });
    return true;
  }

  Future<List<wallet.Transaction>> getPendingTxs(
      String accountId, wallet.TransactionType type) async {
    var finder = Finder(
      filter: Filter.and([
        Filter.equals('account', accountId),
        Filter.equals('type', type.toString())
      ]),
    );
    var records = await pendingTxStore.find(_db, finder: finder);
    return transformPendingTxRecords(records);
  }

  List<wallet.Transaction> transformPendingTxRecords(
      List<RecordSnapshot<Key?, Value?>> records) {
    return records
        .map(
          (e) => wallet.Transaction(
              e.key as String,
              e.key as String,
              DateTime.fromMillisecondsSinceEpoch(e["timestamp"] as int),
              0,
              0,
              e["amount"] as int,
              0,
              type: e["type"] == wallet.TransactionType.azteco.toString()
                  ? wallet.TransactionType.azteco
                  : wallet.TransactionType.pending),
        )
        .toList();
  }

  //returns a stream of all pending transactions that stored in the database
  Stream<List<wallet.Transaction>> getPendingTxsSteam(String? accountId) {
    var finder = Finder(filter: Filter.equals('account', accountId));
    return EnvoyStorage()
        .pendingTxStore
        .query(finder: finder)
        .onSnapshots(_db)
        .map((records) {
      return transformPendingTxRecords(records);
    });
  }

  Future<bool> deletePendingTx(String key) async {
    if (await pendingTxStore.record(key).exists(_db)) {
      await pendingTxStore.record(key).delete(_db);

      return true;
    }
    return false;
  }

  Future addTxNote(String note, String txId) async {
    txNotesStore.record(txId).put(_db, note);
    return true;
  }

  Future<String?> getTxNote(String txId) async {
    if (await txNotesStore.record(txId).exists(_db))
      return txNotesStore.record(txId).get(_db);
    else
      return null;
  }

  Future<bool> deleteTxNote(String note, String txId) async {
    if (await txNotesStore.record(txId).exists(_db)) {
      await txNotesStore.record(txId).delete(_db);
      return true;
    }
    return false;
  }

  void clearDismissedStatesStore() async {
    dismissedPromptsStore.delete(_db);
  }

  void clearPendingStore() async {
    pendingTxStore.delete(_db);
  }

  Future addNewFirmware(int deviceId, String version, String path) async {
    await firmwareStore
        .record(deviceId)
        .put(_db, {'version': version, 'path': path});
    return true;
  }

  Future<FirmwareInfo?> getStoredFirmware(int deviceId) async {
    var finder = Finder(filter: Filter.byKey(deviceId));
    var firmware = await firmwareStore.find(_db, finder: finder);
    return transformFirmware(firmware);
  }

  FirmwareInfo? transformFirmware(List<RecordSnapshot<Key?, Value?>> records) {
    if (records.isEmpty) {
      return null;
    }

    var record = records[0];
    return FirmwareInfo(
        deviceID: record.key as int,
        storedVersion: (record.value! as Map)['version'],
        path: (record.value! as Map)['path']);
  }

  Stream<FirmwareInfo?> getfirmwareSteam(int deviceId) {
    var finder = Finder(filter: Filter.byKey(deviceId));
    return EnvoyStorage()
        .firmwareStore
        .query(finder: finder)
        .onSnapshots(_db)
        .map((firmwares) {
      return transformFirmware(firmwares);
    });
  }

  Database get db => _db;
}
