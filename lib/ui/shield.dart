// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/shield_path.dart';

class Shield extends StatelessWidget {
  const Shield({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ShieldClipper(),
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [EnvoyColors.white95, EnvoyColors.white80])),
          child: child),
    );
  }
}

class QrShield extends StatelessWidget {
  const QrShield({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: ShieldClipper(),
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shadowColor: EnvoyColors.grey85,
      elevation: 4,
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [EnvoyColors.white95, EnvoyColors.white80])),
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
