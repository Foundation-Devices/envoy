// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:backup/backup.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  test("Test offline restore wrong file", () {
    // Create bogus file
    const filename = 'bogus.mpa';
    var file = File(filename);
    file.writeAsStringSync('bogus');

    // Try restoring
    expect(
        () => Backup.restoreOffline(
            "copper december enlist body dove discover cross help evidence fall rich clean",
            file.absolute.path),
        throwsException);
  });
}
