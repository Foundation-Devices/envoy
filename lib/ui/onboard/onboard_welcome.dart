// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_privacy_setup.dart';
import 'package:envoy/ui/shield.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: EnvoyPatternScaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
        ),
        header: Container(
          height: 220,
          child: Image.asset(
            "assets/envoy_logo_rast.png",
            fit: BoxFit.fitHeight,
            height: 220,
            width: 220,
          ),
        ),
        shield: Container(
          height: max(MediaQuery.of(context).size.height * 0.38, 300),
          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      S().welcome_screen_heading,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Padding(padding: EdgeInsets.all(12)),
                    Text(
                      S().welcome_screen_subheading,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //TODO: localization
                  EnvoyButton(
                    S().welcome_screen_cta2,
                    type: EnvoyButtonTypes.secondary,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OnboardPrivacySetup(setUpEnvoyWallet: false),
                          ));
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  EnvoyButton(
                    S().welcome_screen_ctA1,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OnboardPrivacySetup(setUpEnvoyWallet: true),
                          ));
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EnvoyPatternScaffold extends StatefulWidget {
  final Widget? child;
  final Widget? shield;
  final Widget? header;
  final PreferredSizeWidget? appBar;
  final bool animate;

  const EnvoyPatternScaffold(
      {Key? key,
      this.animate = true,
      this.child,
      this.appBar,
      this.shield,
      this.header})
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
            painter: GradientPainter(gradientRadius: animation?.value ?? 0.8),
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
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 24),
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
                              right: 15, left: 15, top: 15, bottom: 50),
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

  GradientPainter({required this.gradientRadius});

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
          center: new Offset(size.width / 2, size.height / 1.5),
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
