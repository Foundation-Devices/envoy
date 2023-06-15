// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

// Dart doesn't support tuples
class ColorPair {
  final Color darker;
  final Color lighter;

  ColorPair(this.darker, this.lighter);
}

class EnvoyColors {
  static const Color tilesLineDarkColor = Color(0xFF232728);
  static const Color deviceBackgroundGradientGrey = Color(0xFFD3D3D3);

  static const Color blue = Color(0xFF509FB5);
  static const Color lightBlue = Color(0xFFA8DDE5);

  static const Color brown = Color(0xFF8A6251);
  static const Color lightBrown = Color(0xFFEEC4B3);

  static const Color blackish = Color(0xFF25292A);
  static const Color lightBlackish = Color(0xFF737A7B);

  static const Color whitePrint = Color(0xFFF8F8F8);
  static const Color white95 = Color(0xF2FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white100 = Color(0xFFFFFFFF);
  static const Color white01 = Color(0x03FFFFFF);

  static const Color transparent = Color(0x00FFFFFF);

  static const Color grey = Color(0xFF686868);
  static const Color grey15 = Color(0x26C0C0C0);
  static const Color grey22 = Color(0x38C0C0C0);
  static const Color grey85 = Color(0xD9C0C0C0);
  static const Color greyLoadingSpinner = Color(0xD9D9D9);

  static const Color darkTeal = Color(0xFF009DB9);
  static const Color teal = Color(0xFF00BDCD);

  static const Color darkCopper = Color(0xFFBF755F);
  static const Color lightCopper = Color(0xFFFBC4AA);

  static const Color danger = Color(0xFFBB6E5A);

  static List<Color> listAccountTileColors = [
    Color(0xFFBF755F),
    Color(0xFF009DB9),
    Color(0xFF007A7A),
    Color(0xFFD68B6E),
    Color(0xFF00A5B2),
    Color(0xFF2E9483),
    // Color(0xFF8A4F38),
    // Color(0xFF007A7A),
    // Color(0xFF004747),
  ];

  static List<ColorPair> listTileColorPairs = [
    ColorPair(blue, lightBlue),
    ColorPair(brown, lightBrown),
    ColorPair(blackish, lightBlackish)
  ];
}
