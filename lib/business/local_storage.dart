// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final secureStorage = new FlutterSecureStorage();
  late final SharedPreferences prefs;
  late final Directory appSupportDir;
  late final Directory appDocumentsDir;

  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage() {
    return _instance;
  }

  static Future<LocalStorage> init() async {
    var singleton = LocalStorage._instance;
    await singleton._initAsync();
    return singleton;
  }

  LocalStorage._internal() {
    print("Instance of LocalStorage created!");
  }

  _initAsync() async {
    prefs = await SharedPreferences.getInstance();
    appSupportDir = await getApplicationSupportDirectory();
    appDocumentsDir = await getApplicationDocumentsDirectory();
    print("Async members initialized!");
  }

  Future<bool> containsSecure(String key) async {
    if (Platform.isAndroid || Platform.isIOS) {
      return secureStorage.containsKey(key: key);
    } else {
      return prefs.containsKey(key);
    }
  }

  Future<bool> saveSecure(String key, String value) async {
    // Write to Keychain on iOS and Keystore on Android
    if (Platform.isAndroid || Platform.isIOS) {
      secureStorage.write(key: key, value: value);
      return true;
    } else {
      return prefs.setString(key, value);
    }
  }

  Future<String?> readSecure(String key) async {
    // Read from Keychain on iOS and Keystore on Android
    if (Platform.isAndroid || Platform.isIOS) {
      return secureStorage.read(key: key);
    } else {
      return prefs.getString(key);
    }
  }

  Future<void> deleteAllSecure() async {
    if (Platform.isAndroid || Platform.isIOS) {
      secureStorage.deleteAll();
    } else {
      prefs.clear();
    }
  }

  Future<File> saveFile(String name, String content) async {
    return File(appSupportDir.path + '/' + name).writeAsString(content);
  }

  Future<String> readFile(String name) async {
    final file = File(appSupportDir.path + '/' + name);
    return file.readAsStringSync();
  }

  Future<void> deleteFile(String name) async {
    File(appSupportDir.path + '/' + name).delete();
  }

  Future<File> saveFileBytes(String name, List<int> content) async {
    return File(appSupportDir.path + '/' + name).writeAsBytes(content);
  }

  File saveFileBytesSync(String name, List<int> content) {
    var file = File(appSupportDir.path + '/' + name)..writeAsBytesSync(content);
    return file;
  }

  Future<List<int>> readFileBytes(String name) async {
    final file = File(appSupportDir.path + '/' + name);
    return file.readAsBytes();
  }

  File openFileBytes(String name) {
    final file = File(appSupportDir.path + '/' + name);
    return file;
  }

  Future<bool> fileExists(String name) async {
    final file = File(appSupportDir.path + '/' + name);
    return file.exists();
  }
}
