// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/devices.dart';
import 'package:path/path.dart';

class UpdatesManager {
  HttpTor http = HttpTor(Tor());
  LocalStorage ls = LocalStorage();

  static const String LATEST_FIRMWARE_VERSION_PREFS = "latest_fw_version";
  static const String LATEST_FIRMWARE_FILE_PATH_PREFS = "latest_fw_file_path";
  static final UpdatesManager _instance = UpdatesManager._internal();

  factory UpdatesManager() {
    return _instance;
  }

  static Future<UpdatesManager> init() async {
    var singleton = UpdatesManager._instance;
    return singleton;
  }

  UpdatesManager._internal() {
    print("Instance of UpdatesManager created!");

    // Go fetch the latest from Server
    Server()
        .fetchFirmwareUpdateInfo(1) // Just Gen2 for now
        .then((fw) => _processFw(fw))
        .catchError((e) {
      print("Couldn't fetch firmware: " + e.toString());
    });
  }

  _processFw(FirmwareUpdate fw) async {
    if (fw.version != ls.prefs.getString(LATEST_FIRMWARE_VERSION_PREFS)) {
      final fwBinary = await http.get(fw.url);

      // Check MD5
      var md5Hash = md5.convert(fwBinary.bodyBytes).toString();
      if (md5Hash != fw.md5) {
        throw Exception('Wrong MD5 hash');
      }

      // Check SHA256
      var sha256Hash = sha256.convert(fwBinary.bodyBytes).toString();
      if (sha256Hash != fw.sha256) {
        throw Exception('Wrong SHA256 hash');
      }

      // Save to filesystem
      final fileName = fw.version + "-passport.bin";
      ls.saveFileBytes(fileName, fwBinary.bodyBytes);

      // Store to preferences
      ls.prefs.setString(LATEST_FIRMWARE_FILE_PATH_PREFS, fileName);
      ls.prefs.setString(LATEST_FIRMWARE_VERSION_PREFS, fw.version);
    }
  }

  File getStoredFw() {
    File file =
        ls.openFileBytes(ls.prefs.getString(LATEST_FIRMWARE_FILE_PATH_PREFS)!);

    // Migration
    if (!file.path.endsWith("-passport.bin")) {
      File newFile = file.copySync(
          dirname(file.path) + getStoredFwVersion()! + "-passport.bin");
      ls.prefs.setString(LATEST_FIRMWARE_FILE_PATH_PREFS, file.path);
      return newFile;
    }

    return file;
  }

  String? getStoredFwVersion() {
    return ls.prefs.getString(LATEST_FIRMWARE_VERSION_PREFS);
  }

  bool shouldUpdate(String version, DeviceType type) {
    if (getStoredFwVersion() != null && type == DeviceType.passportGen12) {
      Version deviceFwVersion = Version.parse(version.replaceAll("v", ""));
      Version currentFwVersion =
          Version.parse(getStoredFwVersion()!.replaceAll("v", ""));

      if (currentFwVersion > deviceFwVersion) {
        return true;
      }
    }

    return false;
  }
}
