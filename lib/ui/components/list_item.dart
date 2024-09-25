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
import 'package:timeago/timeago.dart' as timeago;
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/state/accounts_state.dart';

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
    return GestureDetector(
      onTap: () {},
      child: ListTile(
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
        titleText =
            transaction.amount < 0 ? S().activity_sent : S().activity_received;
        RBFState? cancelState =
            ref.watch(cancelTxStateProvider(transaction.txId));
        if (cancelState != null) {
          if (cancelState.originalTxId == transaction.txId) {
            if (!transaction.isConfirmed) {
              titleText = S().activity_canceling;
            }
          }
          if (cancelState.newTxId == transaction.txId) {
            if (transaction.isConfirmed) {
              titleText = S().activity_sent_canceled;
            } else {
              titleText = S().activity_canceling;
            }
          }
        } else {
          if (isBoosted == true) {
            if (transaction.isConfirmed) {
              titleText = S().activity_sent_boosted;
            }
            titleText = S().activity_boosted;
          }
        }

        if (transaction.type == TransactionType.azteco) {
          subtitleText = S().azteco_account_tx_history_pending_voucher;
        } else if (transaction.type == TransactionType.btcPay) {
          subtitleText = S().btcpay_pendingVoucher;
        } else if (transaction.type == TransactionType.ramp) {
          subtitleText = S().ramp_pendingVoucher;
        } else if (transaction.type == TransactionType.normal &&
            transaction.isConfirmed) {
          subtitleText = timeago
              .format(transaction.date, locale: activeLocale.languageCode)
              .capitalize();
        } else {
          subtitleText = S().receive_tx_list_awaitingConfirmation;
        }

        txIcon = transaction.amount < 0 ? EnvoyIcons.spend : EnvoyIcons.receive;
        if (cancelState != null) {
          if (!transaction.isConfirmed) {
            txIcon = EnvoyIcons.alert;
          } else if (cancelState.newTxId == transaction.txId) {
            txIcon = EnvoyIcons.close;
          } else {
            txIcon =
                transaction.amount < 0 ? EnvoyIcons.spend : EnvoyIcons.receive;
          }
        } else if (isBoosted == true) {
          txIcon = EnvoyIcons.rbf_boost;
        }

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
                SizedBox(height: EnvoySpacing.xs),
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
            return FittedBox(
              child: EnvoyAmount(
                account: transactionAccount!,
                amountSats: transaction.amount,
                amountWidgetStyle: AmountWidgetStyle.normal,
                alignToEnd: true,
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

      return EnvoyListTile(
        titleText: titleText,
        subtitleText: subtitleText,
        txIcon: txIcon,
        iconColor: iconColor,
        unitIcon: unitIcon,
      );
    });
  }
}
