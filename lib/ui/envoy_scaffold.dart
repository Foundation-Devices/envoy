// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:envoy/ui/shield.dart';
import 'package:flutter/material.dart';

Widget EnvoyScaffoldShieldScrollView(BuildContext context, Widget child) {
  double _shieldBottom = MediaQuery.of(context).padding.bottom + 6.0;
  return SingleChildScrollView(
      child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Container(
              padding: EdgeInsets.only(bottom: _shieldBottom),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0x0),
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
      {Key? key,
      this.animate = true,
      this.child,
      this.appBar,
      this.shield,
      this.header,
      this.gradientHeight = 1.5})
      : super(key: key);

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
    if (this.widget.animate == false) {
      controller?.stop(canceled: false);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double _shieldBottom = MediaQuery.of(context).padding.bottom + 6.0;
    return Stack(
      children: [
        SizedBox.expand(
            child: Container(
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: StripePainter(stripeCount: 428),
          ),
        )),
        SizedBox.expand(
            child: Container(
          child: CustomPaint(
            painter: GradientPainter(
                gradientRadius: animation?.value ?? 0.8,
                gradientHeight: widget.gradientHeight),
          ),
        )),
        this.widget.child != null
            ? this.widget.child!
            : Scaffold(
                backgroundColor: Colors.transparent,
                appBar: widget.appBar,
                body: Align(
                  alignment: Alignment.topCenter,
                  child: this.widget.header,
                ),
                bottomNavigationBar: Container(
                  width: double.infinity,
                  height: (MediaQuery.of(context).size.height * 0.5)
                      .clamp(350, 580),
                  child: Container(
                    padding: EdgeInsets.only(bottom: _shieldBottom),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                          Color(0x0),
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
  final int stripeCount;

  StripePainter({this.stripeCount = 400});

  @override
  void paint(Canvas canvas, Size size) {
    //stripes Pattern rect.
    final rect = new Rect.fromPoints(new Offset(size.width / 2, -size.height),
        new Offset(size.width, size.height));

    canvas.save();
    canvas.clipRect(rect);

    final x = rect.left;
    final y = rect.top;

    final maxDimension = max(rect.width, rect.height);
    final stripeW = maxDimension / stripeCount / 6;
    var step = stripeW * 9;
    final paintStrip = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.transparent;
    canvas.drawRect(rect, paintStrip);
    final rectStripesCount = stripeCount * 2.5;
    final allStripesPath = Path();
    for (var i = 1; i < rectStripesCount; i += 2) {
      final stripePath = Path();
      stripePath.moveTo(x - stripeW + step, y);
      stripePath.lineTo(x + step, y);
      stripePath.lineTo(x, y + step);
      stripePath.lineTo(x - stripeW, y + step);
      stripePath.close();
      allStripesPath.addPath(stripePath, Offset.zero);
      step += stripeW * 9;
    }
    paintStrip
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.11);
    canvas.drawPath(allStripesPath, paintStrip);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StripePainter oldDelegate) {
    return oldDelegate.stripeCount != stripeCount;
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
          Color(0xff965C4B),
          Color(0xffD68B6E),
          Color(0xcfd68b6e),
          Color(0xffF0BBA4).withOpacity(0.4),
          Color(0xffF0BBA4).withOpacity(0.1),
          Color(0xffF0BBA4).withOpacity(0.002),
        ],
      ).createShader(Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / gradientHeight),
          radius: min(size.width, size.width * gradientRadius)));

    final rxect = new Rect.fromPoints(
        new Offset(0, -size.height), new Offset(size.width, size.height));
    canvas.drawRRect(RRect.fromRectXY(rxect, 0, 0), paint);

    canvas.drawPath(
        Path()
          ..addRect(Rect.fromPoints(new Offset(size.width / 2, -size.height),
              new Offset(size.width, size.height)))
          ..fillType = PathFillType.evenOdd,
        Paint()
          ..color = Colors.black.withAlpha(50)
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(2)));
  }

  @override
  bool shouldRepaint(covariant GradientPainter oldDelegate) {
    return oldDelegate.gradientRadius != this.gradientRadius;
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }
}
