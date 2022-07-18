// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/util/xfp_endian.dart';
import 'package:test/test.dart';

void main() {
  test("Test XFP endianness reverser", () {
    var wrongXfp = "2acd145d";
    var correctXfp = reverseXfpStringEndianness(wrongXfp);
    expect(correctXfp, "5d14cd2a");
  });

  test("Test XFP endianness reverser -  too few digits", () {
    var wrongXfp = "acd145d";
    var correctXfp = reverseXfpStringEndianness(wrongXfp);
    expect(correctXfp, "5d14cd0a");
  });
}
