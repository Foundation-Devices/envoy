// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';

class LinearGradients {
  static LinearGradient blogPostGradient(bool isScrollAtTop) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        EnvoyColors.solidWhite,
        Colors.transparent,
        Colors.transparent,
        EnvoyColors.solidWhite,
      ],
      stops: isScrollAtTop ? [0.0, 0.0, 0.85, 0.96] : [0.0, 0.05, 0.85, 0.96],
    );
  }

  static Widget gradientShaderMask(
      {required Widget child, required bool isScrollAtTop}) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return blogPostGradient(isScrollAtTop).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: child,
    );
  }
}
