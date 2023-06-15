// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/envoy_colors.dart';

// Defaults to that brown glow
class Glow extends StatelessWidget {
  const Glow({
    Key? key,
    this.innerColor = EnvoyColors.transparent,
    this.middleColor = EnvoyColors.grey,
    this.outerColor = EnvoyColors.white100,
    this.stops = const [0.0, 0.5, 1.0],
  }) : super(key: key);

  final Color innerColor;
  final Color middleColor;
  final Color outerColor;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: RadialGradient(
              radius: 0.5,
              colors: [innerColor, middleColor, outerColor],
              stops: stops)),
    );
  }
}
