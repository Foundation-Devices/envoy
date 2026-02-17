// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/util/easing.dart';
import 'package:flutter/material.dart';

class EnvoyGradientProgress extends StatefulWidget {
  final List<Color> colors;
  final double progress;
  final Color backgroundColor;
  const EnvoyGradientProgress({
    super.key,
    required this.progress,
    this.colors = const [Color(0xff232728), Color(0xff6D7576)],
    this.backgroundColor = EnvoyColors.gray500,
  });

  @override
  State<EnvoyGradientProgress> createState() => _EnvoyGradientProgressState();
}

class _EnvoyGradientProgressState extends State<EnvoyGradientProgress>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: widget.progress),
      curve: EnvoyEasing.defaultEasing,
      builder: (context, value, child) {
        return CustomPaint(
          painter: GradientProgressPainter(
            progress: value,
            colors: widget.colors,
            backgroundColor: widget.backgroundColor,
          ),
          size: const Size(double.infinity, 12), // Height of 4 pixels
        );
      },
      duration: const Duration(milliseconds: 220),
    );
  }
}

class GradientProgressPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final Color backgroundColor;
  GradientProgressPainter({
    required this.progress,
    required this.colors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
      ).createShader(Offset.zero & size);

    final backGroundPaint = Paint()..color = backgroundColor;

    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height),
    );

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width * progress, size.height),
      Radius.circular(size.height),
    );

    canvas.drawRRect(backgroundRect, backGroundPaint);
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(GradientProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
