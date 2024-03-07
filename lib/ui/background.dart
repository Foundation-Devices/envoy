// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatefulWidget {
  @override
  State<AppBackground> createState() => AppBackgroundState();

  const AppBackground({super.key});
}

class AppBackgroundState extends State<AppBackground> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double parentHeight = constraints.maxHeight;
        double parentWidth = constraints.maxWidth;

        return Stack(children: [
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: 0.5,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: LinesPainter(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              height: parentHeight * 2,
              width: parentHeight * 2,
              top: -parentHeight,
              right: parentWidth / 2 - parentHeight,
              child: Opacity(
                  opacity: 0.92,
                  child: Container(
                      decoration: const BoxDecoration(
                          gradient: RadialGradient(
                    radius: 0.5,
                    colors: [
                      Colors.transparent,
                      EnvoyColors.grey,
                      Colors.white
                    ],
                    stops: [0.0, 0.60, 0.85],
                  )))))
        ]);
      },
    );
  }
}

class LinesPainter extends CustomPainter {
  final Color color;
  final double angle;
  final double opacity;
  final double lineDistance;

  LinesPainter(
      {this.angle = 160,
      this.lineDistance = 2.5,
      this.color = EnvoyColors.whitePrint,
      this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    double shieldCrestOffset = size.width * tan(degToRad(angle));

    double currentY = 0;

    while (currentY < size.height - shieldCrestOffset) {
      final p1 = Offset(0, currentY);
      final p2 = Offset(size.width, currentY + shieldCrestOffset);
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..strokeWidth = 1;
      canvas.drawLine(p1, p2, paint);

      currentY += lineDistance;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

//wrap any widget with this to get a envoy striped background
class StripesBackground extends StatelessWidget {
  final Widget child;

  const StripesBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: CustomPaint(
            isComplex: true,
            willChange: false,
            painter: LinesPainter(color: EnvoyColors.gray1000, opacity: 0.4),
            child: child,
          ),
        );
      },
    );
  }
}
