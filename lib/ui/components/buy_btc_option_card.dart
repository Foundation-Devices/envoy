// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class BuyOptionCard extends StatefulWidget {
  final String label;
  final EnvoyIcons icon;
  final bool isSelected;
  final ValueChanged<bool?>? onSelect;
  final String description;

  const BuyOptionCard({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = true,
    this.onSelect,
    required this.description,
  });

  @override
  BuyOptionCardState createState() => BuyOptionCardState();
}

class BuyOptionCardState extends State<BuyOptionCard> {
  @override
  Widget build(BuildContext context) {
    Color textColor = widget.isSelected
        ? EnvoyColors.accentPrimary
        : EnvoyColors.textSecondary;
    Color iconColor =
        widget.isSelected ? EnvoyColors.textPrimary : EnvoyColors.textSecondary;
    Color borderColor =
        widget.isSelected ? EnvoyColors.accentPrimary : EnvoyColors.gray200;
    TextStyle titleStyle = EnvoyTypography.subheading;

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
          padding: const EdgeInsets.all(EnvoySpacing.small),
          child: Row(
            children: [
              EnvoyIcon(
                widget.icon,
                size: EnvoyIconSize.mediumLarge,
                color: iconColor,
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: titleStyle.copyWith(
                      color: textColor,
                    ),
                  ),
                  Text(
                    widget.description,
                    style: EnvoyTypography.info.copyWith(
                      color: iconColor,
                    ),
                    textAlign: TextAlign.start, // TODO: fix overflows
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
