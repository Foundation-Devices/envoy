// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

class EnvoyTag extends StatelessWidget {
  final String title;
  final EnvoyIcons icon;

  const EnvoyTag({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: EnvoySpacing.small),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EnvoyIcon(icon,
              color: EnvoyColors.accentPrimary, size: EnvoyIconSize.superSmall),
          const Padding(padding: EdgeInsets.only(left: EnvoySpacing.xs)),
          Text(
            title,
            style: EnvoyTypography.label
                .copyWith(color: EnvoyColors.accentPrimary),
          ),
        ],
      ),
    );
  }
}
