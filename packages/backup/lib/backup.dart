// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'generated_bindings.dart';

import 'package:shared_preferences/shared_preferences.dart';

DynamicLibrary load(name) {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('lib$name.so');
  } else if (Platform.isLinux) {
    return DynamicLibrary.open('target/debug/lib$name.so');
  } else if (Platform.isIOS || Platform.isMacOS) {
    // iOS and MacOS are statically linked, so it is the same as the current process
    return DynamicLibrary.process();
  } else {
    throw NotSupportedPlatform('${Platform.operatingSystem} is not supported!');
  }
}

class NotSupportedPlatform implements Exception {
  NotSupportedPlatform(String s);
}

class Backup {
  static perform(SharedPreferences prefs, List<String> keysToBackUp,
      String seedWords, String serverUrl, int proxyPort,
      {required String path, bool cloud: true}) {
    Map<String, String> backupData = {};
    for (var key in keysToBackUp) {
      if (prefs.containsKey(key)) {
        backupData[key] = prefs.getString(key)!;
      }
    }

    if (backupData.isEmpty) {
      return;
    }

    // Convert map
    int keysNumber = backupData.length;
    Pointer<Pointer<Char>> nativeData = nullptr;

    nativeData = calloc(keysNumber * 2);

    int i = 0;
    for (var key in backupData.keys) {
      nativeData[i] = key.toNativeUtf8().cast<Char>();
      nativeData[i + 1] = backupData[key]!.toNativeUtf8().cast<Char>();
      i += 2;
    }

    final Pointer<BackupPayload> payload = calloc<BackupPayload>();
    payload.ref.keys_nr = keysNumber;
    payload.ref.data = nativeData;

    var lib = NativeLibrary(load("backup_ffi"));

    // Always do offline backup
    lib.backup_perform_offline(
      payload.ref,
      seedWords.toNativeUtf8().cast<Char>(),
      path.toNativeUtf8().cast(),
    );

    if (cloud) {
      lib.backup_perform(
        payload.ref,
        seedWords.toNativeUtf8().cast<Char>(),
        serverUrl.toNativeUtf8().cast<Char>(),
        proxyPort,
      );
    }
  }

  static bool restoreOffline(
      SharedPreferences prefs, String seedWords, String filePath) {
    var lib = NativeLibrary(load("backup_ffi"));
    var payload = lib.backup_get_offline(seedWords.toNativeUtf8().cast<Char>(),
        filePath.toNativeUtf8().cast<Char>());

    return _restoreFromPayload(payload, prefs);
  }

  static bool _restoreFromPayload(
      BackupPayload payload, SharedPreferences prefs) {
    // TODO: throw an exception from Rust
    if (payload.keys_nr == 0) {
      return false;
    }

    var data = payload.data;

    Map<String, String> backupData = {};
    for (var i = 0; i < payload.keys_nr * 2; i += 2) {
      var key = data.elementAt(i).value.cast<Utf8>().toDartString();
      var value = data.elementAt(i + 1).value.cast<Utf8>().toDartString();
      backupData[key] = value;
    }

    backupData.forEach((key, value) {
      prefs.setString(key, value);
    });

    return true;
  }

  static bool restore(SharedPreferences prefs, String seedWords,
      String serverUrl, int proxyPort) {
    var lib = NativeLibrary(load("backup_ffi"));
    var payload = lib.backup_get(seedWords.toNativeUtf8().cast<Char>(),
        serverUrl.toNativeUtf8().cast<Char>(), proxyPort);

    return _restoreFromPayload(payload, prefs);
  }
}
