// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/shield_path.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/background.dart';

class Shield extends StatelessWidget {
  const Shield({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipPath(
            clipper: ShieldClipper(),
            child: Container(
                color: EnvoyColors.solidWhite, child: const SizedBox.expand()),
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.all(1.5),
            child: ClipPath(
              clipper: ShieldClipper(),
              child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        EnvoyColors.surface2,
                        EnvoyColors.surface1
                      ])),
                  child: child),
            ),
          ),
        ),
      ],
    );
  }
}

class QrShield extends StatelessWidget {
  const QrShield({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: ShieldClipper(),
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shadowColor: EnvoyColors.border1,
      elevation: 4,
      child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [EnvoyColors.surface1, EnvoyColors.surface2])),
          child: child),
    );
  }
}

class BoxShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(
        ShieldClipper.shieldPath(size), Colors.black45, 3.0, true);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

Stack fullScreenShield(Widget child) {
  //double appBarHeight = AppBar().preferredSize.height;
  double topAppBarOffset = 10; //appBarHeight ;//+ 10; // check this size
  return Stack(
    children: [
      const AppBackground(),
      Positioned(
          top: topAppBarOffset,
          left: 5,
          bottom: const BottomAppBar().height ?? 20 + 8,
          right: 5,
          child: Shield(child: child))
    ],
  );
}
