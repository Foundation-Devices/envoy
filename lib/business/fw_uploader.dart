// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:envoy/business/local_storage.dart';

class FwUploader {
  File fw;
  String _sdCardPath =
      "/private/var/mobile/Library/LiveFiles/com.apple.filesystems.userfsd/PASSPORT-SD/";

  static const String LAST_SD_CARD_PATH_PREFS = "last_sd_card_path";

  static const platform = MethodChannel('envoy');
  static const sdCardEventChannel = EventChannel('sd_card_events');

  FwUploader(this.fw) {
    var prefs = LocalStorage().prefs;

    // Get the last used SD CARD path
    if (prefs.containsKey(LAST_SD_CARD_PATH_PREFS)) {
      _sdCardPath = prefs.getString(LAST_SD_CARD_PATH_PREFS)!;
    }

    // On iOS updates are received asynchronously from platform
    sdCardEventChannel.receiveBroadcastStream().listen((path) {
      String pathFromPlatform = (path as String);
      if (Platform.isIOS) {
        _sdCardPath = pathFromPlatform.substring(7);
        prefs.setString(LAST_SD_CARD_PATH_PREFS, _sdCardPath);
      }
    });

    // Android
    if (Platform.isAndroid) {
      platform.invokeMethod('get_sd_card_path').then((value) {
        _sdCardPath = value;
        prefs.setString(LAST_SD_CARD_PATH_PREFS, _sdCardPath);
      });
    }
  }

  promptUserForFolderAccess() {
    platform.invokeMethod('prompt_folder_access');
  }

  _accessFolder() {
    // We don't need arguments for this call but keeping the below for future reference
    // var argsMap = <String, dynamic>{"path": sdCardPath};

    platform.invokeMethod('access_folder');
  }

  _saveFile() {
    var argsMap = <String, dynamic>{"from": fw.path, "path": _sdCardPath};
    platform.invokeMethod('save_file', argsMap);
  }

  _flushFile() {
    platform.invokeMethod('flush_file');
  }

  // ignore: unused_element
  getManageFilesPermission() {
    platform.invokeMethod('get_manage_files_permission');
  }

  // ignore: unused_element
  getDirectoryContentPermission() {
    platform.invokeMethod('get_directory_content_permission', <String, String>{
      'path': _sdCardPath,
    });
  }

  upload() {
    if (Platform.isAndroid) {
      _androidUpload();
    } else {
      _iosUpload();
    }
  }

  flush() {
    if (Platform.isAndroid) {
      _flushFile();
    }
  }

  _iosUpload() {
    print("SD: trying to access folder");
    _accessFolder();

    print("SD: trying to copy file to " + _sdCardPath);
    fw.copySync(_sdCardPath + basename(fw.path));
  }

  _androidUpload() {
    _saveFile();
  }
}
