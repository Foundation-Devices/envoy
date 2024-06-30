// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';

class LinearGradients {
  static const LinearGradient blogPostGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      EnvoyColors.solidWhite,
      Colors.transparent,
      Colors.transparent,
      EnvoyColors.solidWhite,
    ],
    stops: [0.0, 0.05, 0.85, 0.96],
  );

  static Widget gradientShaderMask({required Widget child}) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return blogPostGradient.createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: child,
    );
  }
}
