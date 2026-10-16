// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:envoy/ble/qlv2/handlers/firmware_handler.dart';
import 'package:envoy/business/local_prime_firmware_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final override = LocalPrimeFirmwareUpdateOverride.instance;
  late Directory directory;

  setUp(() async {
    override.clear();
    directory = await Directory.systemTemp.createTemp(
      "envoy-local-prime-firmware-",
    );
  });

  tearDown(() async {
    override.clear();
    await directory.delete(recursive: true);
  });

  test("loads a valid folder and preserves manifest patch order", () async {
    final first = await _writePatch(directory, "first.patch", [1, 2, 3]);
    final second = await _writePatch(directory, "second.patch", [4, 5]);
    await File("${directory.path}/unrelated.json").writeAsString("{}");
    await _writeManifest(directory, [
      _patchJson("2.1.0", "2.0.0", first, changelog: "First"),
      _patchJson("2.2.0", "2.1.0", second, changelog: "Second"),
    ]);

    final manifest = await override.selectFolder(directory.path);

    expect(manifest.targetVersion, "2.2.0");
    expect(manifest.patches.map((patch) => patch.updateFilename), [
      "first.patch",
      "second.patch",
    ]);
    expect(manifest.totalSize, 5);
    final source = selectedQlv2FirmwareSource();
    expect(source, isA<LocalQlv2FirmwareSource>());
    expect(await source.fetchPatches("v2.2.0\u0000"), isEmpty);
    expect(await source.fetchPatches("1.9.0"), isEmpty);
    expect(
      (await source.fetchPatches("2.1.0")).map((patch) => patch.version),
      ["2.2.0"],
    );
    final sourcePatches = await source.fetchPatches("2.0.0");
    expect(sourcePatches.map((patch) => patch.version), ["2.1.0", "2.2.0"]);
    final update = buildQlv2FirmwareUpdateAvailable(
      sourcePatches,
      localOverride: true,
    );
    expect(update.version, "2.2.0");
    expect(
      update.timestamp,
      DateTime.parse("2026-10-14T10:00:00Z").millisecondsSinceEpoch ~/
          Duration.millisecondsPerSecond,
    );
    expect(update.totalSize, 5);
    expect(update.patchCount, 2);
    expect(update.changelog, "Second\nFirst");
  });

  test("rejects a folder without update.json", () async {
    await File("${directory.path}/one.json").writeAsString("{}");
    await File("${directory.path}/two.JSON").writeAsString("{}");

    await expectLater(
      override.selectFolder(directory.path),
      _throwsManifestError("Selected folder must contain update.json"),
    );
  });

  test("copies a selected patch and reports copy progress", () async {
    final patch = await _writePatch(
      directory,
      "copy.patch",
      List<int>.generate(200000, (index) => index % 256),
    );
    await _writeManifest(directory, [
      _patchJson("2.1.0", "2.0.0", patch),
    ]);
    final manifest = await override.selectFolder(directory.path);
    final destination = File("${directory.path}/downloaded/copy.patch");
    final progress = <int>[];

    final bytes = await manifest.patches.single.copyTo(
      destination,
      onProgress: progress.add,
    );

    expect(bytes, patch.bytes);
    expect(await destination.readAsBytes(), patch.bytes);
    expect(progress, isNotEmpty);
    expect(progress.last, patch.bytes.length);
  });

  test("rejects a missing patch file", () async {
    await _writeManifest(directory, [
      _patchJson(
        "2.1.0",
        "2.0.0",
        _PatchFixture("missing.patch", [1, 2, 3]),
      ),
    ]);

    await expectLater(
      override.selectFolder(directory.path),
      _throwsManifestError("Patch file not found: missing.patch"),
    );
  });

  test("rejects a patch whose size does not match", () async {
    final patch = await _writePatch(directory, "size.patch", [1, 2, 3]);
    final json = _patchJson("2.1.0", "2.0.0", patch);
    json["size"] = patch.bytes.length + 1;
    await _writeManifest(directory, [json]);

    await expectLater(
      override.selectFolder(directory.path),
      _throwsManifestError(
        "Patch file size does not match the manifest: size.patch",
      ),
    );
  });

  test("rejects a patch whose checksum does not match", () async {
    final patch = await _writePatch(directory, "checksum.patch", [1, 2, 3]);
    final json = _patchJson("2.1.0", "2.0.0", patch);
    json["signed_sha256"] = List.filled(64, "0").join();
    await _writeManifest(directory, [json]);

    await expectLater(
      override.selectFolder(directory.path),
      _throwsManifestError(
        "Patch file checksum does not match the manifest: checksum.patch",
      ),
    );
  });

  test("rejects an invalid release date", () async {
    final patch = await _writePatch(directory, "date.patch", [1, 2, 3]);
    final json = _patchJson("2.1.0", "2.0.0", patch);
    json["release_date"] = "2026-02-31";
    await _writeManifest(directory, [json]);

    await expectLater(
      override.selectFolder(directory.path),
      _throwsManifestError(
        "Patch 1 release_date must be a valid ISO-8601 date",
      ),
    );
  });

  test("rejects duplicate and nested patch filenames", () async {
    final patch = await _writePatch(directory, "duplicate.patch", [1, 2, 3]);
    final duplicate = _patchJson("2.2.0", "2.1.0", patch);
    await _writeManifest(directory, [
      _patchJson("2.1.0", "2.0.0", patch),
      duplicate,
    ]);

    await expectLater(
      override.selectFolder(directory.path),
      _throwsManifestError("Duplicate patch filename: duplicate.patch"),
    );

    final nestedDirectory = await Directory.systemTemp.createTemp(
      "envoy-local-prime-firmware-nested-",
    );
    addTearDown(() => nestedDirectory.delete(recursive: true));
    await _writeManifest(nestedDirectory, [
      _patchJson(
        "2.1.0",
        "2.0.0",
        _PatchFixture("subfolder/patch.bin", [1]),
      ),
    ]);
    await expectLater(
      override.selectFolder(nestedDirectory.path),
      _throwsManifestError(
        "Patch file must be directly inside the selected folder: subfolder/patch.bin",
      ),
    );
  });

  test("rejects a discontinuous patch chain", () async {
    final first = await _writePatch(directory, "first.patch", [1, 2, 3]);
    final second = await _writePatch(directory, "second.patch", [4, 5]);
    await _writeManifest(directory, [
      _patchJson("2.1.0", "2.0.0", first),
      _patchJson("2.3.0", "2.2.0", second),
    ]);

    await expectLater(
      override.selectFolder(directory.path),
      _throwsManifestError(
        "Patch 2 base_version must match patch 1 version",
      ),
    );
  });

  test("invalid selection preserves the override and clear restores server",
      () async {
    final patch = await _writePatch(directory, "valid.patch", [1, 2, 3]);
    await _writeManifest(directory, [
      _patchJson("2.1.0", "2.0.0", patch),
    ]);
    final active = await override.selectFolder(directory.path);

    final invalidDirectory = await Directory.systemTemp.createTemp(
      "envoy-local-prime-firmware-invalid-",
    );
    addTearDown(() => invalidDirectory.delete(recursive: true));
    await expectLater(
      override.selectFolder(invalidDirectory.path),
      _throwsManifestError("Selected folder must contain update.json"),
    );
    expect(override.manifest, same(active));

    override.clear();

    expect(override.manifest, isNull);
    expect(selectedQlv2FirmwareSource(), isA<ServerQlv2FirmwareSource>());
  });
}

Future<_PatchFixture> _writePatch(
  Directory directory,
  String name,
  List<int> bytes,
) async {
  await File("${directory.path}/$name").writeAsBytes(bytes);
  return _PatchFixture(name, bytes);
}

Future<void> _writeManifest(
  Directory directory,
  List<Map<String, Object>> patches,
) async {
  await File("${directory.path}/update.json").writeAsString(
    jsonEncode({"patches": patches}),
  );
}

Map<String, Object> _patchJson(
  String version,
  String baseVersion,
  _PatchFixture patch, {
  String changelog = "Changes",
}) {
  return {
    "version": version,
    "base_version": baseVersion,
    "signed_sha256": sha256.convert(patch.bytes).toString(),
    "size": patch.bytes.length,
    "update_filename": patch.name,
    "url": "https://firmware.foundation.xyz/${patch.name}",
    "changelog": changelog,
    "release_date": "2026-10-14T10:00:00Z",
  };
}

Matcher _throwsManifestError(String message) {
  return throwsA(
    isA<LocalPrimeFirmwareManifestException>().having(
      (error) => error.message,
      "message",
      message,
    ),
  );
}

class _PatchFixture {
  const _PatchFixture(this.name, this.bytes);

  final String name;
  final List<int> bytes;
}
