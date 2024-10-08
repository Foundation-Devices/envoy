// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/generated/l10n.dart';

class IconTab extends StatefulWidget {
  final String label;
  final EnvoyIcons icon;
  final bool isSelected;
  final bool isLocked;
  final ValueChanged<bool?>? onSelect;
  final bool bigTab;
  final String? description;
  final String? lockedInfoText;
  final List<EnvoyIcons>? poweredByIcons;

  const IconTab({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = true,
    this.onSelect,
    this.bigTab = false,
    this.description,
    this.isLocked = false,
    this.lockedInfoText,
    this.poweredByIcons,
  });

  @override
  IconTabState createState() => IconTabState();
}

class IconTabState extends State<IconTab> {
  @override
  Widget build(BuildContext context) {
    Color titleColor = widget.isLocked
        ? EnvoyColors.textTertiary
        : (widget.isSelected
            ? EnvoyColors.accentPrimary
            : EnvoyColors.textSecondary);

    Color borderColor =
        widget.isSelected ? EnvoyColors.accentPrimary : EnvoyColors.gray200;
    TextStyle titleStyle =
        widget.bigTab ? EnvoyTypography.subheading : EnvoyTypography.label;

    TextStyle descriptionStyle = EnvoyTypography.info.copyWith(
        color: widget.isLocked
            ? EnvoyColors.textTertiary
            : EnvoyColors.textPrimary);

    TextStyle disabledTextStyle =
        EnvoyTypography.info.copyWith(color: EnvoyColors.accentPrimary);

    TextStyle poweredByStyle = EnvoyTypography.info.copyWith(
        color: widget.isLocked
            ? EnvoyColors.textTertiary
            : EnvoyColors.textPrimary);

    Color iconColor =
        widget.isLocked ? EnvoyColors.textTertiary : EnvoyColors.textSecondary;
    Color poweredByIconColor =
        widget.isLocked ? EnvoyColors.textTertiary : EnvoyColors.textPrimary;

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
          padding: EdgeInsets.symmetric(
              vertical: EnvoySpacing.medium1,
              horizontal:
                  widget.bigTab ? EnvoySpacing.medium2 : EnvoySpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EnvoyIcon(
                widget.icon,
                size: widget.bigTab
                    ? EnvoyIconSize.big
                    : EnvoyIconSize.mediumLarge,
                color: iconColor,
              ),
              SizedBox(
                width:
                    widget.bigTab ? EnvoySpacing.medium1 : EnvoySpacing.small,
              ),
              const SizedBox(height: EnvoySpacing.xs),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle.copyWith(
                  color: titleColor,
                ),
              ),
              const SizedBox(height: EnvoySpacing.xs),
              if (widget.description != null)
                Text(
                  widget.description!,
                  textAlign: TextAlign.center,
                  style: descriptionStyle,
                ),
              if (widget.isLocked)
                Column(
                  children: [
                    const SizedBox(height: EnvoySpacing.xs),
                    Text(
                      widget.lockedInfoText!,
                      textAlign: TextAlign.center,
                      style: disabledTextStyle,
                    ),
                  ],
                ),
              if (widget.poweredByIcons != null)
                Padding(
                  padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S().buy_bitcoin_buyOptions_modal_poweredBy,
                        style: poweredByStyle,
                      ),
                      ...widget.poweredByIcons!.map((icon) => Padding(
                            padding: const EdgeInsets.only(
                                left: EnvoySpacing.xs / 2),
                            child: EnvoyIcon(
                              icon,
                              size: EnvoyIconSize.superSmall,
                              color: poweredByIconColor,
                            ),
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
