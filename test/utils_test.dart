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

  test("Test XFP endianness reverser -  passport big endian", () {
    int xfpFromPassport = 2206109696;
    var xfpString = xfpFromPassport.toRadixString(16);
    expect(xfpString, "837e9000");

    var correctXfp = reverseXfpStringEndianness(xfpString);
    expect(correctXfp, "00907e83");
  });

  test("Test XFP endianness reverser -  way too few digits", () {
    int xfpFromPassport = 9469571;
    var xfpString = xfpFromPassport.toRadixString(16);
    expect(xfpString, "907e83");

    var correctXfp = reverseXfpStringEndianness(xfpString);
    expect(correctXfp, "837e9000");
  });
}
