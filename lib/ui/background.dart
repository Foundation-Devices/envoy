// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatefulWidget {
  final bool showRadialGradient;

  @override
  State<AppBackground> createState() => AppBackgroundState();

  const AppBackground({super.key, this.showRadialGradient = false});
}

class LinesBackground extends StatelessWidget {
  const LinesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double parentWidth = constraints.maxWidth;
        return Stack(
          children: [
            Positioned(
              left: parentWidth / 2,
              width: parentWidth,
              height: MediaQuery.sizeOf(context).height,
              child: CustomPaint(
                painter: LinesPainter(
                  opacity: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AppBackgroundState extends State<AppBackground> {
  final _animDuration = const Duration(milliseconds: 310);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double parentHeight = constraints.maxHeight;
        double parentWidth = constraints.maxWidth;

        return Stack(children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Container(
                color: Colors.black,
                child: FractionallySizedBox(
                  alignment: Alignment.centerRight,
                  widthFactor: 0.5,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.02),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds);
                    },
                    child: CustomPaint(
                      isComplex: true,
                      willChange: false,
                      painter: LinesPainter(
                        opacity: 0.5,
                        hideLineGap: true,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
              duration: _animDuration,
              height: parentHeight,
              width: parentWidth,
              top: parentHeight * (widget.showRadialGradient ? 0.2 : 0.9),
              curve: Curves.easeOut,
              child: Opacity(
                  opacity: 0.92,
                  child: Transform.scale(
                    scaleY: 0.8,
                    child: AnimatedContainer(
                        duration: _animDuration,
                        decoration: BoxDecoration(
                            gradient: RadialGradient(
                          radius: widget.showRadialGradient ? 1.8 : 2.1,
                          center: Alignment.topCenter,
                          colors: const [
                            Colors.transparent,
                            EnvoyColors.grey,
                            Colors.white,
                          ],
                          stops: const [0.0, 0.60, 0.85],
                        ))),
                  ))),
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
  final bool hideLineGap;

  LinesPainter(
      {this.angle = -18,
      this.lineDistance = 2.5,
      this.hideLineGap = false,
      this.color = EnvoyColors.whitePrint,
      this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    double offset = size.width * tan(degToRad(angle));

    double currentY = 0;

    while (currentY < size.height - offset) {
      final p1 = Offset(0, currentY);

      final p2 = Offset(size.width - 2, currentY + offset);
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..isAntiAlias = false
        ..strokeWidth = 1;
      canvas.drawLine(p1, p2, paint);

      currentY += lineDistance;
    }

    if (hideLineGap) {
      final p1 = Offset(0, size.height);

      /// the gradient overlay leaves a small dots at the end of the lines
      /// to fix this we draw a line from top to bottom with a blur effect
      final paint = Paint()
        ..color = Colors.black
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1)
        ..blendMode = BlendMode.srcIn
        ..strokeWidth = 1;
      canvas.drawLine(p1, Offset.zero, paint);
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
