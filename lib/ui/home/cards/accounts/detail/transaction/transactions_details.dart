// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:ui';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/locale.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/tx_note_dialog_widget.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/transactions_note_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:wallet/wallet.dart';

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

  void _calculateContainerHeight(timeStamp) {
    if (mounted) {
      ///ensures we only set of the height changes
      double nextHeight = 44 + (_scrollController.position.extentTotal);
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
    final trailingTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: EnvoyColors.textPrimary,
          fontWeight: FontWeight.w600,
        );
    TextStyle _textStyleAmountSatBtc =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: EnvoyColors.textPrimary,
              fontSize: 15,
            );

    final address = tx.address ?? tx.outputs?[0] ?? "";

    TextStyle _textStyleFiat = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: EnvoyColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        );

    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box =
            _detailWidgetKey.currentContext?.findRenderObject() as RenderBox;
        final Offset localOffset = box.globalToLocal(details.globalPosition);

        if (!box.paintBounds.contains(localOffset)) {
          Navigator.of(context).pop();
        }
        //
        // if(details.globalPosition.dy > size.height){
        //   return;
        //   Navigator.of(context).pop();
        // }
        // if(details.globalPosition.dy > size.height)
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
                borderRadius: BorderRadius.all(Radius.circular(24)),
                border: Border.all(
                    color: Colors.black, width: 2, style: BorderStyle.solid),
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
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    border: Border.all(
                        color: accountAccentColor,
                        width: 2,
                        style: BorderStyle.solid)),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    child: StripesBackground(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 36,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(EnvoySpacing.medium2)),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      alignment: Alignment(0, 0),
                                      child: SizedBox.square(
                                          dimension: 12,
                                          child: SvgPicture.asset(
                                            Settings().displayUnit ==
                                                    DisplayUnit.btc
                                                ? "assets/icons/ic_bitcoin_straight.svg"
                                                : "assets/icons/ic_sats.svg",
                                            color: Color(0xff808080),
                                          )),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(
                                          left: Settings().displayUnit ==
                                                  DisplayUnit.btc
                                              ? 4
                                              : 0,
                                          right: Settings().displayUnit ==
                                                  DisplayUnit.btc
                                              ? 0
                                              : 8),
                                      child: hideBalance
                                          ? LoaderGhost(
                                              width: 110,
                                              height: 20,
                                              animate: false,
                                            )
                                          : Text(
                                              "${getFormattedAmount(tx.amount, trailingZeroes: true)}",
                                              textAlign:
                                                  Settings().displayUnit ==
                                                          DisplayUnit.btc
                                                      ? TextAlign.start
                                                      : TextAlign.end,
                                              style: _textStyleAmountSatBtc,
                                            ),
                                    ),
                                  ],
                                ),
                                Container(
                                  constraints: BoxConstraints(minWidth: 80),
                                  alignment: Alignment.centerRight,
                                  child: hideBalance
                                      ? LoaderGhost(
                                          width: 64,
                                          height: 20,
                                          animate: false,
                                        )
                                      : Text(
                                          ExchangeRate().getFormattedAmount(
                                              tx.amount,
                                              wallet: widget.account.wallet),
                                          style: _textStyleFiat,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end,
                                        ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 4),
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
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
                                        child: TweenAnimationBuilder(
                                          tween: Tween<double>(
                                              begin: 0,
                                              end: showAddressExpanded ? 1 : 0),
                                          curve: EnvoyEasing.easeInOut,
                                          duration: Duration(milliseconds: 200),
                                          builder: (context, value, child) {
                                            return SelectableText(
                                              "${truncateWithEllipsisInCenter(address, lerpDouble(20, address.length, value)!.toInt())}",
                                              style:
                                                  trailingTextStyle?.copyWith(
                                                      color: EnvoyColors
                                                          .accentPrimary),
                                              textAlign: TextAlign.end,
                                              minLines: 1,
                                              maxLines: 4,
                                              onTap: () {
                                                setState(() {
                                                  showAddressExpanded =
                                                      !showAddressExpanded;
                                                  showTxIdExpanded = false;
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      )),
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
                                            style: trailingTextStyle?.copyWith(
                                                color:
                                                    EnvoyColors.accentPrimary),
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
                                CoinTagListItem(
                                  title: S().coincontrol_tx_detail_fee,
                                  icon: SvgPicture.asset(
                                    "assets/icons/ic_bitcoin_straight_circle.svg",
                                    color: Colors.black,
                                    height: 14,
                                  ),
                                  trailing: hideBalance
                                      ? LoaderGhost(
                                          width: 74, animate: false, height: 16)
                                      : RichText(
                                          text: TextSpan(
                                              style:
                                                  trailingTextStyle?.copyWith(
                                                color: EnvoyColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              children: [
                                              WidgetSpan(
                                                alignment:
                                                    PlaceholderAlignment.middle,
                                                child: getUnitIcon(
                                                  widget.account,
                                                  iconSize:
                                                      EnvoyIconSize.extraSmall,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "${getFormattedAmount(
                                                  tx.fee,
                                                  trailingZeroes: true,
                                                  testnet: widget.account.wallet
                                                          .network ==
                                                      Network.Testnet,
                                                )}",
                                              ),
                                              TextSpan(
                                                  text:
                                                      "${widget.account.wallet.network == Network.Testnet ? '' : (Settings().selectedFiat != null ? "  " : '')}${ExchangeRate().getFormattedAmount(tx.fee, wallet: widget.account.wallet)}",
                                                  style: trailingTextStyle
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w300,
                                                  )),
                                            ])),
                                ),
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
                                              style: trailingTextStyle
                                                  ?.copyWith(fontSize: 12),
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

  Widget CoinTagListItem(
      {required String title, required Widget icon, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: icon,
                ),
                Padding(padding: EdgeInsets.all(4)),
                Text(
                  "$title",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
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
