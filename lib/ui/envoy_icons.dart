// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TODO: replace with next gen EnvoyIcons from components
class EnvoyIcons {
  static const IconData accounts = IconData(0xE903, fontFamily: 'EnvoyIcons');
  static const IconData devices = IconData(0xE906, fontFamily: 'EnvoyIcons');
  static const IconData lightBulb = IconData(0xE900, fontFamily: 'EnvoyIcons');
  static const IconData qrScan = IconData(0xE904, fontFamily: 'EnvoyIcons');
  static const IconData copyPaste = IconData(0xE902, fontFamily: 'EnvoyIcons');
  static const IconData exclamationWarning =
      IconData(0xE901, fontFamily: 'EnvoyIcons');
}

class EnvoyIcon extends StatelessWidget {
  final String icon;
  final double size;
  final Color? color;

  const EnvoyIcon({super.key, required this.icon, this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/icons/$icon",
      width: size,
      height: size,
      color: color,
    );
  }
}
