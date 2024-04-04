// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String expectedSeed =
      "word word word word word word word word word word word word";
  test("Test converting with slash", () async {
    String inputCode =
        "word/word/word/word/word/word/word/word/word/word/word/word";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });
  test("Test converting with spaces", () async {
    String inputCode = expectedSeed;
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });
  test("Test converting with commas", () async {
    String inputCode =
        "word, word, word, word, word, word, word, word, word, word, word, word";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });

  test("Test converting with additional spaces", () async {
    String inputCode =
        "word   word   word   word   word   word   word   word   word   word   word   word";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });
  test("Test converting with mixed delimiters", () async {
    String inputCode =
        "word word/word, word/word word, word/word, word, word, word, word";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });
  test("Test converting with newlines", () async {
    String inputCode =
        "word\nword\nword\nword\nword\nword\nword\nword\nword\nword\nword\nword";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });
}
