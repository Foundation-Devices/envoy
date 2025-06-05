// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:sembast/sembast.dart';

/// Repository for storing and retrieving coin tag data
class CoinRepository {
  final storage = EnvoyStorage();
  Database db = EnvoyStorage().db();

  static CoinRepository? _instance;

  CoinRepository._();

  factory CoinRepository() => _instance ??= CoinRepository._();

  /// returns a stream of all utxo block state that stored in the [storage.utxoBlockState] database
  Stream<Map<String, bool?>> getCoinBlockStateStream() {
    return storage.utxoBlockState
        .query()
        .onSnapshots(db)
        .transform(_coinBlockStateTransformer);
  }

  /// Transforms the stream of records to a stream of map
  final _coinBlockStateTransformer = StreamTransformer<
      List<RecordSnapshot<String, bool>>,
      Map<String, bool?>>.fromHandlers(handleData: (snapshot, sink) {
    Map<String, bool> map = {};
    for (var element in snapshot) {
      map[element.key] = element.value;
    }
    sink.add(map);
  });

  Future addUtxoBlockState(String hash, bool isBlocked) async {
    await storage.utxoBlockState.record(hash).put(db, isBlocked);
    return true;
  }

  Future<List<String>> getBlockedCoins() async {
    return (await storage.utxoBlockState.find(db))
        .map((e) => e)

        ///return only locked ones
        .where((element) => element.value)
        .map((e) => e.key)
        .toList();
  }

  /// returns a stream of all coin tags that stored in the [storage.tagStore] database
  Stream<List<CoinTag>> getCoinTagStream({String? accountId}) {
    final finder = accountId != null
        ? Finder(filter: Filter.equals('account', accountId))
        : Finder();
    return storage.tagStore
        .query(finder: finder)
        .onSnapshots(db)
        //Transforms the stream of records to a stream of list of maps
        .map((event) {
      return event.map((e) {
        return CoinTag.fromJson(e.value);
      }).toList();
    });
  }

  Future<List<CoinTag>> getCoinTags({String? accountId}) async {
    final finder = accountId != null
        ? Finder(filter: Filter.equals('account', accountId))
        : Finder();

    // Run the query and get the list of results
    final records =
        await storage.tagStore.query(finder: finder).getSnapshots(db);

    // Transform the records to a list of CoinTag objects
    return records.map((record) => CoinTag.fromJson(record.value)).toList();
  }

  //to utxo => tagname map for ngwallet
  Future<Map<String, String>> getTagMap({String? accountId}) async {
    // Run the query and get the list of results
    final finder = accountId != null
        ? Finder(filter: Filter.equals('account', accountId))
        : Finder();
    final records =
        await storage.tagStore.query(finder: finder).getSnapshots(db);
    final tags = records.map((record) => CoinTag.fromJson(record.value));
    Map<String, String> tagMap = {};
    for (var tag in tags) {
      for (var id in tag.coinsId) {
        tagMap[id] = tag.name;
      }
    }
    return tagMap;
  }

  Future addCoinTag(CoinTag tag) async {
    await storage.tagStore.record(tag.id).put(db, tag.toJson());
  }

  Future<int> updateCoinTag(CoinTag existingTag) async {
    return await storage.tagStore.update(db, existingTag.toJson(),
        finder: Finder(filter: Filter.equals("id", existingTag.id)));
  }

  Future deleteTag(CoinTag coinTag) async {
    await storage.tagStore
        .delete(db, finder: Finder(filter: Filter.equals("id", coinTag.id)));
  }
}
