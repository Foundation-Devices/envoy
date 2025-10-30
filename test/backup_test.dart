// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:backup/backup.dart';
import 'package:test/test.dart';

void main() {
  test("Test offline restore wrong file", () async {
    // Create bogus file
    await RustLib.init();
    const filename = 'bogus.mpa';
    var file = File(filename);
    file.writeAsStringSync('bogus');

    // Try restoring
    expect(
        () => Backup.getBackupOffline(
            seedWords:
                "copper december enlist body dove discover cross help evidence fall rich clean",
            filePath: file.absolute.path),
        throwsException);
  });
}
