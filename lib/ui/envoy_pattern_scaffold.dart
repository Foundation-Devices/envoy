// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/ui/components/stripe_painter.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/widgets/color_util.dart';
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
  final Widget? shield;
  final Widget? header;
  final String? heroTag;
  final PreferredSizeWidget? appBar;
  final bool animate;
  final double gradientHeight;
  final double shieldHeightFactor;

  const EnvoyPatternScaffold(
      {super.key,
      this.animate = true,
      this.appBar,
      this.shield,
      this.header,
      this.heroTag,
      this.gradientHeight = 1.5,
      this.shieldHeightFactor = 0.52});

  @override
  State<EnvoyPatternScaffold> createState() => _EnvoyPatternScaffoldState();
}

class _EnvoyPatternScaffoldState extends State<EnvoyPatternScaffold> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double shieldBottom = MediaQuery.of(context).padding.bottom + 6.0;

    Widget shield = Shield(
      child: Padding(
          padding: const EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 40),
          child: SizedBox.expand(child: widget.shield)),
    );
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: widget.appBar,
      primary: widget.appBar != null,
      backgroundColor: Colors.black,
      floatingActionButton: widget.header ?? Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          ScaffoldBackGround(
            animate: widget.animate,
            gradientHeight: widget.gradientHeight,
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        height: (MediaQuery.of(context).size.height * widget.shieldHeightFactor)
            .clamp(350, 650),
        child: Container(
            padding: EdgeInsets.only(bottom: shieldBottom),
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0x00000000),
              Color(0xff686868),
              Color(0xffFFFFFF),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: widget.heroTag != null
                ? Hero(
                    tag: widget.heroTag!,
                    child: Material(
                      color: Colors.transparent,
                      child: shield,
                    ),
                  )
                : shield),
      ),
    );
  }
}

class ScaffoldBackGround extends StatefulWidget {
  final bool animate;

  final double gradientHeight;

  const ScaffoldBackGround(
      {super.key, this.animate = true, this.gradientHeight = 1.5});

  @override
  State<ScaffoldBackGround> createState() => _ScaffoldBackgroundState();
}

class _ScaffoldBackgroundState extends State<ScaffoldBackGround>
    with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.animate == true) {
        startAnimation();
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
    return Stack(
      children: [
        SizedBox.expand(
            child: CustomPaint(
          isComplex: true,
          willChange: false,
          size: const Size(double.infinity, double.infinity),
          painter: StripePainter(
            EnvoyColors.solidWhite.applyOpacity(0.1),
            stripeWidth: 2.0,
            gapWidth: 2.0,
            rotateDegree: 25.0,
            bgColor: Colors.transparent,
            clipHalf: true,
            offsetY: 10.0,
          ),
        )),
        SizedBox.expand(
            child: CustomPaint(
          painter: GradientPainter(
              gradientRadius: animation?.value ?? 0.8,
              gradientHeight: widget.gradientHeight),
        )),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant ScaffoldBackGround oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        startAnimation();
      }
    }
  }

  void startAnimation() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 2200), vsync: this);
    animation = Tween(begin: 0.6, end: .8).animate(controller!);
    controller?.addListener(() {
      setState(() {});
    });
    controller?.repeat(reverse: true);
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
          const Color(0xffF0BBA4).applyOpacity(0.4),
          const Color(0xffF0BBA4).applyOpacity(0.1),
          const Color(0xffF0BBA4).applyOpacity(0.002),
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
