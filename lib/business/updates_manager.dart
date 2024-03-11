// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/devices.dart';
import 'package:path/path.dart';

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
    kPrint("Instance of UpdatesManager created!");

    // Go fetch the latest from Server
    _fetchUpdates();

    // Check once an hour
    Timer.periodic(const Duration(hours: 1), (_) {
      _fetchUpdates();
    });
  }

  void _fetchUpdates() {
    Server()
        .fetchFirmwareUpdateInfo(0) // Gen1
        .then((fw) => _processFw(fw))
        .catchError((e) {
      kPrint("Couldn't fetch firmware: $e");
    });

    Server()
        .fetchFirmwareUpdateInfo(1) // Gen2
        .then((fw) => _processFw(fw))
        .catchError((e) {
      kPrint("Couldn't fetch firmware: $e");
    });
  }

  _processFw(FirmwareUpdate fw) async {
    var storedInfo = await es.getStoredFirmware(fw.deviceId);
    String? storedVersion = storedInfo?.storedVersion;

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
          "${fw.version}${fw.deviceId == 0 ? "-founders" : ""}-passport.bin";
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
        basename(file.path) == "0-passport.bin" ||
        basename(file.path) == "1-passport.bin") {
      String? storedFwVersion = await getStoredFwVersionString(deviceId);

      if (storedFwVersion != null) {
        final fileName =
            "$storedFwVersion${deviceId == 0 ? "-founders" : ""}-passport.bin";
        var newFile = ls.saveFileBytesSync(fileName, file.readAsBytesSync());
        es.addNewFirmware(deviceId, storedFwVersion, fileName);
        return newFile;
      }
    }

    return file;
  }

  Future<String?> getStoredFwVersionString(int deviceId) async {
    var storedInfo = await es.getStoredFirmware(deviceId);
    String? storedVersion = storedInfo?.storedVersion;
    return storedVersion;
  }

  Future<Version?> getStoredFwVersion(int deviceId) async {
    String? storedVersion = await getStoredFwVersionString(deviceId);
    if (storedVersion == null) {
      return null;
    }

    return Version.parse(storedVersion.replaceAll("v", ""));
  }

  Future<bool> shouldUpdate(String version, DeviceType type) async {
    version = version.replaceAll("v", "").substring(0, 5);
    Version deviceFwVersion = Version.parse(version);
    final fw = await getStoredFwVersionString(type.index);
    Version currentFwVersion = Version.parse(fw!.replaceAll("v", ""));

    if (currentFwVersion > deviceFwVersion) {
      return true;
    }

    return false;
  }
}
