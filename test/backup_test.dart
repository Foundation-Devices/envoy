// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:backup/backup.dart';
import 'package:test/test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

void main() {
  setUpAll(() async => await RustLib.init(
      externalLibrary: ExternalLibrary.open(
          'target/debug/librust_lib_backup.${Platform.isMacOS ? "dylib" : "so"}')));

  test('Test offline restore wrong file', () async {
    // Create bogus file
    const filename = 'bogus.mpa';
    var file = File(filename);
    file.writeAsStringSync('bogus');

    // Try restoring
    expect(
        () async => await Backup.getBackupOffline(
            seedWords:
                "copper december enlist body dove discover cross help evidence fall rich clean",
            filePath: file.absolute.path),
        throwsA(equals(GetBackupException.backupNotFound)));
  });
}
