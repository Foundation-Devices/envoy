// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/ui/components/stripe_painter.dart';

class TransactionReviewCard extends ConsumerStatefulWidget {
  final Psbt psbt;
  final bool psbtFinalized;
  final String address;
  final bool loading;
  final int? amountToSend;
  final Widget feeChooserWidget;
  final bool hideTxDetailsDialog;
  final GestureTapCallback onTxDetailTap;
  final String feeTitle;

  const TransactionReviewCard({
    super.key,
    required this.psbt,
    required this.psbtFinalized,
    required this.loading,
    required this.address,
    //for RBF spend screen
    this.amountToSend,
    required this.onTxDetailTap,
    required this.feeChooserWidget,
    this.hideTxDetailsDialog = false,
    required this.feeTitle,
  });

  @override
  ConsumerState<TransactionReviewCard> createState() =>
      _TransactionReviewCardState();
}

class _TransactionReviewCardState extends ConsumerState<TransactionReviewCard> {
  @override
  Widget build(BuildContext context) {
    String address = widget.address;
    const double cardRadius = EnvoySpacing.medium2;

    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
        color: EnvoyColors.textPrimaryInverse, fontWeight: FontWeight.w700);

    TextStyle? trailingStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
        color: EnvoyColors.textPrimaryInverse,
        fontWeight: FontWeight.w400,
        fontSize: 13);

    final uneconomicSpends = ref.watch(uneconomicSpendsProvider);

    // send amount is passed as a prop to the widget, use that if available
    int amount = widget.amountToSend ??
        ref.watch(spendTransactionProvider.select((value) => value.amount));

    Psbt psbt = widget.psbt;
    // total amount to spend including fee
    int totalSpendAmount = amount + psbt.fee;

    Account account = ref.read(selectedAccountProvider)!;

    final sendScreenUnit = ref.watch(sendScreenUnitProvider);

    /// if user selected unit from the form screen then use that, otherwise use the default
    DisplayUnit unit = sendScreenUnit == AmountDisplayUnit.btc
        ? DisplayUnit.btc
        : DisplayUnit.sat;

    if (sendScreenUnit == AmountDisplayUnit.fiat) {
      unit = Settings().displayUnit;
    }

    AmountDisplayUnit formatUnit =
        unit == DisplayUnit.btc ? AmountDisplayUnit.btc : AmountDisplayUnit.sat;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(cardRadius - 1)),
        color: account.color,
        border:
            Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.all(Radius.circular(cardRadius - 3)),
            gradient: LinearGradient(
              begin: const Alignment(0.00, 1.00),
              end: const Alignment(0, -1),
              stops: const [0, .65, 1],
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.13),
                Colors.black.withOpacity(0)
              ],
            ),
            border: Border.all(
                width: 2, color: account.color, style: BorderStyle.solid)),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(cardRadius - 4)),
          child: CustomPaint(
            isComplex: true,
            willChange: false,
            painter: StripePainter(
              EnvoyColors.gray1000.withOpacity(0.4),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: EnvoySpacing.small,
                  right: EnvoySpacing.small,
                  top: EnvoySpacing.small),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: EnvoySpacing.xs,
                        bottom: EnvoySpacing.xs,
                        left: EnvoySpacing.small),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S().coincontrol_tx_detail_amount_to_sent,
                          style: titleStyle,
                        ),
                        GestureDetector(
                          onTap: widget.onTxDetailTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (uneconomicSpends)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: EnvoySpacing.xs),
                                  child: EnvoyIcon(EnvoyIcons.alert,
                                      size: EnvoyIconSize.small,
                                      color: EnvoyColors.solidWhite),
                                ),
                              Text(
                                S().coincontrol_tx_detail_amount_details,
                                style: trailingStyle,
                              ),
                              const Icon(
                                Icons.chevron_right_outlined,
                                color: EnvoyColors.textPrimaryInverse,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  _whiteContainer(
                      child: EnvoyAmount(
                          account: account,
                          unit: formatUnit,
                          amountSats: amount,
                          amountWidgetStyle: AmountWidgetStyle.singleLine)),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: EnvoySpacing.xs,
                        bottom: EnvoySpacing.xs,
                        left: EnvoySpacing.small),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S().coincontrol_tx_detail_destination,
                          style: titleStyle,
                        ),
                      ],
                    ),
                  ),
                  TweenAnimationBuilder(
                      curve: EnvoyEasing.easeInOut,
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            child: _whiteContainer(
                                child: AddressWidget(
                              align: TextAlign.start,
                              address: address,
                              short: true,
                              sideChunks:
                                  2 + (value * (address.length / 4)).round(),
                            )));
                      }),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: EnvoySpacing.xs,
                        bottom: EnvoySpacing.xs,
                        left: EnvoySpacing.small),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.feeTitle,
                          style: titleStyle,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Opacity(
                                opacity: widget.loading ? 1 : 0,
                                child: const SizedBox.square(
                                  dimension: 8,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1,
                                    color: EnvoyColors.textPrimaryInverse,
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(4)),
                              Opacity(
                                opacity: widget.psbtFinalized ? 0.0 : 1,
                                child: IgnorePointer(
                                  ignoring: widget.psbtFinalized,
                                  child: widget.feeChooserWidget,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  _whiteContainer(
                      child: EnvoyAmount(
                          unit: formatUnit,
                          account: account,
                          amountSats: psbt.fee,
                          amountWidgetStyle: AmountWidgetStyle.singleLine)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.xs,
                        horizontal: EnvoySpacing.small),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S().coincontrol_tx_detail_total,
                          style: titleStyle,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: EnvoyColors.textPrimaryInverse,
                              ),
                              Consumer(builder: (context, ref, child) {
                                final spendTimeEstimationProvider =
                                    ref.watch(spendEstimatedBlockTimeProvider);
                                return Text(
                                  " $spendTimeEstimationProvider min",
                                  //TODO: figma
                                  style: trailingStyle,
                                );
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  _whiteContainer(
                      child: EnvoyAmount(
                          account: account,
                          unit: formatUnit,
                          amountSats: totalSpendAmount,
                          amountWidgetStyle: AmountWidgetStyle.singleLine)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _whiteContainer({required Widget child}) {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.small),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 32,
          ),
          alignment: Alignment.centerLeft,
          width: double.infinity,
          decoration: const BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(EnvoySpacing.medium1)),
              color: EnvoyColors.textPrimaryInverse),
          padding: const EdgeInsets.symmetric(
              vertical: 6, horizontal: EnvoySpacing.small),
          child: child,
        ),
      );
    });
  }
}
