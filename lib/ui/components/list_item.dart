// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class EnvoyListTile extends StatelessWidget {
  const EnvoyListTile({
    Key? key,
    required this.textLeft1,
    this.textLeft2,
    this.textRight1,
    this.textRight2,
    this.leftIcon,
    this.rightIcon,
    this.iconColor = EnvoyColors.textPrimary,
  }) : super(key: key);

  final String textLeft1;
  final String? textLeft2;
  final String? textRight1;
  final String? textRight2;
  final EnvoyIcons? leftIcon;
  final EnvoyIcons? rightIcon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        minLeadingWidth: EnvoySpacing.medium1,
        horizontalTitleGap: EnvoySpacing.medium1,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.xs),
          child: Text(
            textLeft1,
            style: EnvoyTypography.body2Medium,
          ),
        ),
        subtitle: textLeft2 == null
            ? (textRight2 == null ? null : Text(""))
            : Text(
                textLeft2!,
                style: EnvoyTypography.caption1Medium
                    .copyWith(color: EnvoyColors.textSecondary),
              ),
        leading: leftIcon == null
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  EnvoyIcon(leftIcon!, color: iconColor),
                ],
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (textRight1 != null || textRight2 != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (textRight1 != null)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: EnvoySpacing.xs),
                      child: Text(
                        textRight1!,
                        style: EnvoyTypography.body2Medium,
                      ),
                    ),
                  if (textRight2 != null)
                    Text(
                      textRight2!,
                      style: EnvoyTypography.caption1Medium
                          .copyWith(color: EnvoyColors.textSecondary),
                    ),
                  if (textRight2 == null && textLeft2 != null) Text(""),
                  if (textRight1 == null && textRight2 != null) Text(""),
                ],
              ),
            if (rightIcon != null)
              Padding(
                padding: const EdgeInsets.only(left: EnvoySpacing.medium1),
                child: EnvoyIcon(rightIcon!, color: iconColor),
              ),
          ],
        ),
      ),
    );
  }
}

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: EnvoySpacing.small),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: EnvoyTypography.caption1Semibold
                .copyWith(color: EnvoyColors.textTertiary),
          ),
          Padding(
            padding: const EdgeInsets.only(top: EnvoySpacing.small),
            child: Container(
              height: 2,
              color: EnvoyColors.border1,
            ),
          )
        ],
      ),
    );
  }
}
