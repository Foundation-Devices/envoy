// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_notifier.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/state/send_unit_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/ui/home/cards/accounts/spend/fee_slider.dart';

class TransactionReviewCard extends ConsumerStatefulWidget {
  final BitcoinTransaction transaction;
  final bool canModifyPsbt;
  final String address;
  final bool loading;
  final int? amountToSend;
  final Function? onFeeTap;
  final GestureTapCallback onTxDetailTap;
  final EnvoyAccount account;

  const TransactionReviewCard({
    super.key,
    required this.transaction,
    required this.canModifyPsbt,
    required this.loading,
    required this.address,
    required this.account,
    //for RBF spend screen
    this.amountToSend,
    required this.onTxDetailTap,
    this.onFeeTap,
  });

  @override
  ConsumerState<TransactionReviewCard> createState() =>
      _TransactionReviewCardState();
}

class _TransactionReviewCardState extends ConsumerState<TransactionReviewCard> {
  @override
  Widget build(BuildContext context) {
    String address = widget.address;

    // send amount is passed as a prop to the widget, use that if available

    BitcoinTransaction transaction = widget.transaction;
    //transaction amount will be negative since it is a spend transaction,
    //but for display purposes we want to show the absolute value
    int amount = transaction.amount.abs();
    if (widget.amountToSend != null) {
      amount = widget.amountToSend!;
    }
    // total amount to spend including fee
    int totalSpendAmount = amount + transaction.fee.toInt();

    TransactionModel transactionModel = ref.watch(spendTransactionProvider);

    final s = Settings();

    /// Leave total as it is (total will be visible after sending)
    double displayFiatTotalAmount =
        ExchangeRate().convertSatsToFiat(totalSpendAmount);

    double? displayFiatSendAmount;
    double? displayFiatFeeAmount;

    if (s.displayFiat() != null) {
      if (transactionModel.mode == SpendMode.sendMax) {
        displayFiatFeeAmount =
            ExchangeRate().convertSatsToFiat(transaction.fee.toInt());
        displayFiatSendAmount = displayFiatTotalAmount - displayFiatFeeAmount;
      } else {
        displayFiatFeeAmount =
            displayFiatTotalAmount - ExchangeRate().convertSatsToFiat(amount);
      }
    }

    final sendScreenUnit = ref.watch(sendUnitProvider);

    /// if user selected unit from the form screen then use that, otherwise use the default
    DisplayUnit unit = sendScreenUnit == AmountDisplayUnit.btc
        ? DisplayUnit.btc
        : DisplayUnit.sat;

    if (sendScreenUnit == AmountDisplayUnit.fiat) {
      unit = Settings().displayUnit;
    }

    AmountDisplayUnit formatUnit =
        unit == DisplayUnit.btc ? AmountDisplayUnit.btc : AmountDisplayUnit.sat;

    // RBFSpendState? rbfSpendState = ref.read(rbfSpendStateProvider);
    // BitcoinTransaction? originalTx = rbfSpendState?.originalTx;

    final spendTimeEstimationProvider =
        ref.watch(spendEstimatedBlockTimeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.all(Radius.circular(EnvoySpacing.medium2)),
            border: Border.all(
                color: EnvoyColors.border2, width: 1, style: BorderStyle.solid),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
            child: Column(
              children: [
                infoState(
                    EnvoyIcons.utxo,
                    S().send_build_amount,
                    EnvoyAmount(
                        unit: formatUnit,
                        account: widget.account,
                        amountSats: widget.transaction.amount.toInt().abs(),
                        displayFiatAmount: displayFiatSendAmount,
                        millionaireMode: false,
                        amountWidgetStyle: AmountWidgetStyle.normal,
                        semanticSuffix: "Amount")),
                _divider(),
                infoState(
                    EnvoyIcons.wallet_coin,
                    S().coincontrol_tx_detail_destination,
                    AddressWidget(
                      address: address,
                      short: false,
                      sideChunks: 2 + ((address.length / 4)).round(),
                    )),
                _divider(),
                infoState(
                    EnvoyIcons.fee,
                    "${S().coincontrol_tx_detail_fee} - ${selectedFeeLabel(ref)}",
                    subtitle: spendTimeEstimationProvider,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        EnvoyAmount(
                            unit: formatUnit,
                            account: widget.account,
                            amountSats: transaction.fee.toInt(),
                            displayFiatAmount: displayFiatFeeAmount,
                            millionaireMode: false,
                            amountWidgetStyle: AmountWidgetStyle.normal,
                            semanticSuffix: "Fee"),
                        if (widget.onFeeTap != null)
                          GestureDetector(
                            onTap: () {
                              widget.onFeeTap!();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: EnvoySpacing.xs),
                              child: EnvoyIcon(EnvoyIcons.chevron_right),
                            ),
                          ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        SizedBox(
          height: EnvoySpacing.medium1,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.all(Radius.circular(EnvoySpacing.medium2)),
            border: Border.all(
                color: EnvoyColors.border2, width: 1, style: BorderStyle.solid),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
            child: infoState(
                EnvoyIcons.receipt,
                S().coincontrol_tx_detail_total,
                EnvoyAmount(
                    account: widget.account,
                    unit: formatUnit,
                    amountSats: transaction.amount.toInt().abs() +
                        transaction.fee.toInt(),
                    displayFiatAmount: displayFiatTotalAmount,
                    millionaireMode: false,
                    amountWidgetStyle: AmountWidgetStyle.normal,
                    semanticSuffix: "Total")),
          ),
        ),
      ],
    );
  }

  Widget infoState(EnvoyIcons icon, String title, Widget trailing,
      {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.medium2, horizontal: EnvoySpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: EnvoySpacing.small),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    EnvoyIcon(icon),
                    SizedBox(width: EnvoySpacing.xs),
                    Text(
                      title,
                      style: EnvoyTypography.body
                          .copyWith(color: EnvoyColors.textPrimary),
                    )
                  ],
                ),
                if (subtitle != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: EnvoySpacing.medium2 + EnvoySpacing.xs),
                      Text(subtitle,
                          style: EnvoyTypography.info
                              .copyWith(color: EnvoyColors.textTertiary)),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(child: trailing)
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: EnvoyColors.border2,
    );
  }
}
