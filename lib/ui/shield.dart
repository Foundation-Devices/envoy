// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/shield_path.dart';

class Shield extends StatelessWidget {
  const Shield({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.path(ShieldPath()),
          shape: NeumorphicShape.flat,
          border: NeumorphicBorder(
            color: Colors.white,
            width: 3,
          ),
          depth: 0,
          lightSource: LightSource.topLeft,
          intensity: 1,
          shadowLightColor: Colors.transparent),
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
