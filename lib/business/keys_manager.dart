// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/business/server.dart';

class KeysManager {
  ApiKeys? keys;

  static final KeysManager _instance = KeysManager._internal();

  factory KeysManager() {
    return _instance;
  }

  static Future<KeysManager> init() async {
    var singleton = KeysManager._instance;
    await singleton._initAsync();
    return singleton;
  }

  _initAsync() async {
    keys = await EnvoyStorage().getApiKeys();
  }

  KeysManager._internal() {
    kPrint("Instance of KeysManager created!");

    // Fetch from the Envoy Server
    _fetchKeysFromServer();

    // Check once an hour
    Timer.periodic(const Duration(hours: 1), (_) {
      _fetchKeysFromServer();
    });
  }

  void _fetchKeysFromServer() {
    Server().fetchApiKeys().then((keys) => _store(keys)).catchError((e) {
      kPrint("Couldn't fetch API keys: $e");
    });
  }

  _store(ApiKeys newKeys) async {
    if (keys == null ||
        keys!.mapsKey != newKeys.mapsKey ||
        keys!.rampKey != newKeys.rampKey) {
      await EnvoyStorage().storeApiKeys(newKeys);
      keys = newKeys;
    }
  }
}
