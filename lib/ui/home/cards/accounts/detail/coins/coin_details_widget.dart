// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart' as LegacyColors;
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/tx_note_dialog_widget.dart';
import 'package:envoy/ui/state/transactions_note_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';

class CoinDetailsWidget extends ConsumerStatefulWidget {
  final Coin coin;
  final CoinTag tag;

  const CoinDetailsWidget({super.key, required this.coin, required this.tag});

  @override
  ConsumerState<CoinDetailsWidget> createState() => _CoinDetailsWidgetState();
}

class _CoinDetailsWidgetState extends ConsumerState<CoinDetailsWidget> {
  bool showExpandedAddress = false;
  bool showExpandedTxId = false;

  @override
  Widget build(BuildContext context) {
    Color accountAccentColor = widget.tag.getAccount()?.color ??
        LegacyColors.EnvoyColors.listAccountTileColors[0];
    final accountTransactions =
        ref.read(transactionsProvider(widget.tag.account));
    final tx = accountTransactions
        .firstWhere((element) => element.txId == widget.coin.utxo.txid);
    final utxoAddress = tx.outputs?[widget.coin.utxo.vout] ?? "";
    final coinTag = widget.tag;
    final coin = widget.coin;
    final note = ref.watch(txNoteProvider(tx.txId)) ?? "";

    final trailingTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: EnvoyColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    if (coinTag.untagged) {
      accountAccentColor = Color(0xff808080);
    }

    double height = showExpandedAddress ? 324 : 280;
    height = showExpandedTxId ? 324 : height;

    return Container(
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: AnimatedContainer(
          height: height,
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(EnvoySpacing.medium2)),
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
                borderRadius:
                    BorderRadius.all(Radius.circular(EnvoySpacing.medium2)),
                border: Border.all(
                    color: accountAccentColor,
                    width: 2,
                    style: BorderStyle.solid)),
            child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(EnvoySpacing.medium2)),
                child: StripesBackground(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 36,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(EnvoySpacing.medium2)),
                          color: Colors.white,
                        ),
                        child: CoinBalanceWidget(
                          coin: coin,
                        ),
                      ),
                      Expanded(
                          child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          color: Colors.white,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runAlignment: WrapAlignment.spaceBetween,
                          children: [
                            CoinTagListItem(
                              title: "Address", // TODO: FIGMA
                              icon: SvgPicture.asset(
                                "assets/icons/ic_spend.svg",
                                color: Colors.black,
                                height: 14,
                              ),
                              trailing: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showExpandedAddress =
                                          !showExpandedAddress;
                                      showExpandedTxId = false;
                                    });
                                  },
                                  child: TweenAnimationBuilder(
                                    tween: Tween<double>(
                                        begin: 0,
                                        end: showExpandedAddress ? 1 : 0),
                                    duration: Duration(milliseconds: 200),
                                    builder: (context, value, child) {
                                      return SelectableText(
                                        "${truncateWithEllipsisInCenter(utxoAddress, lerpDouble(20, utxoAddress.length, value)!.toInt())}",
                                        style: trailingTextStyle?.copyWith(
                                            color: EnvoyColors.accentPrimary),
                                        textAlign: TextAlign.end,
                                        maxLines: 3,
                                        minLines: 1,
                                        enableInteractiveSelection:
                                            showExpandedAddress,
                                        onTap: () {
                                          setState(() {
                                            showExpandedAddress =
                                                !showExpandedAddress;
                                            showExpandedTxId = false;
                                          });
                                        },
                                      );
                                    },
                                  )),
                            ),
                            CoinTagListItem(
                              title: "Transaction ID", // TODO: FIGMA
                              icon: Icon(
                                CupertinoIcons.compass,
                                size: 16,
                                color: Colors.black,
                              ),
                              trailing: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showExpandedTxId = !showExpandedTxId;
                                      showExpandedAddress = false;
                                    });
                                  },
                                  child: TweenAnimationBuilder(
                                    tween: Tween<double>(
                                        begin: 0,
                                        end: showExpandedTxId ? 1 : 0),
                                    duration: Duration(milliseconds: 200),
                                    builder: (context, value, child) {
                                      return SelectableText(
                                        "${truncateWithEllipsisInCenter(widget.coin.utxo.txid, lerpDouble(16, widget.coin.utxo.txid.length, value)!.toInt())}",
                                        style: trailingTextStyle?.copyWith(
                                            color: EnvoyColors.accentPrimary),
                                        textAlign: TextAlign.end,
                                        maxLines: 4,
                                        minLines: 1,
                                        onTap: () {
                                          setState(() {
                                            showExpandedTxId =
                                                !showExpandedTxId;
                                            showExpandedAddress = false;
                                          });
                                        },
                                      );
                                    },
                                  )),
                            ),
                            CoinTagListItem(
                              title: "Date", // TODO: FIGMA
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
                              title:
                                  S().coincontrol_tx_history_tx_details_history,
                              icon: SvgPicture.asset(
                                "assets/icons/ic_tag.svg",
                                color: Colors.black,
                                height: 16,
                              ),
                              trailing: Text("${coinTag.name}",
                                  style: trailingTextStyle),
                            ),
                            CoinTagListItem(
                              title: "Status", // TODO: FIGMA
                              icon: SvgPicture.asset(
                                "assets/icons/ic_status_icon.svg",
                                color: Colors.black,
                                height: 14,
                              ),
                              trailing: Text(getTransactionStatusString(tx),
                                  style: trailingTextStyle),
                            ),
                            GestureDetector(
                              onTap: () {
                                showEnvoyDialog(
                                    context: context,
                                    useRootNavigator: true,
                                    dialog: TxNoteDialog(
                                      txId: tx.txId,
                                      noteTitle: S().add_note_modal_heading,
                                      noteHintText:
                                          S().add_note_modal_ie_text_field,
                                      noteSubTitle:
                                          S().add_note_modal_subheading,
                                      onAdd: (note) async {
                                        await EnvoyStorage()
                                            .addTxNote(note, tx.txId);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    alignment: Alignment(0.0, -0.8));
                              },
                              child: CoinTagListItem(
                                title: "Notes", // TODO: FIGMA
                                icon: SvgPicture.asset(
                                  "assets/icons/ic_notes.svg",
                                  color: Colors.black,
                                  height: 14,
                                ),
                                trailing: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text("$note",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: trailingTextStyle?.copyWith(
                                              fontSize: 12),
                                          textAlign: TextAlign.end),
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.all(EnvoySpacing.xs)),
                                    note.trim().isNotEmpty
                                        ? SvgPicture.asset(
                                            note.trim().isNotEmpty
                                                ? "assets/icons/ic_edit_note.svg"
                                                : "assets/icons/ic_notes.svg",
                                            color:
                                                Theme.of(context).primaryColor,
                                            height: 14,
                                          )
                                        : Icon(Icons.add_circle_rounded,
                                            color: EnvoyColors.accentPrimary,
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
        ),
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
