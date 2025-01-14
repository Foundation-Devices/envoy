// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:ui';

String colorToJson(Color color) => jsonEncode(_getColorValue(color));

Color colorFromJson(String json) => Color(jsonDecode(json));

int _getColorValue(Color color) {
  return _floatToInt8(color.a) << 24 |
      _floatToInt8(color.r) << 16 |
      _floatToInt8(color.g) << 8 |
      _floatToInt8(color.b) << 0;
}

int _floatToInt8(double x) {
  return (x * 255.0).round() & 0xff;
}
