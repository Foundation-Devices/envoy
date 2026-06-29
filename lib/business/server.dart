// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
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
    final response = await http!.get(
      '$_serverAddress/firmware/device?id=$deviceId',
    );

    if (response.statusCode == 202) {
      var fw = FirmwareUpdate.fromJson(jsonDecode(response.body));
      return fw;
    } else {
      throw Exception('Failed to find firmware');
    }
  }

  Future<List<PrimePatch>> fetchPrimePatches(String currentVersion) async {
    final channel = Settings().selectedBetaChannel;
    final channelParam =
        channel != null ? '&channel=${Uri.encodeQueryComponent(channel)}' : '';
    if (channel != null) {
      kPrint(
          "Fetching beta prime patches, url: '$_serverAddress/prime/patches?version=$currentVersion$channelParam'");
    }
    final response = await http!.get(
      '$_serverAddress/prime/patches?version=$currentVersion$channelParam',
    );

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

  Future<List<BetaChannel>> fetchBetaChannels() async {
    final response = await http!.get('$_serverAddress/prime/beta-channels');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch beta channels: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final List<dynamic>? channels = json['channels'];
    if (channels == null) {
      return [];
    }

    return channels
        .map((c) => BetaChannel.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  String _primePatchUrl(PrimePatch patch) {
    final channel = Settings().selectedBetaChannel;
    final channelSegment = channel != null ? '${Uri.encodeComponent(channel)}/' : '';
    return '${Settings().primeFirmwareServerAddress}/prime-firmware/$channelSegment${patch.version}/release.tar';
  }

  Future<Uint8List?> fetchPrimePatchBinary(PrimePatch patch) async {
    final url = _primePatchUrl(patch);
    try {
      final response = await http!.get(url);
      if (response.statusCode == 200) {
        return Uint8List.fromList(response.bodyBytes);
      } else {
        throw Exception(
          'Failed to fetch prime patch ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      EnvoyReport().log(
        "Sever",
        "Error fetching prime patches: $e : $url",
      );
    }

    return null;
  }

  Future<List<PatchBinary>> fetchPrimePatchBinaries(
    String currentVersion,
  ) async {
    List<PatchBinary> result = [];

    try {
      final patches = await fetchPrimePatches(currentVersion);
      for (final patch in patches) {
        final response = await http!.get(_primePatchUrl(patch));
        if (response.statusCode == 200) {
          PatchBinary patchBinary = (
            binary: Uint8List.fromList(response.bodyBytes),
            patch: patch,
          );
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

  Future<bool> checkForForceUpdate() async {
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

        return isDeprecated;
      } else {
        throw Exception(
          'Failed to fetch deprecated versions,server error ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      EnvoyReport().log(
        "UpdateCheck",
        "Error checking envoy update: $e",
        stackTrace: stackTrace,
      );
      kPrint("Error checking for force update: $e");
      return false;
    }
  }
}

class PrimePatch {
  final String version;
  final String baseVersion;
  final String signedSha256;
  final String unsignedSha256;
  final int size;
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
    required this.size,
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
      size: (json['size'] as num?)?.toInt() ?? 0,
      updateFilename: json['update_filename'],
      signatureFilename: json['signature_filename'],
      url: json['url'],
      changelog: json['changelog'],
      releaseDate: DateTime.parse((json['release_date'])),
    );
  }
}

class BetaChannel {
  final String name;
  final int patchCount;
  final String latestVersion;
  final DateTime latestReleaseDate;

  BetaChannel({
    required this.name,
    required this.patchCount,
    required this.latestVersion,
    required this.latestReleaseDate,
  });

  factory BetaChannel.fromJson(Map<String, dynamic> json) {
    return BetaChannel(
      name: json['name'] as String,
      patchCount: (json['patch_count'] as num).toInt(),
      latestVersion: json['latest_version'] as String,
      latestReleaseDate: DateTime.parse(json['latest_release_date'] as String),
    );
  }
}

class ApiKeys {
  final String mapsKey;
  final String rampKey;

  ApiKeys({required this.mapsKey, required this.rampKey});

  factory ApiKeys.fromJson(Map<String, dynamic> json) {
    final keys = json['keys'];
    return ApiKeys(mapsKey: keys['maps_api'], rampKey: keys['ramp_api']);
  }

  Map<String, dynamic> toJson() {
    return {
      'keys': {'maps_api': mapsKey, 'ramp_api': rampKey},
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
  final int? size;

  FirmwareUpdate({
    required this.version,
    required this.url,
    required this.sha256,
    required this.reproducibleHash,
    required this.md5,
    required this.changeLog,
    required this.releaseDate,
    required this.deviceId,
    this.size,
  });

  factory FirmwareUpdate.fromJson(Map<String, dynamic> json) {
    final fw = json['firmware'];
    return FirmwareUpdate(
      deviceId: fw['device_id'],
      sha256: fw['sha256'],
      size: fw['size'],
      md5: fw['md5'],
      url: fw['url'],
      changeLog: fw['changelog'],
      reproducibleHash: fw['reproducible_hash'],
      releaseDate: DateTime.fromMillisecondsSinceEpoch(
        (fw['release_date']['secs_since_epoch']) * 1000,
      ),
      version: fw['version'],
    );
  }
}
