// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ffi';
import 'dart:io';
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
  static perform(SharedPreferences prefs, List<String> keysToBackUp, String password) {
    Map<String, String> backupData = {};
    for (var key in keysToBackUp) {
      if (prefs.containsKey(key)) {
        backupData[key] = prefs.getString(key)!;
      }
    }

    // Convert map



    var lib = NativeLibrary(load("backup_ffi"));
  }
}
