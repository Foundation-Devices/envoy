// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum EnvoyIconSize { normal, small, big, extraSmall, superSmall }

enum EnvoyIcons {
  chevron_left,
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
  rbf_boost,
  copy,
  share,
  stop_watch,
  close,
  spend,
  receive,
  btcPay,
}

class EnvoyIcon extends StatelessWidget {
  final EnvoyIcons icon;
  final EnvoyIconSize size; // Use the enum type here
  final Color? color;

  const EnvoyIcon(this.icon,
      {super.key, this.color, this.size = EnvoyIconSize.normal});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/components/icons/${icon.name}.svg",
      width: size.toDouble,
      height: size.toDouble,
      color: color,
    );
  }
}

/// Testnet icons have a coloured 'T' badge
class TestnetIcon extends StatelessWidget {
  final EnvoyIcons icon;
  final EnvoyIconSize size;
  final Color? badgeColor;
  final Color? iconColor;

  const TestnetIcon(this.icon,
      {super.key,
      this.badgeColor,
      this.size = EnvoyIconSize.normal,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SvgPicture.asset(
        "assets/components/icons/testnet_badge.svg",
        width: size.toDouble / 2,
        height: size.toDouble / 2,
        color: badgeColor,
      ),
      Padding(
        padding: EdgeInsets.only(
          left: size.toDouble / 5,
        ),
        child: SvgPicture.asset(
          "assets/components/icons/${icon.name}.svg",
          width: size.toDouble,
          height: size.toDouble,
          color: iconColor,
        ),
      ),
    ]);
  }
}

extension FloatSize on EnvoyIconSize {
  double get toDouble {
    switch (this) {
      case EnvoyIconSize.extraSmall:
        return 16.0;
      case EnvoyIconSize.superSmall:
        return 12.0;
      case EnvoyIconSize.small:
        return 18.0;
      case EnvoyIconSize.normal:
        return 24.0; // Default
      case EnvoyIconSize.big:
        return 64.0;
      default:
        return 24.0;
    }
  }
}
