// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

String captureBetween(String string, String first, String second) {
  int firstIndex = string.indexOf(first) + first.length;
  int secondIndex = firstIndex + string.substring(firstIndex).indexOf(second);
  return string.substring(firstIndex, secondIndex);
}
