// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/tx_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:ngwallet/src/wallet.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/util/blur_container_transform.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/business/settings.dart';

class EnvoyListTile extends StatelessWidget {
  const EnvoyListTile({
    super.key,
    required this.titleText,
    this.subtitleText,
    this.txIcon,
    this.iconColor = EnvoyColors.textPrimary,
    this.unitIcon,
  });

  final String titleText;
  final String? subtitleText;
  final EnvoyIcons? txIcon;
  final Color? iconColor;
  final Widget? unitIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        minLeadingWidth: 0,
        horizontalTitleGap: EnvoySpacing.medium1,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.xs),
          child: Text(
            titleText,
            style:
                EnvoyTypography.body.copyWith(color: EnvoyColors.textPrimary),
          ),
        ),
        subtitle: subtitleText == null
            ? const Text("")
            : Text(
                subtitleText!,
                style: EnvoyTypography.info
                    .copyWith(color: EnvoyColors.textSecondary),
              ),
        leading: txIcon == null
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  EnvoyIcon(
                    txIcon!,
                    color: iconColor,
                    size: EnvoyIconSize.small,
                  ),
                ],
              ),
        trailing: unitIcon == null
            ? const Text("")
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  unitIcon!,
                ],
              ));
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: EnvoySpacing.medium3),
          child: Text(
            title,
            style:
                EnvoyTypography.info.copyWith(color: EnvoyColors.textTertiary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: EnvoySpacing.small),
          child: Container(
            height: 1,
            color: EnvoyColors.tabBar,
          ),
        )
      ],
    );
  }
}

class ActivityListTile extends ConsumerStatefulWidget {
  const ActivityListTile(this.notification, {super.key});

  final EnvoyNotification notification;

  @override
  ActivityListTileState createState() => ActivityListTileState();
}

final Settings s = Settings();

class ActivityListTileState extends ConsumerState<ActivityListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      String titleText = "";
      String? subtitleText;
      EnvoyIcons? txIcon;
      Color? iconColor;
      Widget? unitIcon;
      final Locale activeLocale = Localizations.localeOf(context);
      final notification = widget.notification;
      final transaction = notification.transaction;

      if (transaction != null) {
        bool? isBoosted = ref.watch(isTxBoostedProvider(transaction.txId));
        RBFState? cancelState =
            ref.watch(cancelTxStateProvider(transaction.txId));

        titleText =
            getTransactionTitleText(transaction, cancelState, isBoosted);
        subtitleText = getTransactionSubtitleText(transaction, activeLocale);
        txIcon = getTransactionIcon(transaction, cancelState, isBoosted);

        unitIcon = () {
          final accountManager = ref.watch(accountManagerProvider);
          bool isTransactionHidden = false;
          Account? transactionAccount;

          // Check if the account of the current transaction is hidden
          for (var account in accountManager.accounts) {
            final transactions = ref.watch(transactionsProvider(account.id));
            for (var tx in transactions) {
              if (tx.txId == transaction.txId) {
                transactionAccount = account;
                isTransactionHidden =
                    ref.watch(balanceHideStateStatusProvider(account.id));
                break;
              }
            }
            if (isTransactionHidden) break;
          }

          if (isTransactionHidden) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: EnvoySpacing.small),
                LoaderGhost(
                  width: 120,
                  height: 15,
                  animate: false,
                ),
                SizedBox(height: EnvoySpacing.xs),
                LoaderGhost(
                  width: 40,
                  height: 15,
                  animate: false,
                ),
              ],
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: s.displayFiat() == null ? EnvoySpacing.medium1 : 0),
              child: FittedBox(
                child: EnvoyAmount(
                  account: transactionAccount!,
                  amountSats: transaction.amount,
                  amountWidgetStyle: AmountWidgetStyle.normal,
                  alignToEnd: true,
                ),
              ),
            );
          }
        }();
      }

      iconColor = EnvoyColors.textTertiary;

      if (notification.type == EnvoyNotificationType.firmware) {
        txIcon = EnvoyIcons.tool;
        titleText = S().activity_passportUpdate;
        subtitleText = timeago
            .format(notification.date ?? DateTime.now(),
                locale: activeLocale.languageCode)
            .capitalize();

        iconColor = EnvoyColors.textTertiary;
      }

      if (notification.type == EnvoyNotificationType.envoyUpdate) {
        txIcon = EnvoyIcons.download;
        titleText = S().activity_envoyUpdateAvailable;
        subtitleText = timeago
            .format(notification.date ?? DateTime.now(),
                locale: activeLocale.languageCode)
            .capitalize();

        iconColor = EnvoyColors.textTertiary;
      }

      return notification.transaction != null
          ? BlurContainerTransform(
              useRootNavigator: true,
              closedBuilder: (context, action) {
                return GestureDetector(
                    onTap: () {
                      if (!ref.read(transactionDetailsOpen.notifier).state) {
                        ref.read(transactionDetailsOpen.notifier).state = true;
                        action();
                      }
                    },
                    child: EnvoyListTile(
                      titleText: titleText,
                      subtitleText: subtitleText,
                      txIcon: txIcon,
                      iconColor: iconColor,
                      unitIcon: unitIcon,
                    ));
              },
              openBuilder: (context, action) {
                return openTransactionDetails(context, transaction!);
              },
            )
          : GestureDetector(
              onTap: () {
                openNotificationEvent(context);
              },
              child: EnvoyListTile(
                titleText: titleText,
                subtitleText: subtitleText,
                txIcon: txIcon,
                iconColor: iconColor,
                unitIcon: unitIcon,
              ),
            );
    });
  }

  Widget openTransactionDetails(BuildContext context, Transaction transaction) {
    if (widget.notification.accountId != null) {
      Account? account =
          AccountManager().getAccountById(widget.notification.accountId!);
      if (account != null) {
        return TransactionsDetailsWidget(
          account: account,
          tx: transaction,
          iconTitleWidget: transactionIcon(context, transaction,
              iconColor: EnvoyColors.textPrimaryInverse),
          titleWidget: transactionTitle(
            context,
            transaction,
            txTitleStyle: EnvoyTypography.subheading
                .copyWith(color: EnvoyColors.textPrimaryInverse),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  void openNotificationEvent(BuildContext context) {
    switch (widget.notification.type) {
      case EnvoyNotificationType.firmware:
        context.go(ROUTE_DEVICES);
      case EnvoyNotificationType.transaction:
        break;
      case EnvoyNotificationType.security:
        break;
      case EnvoyNotificationType.envoyUpdate:
        launchUrlString(
            "https://github.com/Foundation-Devices/envoy/releases/tag/${widget.notification.body}");
    }
  }
}
