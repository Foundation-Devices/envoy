// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:envoy/business/blog_post.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/media.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/src/type.dart';
import 'package:sembast/utils/sembast_import_export.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

final readBlogStreamProvider = StreamProvider.family<bool, String>(
    (ref, url) => EnvoyStorage().isBlogRead(url));

final watchedVideoStreamProvider = StreamProvider.family<bool, String>(
    (ref, url) => EnvoyStorage().isVideoWatched(url));

const String txNotesStoreName = "tx_notes";
const String videosStoreName = "videos";
const String pendingTxStoreName = "pending_tx";
const String rbfBoostStoreName = "boosted_tx";
const String canceledTxStoreName = "rbf_cancel_tx";
const String dismissedPromptsStoreName = "dismissed_prompts";
const String firmwareStoreName = "firmware";
const String utxoBlockStateStoreName = "utxo_block_state";
const String tagsStoreName = "tags";
const String preferencesStoreName = "preferences";
const String blogPostsStoreName = "blog_posts";
const String exchangeRateStoreName = "exchange_rate";

///keeps track of spend input tags, this would be handy to show previously used tags
///for example when user trying RBF.
const String inputTagHistoryStoreName = "input_coin_history";

const String exchangeRateKey = exchangeRateStoreName;

class EnvoyStorage {
  static String dbName = 'envoy.db';
  late Database _db;

  bool _backupInProgress = false;

  StoreRef<String, String> txNotesStore =
      StoreRef<String, String>(txNotesStoreName);
  StoreRef<String, Map> pendingTxStore =
      StoreRef<String, Map>(pendingTxStoreName);
  StoreRef<String, bool> dismissedPromptsStore =
      StoreRef<String, bool>(dismissedPromptsStoreName);
  StoreRef<String, Map> rbfBoostStore =
      StoreRef<String, Map>(rbfBoostStoreName);

  StoreRef<int, Map> canceledTxStore =
      intMapStoreFactory.store(canceledTxStoreName);

  StoreRef<String, Map<String, dynamic>> tagHistoryStore =
      StoreRef<String, Map<String, dynamic>>(inputTagHistoryStoreName);

  StoreRef<int, Map> firmwareStore = StoreRef<int, Map>(firmwareStoreName);

  StoreRef<String, bool> utxoBlockState = StoreRef(utxoBlockStateStoreName);
  StoreRef<String, Map<String, Object?>> tagStore = StoreRef(tagsStoreName);

  StoreRef<String, String> videoStore =
      StoreRef<String, String>(videosStoreName);

  StoreRef<String, String> blogPostsStore =
      StoreRef<String, String>(blogPostsStoreName);

  StoreRef<String, Object?> preferencesStore =
      StoreRef<String, Object?>(preferencesStoreName);
  final Map<String, Object?> _preferencesCache = {};

  StoreRef<String, Map> exchangeRateStore =
      StoreRef<String, Map>(exchangeRateStoreName);

  // Store everything except videos and blogs
  Map<String, StoreRef> storesToBackUp = {};

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
    _db = await dbFactory.openDatabase(join(appDocumentDir.path, dbName),
        version: 3, onVersionChanged: (db, oldVersion, newVersion) async {
      if (oldVersion == 1) {
        // Migrate dismissed prompts to its own store
        for (DismissiblePrompt prompt in DismissiblePrompt.values) {
          String key = prompt.toString();
          final record = await StoreRef.main().record(key).get(db);
          if (record != null) {
            await dismissedPromptsStore.record(key).add(db, true);
            await StoreRef.main().record(key).delete(db);
          }
        }
      }

      if (oldVersion == 2 || oldVersion == 1) {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        for (String key in keys) {
          final value = prefs.get(key);
          await preferencesStore.record(key).put(db, value);
          await _updatePreferencesCache(db);
        }
      }
    });

    await _updatePreferencesCache(_db);

    EnvoyStorage().preferencesStore.addOnChangesListener(_db,
        (transaction, changes) {
      _updatePreferencesCache(_db);
    });

    storesToBackUp = {
      txNotesStoreName: txNotesStore,
      pendingTxStoreName: pendingTxStore,
      dismissedPromptsStoreName: dismissedPromptsStore,
      firmwareStoreName: firmwareStore,
      tagsStoreName: tagStore,
      utxoBlockStateStoreName: utxoBlockState,
      preferencesStoreName: preferencesStore,
      exchangeRateStoreName: exchangeRateStore,
      rbfBoostStoreName: rbfBoostStore,
    };

    for (var store in storesToBackUp.values) {
      store.addOnChangesListener(_db, (transaction, changes) {
        _possiblyBackUp();
        //return null;
      });
    }
    removeOutstandingAztecoPendingTxs();
  }

  Future<void> removeOutstandingAztecoPendingTxs() async {
    const String key = "azteco";
    deletePendingTx(key);
  }

  void _possiblyBackUp() {
    if (_backupInProgress) {
      return;
    }

    // Only back up if an hour has passed
    DateTime lastBackUpTime = EnvoySeed().getLastBackupTime() ?? DateTime(2000);
    if (lastBackUpTime
        .add(const Duration(minutes: 60))
        .isBefore(DateTime.now())) {
      _backupInProgress = true;
      EnvoySeed().backupData().then((_) => _backupInProgress = false,
          onError: (_) => _backupInProgress = false);
    }
  }

  // Preferences are stored in a cache for fast retrieval
  _updatePreferencesCache(DatabaseClient db) async {
    final keys = await preferencesStore.findKeys(db);

    for (String key in keys) {
      final value = await preferencesStore.record(key).get(db);
      _preferencesCache[key.toString()] = value;
    }
  }

  Future addPromptState(DismissiblePrompt prompt) async {
    await dismissedPromptsStore.record(prompt.toString()).add(_db, true);
    return true;
  }

  Future removePromptState(DismissiblePrompt prompt) async {
    await dismissedPromptsStore.record(prompt.toString()).delete(db);
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

  Future<bool> checkPromptDismissed(DismissiblePrompt prompt) {
    final filter = Finder(filter: Filter.byKey(prompt.toString()));
    //returns boolean stream that updates when provided key is updated
    return dismissedPromptsStore
        .find(db, finder: filter)
        .then((event) => event.length != 0);
  }

  Future addPendingTx(String key, String accountId, DateTime timestamp,
      wallet.TransactionType type, int amount, int fee, String address) async {
    await pendingTxStore.record(key).put(_db, {
      'account': accountId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.toString(),
      'amount': amount,
      'fee': fee,
      'address': address,
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
              e["fee"] as int,
              0,
              e["amount"] as int,
              0,
              e["address"] as String,
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

  // key is usually the txid
  // except for pending Azteco tx where it's the receive address
  Future addTxNote(String note, String key) async {
    txNotesStore.record(key).put(_db, note);
    return true;
  }

  //returns a stream of all pending transactions that stored in the database
  Stream<String> getTxNotesStream(String txId) {
    var finder = Finder(filter: Filter.byKey(txId));
    return EnvoyStorage()
        .txNotesStore
        .query(finder: finder)
        .onSnapshots(_db)
        .map((records) {
      return records.first.value;
    });
  }

  Future<String?> getTxNote(String txId) async {
    if (await txNotesStore.record(txId).exists(_db)) {
      return txNotesStore.record(txId).get(_db);
    } else {
      return null;
    }
  }

  Future<bool> deleteTxNote(String txId) async {
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

  Future<String> export() async {
    await _updatePreferencesCache(_db);
    return jsonEncode(
        await exportDatabase(_db, storeNames: storesToBackUp.keys.toList()));
  }

  restore(String json) async {
    var map = jsonDecode(json) as Map;
    if (map.isEmpty) {
      return;
    }

    final appDocumentDir = await getApplicationDocumentsDirectory();
    await _db.close();
    _db = await importDatabase(
        map, databaseFactoryIo, join(appDocumentDir.path, dbName));

    await _updatePreferencesCache(_db);
  }

  // Since version 3 we migrate away from using shared_preferences

  // Following methods have same signature as shared_preferences
  // but use the preferences DB store instead
  Future setNewPreferencesValue(String key, value) async {
    await preferencesStore.record(key).put(db, value);
    return true;
  }

  bool containsKey(String key) {
    return _preferencesCache.containsKey(key);
  }

  bool? getBool(String key) {
    return _preferencesCache[key] as bool?;
  }

  String? getString(String key) {
    return _preferencesCache[key] as String?;
  }

  Future<bool> clear() async {
    var cleared = await preferencesStore.delete(_db);
    return cleared != 0;
  }

  Future<bool> remove(key) async {
    var removed = await preferencesStore.record(key).delete(_db);
    return removed == key;
  }

  Future<bool> setBool(String key, bool value) async {
    await preferencesStore.record(key).put(_db, value);
    _updatePreferencesCache(_db);
    return true;
  }

  Future<bool> setString(String key, String value) async {
    final record = await preferencesStore.record(key);
    await record.put(_db, value);
    _updatePreferencesCache(_db);
    return true;
  }

  Future<bool> setExchangeRate(Map<dynamic, dynamic> data) async {
    final record = await exchangeRateStore.record(exchangeRateKey);
    await record.put(_db, data);

    return true;
  }

  Future<Map?>? getExchangeRate() async {
    if (await exchangeRateStore.record(exchangeRateKey).exists(_db)) {
      return exchangeRateStore.record(exchangeRateKey).get(_db);
    } else {
      return null;
    }
  }

  Future<bool> clearVideosStore() async {
    var cleared = await videoStore.delete(_db);

    return cleared > 0;
  }

  insertVideo(Video video) async {
    await videoStore.record(video.id).put(_db, jsonEncode(video));
  }

  updateVideo(Video video) {
    videoStore.record(video.id).update(_db, jsonEncode(video));
  }

  Video? transformVideo(RecordSnapshot<String, String> records) {
    return Video.fromJson(jsonDecode(records.value));
  }

  Future<List<Video?>?> getAllVideos() async {
    var videos = await videoStore.find(_db);

    return videos.map((e) => transformVideo(e)).toList();
  }

  Stream<bool> isVideoWatched(String url) {
    final filter = Finder(filter: Filter.byKey(url));

    return EnvoyStorage()
        .videoStore
        .query(finder: filter)
        .onSnapshots(_db)
        .map((videos) {
      var video = transformVideo(videos[0]);
      return video?.watched ?? false;
    });
  }

  updateBlogPost(BlogPost blog) {
    blogPostsStore.record(blog.id).update(_db, jsonEncode(blog));
  }

  insertBlogPost(BlogPost blog) async {
    await blogPostsStore.record(blog.id).put(_db, jsonEncode(blog));
  }

  BlogPost? transformBlog(RecordSnapshot<String, String> records) {
    return BlogPost.fromJson(jsonDecode(records.value));
  }

  Future<List<BlogPost?>?> getAllBlogPosts() async {
    var blogs = await blogPostsStore.find(_db);

    return blogs.map((e) => transformBlog(e)).toList();
  }

  Stream<bool> isBlogRead(String url) {
    final filter = Finder(filter: Filter.byKey(url));

    return EnvoyStorage()
        .blogPostsStore
        .query(finder: filter)
        .onSnapshots(_db)
        .map((blogs) {
      var blog = transformBlog(blogs[0]);
      return blog?.read ?? false;
    });
  }

  Future<void> insertMediaItems<T extends Media>(List<T?> items) async {
    for (var item in items) {
      if (item != null) {
        if (item is BlogPost) insertBlogPost(item);
        if (item is Video) insertVideo(item);
      }
    }
  }

  Future addRBFBoost(String txId, RBFState payload) async {
    await rbfBoostStore.record(txId).put(_db, payload.toJson());
    return true;
  }

  Future addCoinHistory(String txId, InputCoinHistory inputHistory) async {
    await tagHistoryStore.record(txId).put(_db, inputHistory.toJson());
    return true;
  }

  Future<InputCoinHistory?> getCoinHistory(String txId) async {
    return await tagHistoryStore
        .record(txId)
        .get(_db)
        .then((value) => InputCoinHistory.fromJson(value!));
  }

  Future<List<InputCoinHistory>?> getCoinHistoryByTransactionId(
      String txId) async {
    return await tagHistoryStore.find(_db, finder: Finder()).then((record) =>
        record.map((e) => InputCoinHistory.fromJson(e.value)).toList());
  }

  Future<RBFState?> getRBFBoostState(String txId, String accountId) async {
    RecordSnapshot? data =
        await rbfBoostStore.findFirst(_db, finder: Finder(filter: Filter.custom(
      (record) {
        final data = record.value;
        if (data != null && data is Map) {
          if (data["originalTxId"] == txId) {
            return true;
          }
          if (data["newTxId"] == txId) {
            return true;
          }
        }
        return false;
      },
    )));
    if (data != null) {
      RBFState rbf = RBFState.fromJson(data.value as Map<String, Object?>);
      if (rbf.accountId == accountId) {
        return rbf;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future addCancelState(Map<String, dynamic> payload) async {
    await canceledTxStore.add(_db, payload);
    return payload;
  }

  /// Returns the cancel state for a given txId
  /// If the txId matches with originalTxId or newTxId.
  Future<RBFState?> getCancelTxState(String accountId, String txId) async {
    RecordSnapshot? data = await canceledTxStore.findFirst(_db,
        finder: Finder(filter: Filter.custom(
      (record) {
        final data = record.value;
        if (data != null && data is Map) {
          if (data["originalTxId"] == txId) {
            return true;
          }
          if (data["newTxId"] == txId) {
            return true;
          }
        }
        return false;
      },
    )));
    if (data != null) {
      RBFState rbf = RBFState.fromJson(data.value as Map<String, Object?>);
      if (rbf.accountId == accountId) {
        return rbf;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Database get db => _db;
}
