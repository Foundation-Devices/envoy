// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart' as LegacyColors;
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/tx_note_dialog_widget.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/state/transactions_note_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/amount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class CoinDetailsWidget extends ConsumerStatefulWidget {
  final Coin coin;
  final CoinTag tag;

  const CoinDetailsWidget({super.key, required this.coin, required this.tag});

  @override
  ConsumerState<CoinDetailsWidget> createState() => _CoinDetailsWidgetState();
}

class _CoinDetailsWidgetState extends ConsumerState<CoinDetailsWidget> {
  bool showExpanded = false;

  @override
  Widget build(BuildContext context) {
    Color accountAccentColor = widget.tag.getAccount()?.color ??
        LegacyColors.EnvoyColors.listAccountTileColors[0];
    final accountTransactions =
        ref.read(transactionsProvider(widget.tag.account));
    final tx = accountTransactions
        .firstWhere((element) => element.txId == widget.coin.utxo.txid);
    final localizationTag =
        Localizations.maybeLocaleOf(context)?.toLanguageTag();
    final utxoAddress = tx.outputs?[widget.coin.utxo.vout] ?? "";
    final coinTag = widget.tag;
    final coin = widget.coin;
    final note = ref.watch(txNoteProvider(tx.txId)) ?? "";

    final trailingTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: EnvoyColors.textPrimary,
          fontWeight: FontWeight.w500,
        );

    return Container(
      padding: EdgeInsets.all(8),
      child: AnimatedContainer(
        height: 280,
        duration: Duration(milliseconds: 300),
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
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        color: Colors.white,
                      ),
                      child: CoinBalanceWidget(
                        coin: coin,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CoinTagListItem(
                            title: "Address",
                            icon: SvgPicture.asset(
                              "assets/icons/ic_spend.svg",
                              color: Colors.black,
                              height: 14,
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showExpanded = !showExpanded;
                                });
                              },
                              child: showExpanded
                                  ? SelectableText(
                                      "${utxoAddress}",
                                      style: trailingTextStyle?.copyWith(
                                          color: EnvoyColors.accentPrimary),
                                      textAlign: TextAlign.end,
                                      onTap: () {
                                        setState(() {
                                          showExpanded = !showExpanded;
                                        });
                                      },
                                    )
                                  : Text(
                                      "${truncateWithEllipsisInCenter(utxoAddress, 20)}",
                                      style: trailingTextStyle?.copyWith(
                                          color: EnvoyColors.accentPrimary),
                                      textAlign: TextAlign.end,
                                    ),
                            ),
                          ),
                          CoinTagListItem(
                            title: "Transaction ID",
                            icon: Icon(
                              CupertinoIcons.compass,
                              size: 16,
                              color: Colors.black,
                            ),
                            trailing: LinkText(
                                text:
                                    "${truncateWithEllipsisInCenter("${widget.coin.utxo.txid}", 16)}",
                                onTap: () {},
                                textStyle: trailingTextStyle?.copyWith(
                                    color: EnvoyColors.accentPrimary)),
                          ),
                          CoinTagListItem(
                            title: "Date",
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Colors.black,
                            ),
                            trailing: Text(
                                "${DateFormat.yMd(localizationTag).format(tx.date)} at ${DateFormat.Hm(localizationTag).format(tx.date)}",
                                style: trailingTextStyle),
                          ),
                          CoinTagListItem(
                            title: "Tag",
                            icon: SvgPicture.asset(
                              "assets/icons/ic_tag.svg",
                              color: Colors.black,
                              height: 16,
                            ),
                            trailing: Text("${coinTag.name}",
                                style: trailingTextStyle),
                          ),
                          CoinTagListItem(
                            title: "Status",
                            icon: SvgPicture.asset(
                              "assets/icons/ic_status_icon.svg",
                              color: Colors.black,
                              height: 14,
                            ),
                            trailing: Text(
                                "${tx.isConfirmed ? "Confirmed" : "Pending"} ",
                                style: trailingTextStyle),
                          ),
                          GestureDetector(
                            onTap: () {
                              showEnvoyDialog(
                                  context: context,
                                  dialog: TxNoteDialog(txId: tx.txId),
                                  alignment: Alignment(0.0, -0.8));
                            },
                            child: CoinTagListItem(
                              title: "Notes",
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
                                      padding: EdgeInsets.all(EnvoySpacing.xs)),
                                  SvgPicture.asset(
                                    "assets/icons/ic_edit_note.svg",
                                    color: EnvoyColors.accentPrimary,
                                    height: 14,
                                  ),
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
