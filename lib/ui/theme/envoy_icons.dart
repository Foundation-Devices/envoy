// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum EnvoyIconSize { normal, small, big }

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
  scan,
  clipboard,
  filter,
  info,
  alert,
  bell,
  arrow_down_left,
  arrow_up_right,
  delete,
  search,
  remove,
  sats,
  btc,
  tool,
  testnet_badge,
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
      case EnvoyIconSize.big:
        return 64;
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

/// Testnet icons have a coloured 'T' badge
class TestnetIcon extends StatelessWidget {
  final EnvoyIcons icon;
  final double? size;
  final Color? color;

  TestnetIcon(this.icon, {this.color, this.size = 24});

  double? getSize() {
    return size;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SvgPicture.asset(
        "assets/components/icons/testnet_badge.svg",
        width: getSize()! / 2,
        height: getSize()! / 2,
        color: this.color,
      ),
      Padding(
        padding: EdgeInsets.only(
          left: getSize()! / 5,
        ),
        child: SvgPicture.asset(
          "assets/components/icons/${this.icon.name}.svg",
          width: getSize(),
          height: getSize(),
        ),
      ),
    ]);
  }
}
