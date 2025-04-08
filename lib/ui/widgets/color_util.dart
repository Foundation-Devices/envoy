// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

extension ColorExtension on Color {
  applyOpacity(double opacity) {
    return withAlpha((255.0 * opacity).round());
  }

  String toHex() {
    return toColorHex(this);
  }
}

Color fromHex(String hexColor) {
  final buffer = StringBuffer();
  if (hexColor.length == 6 || hexColor.length == 7) {
    buffer.write('ff');
  }
  buffer.write(hexColor.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

String toColorHex(Color color) {
  return '#${(color.a * 255).round().toRadixString(16).padLeft(2, '0')}${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}';
}
