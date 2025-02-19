// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/services.dart';
import 'package:http_tor/http_tor.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tor/tor.dart';

class UpdatesManager {
  static final UpdatesManager _instance = UpdatesManager._internal();

  factory UpdatesManager() => _instance;

  final LocalStorage _localStorage = LocalStorage();
  final EnvoyStorage _envoyStorage = EnvoyStorage();

  UpdatesManager._internal() {
    kPrint("Instance of UpdatesManager created!");
    _fetchUpdates();
    Timer.periodic(const Duration(hours: 1), (_) => _fetchUpdates());
  }

  static Future<UpdatesManager> init() async => _instance;

  void _fetchUpdates() {
    for (var device in [DeviceType.passportGen1, DeviceType.passportGen12]) {
      Server()
          .fetchFirmwareUpdateInfo(device.id)
          .then(_downloadAndStoreFirmware)
          .catchError((e) {
        kPrint("Couldn't fetch firmware for device $device: $e");
      });
    }
    Server().checkForForceUpdate();
  }

  Future<void> _downloadAndStoreFirmware(FirmwareUpdate fw) async {
    final storedInfo = await _envoyStorage.getStoredFirmware(fw.deviceId);
    final storedVersion = storedInfo?.storedVersion;
    final storedPath = storedInfo?.path;

    if (fw.version == storedVersion &&
        await _localStorage.fileExists(storedPath ?? "")) {
      return;
    }

    final response =
        await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(fw.url);
    final bytes = response.bodyBytes;

    _verifyChecksum(bytes, fw.md5, () => md5, 'MD5');
    _verifyChecksum(bytes, fw.sha256, () => sha256, 'SHA256');

    String fileName = generateFirmwareFileName(fw);

    await _localStorage.saveFileBytes(fileName, bytes);

    if (fw.deviceId == DeviceType.passportPrime.id) {
      await _localStorage.extractTarFile(fileName);
      await _addPrimeFirmwareToEnvoyStorage(fileName, fw);
    } else {
      _envoyStorage.addNewFirmware(fw.deviceId, fw.version, fileName);
    }
  }

  /// Adds firmware data from the manifest file to Envoy storage.
  ///
  /// This function reads the `manifest.json` file located in the application's support directory,
  /// extracts package actions, and stores the firmware information in `_envoyStorage`.
  /// This allows the system to later handle firmware updates and inform the user about firmware status.
  ///
  Future<void> _addPrimeFirmwareToEnvoyStorage(
      String fileName, FirmwareUpdate fw) async {
    try {
      Directory appSupportDir = await getApplicationSupportDirectory();
      final folderName = fileName.replaceAll('.tar', '');
      final manifestPath = "${appSupportDir.path}/$folderName/manifest.json";

      if (!File(manifestPath).existsSync()) {
        throw Exception("Manifest file not found at $manifestPath");
      }

      String jsonString = await rootBundle.loadString(manifestPath);
      Map<String, dynamic> data;

      try {
        data = jsonDecode(jsonString);
      } catch (e) {
        throw Exception("Failed to parse JSON from manifest: $e");
      }

      List<PackageAction> actionInfo =
          await createPackageActionsFromManifest(data);

      await _envoyStorage.addNewFirmware(fw.deviceId, fw.version, folderName,
          packageActions: actionInfo);
    } catch (e) {
      throw Exception("Failed to add prime firmware to storage: $e");
    }
  }

  String generateFirmwareFileName(FirmwareUpdate fw) {
    final deviceType = DeviceType.values.firstWhere(
      (device) => device.id == fw.deviceId,
      orElse: () => throw Exception("Unsupported deviceId: ${fw.deviceId}"),
    );

    switch (deviceType) {
      case DeviceType.passportGen1:
        return "${fw.version}-founders-passport.bin";
      case DeviceType.passportGen12:
        return "${fw.version}-passport.bin";
      case DeviceType.passportPrime:
        return "${fw.version}-prime-release.tar";
    }
  }

  void _verifyChecksum(List<int> bytes, String expected,
      Hash Function() algorithm, String name) {
    final computedHash = algorithm().convert(bytes).toString();
    if (computedHash != expected) {
      throw Exception('Wrong $name hash');
    }
  }

  Future<File> getStoredFirmware(int deviceId) async {
    final storedInfo = await _envoyStorage.getStoredFirmware(deviceId);
    final storedPath = storedInfo?.path;

    if (storedPath == null || !await _localStorage.fileExists(storedPath)) {
      throw Exception("Firmware file does not exist");
    }

    final file = _localStorage.openFileBytes(storedPath);

    if (!_isFileNameValid(deviceId, file.path)) {
      return _migrateFileName(deviceId, file);
    }

    return file;
  }

  bool _isFileNameValid(int deviceId, String path) {
    if (deviceId == DeviceType.passportPrime.id) {
      return true;
    } else {
      final fileName = basename(path);
      return fileName.endsWith("-passport.bin") &&
          fileName != "0-passport.bin" &&
          fileName != "1-passport.bin";
    }
  }

  Future<File> _migrateFileName(int deviceId, File file) async {
    final storedFwVersion = await getStoredFirmwareVersionString(deviceId);
    if (storedFwVersion == null) {
      throw Exception("Cannot determine stored firmware version");
    }

    final newFileName =
        "$storedFwVersion${deviceId == 0 ? "-founders" : ""}-passport.bin";
    final newFile =
        _localStorage.saveFileBytesSync(newFileName, file.readAsBytesSync());

    _envoyStorage.addNewFirmware(deviceId, storedFwVersion, newFileName);
    return newFile;
  }

  Future<String?> getStoredFirmwareVersionString(int deviceId) async {
    return (await _envoyStorage.getStoredFirmware(deviceId))?.storedVersion;
  }

  Future<Version?> getStoredFirmwareVersion(int deviceId) async {
    final storedVersion = await getStoredFirmwareVersionString(deviceId);
    return storedVersion != null
        ? Version.parse(storedVersion.replaceAll("v", ""))
        : null;
  }

  Future<List<PackageAction>> createPackageActionsFromManifest(
      Map<String, dynamic> manifest) async {
    final actionsData = manifest['signed-data']['actions'] as List<dynamic>;

    return actionsData.map((actionGroup) {
      final name = actionGroup['action'];
      final actionsList = actionGroup['actions'] as List<dynamic>? ?? [];
      final actions = actionsList
          .map((action) => Action(
                action: action['action'],
                source: action['source'],
                dest: action['dest'],
                patchFile: action['patch-file'],
                patchSource: action['patch-source'],
                baseVersion: action['base-version'],
                newVersion: action['new-version'],
              ))
          .toList();

      return PackageAction(name: name, actions: actions);
    }).toList();
  }

  Future<bool> shouldUpdate(String version, DeviceType type) async {
    final parsedVersion =
        Version.parse(version.replaceAll("v", "").substring(0, 5));
    final storedVersionString =
        await getStoredFirmwareVersionString(type.index);
    if (storedVersionString == null) return false;

    final currentVersion =
        Version.parse(storedVersionString.replaceAll("v", ""));
    return currentVersion > parsedVersion;
  }
}
