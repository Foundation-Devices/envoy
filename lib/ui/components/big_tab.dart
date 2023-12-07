// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class BigTab extends StatefulWidget {
  final String label;
  final EnvoyIcons icon;
  final bool isActive;
  final ValueChanged<bool?>? onSelect;

  BigTab({
    required this.label,
    required this.icon,
    this.isActive = true,
    this.onSelect,
  });

  @override
  _BigTabState createState() => _BigTabState();
}

class _BigTabState extends State<BigTab> {
  @override
  Widget build(BuildContext context) {
    Color iconColor =
        widget.isActive ? EnvoyColors.accentPrimary : EnvoyColors.textPrimary;
    Color textColor =
        widget.isActive ? EnvoyColors.accentPrimary : EnvoyColors.textPrimary;
    Color backgroundColor =
        widget.isActive ? EnvoyColors.surface2 : Colors.transparent;
    Color borderColor =
        widget.isActive ? EnvoyColors.accentPrimary : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onSelect?.call(!widget.isActive);
        },
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              width: 2,
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EnvoyIcon(
                  widget.icon,
                  color: iconColor,
                ),
                SizedBox(
                  width: EnvoySpacing.small,
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 100.0, // Set your desired maximum width here
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        style: EnvoyTypography.button.copyWith(
                          color: textColor,
                          fontSize: 12.0,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
