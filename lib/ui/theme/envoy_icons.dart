// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum EnvoyIconSize { normal, small }

enum EnvoyIcons {
  chevron_down,
  biometrics,
  node,
  performance,
  privacy,
  check,
  bitcoin_b,
  list,
  card_view,
  history,
  shield,
  learn,
  devices,
  filter,
}

class EnvoyIcon extends StatelessWidget {
  final EnvoyIcons icon;
  final EnvoyIconSize size; // Use the enum type here
  final Color? color;

  EnvoyIcon(this.icon, {this.color, this.size = EnvoyIconSize.normal});

  double getSize() {
    switch (size) {
      case EnvoyIconSize.normal:
        return 24.0; // Default
      case EnvoyIconSize.small:
        return 18.0;
      default:
        return 24.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/components/icons/${this.icon.name}.svg",
      width: getSize(),
      height: getSize(),
      color: this.color,
    );
  }
}
