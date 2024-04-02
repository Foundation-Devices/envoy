// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';

class EnvoyListTile extends StatelessWidget {
  const EnvoyListTile({
    super.key,
    required this.textLeft1,
    this.textLeft2,
    this.leftIcon,
    this.iconColor = EnvoyColors.textPrimary,
    this.unitIcon,
  });

  final String textLeft1;
  final String? textLeft2;
  final EnvoyIcons? leftIcon;
  final Color? iconColor;
  final Widget? unitIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          minLeadingWidth: 0,
          horizontalTitleGap: EnvoySpacing.small,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.xs),
            child: Text(
              textLeft1,
              style: EnvoyTypography.body,
            ),
          ),
          subtitle: textLeft2 == null
              ? const Text("")
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
          trailing: unitIcon == null
              ? const Text("")
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    unitIcon!,
                  ],
                )),
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
      padding: const EdgeInsets.only(
        top: EnvoySpacing.small,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: EnvoySpacing.medium3),
            child: Text(
              title,
              style: EnvoyTypography.info
                  .copyWith(color: EnvoyColors.textTertiary),
            ),
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
    super.key,
  });

  final EnvoyNotification notification;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      String textLeft1 = "";
      String? textLeft2;
      EnvoyIcons? leftIcon;
      Color? iconColor;
      Widget? unitIcon;
      final Locale activeLocale = Localizations.localeOf(context);
      final accountId = notification.accountId;
      bool? hide;

      if (accountId != null) {
        hide = ref.watch(balanceHideStateStatusProvider(accountId));
      }

      if (notification.type == EnvoyNotificationType.transaction) {
        leftIcon = notification.amount! >= 0
            ? EnvoyIcons.arrow_down_left
            : EnvoyIcons.arrow_up_right;
        textLeft1 = notification.amount! >= 0
            ? S().activity_received
            : S().activity_sent;
        textLeft2 = timeago
            .format(notification.date, locale: activeLocale.languageCode)
            .capitalize();
        iconColor = EnvoyColors.textTertiary;

        if (hide! ||
            AccountManager().getAccountById(accountId!)!.dateSynced == null) {
          unitIcon = const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LoaderGhost(
                width: 120,
                height: 15,
                animate: false,
              ),
              Padding(padding: EdgeInsets.only(top: 3.0)),
              LoaderGhost(
                width: 40,
                height: 15,
                animate: false,
              ),
            ],
          );
        } else {
          unitIcon = EnvoyAmount(
            account: AccountManager().getAccountById(accountId)!,
            amountSats: notification.amount!,
            amountWidgetStyle: AmountWidgetStyle.normal,
            alignToEnd: true,
          );
        }
      }

      if (notification.type == EnvoyNotificationType.firmware) {
        leftIcon = EnvoyIcons.tool;
        textLeft1 = S().activity_firmwareUpdate;
        textLeft2 = timeago
            .format(notification.date, locale: activeLocale.languageCode)
            .capitalize();

        iconColor = EnvoyColors.textTertiary;
      }

      if (notification.type == EnvoyNotificationType.envoyUpdate) {
        leftIcon = EnvoyIcons.tool;
        textLeft1 = S().activity_envoyUpdate;
        textLeft2 = timeago
            .format(notification.date, locale: activeLocale.languageCode)
            .capitalize();

        iconColor = EnvoyColors.textTertiary;
      }

      return EnvoyListTile(
        textLeft1: textLeft1,
        textLeft2: textLeft2,
        leftIcon: leftIcon,
        iconColor: iconColor,
        unitIcon: unitIcon,
      );
    });
  }
}
