// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

enum FlexAlignment { flexLeft, flexRight, noFlex }

class EnvoyInfoCardListItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final Widget trailing;
  final FlexAlignment flexAlignment;
  final Color? textColor;

  const EnvoyInfoCardListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.trailing,
    this.flexAlignment = FlexAlignment.noFlex,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.small),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: flexAlignment == FlexAlignment.flexRight ? 8 : 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 26,
                  child: icon,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: EnvoySpacing.xs,
                    ),
                    child: Text(
                      title,
                      style: EnvoyTypography.body.copyWith(
                          color: textColor ?? EnvoyColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
              flex: flexAlignment == FlexAlignment.flexLeft ? 8 : 4,
              child: trailing),
        ],
      ),
    );
  }
}
