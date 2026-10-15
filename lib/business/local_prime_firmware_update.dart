// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:envoy/util/console.dart';
import 'package:path/path.dart' as p;

class LocalPrimeFirmwareUpdateOverride {
  LocalPrimeFirmwareUpdateOverride._();

  static final LocalPrimeFirmwareUpdateOverride instance =
      LocalPrimeFirmwareUpdateOverride._();

  LocalPrimeFirmwareManifest? _manifest;

  LocalPrimeFirmwareManifest? get manifest => _manifest;

  bool get isActive => _manifest != null;

  Future<LocalPrimeFirmwareManifest> selectFolder(String folderPath) async {
    _logLocalPrimeFirmware("select: folder=$folderPath");
    try {
      final manifest =
          await LocalPrimeFirmwareManifest.fromDirectory(folderPath);
      _manifest = manifest;
      _logLocalPrimeFirmware(
        "select: active manifest=${manifest.manifestPath} "
        "target=${manifest.targetVersion} patches=${manifest.patches.length}",
      );
      return manifest;
    } catch (error, stackTrace) {
      _logLocalPrimeFirmware(
        "select: failed folder=$folderPath error=$error",
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void clear() {
    _logLocalPrimeFirmware(
      "clear: manifest=${_manifest?.manifestPath ?? "none"}",
    );
    _manifest = null;
  }
}

class LocalPrimeFirmwareManifest {
  const LocalPrimeFirmwareManifest({
    required this.directoryPath,
    required this.manifestPath,
    required this.patches,
  });

  final String directoryPath;
  final String manifestPath;
  final List<LocalPrimeFirmwarePatch> patches;

  String get targetVersion => patches.last.version;

  int get totalSize => patches.fold(0, (sum, patch) => sum + patch.size);

  static Future<LocalPrimeFirmwareManifest> fromDirectory(
    String folderPath,
  ) async {
    final directory = Directory(p.absolute(folderPath));
    _logLocalPrimeFirmware("validate: directory=${directory.path}");
    if (!await directory.exists()) {
      throw const LocalPrimeFirmwareManifestException(
        "Selected firmware folder does not exist",
      );
    }

    final manifestFile = File(p.join(directory.path, "update.json"));
    _logLocalPrimeFirmware(
      "validate: looking for manifest=${manifestFile.path}",
    );
    if (await FileSystemEntity.type(
          manifestFile.path,
          followLinks: false,
        ) !=
        FileSystemEntityType.file) {
      throw const LocalPrimeFirmwareManifestException(
        "Selected folder must contain update.json",
      );
    }

    late final Object? decoded;
    try {
      final manifestJson = await manifestFile.readAsString();
      _logLocalPrimeFirmware(
        "validate: read manifest bytes=${manifestJson.length}",
      );
      decoded = jsonDecode(manifestJson);
    } on FormatException {
      throw const LocalPrimeFirmwareManifestException(
        "Manifest is not valid JSON",
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const LocalPrimeFirmwareManifestException(
        "Manifest must be a JSON object",
      );
    }

    final rawPatches = decoded["patches"];
    if (rawPatches is! List || rawPatches.isEmpty) {
      throw const LocalPrimeFirmwareManifestException(
        "Manifest must include at least one patch",
      );
    }
    _logLocalPrimeFirmware(
      "validate: manifest contains patches=${rawPatches.length}",
    );

    final patchNames = <String>{};
    final patches = <LocalPrimeFirmwarePatch>[];
    for (var index = 0; index < rawPatches.length; index++) {
      final rawPatch = rawPatches[index];
      if (rawPatch is! Map<String, dynamic>) {
        throw LocalPrimeFirmwareManifestException(
          "Patch ${index + 1} must be a JSON object",
        );
      }

      final patch = await LocalPrimeFirmwarePatch.fromJson(
        rawPatch,
        directoryPath: directory.path,
        patchNumber: index + 1,
      );
      if (!patchNames.add(patch.updateFilename)) {
        throw LocalPrimeFirmwareManifestException(
          "Duplicate patch filename: ${patch.updateFilename}",
        );
      }
      patches.add(patch);
      _logLocalPrimeFirmware(
        "validate: patch ${index + 1}/${rawPatches.length} ready "
        "file=${patch.updateFilename} path=${patch.path} size=${patch.size}",
      );
    }

    final manifest = LocalPrimeFirmwareManifest(
      directoryPath: directory.path,
      manifestPath: manifestFile.path,
      patches: List.unmodifiable(patches),
    );
    _logLocalPrimeFirmware(
      "validate: complete target=${manifest.targetVersion} "
      "totalSize=${manifest.totalSize}",
    );
    return manifest;
  }
}

class LocalPrimeFirmwarePatch {
  const LocalPrimeFirmwarePatch({
    required this.path,
    required this.version,
    required this.baseVersion,
    required this.signedSha256,
    required this.size,
    required this.updateFilename,
    required this.url,
    required this.changelog,
    required this.releaseDate,
  });

  final String path;
  final String version;
  final String baseVersion;
  final String signedSha256;
  final int size;
  final String updateFilename;
  final String url;
  final String changelog;
  final DateTime releaseDate;

  Future<Uint8List> copyTo(
    File destination, {
    required void Function(int copiedBytes) onProgress,
  }) async {
    final bytes = BytesBuilder(copy: false);
    var copiedBytes = 0;
    await destination.parent.create(recursive: true);

    try {
      await File(path).openRead().map((chunk) {
        bytes.add(chunk);
        copiedBytes += chunk.length;
        onProgress(copiedBytes);
        return chunk;
      }).pipe(destination.openWrite());

      final result = bytes.takeBytes();
      if (result.length != size) {
        throw LocalPrimeFirmwareManifestException(
          "Patch file size does not match the manifest: $updateFilename",
        );
      }
      if (sha256.convert(result).toString().toLowerCase() != signedSha256) {
        throw LocalPrimeFirmwareManifestException(
          "Patch file checksum does not match the manifest: $updateFilename",
        );
      }
      return result;
    } catch (_) {
      if (await destination.exists()) {
        await destination.delete();
      }
      rethrow;
    }
  }

  static Future<LocalPrimeFirmwarePatch> fromJson(
    Map<String, dynamic> json, {
    required String directoryPath,
    required int patchNumber,
  }) async {
    final version = _requiredNonEmptyString(json, "version", patchNumber);
    final baseVersion =
        _requiredNonEmptyString(json, "base_version", patchNumber);
    final signedSha256 =
        _requiredNonEmptyString(json, "signed_sha256", patchNumber)
            .toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(signedSha256)) {
      throw LocalPrimeFirmwareManifestException(
        "Patch $patchNumber has an invalid signed_sha256",
      );
    }

    final sizeValue = json["size"];
    if (sizeValue is! int || sizeValue <= 0) {
      throw LocalPrimeFirmwareManifestException(
        "Patch $patchNumber must include a positive integer size",
      );
    }

    final updateFilename =
        _requiredNonEmptyString(json, "update_filename", patchNumber);
    _logLocalPrimeFirmware(
      "validate: patch $patchNumber update_filename=$updateFilename",
    );
    if (updateFilename == "." ||
        updateFilename == ".." ||
        p.posix.basename(updateFilename) != updateFilename ||
        p.windows.basename(updateFilename) != updateFilename) {
      throw LocalPrimeFirmwareManifestException(
        "Patch file must be directly inside the selected folder: $updateFilename",
      );
    }

    final url = _requiredString(json, "url", patchNumber);
    final releaseDateValue =
        _requiredNonEmptyString(json, "release_date", patchNumber);
    final releaseDate = _parseReleaseDate(releaseDateValue, patchNumber);

    final changelogValue = json["changelog"];
    if (changelogValue != null && changelogValue is! String) {
      throw LocalPrimeFirmwareManifestException(
        "Patch $patchNumber changelog must be a string",
      );
    }

    final patchPath = p.join(directoryPath, updateFilename);
    _logLocalPrimeFirmware(
      "validate: patch $patchNumber looking for file=$patchPath",
    );
    if (await FileSystemEntity.type(patchPath, followLinks: false) !=
        FileSystemEntityType.file) {
      throw LocalPrimeFirmwareManifestException(
        "Patch file not found: $updateFilename",
      );
    }

    final patchFile = File(patchPath);
    final actualSize = await patchFile.length();
    _logLocalPrimeFirmware(
      "validate: patch $patchNumber size expected=$sizeValue actual=$actualSize",
    );
    if (actualSize != sizeValue) {
      throw LocalPrimeFirmwareManifestException(
        "Patch file size does not match the manifest: $updateFilename",
      );
    }

    final actualSha256 = await sha256.bind(patchFile.openRead()).first;
    if (actualSha256.toString().toLowerCase() != signedSha256) {
      throw LocalPrimeFirmwareManifestException(
        "Patch file checksum does not match the manifest: $updateFilename",
      );
    }
    _logLocalPrimeFirmware(
      "validate: patch $patchNumber checksum matched file=$updateFilename",
    );

    return LocalPrimeFirmwarePatch(
      path: patchPath,
      version: version,
      baseVersion: baseVersion,
      signedSha256: signedSha256,
      size: sizeValue,
      updateFilename: updateFilename,
      url: url,
      changelog: changelogValue as String? ?? "",
      releaseDate: releaseDate,
    );
  }

  static String _requiredNonEmptyString(
    Map<String, dynamic> json,
    String key,
    int patchNumber,
  ) {
    final value = _requiredString(json, key, patchNumber);
    if (value.trim().isEmpty) {
      throw LocalPrimeFirmwareManifestException(
        "Patch $patchNumber must include a non-empty $key",
      );
    }
    return value;
  }

  static String _requiredString(
    Map<String, dynamic> json,
    String key,
    int patchNumber,
  ) {
    final value = json[key];
    if (value is! String) {
      throw LocalPrimeFirmwareManifestException(
        "Patch $patchNumber must include a string $key",
      );
    }
    return value;
  }

  static DateTime _parseReleaseDate(String value, int patchNumber) {
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2})(?::(\d{2})(?:[.,]\d{1,6})?)?(?:Z|[+-](\d{2}):?(\d{2}))?)?$',
      caseSensitive: false,
    ).firstMatch(value);
    final parsed = DateTime.tryParse(value);
    if (match == null || parsed == null) {
      throw LocalPrimeFirmwareManifestException(
        "Patch $patchNumber release_date must be a valid ISO-8601 date",
      );
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final hour = int.tryParse(match.group(4) ?? "0") ?? 0;
    final minute = int.tryParse(match.group(5) ?? "0") ?? 0;
    final second = int.tryParse(match.group(6) ?? "0") ?? 0;
    final offsetHour = int.tryParse(match.group(7) ?? "0") ?? 0;
    final offsetMinute = int.tryParse(match.group(8) ?? "0") ?? 0;
    final validDate = month >= 1 &&
        month <= 12 &&
        day >= 1 &&
        day <= DateTime.utc(year, month + 1, 0).day;
    if (!validDate ||
        hour > 23 ||
        minute > 59 ||
        second > 59 ||
        offsetHour > 23 ||
        offsetMinute > 59) {
      throw LocalPrimeFirmwareManifestException(
        "Patch $patchNumber release_date must be a valid ISO-8601 date",
      );
    }
    return parsed;
  }
}

class LocalPrimeFirmwareManifestException implements Exception {
  const LocalPrimeFirmwareManifestException(this.message);

  final String message;

  @override
  String toString() => message;
}

void _logLocalPrimeFirmware(String message, {StackTrace? stackTrace}) {
  kPrint(
    "[LocalPrimeFirmware] $message",
    stackTrace: stackTrace,
  );
}
