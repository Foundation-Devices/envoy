// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

String reverseXfpStringEndianness(String xfp) {
  String toReverse = xfp.padLeft(8, '0');
  String reversed = "";

  for (int i = 0; i < toReverse.length; i += 2) {
    reversed = toReverse.substring(i, i + 2) + reversed;
  }

  return reversed;
}
