// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/cupertino.dart';

class EnvoyLoader extends StatelessWidget {
  const EnvoyLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: EnvoySpacing.medium3,
      width: EnvoySpacing.medium3,
      child: CircularProgressIndicator(
        color: EnvoyColors.tealLight,
        backgroundColor: EnvoyColors.surface4,
        strokeWidth: 3,
      ),
    );
  }
}

class EnvoyActivityIndicator extends StatelessWidget {
  const EnvoyActivityIndicator({
    super.key,
    this.radius = 12,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 150),
  });

  final double radius;
  final Color color;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: CupertinoActivityIndicator(
        color: color,
        radius: radius,
      ),
    );
  }
}
