// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader(
      {super.key,
      required this.title,
      required this.linkText,
      this.onTap,
      required this.icon});

  final String title;
  final String linkText;
  final Function()? onTap;
  final EnvoyIcons icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 3,
          child: Row(
            children: [
              EnvoyIcon(icon),
              const SizedBox(
                width: EnvoySpacing.small,
              ),
              Text(
                title,
                style: EnvoyTypography.body,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        Flexible(
          flex: 2,
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              linkText,
              style: EnvoyTypography.button
                  .copyWith(color: EnvoyColors.accentPrimary),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('linkText', linkText));
  }
}
