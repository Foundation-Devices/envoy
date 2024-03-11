// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

///Capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (length == 0) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
