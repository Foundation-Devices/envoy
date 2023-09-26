// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

class EnvoyFilterChip extends StatelessWidget {
  final bool selected;
  final String text;
  final IconData? icon;
  final GestureTapCallback? onTap;

  const EnvoyFilterChip(
      {super.key,
      this.selected = false,
      required this.text,
      this.icon,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final chipBorder = BorderRadius.circular(EnvoySpacing.medium3);
    final foregroundColor =
        selected ? EnvoyColors.solidWhite : EnvoyColors.textTertiary;
    return InkWell(
      borderRadius: chipBorder,
      mouseCursor: SystemMouseCursors.click,
      onTap: onTap,
      child: AnimatedContainer(
        constraints: BoxConstraints(),
        padding: EdgeInsets.all(EnvoySpacing.xs),
        decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).primaryColor
                : EnvoyColors.surface2,
            borderRadius: chipBorder),
        duration: Duration(milliseconds: 250),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: EnvoySpacing.xs),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsets.all(EnvoySpacing.xs),
                  child: Icon(
                    icon,
                    size: 18,
                    color: foregroundColor,
                  ),
                ),
              Text(text,
                  style: EnvoyTypography.caption1Semibold
                      .copyWith(color: foregroundColor)),
            ],
          ),
        ),
      ),
    );
  }
}
