// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/notifications.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:envoy/util/amount.dart';

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
    this.unitIcon,
  }) : super(key: key);

  final String textLeft1;
  final String? textLeft2;
  final String? textRight1;
  final String? textRight2;
  final EnvoyIcons? leftIcon;
  final EnvoyIcons? rightIcon;
  final Color? iconColor;
  final EnvoyIcon? unitIcon;

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
            style: EnvoyTypography.body,
          ),
        ),
        subtitle: textLeft2 == null
            ? (textRight2 == null ? null : Text(""))
            : Text(
                textLeft2!,
                style: EnvoyTypography.info
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
                      child: Row(
                        children: [
                          if (unitIcon != null)
                            SizedBox(height: 20, child: unitIcon!),
                          Text(
                            textRight1!,
                            style: EnvoyTypography.body,
                          ),
                        ],
                      ),
                    ),
                  if (textRight2 != null)
                    Text(
                      textRight2!,
                      style: EnvoyTypography.info
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
            style:
                EnvoyTypography.info.copyWith(color: EnvoyColors.textTertiary),
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

class ActivityListTile extends StatelessWidget {
  const ActivityListTile(
    this.notification, {
    Key? key,
  }) : super(key: key);

  final EnvoyNotification notification;

  @override
  Widget build(BuildContext context) {
    String textLeft1 = "";
    String? textLeft2;
    String? textRight1;
    String? textRight2;
    EnvoyIcons? leftIcon;
    EnvoyIcons? rightIcon;
    Color? iconColor;
    EnvoyIcon? unitIcon;

    if (notification.type == EnvoyNotificationType.transaction) {
      leftIcon = notification.amount! >= 0
          ? EnvoyIcons.arrow_down_left
          : EnvoyIcons.arrow_up_right;
      textLeft1 = notification.amount! >= 0 ? "Received" : "Sent";
      textLeft2 = timeago.format(notification.date);
      textRight1 = getFormattedAmount(notification.amount!);
      textRight2 = Settings().selectedFiat == null
          ? null
          : ExchangeRate().getFormattedAmount(notification.amount!,
              wallet: AccountManager().getWallet(notification.accountId!));
      iconColor = EnvoyColors.textTertiary;
      unitIcon = getUnitIcon(
          AccountManager().getAccountById(notification.accountId!)!);
    }

    return EnvoyListTile(
      textLeft1: textLeft1,
      textLeft2: textLeft2,
      textRight1: textRight1,
      textRight2: textRight2,
      rightIcon: rightIcon,
      leftIcon: leftIcon,
      iconColor: iconColor,
      unitIcon: unitIcon,
    );
  }
}
