// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class IconTab extends StatefulWidget {
  final String label;
  final EnvoyIcons icon;
  final bool isSelected;
  final ValueChanged<bool?>? onSelect;

  final bool bigTab;
  final String? description;

  const IconTab({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = true,
    this.onSelect,
    this.bigTab = false,
    this.description,
  });

  @override
  IconTabState createState() => IconTabState();
}

class IconTabState extends State<IconTab> {
  @override
  Widget build(BuildContext context) {
    Color textColor =
        widget.isSelected ? EnvoyColors.accentPrimary : EnvoyColors.textPrimary;
    Color borderColor =
        widget.isSelected ? EnvoyColors.accentPrimary : EnvoyColors.gray200;
    TextStyle titleStyle =
        widget.bigTab ? EnvoyTypography.subheading : EnvoyTypography.label;

    TextStyle descriptionStyle =
        EnvoyTypography.info.copyWith(color: EnvoyColors.textPrimary);

    return GestureDetector(
      onTap: () {
        widget.onSelect?.call(!widget.isSelected);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 2,
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(EnvoySpacing.medium1),
          child: Column(
            children: [
              EnvoyIcon(
                widget.icon,
                size: widget.bigTab
                    ? EnvoyIconSize.big
                    : EnvoyIconSize.mediumLarge,
                color: EnvoyColors.textSecondary,
              ),
              SizedBox(
                width:
                    widget.bigTab ? EnvoySpacing.medium1 : EnvoySpacing.small,
              ),
              Text(
                widget.label,
                style: titleStyle.copyWith(
                  color: textColor,
                ),
              ),
              if (widget.description != null)
                Text(
                  widget.description!,
                  textAlign: TextAlign.center,
                  style: descriptionStyle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}