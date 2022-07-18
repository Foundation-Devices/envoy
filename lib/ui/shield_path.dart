// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'dart:math';

class ShieldPath extends NeumorphicPathProvider {
  @override
  Path getPath(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    var path = Path();
    double arcSize = 64;
    double padding = 0;

    double shieldCrestAngle = 160;
    double arcAngle = (180 - shieldCrestAngle) / 2;

    double shieldCrestOffset =
        (size.width - (2 * padding)) * tan(degToRad(arcAngle)) / 2;

    path.arcTo(Rect.fromLTWH(padding, padding, arcSize, arcSize), degToRad(180),
        degToRad(90), false);
    path.arcTo(
        Rect.fromLTWH(
            size.width - (arcSize + padding), padding, arcSize, arcSize),
        degToRad(270),
        degToRad(90),
        false);

    path.arcTo(
        Rect.fromLTWH(
            size.width - (arcSize + padding),
            size.height - (arcSize + padding + shieldCrestOffset),
            arcSize,
            arcSize),
        degToRad(0),
        degToRad(90 - arcAngle),
        false);

    path.lineTo(size.width / 2, size.height - padding);

    path.arcTo(
        Rect.fromLTWH(
            padding,
            size.height - (arcSize + padding + shieldCrestOffset),
            arcSize,
            arcSize),
        degToRad(90 + arcAngle),
        degToRad(90 - arcAngle),
        false);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(NeumorphicPathProvider oldClipper) {
    return true;
  }

  @override
  bool get oneGradientPerPath {
    return true;
  }
}
