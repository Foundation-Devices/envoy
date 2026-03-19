// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep; // Current active step, indexed from 0
  final int totalSteps;

  const StepIndicator(
      {super.key, required this.currentStep, this.totalSteps = 4});

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [];

    for (int i = 0; i < totalSteps; i++) {
      // Determine icon/content for step (last step has an icon)
      Widget child;
      if (i == totalSteps - 1) {
        child = EnvoyIcon(
          EnvoyIcons.send,
          size: EnvoyIconSize.extraSmall,
          color: EnvoyColors.solidWhite,
        );
      } else {
        child = Text(
          '${i + 1}',
          style: EnvoyTypography.digitsSmall
              .copyWith(color: EnvoyColors.solidWhite),
        );
      }

      // Step circle
      steps.add(Container(
        width: EnvoySpacing.medium2,
        height: EnvoySpacing.medium2,
        decoration: BoxDecoration(
          color: i <= currentStep
              ? EnvoyColors.accentPrimary
              : EnvoyColors.contentTertiary,
          borderRadius: BorderRadius.circular(EnvoySpacing.small),
        ),
        child: Center(child: child),
      ));

      // Connecting line (not after last icon)
      if (i < totalSteps - 1) {
        steps.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.xs),
          child: Container(
            width: EnvoySpacing.medium2,
            height: 1,
            color: i < currentStep
                ? EnvoyColors.accentPrimary
                : EnvoyColors.textTertiary,
          ),
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: steps,
    );
  }
}
