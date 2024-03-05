// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

Directory libDirectory =
    Directory("${Directory.current.path}${Platform.pathSeparator}lib");

List excludedDirs = [
  "${libDirectory.path}${Platform.pathSeparator}l10n",
  "${libDirectory.path}${Platform.pathSeparator}generated",
];

Directory arbDirectory = Directory(
    "${Directory.current.path}${Platform.pathSeparator}lib${Platform.pathSeparator}l10n");

main(args) async {
  File baseArbFile =
      File("${arbDirectory.path}${Platform.pathSeparator}intl_en.arb");

  String arbContent = await baseArbFile.readAsString();
  Map<String, dynamic> textKeys = jsonDecode(arbContent);
  if (kDebugMode) {
    print("Total Keys: ${textKeys.keys.length}");
  }

  List<String> excludedKeys = [];
  textKeys.keys.forEach((element) {
    bool foundUsage = false;
    libDirectory.listSync(recursive: true).forEach((file) {
      if (file is File && file.path.endsWith(".dart")) {
        for (final dir in excludedDirs) {
          if (file.path.contains(dir)) {
            /// Skip excluded directories files
            return;
          }
        }
        // Already found usage; no need to check other files.
        if (foundUsage) {
          return;
        }
        String content = file.readAsStringSync();
        if (content.contains(element)) {
          foundUsage = true;
        }
      }
    });
    if (!foundUsage) {
      if (!excludedKeys.contains(element)) {
        excludedKeys.add(element);
      }
    }
  });

  print(
      "Excluded: ${excludedKeys.length} \nAfter filter: ${textKeys.keys.length - excludedKeys.length}\n Generating intl files...");

  print("Excluded keys:\n ${excludedKeys.join("\n")}");
}
