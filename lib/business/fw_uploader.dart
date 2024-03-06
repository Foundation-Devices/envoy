// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/util/console.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:envoy/util/envoy_storage.dart';

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
  File fw;
  String _sdCardPath =
      "/private/var/mobile/Library/LiveFiles/com.apple.filesystems.userfsd/PASSPORT-SD/";

  static const String lastSDCardPathPrefs = "last_sd_card_path";

  static const platform = MethodChannel('envoy');

  FwUploader(this.fw) {
    // Get the last used SD CARD path
    if (EnvoyStorage().containsKey(lastSDCardPathPrefs)) {
      _sdCardPath = EnvoyStorage().getString(lastSDCardPathPrefs)!;
    }

    // Android
    if (Platform.isAndroid) {
      platform.invokeMethod('get_sd_card_path').then((value) {
        _sdCardPath = value;
        EnvoyStorage().setString(lastSDCardPathPrefs, _sdCardPath);
      });
    }
  }

  promptUserForFolderAccess() async {
    final result = await platform.invokeMethod('prompt_folder_access');
    if (result != null && result is String) {
      _sdCardPath = result.substring(7);
      EnvoyStorage().setString(lastSDCardPathPrefs, _sdCardPath);
    }

    return result;
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

  upload() async {
    if (Platform.isAndroid) {
      await _androidUpload();
    } else {
      await _iosUpload();
    }
  }

  _iosUpload() {
    kPrint("SD: trying to access folder");
    _accessFolder();

    kPrint("SD: trying to copy file to $_sdCardPath");
    fw.copySync(_sdCardPath + basename(fw.path));
  }

  _androidUpload() {
    _saveFile();
  }
}
