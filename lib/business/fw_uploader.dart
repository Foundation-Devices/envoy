// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:envoy/business/local_storage.dart';

const sdCardEventChannel = EventChannel('sd_card_events');
final sdFwUploadStreamProvider = StreamProvider.autoDispose(
    (ref) => sdCardEventChannel.receiveBroadcastStream().asBroadcastStream());
//
final sdFwUploadProgressProvider = StateProvider.autoDispose<bool?>((ref) {
  dynamic streamData = ref.watch(sdFwUploadStreamProvider).value;
  if (streamData is bool) {
    return streamData;
  } else {
    return null;
  }
});

class FwUploader {
  Function? onUploaded;
  File fw;
  String _sdCardPath =
      "/private/var/mobile/Library/LiveFiles/com.apple.filesystems.userfsd/PASSPORT-SD/";

  static const String LAST_SD_CARD_PATH_PREFS = "last_sd_card_path";

  static const platform = MethodChannel('envoy');

  FwUploader(this.fw, {this.onUploaded}) {
    var prefs = LocalStorage().prefs;

    // Get the last used SD CARD path
    if (prefs.containsKey(LAST_SD_CARD_PATH_PREFS)) {
      _sdCardPath = prefs.getString(LAST_SD_CARD_PATH_PREFS)!;
    }

    // On iOS updates are received asynchronously from platform
    sdCardEventChannel
        .receiveBroadcastStream()
        .asBroadcastStream()
        .listen((event) {
      print(" sdCardEventChannel.receiveBroadcastStream() ${event}");
      if (event is bool) {
        onUploaded!();
      } else {
        String pathFromPlatform = (event as String);
        if (Platform.isIOS) {
          _sdCardPath = pathFromPlatform.substring(7);
          prefs.setString(LAST_SD_CARD_PATH_PREFS, _sdCardPath);
        }
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

  _iosUpload() {
    print("SD: trying to access folder");
    _accessFolder();

    print("SD: trying to copy file to " + _sdCardPath);
    fw.copySync(_sdCardPath + basename(fw.path));

    onUploaded!();
  }

  _androidUpload() {
    _saveFile();
  }
}
