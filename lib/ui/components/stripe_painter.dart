// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:flutter/material.dart';

class StripePainter extends CustomPainter {
  final double stripeWidth;
  final double gapWidth;
  final double rotateDegree;
  final Color stripeColor;
  final Color bgColor;
  final bool clipHalf;
  final double offsetX;
  final double offsetY;

  StripePainter(
    this.stripeColor, {
    this.stripeWidth = 2.0,
    this.gapWidth = 2.0,
    this.rotateDegree = 25.0,
    this.bgColor = Colors.transparent,
    this.clipHalf = true,
    this.offsetX = 0,
    this.offsetY = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    /// Expand canvas size
    final width = size.width + offsetX * 2;
    final height = size.height + offsetY * 2;

    /// Shift canvas to top,left with offsetX,Y
    canvas.translate(-offsetX, -offsetY);

    /// Clip the canvas (draw lines on the right side)
    if (clipHalf) {
      final rightHalfRect =
          Rect.fromLTRB(size.width / 2, 0, size.width, size.height);
      canvas.clipRect(rightHalfRect);
    } else {
      final fullRect = Rect.fromLTRB(0, 0, size.width, size.height);
      canvas.clipRect(fullRect);
    }

    /// Calculate the biggest diagonal of the screen.
    final double diagonal = sqrt(width * width + height * height);

    /// jointSize: distance from right edge of (i) stripe to right one of next stripe
    final double jointSize = stripeWidth + gapWidth;

    /// Calculate the number of iterations needed to cover the diagonal of the screen.
    final int numIterations = (diagonal / jointSize).ceil();

    /// convert degree to radian
    final rotateRadian = pi / 180 * rotateDegree;

    /// calculate the xOffset, yOffset according to the trigonometric formula
    final xOffset = jointSize / sin(rotateRadian);
    final yOffset = jointSize / sin(pi / 2 - rotateRadian);

    /// config stroke paint object
    final paint = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stripeWidth;
    final path = Path();

    /// setup the path
    for (int i = 0; i < numIterations; i++) {
      /// setup the path
      const double xStart = 0;

      /// start point on Y axis -> xStart = 0
      final double yStart = i * yOffset;

      /// end point on X axis -> yEnd = 0
      final double xEnd = i * xOffset;
      const double yEnd = 0;

      /// make line start -> end
      path.moveTo(xStart, yStart);
      path.lineTo(xEnd, yEnd);
    }

    /// draw path on canvas by using paint object
    canvas.drawPath(path, paint);

    /// Fill the pattern area background with the patternColor.
    final patternPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, patternPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
