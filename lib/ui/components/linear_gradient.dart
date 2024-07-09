// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';

class LinearGradients {
  static LinearGradient blogPostGradient(double topGradientEnd) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        EnvoyColors.solidWhite,
        Colors.transparent,
        Colors.transparent,
        EnvoyColors.solidWhite,
      ],
      stops: [0.0, topGradientEnd, 0.85, 0.96],
    );
  }

  static Widget gradientShaderMask({
    required Widget child,
    required double topGradientEnd,
  }) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return blogPostGradient(topGradientEnd).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: child,
    );
  }

  static Widget scrollGradientMask({
    required Widget child,
    ValueNotifier<double>? topGradientEndNotifier,
  }) {
    final notifier = topGradientEndNotifier ?? ValueNotifier<double>(0.0);
    bool hasScrollReachedThreshold = false;
    const thresholdPos = 1;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final currentPosition = notification.metrics.pixels;

          if (!hasScrollReachedThreshold && currentPosition >= thresholdPos) {
            hasScrollReachedThreshold = true;
            notifier.value = 0.05;
          } else if (hasScrollReachedThreshold && currentPosition == 0) {
            hasScrollReachedThreshold = false;
            notifier.value = 0.0;
          }
        }
        return false;
      },
      child: ValueListenableBuilder<double>(
        valueListenable: notifier,
        builder: (context, topGradientEnd, child) {
          return gradientShaderMask(
            topGradientEnd: topGradientEnd,
            child: child!,
          );
        },
        child: child,
      ),
    );
  }
}
