// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

class SettingText extends StatelessWidget {
  final String label;
  final Function? onTap;
  final Color color;
  final int maxLines;

  const SettingText(
    this.label, {
    super.key,
    this.onTap,
    this.color = Colors.white,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: maxLines,
          style: EnvoyTypography.body.copyWith(color: color),
        ),
      ),
    );
  }
}
