// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';

enum BrandmarkStyle {
  normal,
  endMark, // Mark used to signify the end of a list or in other contexts
}

class Brandmark extends StatelessWidget {
  const Brandmark({
    Key? key,
    required this.logoSize,
    required this.style,
  }) : super(key: key);

  final double logoSize;
  final BrandmarkStyle style;

  @override
  Widget build(BuildContext context) {
    Color filterColor;
    double opacity;
    BlendMode blendMode;

    switch (style) {
      case BrandmarkStyle.normal:
        filterColor = Colors.transparent;
        opacity = 1.0;
        blendMode = BlendMode.saturation;
        break;
      case BrandmarkStyle.endMark:
        filterColor = EnvoyColors.surface1;
        opacity = 0.2;
        blendMode = BlendMode.saturation;
        break;
    }

    return Center(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(100)),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            filterColor,
            blendMode,
          ),
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              "assets/components/icons/brandmark.png",
              width: logoSize,
              height: logoSize,
            ),
          ),
        ),
      ),
    );
  }
}
