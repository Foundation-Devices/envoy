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
      {String? path}) {
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
    lib.backup_perform(
        payload.ref,
        seedWords.toNativeUtf8().cast<Char>(),
        serverUrl.toNativeUtf8().cast<Char>(),
        proxyPort,
        path != null ? path.toNativeUtf8().cast() : nullptr);
  }

  static restore(SharedPreferences prefs, String seedWords, String serverUrl,
      int proxyPort) {
    var lib = NativeLibrary(load("backup_ffi"));
    var payload = lib.backup_get(seedWords.toNativeUtf8().cast<Char>(),
        serverUrl.toNativeUtf8().cast<Char>(), proxyPort);

    Map<String, String> backupData = {};
    for (var i = 0; i < payload.keys_nr; i++) {
      var key = payload.data.elementAt(i).cast<Utf8>().toDartString();
      var value = payload.data.elementAt(i + 1).cast<Utf8>().toDartString();
      backupData[key] = value;
      i += 2;
    }

    backupData.forEach((key, value) {
      prefs.setString(key, value);
    });
  }
}
