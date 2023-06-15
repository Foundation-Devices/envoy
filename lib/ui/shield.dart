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
      clipper: ShieldPath(),
      // style: NeumorphicStyle(
      //     boxShape: NeumorphicBoxShape.path(ShieldPath()),
      //     shape: NeumorphicShape.flat,
      //     border: NeumorphicBorder(
      //       color: Colors.white,
      //       width: 3,
      //     ),
      //     depth: 0,
      //     lightSource: LightSource.topLeft,
      //     intensity: 1,
      //     shadowLightColor: Colors.transparent),
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
    return ClipPath(
      clipper: ShieldPath(),
    // return Neumorphic(
    //   style: NeumorphicStyle(
    //     boxShape: NeumorphicBoxShape.path(ShieldPath()),
    //     shape: NeumorphicShape.flat,
    //     border: NeumorphicBorder(
    //       color: Colors.white,
    //       width: 1,
    //     ),
    //     color: EnvoyColors.white01,
    //     depth: 5,
    //     lightSource: LightSource.top,
    //     intensity: 1,
    //   ),
      child: Container(child: child),
    );
  }
}
