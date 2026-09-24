// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/services.dart';
import 'package:http_tor/http_tor.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';

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

  Future<List<PrimePatch>> fetchPrimePatches(
    String currentVersion, {
    bool foreground = false,
  }) async {
    final channel = Settings().selectedBetaChannel;
    final channelParam =
        channel != null ? '&channel=${Uri.encodeQueryComponent(channel)}' : '';
    if (channel != null) {
      kPrint(
          "Fetching beta prime patches, url: '$_serverAddress/prime/patches?version=$currentVersion$channelParam'");
    }
    final get = foreground ? http!.getForeground : http!.get;
    final response = await get(
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
    final path = Uri.parse(patch.url).pathSegments.skip(1).join('/');
    return '${Settings().primeFirmwareServerAddress}/$path';
  }

  Future<Uint8List> fetchPrimePatchBinary(
    PrimePatch patch, {
    required DownloadCancellationToken cancellationToken,
    void Function(Progress progress)? onProgress,
  }) async {
    final digest = patch.signedSha256.toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(digest)) {
      throw const FormatException('Prime patch has an invalid SHA-256 digest');
    }
    if (patch.size <= 0) {
      throw const FormatException(
        'Prime patch metadata is missing the update size',
      );
    }

    // Resolve the async cache path before selecting the URL. The subsequent
    // download call captures the matching Tor route synchronously.
    final cachePath = await _primePatchCachePath(digest);
    final url = _primePatchUrl(patch);

    try {
      final file = await http!.downloadVerifiedFile(
        cachePath,
        url,
        expectedSize: patch.size,
        expectedSha256: digest,
        cancellationToken: cancellationToken,
        onProgress: onProgress,
      );
      return file.readAsBytes();
    } catch (e, stack) {
      EnvoyReport().log(
        "Server",
        "Error fetching Prime patch: $e : $url",
        stackTrace: stack,
      );
      rethrow;
    }
  }

  static Future<String> _primePatchCachePath(String digest) async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}${Platform.pathSeparator}prime-$digest.tar';
  }

  static Future<void> cleanupStalePrimePatchFiles({
    Duration maxAge = const Duration(days: 2),
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final cutoff = DateTime.now().subtract(maxAge);
      final cacheFilePattern = RegExp(
        r'^prime-[0-9a-f]{64}\.tar(?:\.part)?$',
      );

      await for (final entity in directory.list()) {
        if (entity is! File ||
            !cacheFilePattern.hasMatch(entity.uri.pathSegments.last)) {
          continue;
        }

        try {
          final modified = await entity.lastModified();
          if (modified.isBefore(cutoff)) {
            await entity.delete();
          }
        } catch (e, stack) {
          EnvoyReport().log(
            "Server",
            "Failed to remove stale Prime patch cache file: $e : ${entity.path}",
            stackTrace: stack,
          );
        }
      }
    } catch (e, stack) {
      // Cache cleanup is best-effort and must not affect a completed update.
      EnvoyReport().log(
        "Server",
        "Failed to clean the Prime patch cache: $e",
        stackTrace: stack,
      );
    }
  }

  Future<bool> checkForForceUpdate({bool foreground = false}) async {
    late final Response response;
    try {
      // Fetch deprecated versions from the backend
      response = foreground
          ? await http!.getForeground('$_serverAddress/deprecated-versions')
          : await http!.get('$_serverAddress/deprecated-versions');
    } catch (e, stackTrace) {
      _reportUpdateCheckError(e, stackTrace);
      if (foreground) {
        rethrow;
      }
      return false;
    }

    try {
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
      _reportUpdateCheckError(e, stackTrace);
      return false;
    }
  }

  void _reportUpdateCheckError(Object error, StackTrace stackTrace) {
    EnvoyReport().log(
      "UpdateCheck",
      "Error checking envoy update: $error",
      stackTrace: stackTrace,
    );
    kPrint("Error checking for force update: $error");
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
