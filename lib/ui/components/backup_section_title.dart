// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/cupertino.dart';

class BackupSectionTitle extends StatelessWidget {
  final String title;
  final ValueChanged<bool>? onSwitch;
  final bool switchValue;
  final EnvoyIcons icon;
  final Function()? onIconTap;

  const BackupSectionTitle({
    super.key,
    required this.title,
    this.onSwitch,
    required this.icon,
    required this.switchValue,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onIconTap,
              child: EnvoyIcon(
                icon,
                color: EnvoyColors.textPrimaryInverse,
              ),
            ),
            Text(
              title,
              style: EnvoyTypography.body
                  .copyWith(color: EnvoyColors.textPrimaryInverse),
            ),
          ],
        ),
        EnvoySwitch(value: switchValue, onChanged: onSwitch),
      ],
    );
  }
}
