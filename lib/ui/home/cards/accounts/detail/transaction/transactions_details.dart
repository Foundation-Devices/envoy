// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/locale.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/tx_note_dialog_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_button.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/transactions_note_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/util/tuple.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/components/envoy_info_card.dart';
import 'package:envoy/ui/components/envoy_tag_list_item.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';

class TransactionsDetailsWidget extends ConsumerStatefulWidget {
  final Account account;
  final Transaction tx;
  final Widget? iconTitleWidget;
  final Widget? titleWidget;

  const TransactionsDetailsWidget({
    super.key,
    required this.account,
    required this.tx,
    this.iconTitleWidget,
    this.titleWidget,
  });

  @override
  ConsumerState<TransactionsDetailsWidget> createState() =>
      _TransactionsDetailsWidgetState();
}

class _TransactionsDetailsWidgetState
    extends ConsumerState<TransactionsDetailsWidget> {
  bool showTxIdExpanded = false;
  bool showAddressExpanded = false;
  bool showPaymentId = false;
  final GlobalKey _detailWidgetKey = GlobalKey();

  String _getConfirmationTimeString(int minutes) {
    String confirmationTime = "";

    if (minutes < 60) {
      confirmationTime = "${minutes}m";
    } else if (minutes >= 60 && minutes < 120) {
      confirmationTime = "1h";
    } else {
      confirmationTime = "1 ${S().coindetails_overlay_confirmationIn_day}";
    }

    return "${S().coindetails_overlay_confirmationIn} ~$confirmationTime";
  }

  @override
  Widget build(BuildContext context) {
    ///watch transaction changes to get real time updates
    final tx = ref.watch(getTransactionProvider(widget.tx.txId)) ?? widget.tx;
    final note = ref.watch(txNoteProvider(tx.txId)) ?? "";

    final hideBalance =
        ref.watch(balanceHideStateStatusProvider(widget.account.id));
    final accountAccentColor = widget.account.color;
    final trailingTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: EnvoyColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    bool addressNotAvailable = tx.address == null || tx.address!.isEmpty;
    final address = tx.address ?? "";

    bool rbfPossible =
        (!tx.isConfirmed && tx.type == TransactionType.normal && tx.amount < 0);

    final cancelState = ref.watch(cancelTxStateProvider(tx.txId));

    if (cancelState?.newTxId == tx.txId) {
      rbfPossible = false;
    }

    return GestureDetector(
      onTapUp: (details) {
        final RenderBox box =
            _detailWidgetKey.currentContext?.findRenderObject() as RenderBox;
        final Offset localOffset = box.globalToLocal(details.globalPosition);

        if (!box.paintBounds.contains(localOffset)) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          flexibleSpace: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  height: 100,
                  child: IndicatorShield(),
                ),
                Text(
                  S().coincontrol_tx_detail_expand_heading.toUpperCase(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            EnvoyInfoCard(
              key: _detailWidgetKey,
              backgroundColor: accountAccentColor,
              titleWidget: widget.titleWidget,
              iconTitleWidget: widget.iconTitleWidget,
              topWidget: hideBalance
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // hide placeholder for btc
                        LoaderGhost(
                          width: 110,
                          height: 20,
                          animate: false,
                        ),
                        // hide placeholder for fiat
                        LoaderGhost(
                          width: 80,
                          height: 20,
                          animate: false,
                        ),
                      ],
                    )
                  : (tx.amount == 0 &&
                          tx.currency != null &&
                          tx.currencyAmount != null)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const LoaderGhost(
                              width: 110,
                              height: 20,
                              animate: false,
                            ),
                            // hide placeholder for fiat
                            Text(
                              "${tx.currencyAmount!} ${tx.currency!}",
                              style: EnvoyTypography.body.copyWith(
                                color: EnvoyColors.textPrimary,
                              ),
                            ),
                          ],
                        )
                      : EnvoyAmount(
                          account: widget.account,
                          amountSats: tx.amount,
                          amountWidgetStyle: AmountWidgetStyle.singleLine),
              bottomWidgets: [
                EnvoyInfoCardListItem(
                  title: S().coindetails_overlay_address,
                  icon: const EnvoyIcon(EnvoyIcons.send,
                      color: EnvoyColors.textPrimary,
                      size: EnvoyIconSize.extraSmall),
                  trailing: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        showAddressExpanded = !showAddressExpanded;
                        showTxIdExpanded = false;
                        showPaymentId = false;
                      });
                    },
                    child: TweenAnimationBuilder(
                        curve: EnvoyEasing.easeInOut,
                        tween: Tween<double>(
                            begin: 0, end: showAddressExpanded ? 1 : 0),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, value, child) {
                          return addressNotAvailable
                              ? Text("Address not available ",
                                  // TODO: Figma
                                  style: trailingTextStyle)
                              : AddressWidget(
                                  widgetKey:
                                      ValueKey<bool>(showAddressExpanded),
                                  address: address,
                                  short: true,
                                  sideChunks: 2 +
                                      (value * (address.length / 4)).round(),
                                );
                        }),
                  ),
                ),
                EnvoyInfoCardListItem(
                  title: S().coindetails_overlay_transactionID,
                  icon: const EnvoyIcon(EnvoyIcons.compass,
                      color: EnvoyColors.textPrimary,
                      size: EnvoyIconSize.small),
                  trailing: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: () {
                      if (tx.type != TransactionType.ramp) {
                        copyTxId(context, tx.txId, tx.type);
                      }
                    },
                    onTap: () {
                      if (tx.type != TransactionType.ramp) {
                        setState(() {
                          showTxIdExpanded = !showTxIdExpanded;
                          showAddressExpanded = false;
                          showPaymentId = false;
                        });
                      }
                    },
                    child: TweenAnimationBuilder(
                      curve: EnvoyEasing.easeInOut,
                      tween: Tween<double>(
                          begin: 0, end: showTxIdExpanded ? 1 : 0),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        String txId = tx.type == TransactionType.ramp
                            ? "loading"
                            : tx.txId; // TODO: Figma
                        return Text(
                          truncateWithEllipsisInCenter(txId,
                              lerpDouble(16, txId.length, value)!.toInt()),
                          style: EnvoyTypography.info
                              .copyWith(color: EnvoyColors.textPrimary),
                          textAlign: TextAlign.end,
                          maxLines: 4,
                        );
                      },
                    ),
                  ),
                ),
                EnvoyInfoCardListItem(
                  title: S().coindetails_overlay_date,
                  icon: const EnvoyIcon(EnvoyIcons.calendar,
                      color: EnvoyColors.textPrimary,
                      size: EnvoyIconSize.small),
                  trailing: Text(getTransactionDateAndTimeString(tx),
                      style: trailingTextStyle),
                ),
                EnvoyInfoCardListItem(
                  title: S().coindetails_overlay_status,
                  icon: const EnvoyIcon(EnvoyIcons.activity,
                      color: EnvoyColors.textPrimary,
                      size: EnvoyIconSize.small),
                  trailing: Text(getTransactionStatusString(tx),
                      style: trailingTextStyle),
                ),
                if (tx.pullPaymentId != null)
                  EnvoyInfoCardListItem(
                      title: S().coindetails_overlay_paymentID,
                      icon: const EnvoyIcon(EnvoyIcons.btcPay,
                          color: EnvoyColors.textPrimary,
                          size: EnvoyIconSize.small),
                      trailing: GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(
                              ClipboardData(text: tx.pullPaymentId!));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Payment ID copied to clipboard!'))); //TODO: FIGMA
                        },
                        onTap: () {
                          setState(() {
                            showPaymentId = !showPaymentId;
                            showTxIdExpanded = false;
                            showAddressExpanded = false;
                          });
                        },
                        child: TweenAnimationBuilder(
                          curve: EnvoyEasing.easeInOut,
                          tween: Tween<double>(
                              begin: 0, end: showPaymentId ? 1 : 0),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, value, child) {
                            return Text(
                                truncateWithEllipsisInCenter(
                                    tx.pullPaymentId!,
                                    lerpDouble(16, tx.pullPaymentId!.length,
                                            value)!
                                        .toInt()),
                                style: EnvoyTypography.info
                                    .copyWith(color: EnvoyColors.textPrimary),
                                textAlign: TextAlign.end,
                                maxLines: 4);
                          },
                        ),
                      )),
                if (tx.rampId != null)
                  EnvoyInfoCardListItem(
                    title: S().coindetails_overlay_rampID,
                    icon: const EnvoyIcon(
                      EnvoyIcons.ramp_without_name,
                      size: EnvoyIconSize.extraSmall,
                      color: EnvoyColors.textPrimary,
                    ),
                    trailing: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () {
                        copyTxId(context, tx.rampId!, tx.type);
                      },
                      child: Text(
                        tx.rampId!,
                        style:
                            EnvoyTypography.info.copyWith(color: Colors.black),
                        textAlign: TextAlign.end,
                        maxLines: 4,
                      ),
                    ),
                  ),
                if (tx.rampFee != null)
                  EnvoyInfoCardListItem(
                    title: S().coindetails_overlay_rampFee,
                    icon: const EnvoyIcon(
                      EnvoyIcons.ramp_without_name,
                      size: EnvoyIconSize.extraSmall,
                      color: EnvoyColors.textPrimary,
                    ),
                    trailing: hideBalance
                        ? const LoaderGhost(
                            width: 74, animate: false, height: 16)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              EnvoyAmount(
                                  account: widget.account,
                                  amountSats: tx.rampFee!,
                                  amountWidgetStyle: AmountWidgetStyle.normal),
                            ],
                          ),
                  ),
                rbfPossible
                    ? EnvoyInfoCardListItem(
                        spacingPriority: FlexPriority.trailing,
                        title: _getConfirmationTimeString(ref.watch(
                            txEstimatedConfirmationTimeProvider(
                                Tuple(tx, widget.account.wallet.network)))),
                        icon: const EnvoyIcon(
                          EnvoyIcons.clock,
                          size: EnvoyIconSize.extraSmall,
                          color: EnvoyColors.textPrimary,
                        ),
                        trailing: TxRBFButton(
                          tx: tx,
                        ),
                      )
                    : Container(),
                if (tx.type != TransactionType.ramp)
                  _renderFeeWidget(context, tx),
                GestureDetector(
                  onTap: () {
                    showEnvoyDialog(
                        context: context,
                        dialog: TxNoteDialog(
                          txId: tx.txId,
                          noteTitle: S().add_note_modal_heading,
                          noteHintText: S().add_note_modal_ie_text_field,
                          noteSubTitle: S().add_note_modal_subheading,
                          onAdd: (note) {
                            EnvoyStorage().addTxNote(note: note, key: tx.txId);
                            Navigator.pop(context);
                          },
                        ),
                        alignment: const Alignment(0.0, -0.8));
                  },
                  child: EnvoyInfoCardListItem(
                    title: S().coincontrol_tx_history_tx_detail_note,
                    icon: const EnvoyIcon(
                      EnvoyIcons.note,
                      size: EnvoyIconSize.small,
                      color: EnvoyColors.textPrimary,
                    ),
                    trailing: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(note,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: EnvoyTypography.body
                                .copyWith(color: EnvoyColors.textPrimary),
                            textAlign: TextAlign.end),
                        const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                        note.trim().isNotEmpty
                            ? SvgPicture.asset(
                                note.trim().isNotEmpty
                                    ? "assets/icons/ic_edit_note.svg"
                                    : "assets/icons/ic_notes.svg",
                                color: Theme.of(context).primaryColor,
                                height: 14,
                              )
                            : const Icon(Icons.add_circle_rounded,
                                color: EnvoyColors.accentPrimary, size: 24),
                      ],
                    ),
                  ),
                ),
                rbfPossible
                    ? CancelTxButton(
                        transaction: tx,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            if (tx.type == TransactionType.ramp) ...[
              const EnvoyIcon(
                EnvoyIcons.info,
                color: EnvoyColors.textPrimaryInverse,
                size: EnvoyIconSize.medium,
              ),
              const SizedBox(height: EnvoySpacing.xs),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: EnvoySpacing.large1),
                child: Text(
                  S().replaceByFee_ramp_incompleteTransactionAutodeleteWarning,
                  style: EnvoyTypography.info
                      .copyWith(color: EnvoyColors.textPrimaryInverse),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _renderFeeWidget(BuildContext context, Transaction tx) {
    final isBoosted = ref.watch(isTxBoostedProvider(tx.txId)) ?? false;
    final cancelState = ref.watch(cancelTxStateProvider(tx.txId));
    final hideBalance =
        ref.watch(balanceHideStateStatusProvider(widget.account.id));

    String feeTitle = isBoosted
        ? S().coindetails_overlay_boostedFees
        : S().coincontrol_tx_detail_fee;

    Widget icon = isBoosted
        ? const EnvoyIcon(
            EnvoyIcons.rbf_boost,
            size: EnvoyIconSize.extraSmall,
          )
        : SvgPicture.asset(
            "assets/icons/ic_bitcoin_straight_circle.svg",
            color: Colors.black,
            height: 18,
          );

    if (cancelState?.newTxId == tx.txId) {
      icon = const Icon(
        Icons.close,
        size: 16,
      );
      feeTitle = S().replaceByFee_cancel_overlay_modal_cancelationFees;
    }
    return EnvoyInfoCardListItem(
      title: feeTitle,
      icon: icon,
      trailing: hideBalance
          ? const LoaderGhost(width: 74, animate: false, height: 16)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                EnvoyAmount(
                    account: widget.account,
                    amountSats: tx.fee,
                    amountWidgetStyle: AmountWidgetStyle.normal),
              ],
            ),
    );
  }
}

String getTransactionDateAndTimeString(Transaction transaction) {
  if (!transaction.isConfirmed) {
    return S().activity_pending;
  }
  final String transactionDateInfo =
      "${DateFormat.yMd(currentLocale).format(transaction.date)} ${S().coindetails_overlay_at} ${DateFormat.Hm(currentLocale).format(transaction.date)}";
  return transactionDateInfo;
}

String getTransactionStatusString(Transaction tx) {
  return tx.type == TransactionType.normal && tx.isConfirmed
      ? S().coindetails_overlay_status_confirmed
      : S().activity_pending;
}
