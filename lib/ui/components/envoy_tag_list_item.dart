// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/widgets.dart';

enum FlexPriority { title, trailing }

class EnvoyInfoCardListItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final Widget trailing;
  final bool priority;
  final Color? textColor;
  final FlexPriority spacingPriority;
  final CrossAxisAlignment crossAxisAlignment;

  const EnvoyInfoCardListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.trailing,
    this.priority = false,
    this.textColor,
    this.spacingPriority = FlexPriority.title,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.small),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: EnvoySpacing.xs / 2),
            child: SizedBox(
              width: 26,
              child: icon,
            ),
          ),
          const SizedBox(width: EnvoySpacing.xs),
          Flexible(
            child: spacingPriority == FlexPriority.trailing
                ? Row(
                    crossAxisAlignment: crossAxisAlignment,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: EnvoyTypography.body.copyWith(
                              color: textColor ?? EnvoyColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: EnvoySpacing.small),
                      trailing,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: EnvoyTypography.body.copyWith(
                            color: textColor ?? EnvoyColors.textPrimary),
                      ),
                      const SizedBox(width: EnvoySpacing.medium1),
                      Flexible(child: trailing),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
