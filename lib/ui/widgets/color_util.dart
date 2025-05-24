// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/ui/envoy_colors.dart';

extension ColorExtension on Color {
  applyOpacity(double opacity) {
    return withAlpha((255.0 * opacity).round());
  }

  String toHex() {
    return toColorHex(this);
  }
}

extension ColorExtensionOnString on String {
  Color toColor() {
    return fromHex(this);
  }
}

Color fromHex(String hexColor) {
  final buffer = StringBuffer();
  if (hexColor.length == 6 || hexColor.length == 7) {
    buffer.write('ff');
  }
  buffer.write(hexColor.replaceFirst('#', ''));

  try {
    final colorValue = int.parse(buffer.toString(), radix: 16);
    return Color(colorValue);
  } on Exception catch (_) {
     return EnvoyColors.listAccountTileColors.first;
  }

}

String toColorHex(Color color) {
  return '#${(color.a * 255).round().toRadixString(16).padLeft(2, '0')}${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}';
}
