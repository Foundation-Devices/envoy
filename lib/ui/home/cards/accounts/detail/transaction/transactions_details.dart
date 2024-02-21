// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:ui';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/locale.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/util/tuple.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class TransactionsDetailsWidget extends ConsumerStatefulWidget {
  final Account account;
  final Transaction tx;

  const TransactionsDetailsWidget(
      {super.key, required this.account, required this.tx});

  @override
  ConsumerState<TransactionsDetailsWidget> createState() =>
      _TransactionsDetailsWidgetState();
}

class _TransactionsDetailsWidgetState
    extends ConsumerState<TransactionsDetailsWidget> {
  bool showTxIdExpanded = false;
  bool showAddressExpanded = false;
  GlobalKey _detailWidgetKey = GlobalKey();
  ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //Calculate height periodically
    _timer =
        Timer.periodic(Duration(milliseconds: 100), _calculateContainerHeight);
  }

  String _getConfirmationTimeString(int minutes) {
    String confirmationTime = "";

    if (minutes < 60) {
      confirmationTime = minutes.toString() + "m";
    } else if (minutes >= 60 && minutes < 120) {
      confirmationTime = "~1h";
    } else {
      confirmationTime = "~1day";
    }

    return S().coindetails_overlay_confirmationIn + " ~" + confirmationTime;
  }

  void _calculateContainerHeight(timeStamp) {
    if (mounted) {
      ///ensures we only set of the height changes
      double nextHeight = 36 + (_scrollController.position.extentTotal);
      if (nextHeight != containerHeight)
        setState(() {
          containerHeight = nextHeight;
        });
    }
  }

  double containerHeight = 280;

  @override
  Widget build(BuildContext context) {
    ///watch transaction changes to get real time updates
    final tx = ref.watch(getTransactionProvider(widget.tx.txId)) ?? widget.tx;
    final note = ref.watch(txNoteProvider(tx.txId)) ?? "";

    final hideBalance =
        ref.watch(balanceHideStateStatusProvider(widget.account.id));
    final accountAccentColor = widget.account.color;
    final trailingTextStyle =
        EnvoyTypography.info.copyWith(color: EnvoyColors.textPrimary);

    bool addressNotAvailable = tx.address == null || tx.address!.isEmpty;
    final address = tx.address ?? "";

    bool RBFPossible =
        (!tx.isConfirmed && tx.type == TransactionType.normal && tx.amount < 0);

    final cancelState = ref.watch(cancelTxStateProvider(tx.txId));

    if (cancelState?.newTxId == tx.txId) {
      RBFPossible = false;
    }
    double cardRadius = 20;

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
                Container(
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
        body: Container(
            key: _detailWidgetKey,
            padding: EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium2,
                vertical: EnvoySpacing.medium2),
            child: AnimatedContainer(
              height: containerHeight,
              duration: Duration(milliseconds: 160),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
                border: Border.all(
                    color: Colors.black, width: 1.5, style: BorderStyle.solid),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accountAccentColor,
                      Colors.black,
                    ]),
              ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
                    border: Border.all(
                        color: accountAccentColor,
                        width: 1.5,
                        style: BorderStyle.solid)),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
                    child: StripesBackground(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 36,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.xs),
                            margin: EdgeInsets.all(EnvoySpacing.xs),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(EnvoySpacing.medium2)),
                              color: Colors.white,
                            ),
                            child: hideBalance
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                : EnvoyAmount(
                                    account: widget.account,
                                    amountSats: tx.amount,
                                    amountWidgetStyle:
                                        AmountWidgetStyle.singleLine),
                          ),
                          Expanded(
                              child: Container(
                            margin: EdgeInsets.all(EnvoySpacing.xs),
                            padding: EdgeInsets.all(EnvoySpacing.xs),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(EnvoySpacing.medium1),
                              color: Colors.white,
                            ),
                            child: ListView(
                              controller: _scrollController,
                              children: [
                                CoinTagListItem(
                                  title: S().coindetails_overlay_address,
                                  icon: SvgPicture.asset(
                                    "assets/icons/ic_spend.svg",
                                    color: Colors.black,
                                    height: 14,
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showAddressExpanded =
                                            !showAddressExpanded;
                                        showTxIdExpanded = false;
                                      });
                                    },
                                    child: SingleChildScrollView(
                                      child: AnimatedSize(
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        child: addressNotAvailable
                                            ? Text("Address not available ",
                                                // TODO: Figma
                                                style: trailingTextStyle)
                                            : AddressWidget(
                                                widgetKey: ValueKey<bool>(
                                                    showAddressExpanded),
                                                address: address,
                                                short: !showAddressExpanded,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                CoinTagListItem(
                                  title: S().coindetails_overlay_transactionID,
                                  icon: Icon(
                                    CupertinoIcons.compass,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  trailing: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showTxIdExpanded = !showTxIdExpanded;
                                          showAddressExpanded = false;
                                        });
                                      },
                                      child: TweenAnimationBuilder(
                                        curve: EnvoyEasing.easeInOut,
                                        tween: Tween<double>(
                                            begin: 0,
                                            end: showTxIdExpanded ? 1 : 0),
                                        duration: Duration(milliseconds: 200),
                                        builder: (context, value, child) {
                                          return SelectableText(
                                            "${truncateWithEllipsisInCenter(tx.txId, lerpDouble(16, tx.txId.length, value)!.toInt())}",
                                            style: EnvoyTypography.info
                                                .copyWith(
                                                    color: EnvoyColors
                                                        .textSecondary),
                                            textAlign: TextAlign.end,
                                            minLines: 1,
                                            maxLines: 4,
                                            onTap: () {
                                              setState(() {
                                                showTxIdExpanded =
                                                    !showTxIdExpanded;
                                                showAddressExpanded = false;
                                              });
                                            },
                                          );
                                        },
                                      )),
                                ),
                                CoinTagListItem(
                                  title: S().coindetails_overlay_date,
                                  icon: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  trailing: Text(
                                      getTransactionDateAndTimeString(tx),
                                      style: trailingTextStyle),
                                ),
                                CoinTagListItem(
                                  title: S().coindetails_overlay_status,
                                  icon: SvgPicture.asset(
                                    "assets/icons/ic_status_icon.svg",
                                    color: Colors.black,
                                    height: 14,
                                  ),
                                  trailing: Text(getTransactionStatusString(tx),
                                      style: trailingTextStyle),
                                ),
                                RBFPossible
                                    ? CoinTagListItem(
                                        title: _getConfirmationTimeString(ref.watch(
                                            txEstimatedConfirmationTimeProvider(
                                                Tuple(
                                                    tx,
                                                    widget.account.wallet
                                                        .network)))),
                                        icon: Icon(
                                          Icons.access_time,
                                          color: Colors.black,
                                          size: 16,
                                        ),
                                        trailing: TxRBFButton(
                                          tx: tx,
                                        ),
                                      )
                                    : Container(),
                                _renderFeeWidget(context, tx),
                                GestureDetector(
                                  onTap: () {
                                    showEnvoyDialog(
                                        context: context,
                                        dialog: TxNoteDialog(
                                          txId: tx.txId,
                                          noteTitle: S().add_note_modal_heading,
                                          noteHintText:
                                              S().add_note_modal_ie_text_field,
                                          noteSubTitle:
                                              S().add_note_modal_subheading,
                                          onAdd: (note) {
                                            EnvoyStorage()
                                                .addTxNote(note, tx.txId);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        alignment: Alignment(0.0, -0.8));
                                  },
                                  child: CoinTagListItem(
                                    title: S()
                                        .coincontrol_tx_history_tx_detail_note,
                                    icon: SvgPicture.asset(
                                      "assets/icons/ic_notes.svg",
                                      color: Colors.black,
                                      height: 14,
                                    ),
                                    trailing: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Text("$note",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: EnvoyTypography.body
                                                  .copyWith(
                                                      color: EnvoyColors
                                                          .textPrimary),
                                              textAlign: TextAlign.end),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.all(
                                                EnvoySpacing.xs)),
                                        note.trim().isNotEmpty
                                            ? SvgPicture.asset(
                                                note.trim().isNotEmpty
                                                    ? "assets/icons/ic_edit_note.svg"
                                                    : "assets/icons/ic_notes.svg",
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                height: 14,
                                              )
                                            : Icon(Icons.add_circle_rounded,
                                                color:
                                                    EnvoyColors.accentPrimary,
                                                size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                                if (tx.pullPaymentId != null ||
                                    tx.type == TransactionType.btcPay)
                                  CoinTagListItem(
                                    title: S().coindetails_overlay_paymentID,
                                    icon: EnvoyIcon(EnvoyIcons.btcPay,
                                        size: EnvoyIconSize.extraSmall),
                                    trailing: Text(tx.pullPaymentId ?? tx.txId,
                                        style: trailingTextStyle),
                                  ),
                                RBFPossible
                                    ? CancelTxButton(
                                        transaction: tx,
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          )),
                        ],
                      ),
                    )),
              ),
            )),
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
        ? EnvoyIcon(
            EnvoyIcons.rbf_boost,
            size: EnvoyIconSize.extraSmall,
          )
        : SvgPicture.asset(
            "assets/icons/ic_bitcoin_straight_circle.svg",
            color: Colors.black,
            height: 14,
          );

    if (cancelState?.newTxId == tx.txId) {
      icon = Icon(
        Icons.close,
        size: 16,
      );
      feeTitle = S().replaceByFee_cancel_overlay_modal_cancelationFees;
    }
    return CoinTagListItem(
      title: feeTitle,
      icon: icon,
      trailing: hideBalance
          ? LoaderGhost(width: 74, animate: false, height: 16)
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

  Widget CoinTagListItem(
      {required String title, required Widget icon, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.small),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 4,
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
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
                        "$title",
                        style: EnvoyTypography.body
                            .copyWith(color: EnvoyColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
              flex: 4,
              child: Container(
                alignment: Alignment.centerRight,
                child: trailing,
              )),
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
      DateFormat.yMd(currentLocale).format(transaction.date) +
          " " +
          S().coindetails_overlay_at +
          " " +
          DateFormat.Hm(currentLocale).format(transaction.date);
  return transactionDateInfo;
}

String getTransactionStatusString(Transaction tx) {
  return tx.type == TransactionType.normal && tx.isConfirmed
      ? S().coindetails_overlay_status_confirmed
      : S().activity_pending;
}
