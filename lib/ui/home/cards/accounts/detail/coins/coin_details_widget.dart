// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/envoy_tag_list_item.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/components/envoy_info_card.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';

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

    bool addressNotAvailable = utxoAddress.isEmpty;

    return EnvoyInfoCard(
        backgroundColor: accountAccentColor,
        topWidget: CoinBalanceWidget(
          coin: coin,
          coinTag: widget.tag,
        ),
        bottomWidgets: [
          EnvoyInfoCardListItem(
            title: S().coindetails_overlay_address,
            icon: const EnvoyIcon(EnvoyIcons.send,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
            trailing: GestureDetector(
              onTap: () {
                setState(() {
                  showExpandedAddress = !showExpandedAddress;
                  showExpandedTxId = false;
                });
              },
              child: TweenAnimationBuilder(
                  curve: EnvoyEasing.easeInOut,
                  tween:
                      Tween<double>(begin: 0, end: showExpandedAddress ? 1 : 0),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return addressNotAvailable
                        ? Text("Address not available ",
                            // TODO: Figma
                            style: trailingTextStyle)
                        : AddressWidget(
                            widgetKey: ValueKey<bool>(showExpandedAddress),
                            address: utxoAddress,
                            short: true,
                            sideChunks:
                                2 + (value * (utxoAddress.length / 4)).round(),
                          );
                  }),
            ),
          ),
          EnvoyInfoCardListItem(
            title: S().coindetails_overlay_transactionID,
            icon: const EnvoyIcon(EnvoyIcons.compass,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
            trailing: GestureDetector(
                onLongPress: () {
                  copyTxId(context, tx.txId);
                },
                onTap: () {
                  setState(() {
                    showExpandedTxId = !showExpandedTxId;
                    showExpandedAddress = false;
                  });
                },
                child: TweenAnimationBuilder(
                  curve: EnvoyEasing.easeInOut,
                  tween: Tween<double>(begin: 0, end: showExpandedTxId ? 1 : 0),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, value, child) {
                    return Text(
                      truncateWithEllipsisInCenter(
                          widget.coin.utxo.txid,
                          lerpDouble(16, widget.coin.utxo.txid.length, value)!
                              .toInt()),
                      style: EnvoyTypography.info
                          .copyWith(color: EnvoyColors.textPrimary),
                      textAlign: TextAlign.end,
                      maxLines: 4,
                    );
                  },
                )),
          ),
          EnvoyInfoCardListItem(
            title: S().coindetails_overlay_date,
            icon: const EnvoyIcon(EnvoyIcons.calendar,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
            trailing: Text(getTransactionDateAndTimeString(tx),
                style: trailingTextStyle),
          ),
          EnvoyInfoCardListItem(
            title: S().coindetails_overlay_tag,
            icon: const EnvoyIcon(EnvoyIcons.tag,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
            trailing: Text(coinTag.name, style: trailingTextStyle),
          ),
          EnvoyInfoCardListItem(
            title: S().coindetails_overlay_status,
            icon: const EnvoyIcon(EnvoyIcons.activity,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
            trailing:
                Text(getTransactionStatusString(tx), style: trailingTextStyle),
          ),
          GestureDetector(
            onTap: () {
              final navigator = Navigator.of(context);
              showEnvoyDialog(
                  context: context,
                  useRootNavigator: true,
                  dialog: TxNoteDialog(
                    txId: tx.txId,
                    noteTitle: S().add_note_modal_heading,
                    noteHintText: S().add_note_modal_ie_text_field,
                    noteSubTitle: S().add_note_modal_subheading,
                    onAdd: (note) async {
                      await EnvoyStorage().addTxNote(key: tx.txId, note: note);
                      navigator.pop();
                    },
                  ),
                  alignment: const Alignment(0.0, -0.8));
            },
            child: EnvoyInfoCardListItem(
              title: S().coindetails_overlay_notes,
              icon: const EnvoyIcon(
                EnvoyIcons.note,
                size: EnvoyIconSize.small,
                color: EnvoyColors.textPrimary,
              ),
              trailing: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
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
        ]);
  }
}
