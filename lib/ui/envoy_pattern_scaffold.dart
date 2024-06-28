// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/shield.dart';
import 'package:flutter/material.dart';

Widget envoyScaffoldShieldScrollView(BuildContext context, Widget child) {
  double shieldBottom = MediaQuery.of(context).padding.bottom + 6.0;
  return SingleChildScrollView(
      child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.53,
          child: Container(
              padding: EdgeInsets.only(bottom: shieldBottom),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0x00000000),
                Color(0xff686868),
                Color(0xffFFFFFF),
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Shield(child: child))));
}

class EnvoyPatternScaffold extends StatefulWidget {
  final Widget? child;
  final Widget? shield;
  final Widget? header;
  final PreferredSizeWidget? appBar;
  final bool animate;
  final double gradientHeight;

  const EnvoyPatternScaffold(
      {super.key,
      this.animate = true,
      this.child,
      this.appBar,
      this.shield,
      this.header,
      this.gradientHeight = 1.5});

  @override
  State<EnvoyPatternScaffold> createState() => _EnvoyPatternScaffoldState();
}

class _EnvoyPatternScaffoldState extends State<EnvoyPatternScaffold>
    with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.animate == true) {
        controller = AnimationController(
            duration: const Duration(milliseconds: 2200), vsync: this);
        animation = Tween(begin: 0.6, end: .8).animate(controller!);
        controller?.addListener(() {
          setState(() {});
        });
        controller?.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (widget.animate == false) {
      controller?.stop(canceled: false);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double shieldBottom = MediaQuery.of(context).padding.bottom + 6.0;
    return Stack(
      children: [
        const Positioned.fill(
            child: AppBackground(
          showRadialGradient: true,
        )),
        widget.child != null
            ? widget.child!
            : Scaffold(
                backgroundColor: Colors.transparent,
                appBar: widget.appBar,
                body: Align(
                  alignment: Alignment.center,
                  child: widget.header,
                ),
                bottomNavigationBar: SizedBox(
                  width: double.infinity,
                  height: (MediaQuery.of(context).size.height * 0.5)
                      .clamp(350, 580),
                  child: Container(
                    padding: EdgeInsets.only(bottom: shieldBottom),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                          Color(0x00000000),
                          Color(0xff686868),
                          Color(0xffFFFFFF),
                        ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                    child: Shield(
                      child: Padding(
                          padding: const EdgeInsets.only(
                              right: 8, left: 8, top: 8, bottom: 40),
                          child: SizedBox.expand(child: widget.shield)),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class StripePainter extends CustomPainter {
  final double stripeWidth;
  final double gapWidth;
  final double rotateDegree;
  final Color stripeColor;
  final Color bgColor;

  StripePainter(
    this.stripeColor, {
    this.stripeWidth = 2.0,
    this.gapWidth = 2.0,
    this.rotateDegree = 25.0,
    this.bgColor = Colors.transparent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    /// Expand canvas size
    const offsetX = 0.0;
    const offsetY = 10.0;
    final width = size.width + offsetX * 2;
    final height = size.height + offsetY * 2;

    /// Shift canvas to top,left with offsetX,Y
    canvas.translate(-offsetX, -offsetY);

    // Clip the canvas to the right half
    final rightHalfRect =
        Rect.fromLTRB(size.width / 2, 0, size.width, size.height);
    canvas.clipRect(rightHalfRect);

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
      /// start point on Y axis -> xStart = 0
      final double yStart = i * yOffset;

      /// end point on X axis -> yEnd = 0
      final double xEnd = i * xOffset;

      /// make line start -> end
      path.moveTo(0, yStart);
      path.lineTo(xEnd, 0);
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

class GradientPainter extends CustomPainter {
  final double gradientRadius;
  final double gradientHeight;

  GradientPainter({required this.gradientRadius, this.gradientHeight = 1.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xff965C4B),
          const Color(0xffD68B6E),
          const Color(0xcfd68b6e),
          const Color(0xffF0BBA4).withOpacity(0.4),
          const Color(0xffF0BBA4).withOpacity(0.1),
          const Color(0xffF0BBA4).withOpacity(0.002),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / gradientHeight),
          radius: min(size.width, size.width * gradientRadius)));

    final rxect = Rect.fromPoints(
        Offset(0, -size.height), Offset(size.width, size.height));
    canvas.drawRRect(RRect.fromRectXY(rxect, 0, 0), paint);

    canvas.drawPath(
        Path()
          ..addRect(Rect.fromPoints(Offset(size.width / 2, -size.height),
              Offset(size.width, size.height)))
          ..fillType = PathFillType.evenOdd,
        Paint()
          ..color = Colors.black.withAlpha(50)
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(2)));
  }

  @override
  bool shouldRepaint(covariant GradientPainter oldDelegate) {
    return oldDelegate.gradientRadius != gradientRadius;
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }
}
