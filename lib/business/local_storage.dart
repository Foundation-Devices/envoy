// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  final secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      synchronizable: true,
      accessibility: KeychainAccessibility.unlocked,
    ),
  );
  final EnvoyStorage prefs = EnvoyStorage();
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
    if (Platform.isIOS) {
      _performKeychainMigration();
    }
  }

  Future<void> _initAsync() async {
    appSupportDir = await getApplicationSupportDirectory();
    appDocumentsDir = await getApplicationDocumentsDirectory();
    kPrint("Async members initialized!");
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
      await secureStorage.write(key: key, value: value);
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
      await secureStorage.deleteAll();
    } else {
      await prefs.clear();
    }
  }

  Future<void> deleteSecure(String key) async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await secureStorage.containsKey(key: key)) {
        await secureStorage.delete(key: key);
      }
    } else {
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }
    }
  }

  Future<File> saveFile(String name, String content) async {
    final file = await File(
      '${appSupportDir.path}/$name',
    ).create(recursive: true);
    return file.writeAsString(content);
  }

  Future<String> readFile(String name) async {
    final file = File('${appSupportDir.path}/$name');
    return file.readAsStringSync();
  }

  Future<void> deleteFile(String name) async {
    if (await File('${appSupportDir.path}/$name').exists()) {
      await File('${appSupportDir.path}/$name').delete();
    }
  }

  Future<File> saveFileBytes(String name, List<int> content) async {
    final file = await File(
      '${appSupportDir.path}/$name',
    ).create(recursive: true);
    return file.writeAsBytes(content);
  }

  File saveFileBytesSync(String name, List<int> content) {
    var file = File('${appSupportDir.path}/$name')
      ..createSync(recursive: true)
      ..writeAsBytesSync(content);
    return file;
  }

  Future<List<int>> readFileBytes(String name) async {
    final file = File('${appSupportDir.path}/$name');
    return file.readAsBytes();
  }

  File openFileBytes(String name) {
    final file = File('${appSupportDir.path}/$name');
    return file;
  }

  Future<bool> fileExists(String name) async {
    final file = File('${appSupportDir.path}/$name');
    return file.exists();
  }

  Future<void> extractTarFile(String path) async {
    final file = File('${appSupportDir.path}/$path');
    if (!await file.exists()) {
      throw Exception('Tar file does not exist: $path');
    }

    final folderName = path.replaceAll('.tar', '');
    await extractFileToDisk(
      '${appSupportDir.path}/$path',
      '${appSupportDir.path}/$folderName',
    );
  }

  //IOS keychain previous secure storage configuration to new configuration.
  //configuration changed to support iOS Keychain synchronizable across different
  //devices
  void _performKeychainMigration() async {
    final storage = FlutterSecureStorage();
    final allValues = await storage.readAll();
    //already migrated or nothing to migrate
    if (allValues.isEmpty) {
      return;
    }
    for (var key in allValues.keys) {
      if (allValues[key] != null) {
        await secureStorage.write(key: key, value: allValues[key]);
      }
    }
    // Verify all values migrated successfully to new storage configuration
    bool allMigrated = true;
    for (var key in allValues.keys) {
      final migratedValue = await secureStorage.read(key: key);
      if (migratedValue != allValues[key]) {
        allMigrated = false;
        EnvoyReport().log("LocalStorage", "Migration failed for key: $key");
        break;
      }
    }
    // Delete all from old storage if migration successful
    if (allMigrated) {
      await storage.deleteAll();
      kPrint("Old keychain storage cleared after successful migration");
    }
  }
}
