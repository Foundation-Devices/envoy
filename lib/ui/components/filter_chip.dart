// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

class EnvoyFilterChip extends StatelessWidget {
  final bool selected;
  final String text;
  final EnvoyIcons? icon;
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

    return IntrinsicWidth(
        child: InkWell(
      borderRadius: chipBorder,
      mouseCursor: SystemMouseCursors.click,
      onTap: onTap,
      child: AnimatedContainer(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 30),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(EnvoySpacing.xs),
        decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).primaryColor
                : EnvoyColors.surface2,
            borderRadius: chipBorder),
        duration: const Duration(milliseconds: 250),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.all(EnvoySpacing.xs),
                  child: EnvoyIcon(
                    icon!,
                    size: EnvoyIconSize.extraSmall,
                    color: foregroundColor,
                  ),
                ),
              Text(text,
                  style: EnvoyTypography.info.copyWith(color: foregroundColor)),
            ],
          ),
        ),
      ),
    ));
  }
}
