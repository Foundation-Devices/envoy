// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/services.dart';
import 'package:http_tor/http_tor.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

typedef PatchBinary = ({Uint8List binary, PrimePatch patch});

class Server {
  HttpTor? http;
  final String _serverAddress = Settings().envoyServerAddress;

  Server({this.http}) {
    http ??= HttpTor();
  }

  Future<FirmwareUpdate> fetchFirmwareUpdateInfo(int deviceId) async {
    final response =
        await http!.get('$_serverAddress/firmware/device?id=$deviceId');

    if (response.statusCode == 202) {
      var fw = FirmwareUpdate.fromJson(jsonDecode(response.body));
      return fw;
    } else {
      throw Exception('Failed to find firmware');
    }
  }

  Future<List<PrimePatch>> fetchPrimePatches(String currentVersion) async {
    final response = await http!
        .get('$_serverAddress/prime/patches?version=$currentVersion');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json['patches'] == null) {
        return [];
      }

      final List<dynamic> patches = json['patches'];

      final List<PrimePatch> updates = [];
      for (final patch in patches) {
        updates.add(PrimePatch.fromJson(patch));
      }

      return updates;
    } else {
      throw Exception('Failed to fetch update chain');
    }
  }

  Future<Uint8List?> fetchPrimePatchBinary(PrimePatch patch) async {
    try {
      final response = await http!.get(patch.url);
      if (response.statusCode == 200) {
        return Uint8List.fromList(response.bodyBytes);
      } else {
        throw Exception('Failed to fetch prime patch');
      }
    } catch (e) {
      kPrint("Error fetching prime patches: $e");
    }

    return null;
  }

  Future<List<PatchBinary>> fetchPrimePatchBinaries(
      String currentVersion) async {
    List<PatchBinary> result = [];

    try {
      final patches = await fetchPrimePatches(currentVersion);
      for (final patch in patches) {
        final response = await http!.get(patch.url);
        if (response.statusCode == 200) {
          PatchBinary patchBinary =
              (binary: Uint8List.fromList(response.bodyBytes), patch: patch);
          result.add(patchBinary);
        } else {
          throw Exception('Failed to fetch prime patch');
        }
      }
    } catch (e) {
      kPrint("Error fetching prime patches: $e");
    }

    return result;
  }

  Future<ApiKeys> fetchApiKeys() async {
    final response = await http!.get('$_serverAddress/keys');

    if (response.statusCode == 202) {
      return ApiKeys.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch API keys');
    }
  }

  Future<void> checkForForceUpdate() async {
    try {
      // Fetch deprecated versions from the backend
      final response = await http!.get('$_serverAddress/deprecated-versions');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> deprecatedVersions = data['deprecated_versions'];

        // Get the app's current version
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        Version envoyVersionOnPhone = Version.parse(packageInfo.version);

        // Check if the app's version is in the list of deprecated versions
        bool isDeprecated = deprecatedVersions.any((version) {
          Version deprecatedVersion = Version.parse(version);
          return envoyVersionOnPhone == deprecatedVersion;
        });

        if (isDeprecated) {
          isCurrentVersionDeprecated.add(true);
        }
      } else {
        throw Exception('Failed to fetch deprecated versions');
      }
    } catch (e) {
      kPrint("Error checking for force update: $e");
    }
  }
}

class PrimePatch {
  final String version;
  final String baseVersion;
  final String signedSha256;
  final String unsignedSha256;
  final String updateFilename;
  final String signatureFilename;
  final String url;
  final String changelog;
  final DateTime releaseDate;

  PrimePatch({
    required this.version,
    required this.baseVersion,
    required this.signedSha256,
    required this.unsignedSha256,
    required this.updateFilename,
    required this.signatureFilename,
    required this.url,
    required this.changelog,
    required this.releaseDate,
  });

  factory PrimePatch.fromJson(Map<String, dynamic> json) {
    return PrimePatch(
        version: json['version'],
        baseVersion: json['base_version'],
        signedSha256: json['signed_sha256'],
        unsignedSha256: json['unsigned_sha256'],
        updateFilename: json['update_filename'],
        signatureFilename: json['signature_filename'],
        url: json['url'],
        changelog: json['changelog'],
        releaseDate: DateTime.parse(
          (json['release_date']),
        ));
  }
}

class ApiKeys {
  final String mapsKey;
  final String rampKey;

  ApiKeys({
    required this.mapsKey,
    required this.rampKey,
  });

  factory ApiKeys.fromJson(Map<String, dynamic> json) {
    final keys = json['keys'];
    return ApiKeys(mapsKey: keys['maps_api'], rampKey: keys['ramp_api']);
  }

  Map<String, dynamic> toJson() {
    return {
      'keys': {
        'maps_api': mapsKey,
        'ramp_api': rampKey,
      }
    };
  }
}

class FirmwareUpdate {
  final String version;
  final String url;
  final String sha256;
  final String reproducibleHash;
  final String md5;
  final String changeLog;
  final DateTime releaseDate;
  final int deviceId;

  FirmwareUpdate(
      {required this.version,
      required this.url,
      required this.sha256,
      required this.reproducibleHash,
      required this.md5,
      required this.changeLog,
      required this.releaseDate,
      required this.deviceId});

  factory FirmwareUpdate.fromJson(Map<String, dynamic> json) {
    final fw = json['firmware'];
    return FirmwareUpdate(
        deviceId: fw['device_id'],
        sha256: fw['sha256'],
        md5: fw['md5'],
        url: fw['url'],
        changeLog: fw['changelog'],
        reproducibleHash: fw['reproducible_hash'],
        releaseDate: DateTime.fromMillisecondsSinceEpoch(
            (fw['release_date']['secs_since_epoch']) * 1000),
        version: fw['version']);
  }
}
