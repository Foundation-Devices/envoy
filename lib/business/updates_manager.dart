// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/devices.dart';

class UpdatesManager {
  HttpTor http = HttpTor(Tor.instance, EnvoyScheduler().parallel);
  LocalStorage ls = LocalStorage();
  EnvoyStorage es = EnvoyStorage();

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
        .fetchFirmwareUpdateInfo(0) // Gen1
        .then((fw) => _processFw(fw))
        .catchError((e) {
      print("Couldn't fetch firmware: " + e.toString());
    });

    Server()
        .fetchFirmwareUpdateInfo(1) // Gen2
        .then((fw) => _processFw(fw))
        .catchError((e) {
      print("Couldn't fetch firmware: " + e.toString());
    });
  }

  _processFw(FirmwareUpdate fw) async {
    var StoredInfo = await es.getStoredFirmware(fw.deviceId);
    String? storedVersion = StoredInfo?.storedVersion;

    if (fw.version != storedVersion) {
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

      final fileName =
          fw.version + (fw.deviceId == 0 ? "-founders" : "") + "-passport.bin";
      ls.saveFileBytes(fileName, fwBinary.bodyBytes);
      es.addNewFirmware(fw.deviceId, fw.version, fileName);
    }
  }

  Future<File> getStoredFw(int deviceId) async {
    var storedInfo = await es.getStoredFirmware(deviceId);

    String? storedPath = storedInfo?.path;
    File file = ls.openFileBytes(storedPath!);

    // Migration
    if (!file.path.endsWith("-passport.bin") ||
        file.path.endsWith("0-passport.bin") ||
        file.path.endsWith("1-passport.bin")) {
      final fileName = (getStoredFwVersion(deviceId) as String) +
          (deviceId == 0 ? "-founders" : "") +
          "-passport.bin";
      var newFile = ls.saveFileBytesSync(fileName, file.readAsBytesSync());
      es.addNewFirmware(
          deviceId, getStoredFwVersion(deviceId) as String, fileName);
      return newFile;
    }

    return file;
  }

  Future<String?> getStoredFwVersion(int deviceId) async {
    var StoredInfo = await es.getStoredFirmware(deviceId);
    String? storedVersion = StoredInfo?.storedVersion;
    return storedVersion;
  }

  Future<bool> shouldUpdate(String version, DeviceType type) async {
    Version deviceFwVersion = Version.parse(version.replaceAll("v", ""));
    final fw = await getStoredFwVersion(type.index);
    Version currentFwVersion = Version.parse(fw!.replaceAll("v", ""));

    if (currentFwVersion > deviceFwVersion) {
      return true;
    }

    return false;
  }
}
