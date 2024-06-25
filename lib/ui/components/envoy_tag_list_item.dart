// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/widgets.dart';

enum FlexAlignment { flexLeft, flexRight, noFlex }

class EnvoyInfoCardListItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final Widget trailing;
  final FlexAlignment flexAlignment;
  final Color? textColor;
  final bool verticalPadding;

  const EnvoyInfoCardListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.trailing,
    this.flexAlignment = FlexAlignment.noFlex,
    this.textColor,
    this.verticalPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: EnvoySpacing.xs,
          vertical: verticalPadding ? EnvoySpacing.small : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: flexAlignment == FlexAlignment.flexRight ? 8 : 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: EnvoySpacing.xs / 2),
                  child: SizedBox(
                    width: 26,
                    child: icon,
                  ),
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
