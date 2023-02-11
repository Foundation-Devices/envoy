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
  static perform(
      SharedPreferences prefs, List<String> keysToBackUp, String seedWords, String serverUrl, int proxyPort) {
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

    var lib = NativeLibrary(load("backup_ffi"));
    lib.backup_perform(keysNumber,
        nativeData,
        seedWords.toNativeUtf8().cast<Char>(),
        serverUrl.toNativeUtf8().cast<Char>(),
        proxyPort);
  }
}
