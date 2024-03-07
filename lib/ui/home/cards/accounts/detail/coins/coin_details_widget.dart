// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart' as old_colors;
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/tx_note_dialog_widget.dart';
import 'package:envoy/ui/state/transactions_note_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';
import 'package:envoy/ui/components/address_widget.dart';

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
        old_colors.EnvoyColors.listAccountTileColors[0];
    final accountTransactions =
        ref.read(transactionsProvider(widget.tag.account));
    final tx = accountTransactions
        .firstWhereOrNull((element) => element.txId == widget.coin.utxo.txid);
    //if tx is not found in the list of transactions,
    if (tx == null) {
      return Container();
    }
    final utxoAddress = tx.outputs?[widget.coin.utxo.vout] ?? "";
    final coinTag = widget.tag;
    final coin = widget.coin;
    final note = ref.watch(txNoteProvider(tx.txId)) ?? "";

    final trailingTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: EnvoyColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    if (coinTag.untagged) {
      accountAccentColor = const Color(0xff808080);
    }

    double cardRadius = 26;

    return Container(
      padding: const EdgeInsets.all(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
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
              borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
              border: Border.all(
                  color: accountAccentColor,
                  width: 2,
                  style: BorderStyle.solid)),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(cardRadius - 2)),
              child: StripesBackground(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(EnvoySpacing.medium2)),
                        color: Colors.white,
                      ),
                      child: CoinBalanceWidget(
                        coin: coin,
                      ),
                    ),
                    Flexible(
                        child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        color: Colors.white,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          coinTagListItem(
                            title: S().coindetails_overlay_address,
                            icon: SvgPicture.asset(
                              "assets/icons/ic_spend.svg",
                              color: Colors.black,
                              height: 14,
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showExpandedAddress = !showExpandedAddress;
                                  showExpandedTxId = false;
                                });
                              },
                              child: SingleChildScrollView(
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: AddressWidget(
                                    widgetKey:
                                        ValueKey<bool>(showExpandedAddress),
                                    address: utxoAddress,
                                    short: !showExpandedAddress,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          coinTagListItem(
                            title: S().coindetails_overlay_transactionID,
                            icon: const Icon(
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
                                      begin: 0, end: showExpandedTxId ? 1 : 0),
                                  duration: const Duration(milliseconds: 200),
                                  builder: (context, value, child) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: EnvoySpacing.small),
                                      child: SelectableText(
                                        truncateWithEllipsisInCenter(
                                            widget.coin.utxo.txid,
                                            lerpDouble(
                                                    16,
                                                    widget
                                                        .coin.utxo.txid.length,
                                                    value)!
                                                .toInt()),
                                        style: EnvoyTypography.info
                                            .copyWith(color: Colors.black),
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
                                      ),
                                    );
                                  },
                                )),
                          ),
                          coinTagListItem(
                            title: S().coindetails_overlay_date,
                            icon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Colors.black,
                            ),
                            trailing: Text(getTransactionDateAndTimeString(tx),
                                style: trailingTextStyle),
                          ),
                          coinTagListItem(
                            title: S().coindetails_overlay_tag,
                            icon: SvgPicture.asset(
                              "assets/icons/ic_tag.svg",
                              color: Colors.black,
                              height: 16,
                            ),
                            trailing:
                                Text(coinTag.name, style: trailingTextStyle),
                          ),
                          coinTagListItem(
                            title: S().coindetails_overlay_status,
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
                              final navigator =  Navigator.of(context);
                              showEnvoyDialog(
                                  context: context,
                                  useRootNavigator: true,
                                  dialog: TxNoteDialog(
                                    txId: tx.txId,
                                    noteTitle: S().add_note_modal_heading,
                                    noteHintText:
                                        S().add_note_modal_ie_text_field,
                                    noteSubTitle: S().add_note_modal_subheading,
                                    onAdd: (note) async {
                                      await EnvoyStorage()
                                          .addTxNote(note, tx.txId);
                                      navigator.pop();
                                    },
                                  ),
                                  alignment: const Alignment(0.0, -0.8));
                            },
                            child: coinTagListItem(
                              title: S().coindetails_overlay_notes,
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
                                    child: Text(note,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: trailingTextStyle?.copyWith(
                                            fontSize: 12),
                                        textAlign: TextAlign.end),
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.all(EnvoySpacing.xs)),
                                  note.trim().isNotEmpty
                                      ? SvgPicture.asset(
                                          note.trim().isNotEmpty
                                              ? "assets/icons/ic_edit_note.svg"
                                              : "assets/icons/ic_notes.svg",
                                          color: Theme.of(context).primaryColor,
                                          height: 14,
                                        )
                                      : const Icon(Icons.add_circle_rounded,
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
    );
  }

  Widget coinTagListItem(
      {required String title,
      required Widget icon,
      required Widget trailing,
      Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.small),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: EnvoySpacing.xs),
                  child: icon,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: EnvoySpacing.xs),
                    child: Text(
                      title,
                      style: EnvoyTypography.body
                          .copyWith(color: color ?? EnvoyColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
              flex: 6,
              child: Container(
                alignment: Alignment.centerRight,
                child: trailing,
              )),
        ],
      ),
    );
  }
}
