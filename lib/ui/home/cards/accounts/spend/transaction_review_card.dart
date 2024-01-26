// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_details.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/components/address_widget.dart';

class TransactionReviewCard extends ConsumerStatefulWidget {
  final Psbt psbt;
  final bool psbtFinalized;
  final String address;
  final bool loading;
  final Widget feeChooserWidget;
  final bool hideTxDetailsDialog;
  final String feeTitle;

  const TransactionReviewCard({
    super.key,
    required this.psbt,
    required this.psbtFinalized,
    required this.loading,
    required this.address,
    required this.feeChooserWidget,
    this.hideTxDetailsDialog = false,
    required this.feeTitle,
  });

  @override
  ConsumerState<TransactionReviewCard> createState() =>
      _TransactionReviewCardState();
}

class _TransactionReviewCardState extends ConsumerState<TransactionReviewCard> {
  bool _showFullAddress = false;

  @override
  Widget build(BuildContext context) {
    final spendScreenUnit = ref.watch(sendScreenUnitProvider);
    String address = widget.address;

    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
        color: EnvoyColors.textPrimaryInverse, fontWeight: FontWeight.w700);

    TextStyle? trailingStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
        color: EnvoyColors.textPrimaryInverse,
        fontWeight: FontWeight.w400,
        fontSize: 13);

    /// if user selected unit from the form screen then use that, otherwise use the default
    DisplayUnit unit = spendScreenUnit == AmountDisplayUnit.btc
        ? DisplayUnit.btc
        : DisplayUnit.sat;
    if (spendScreenUnit == AmountDisplayUnit.fiat) {
      unit = Settings().displayUnit;
    }
    AmountDisplayUnit formatUnit =
        unit == DisplayUnit.btc ? AmountDisplayUnit.btc : AmountDisplayUnit.sat;

    final uneconomicSpends = ref.watch(uneconomicSpendsProvider);

    int amount = ref.watch(spendAmountProvider);
    Psbt psbt = widget.psbt;
    // total amount to spend including fee
    int totalSpendAmount = amount + psbt.fee;

    TextStyle contentLeadingStyle =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Color(0xFF808080),
              fontWeight: FontWeight.w400,
              fontSize: 18,
            );
    TextStyle contentTrailingStyle =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Color(0xFF808080),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            );
    Account account = ref.read(selectedAccountProvider)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        color: account.color,
        border:
            Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            gradient: LinearGradient(
              begin: Alignment(0.00, 1.00),
              end: Alignment(0, -1),
              stops: [0, .65, 1],
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.black.withOpacity(0.13),
                Colors.black.withOpacity(0)
              ],
            ),
            border: Border.all(
                width: 2, color: account.color, style: BorderStyle.solid)),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: CustomPaint(
            isComplex: true,
            willChange: false,
            painter: LinesPainter(
                lineDistance: 2.5, color: EnvoyColors.gray1000, opacity: 0.4),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.small, horizontal: EnvoySpacing.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.xs,
                        horizontal: EnvoySpacing.small),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S().coincontrol_tx_detail_amount_to_sent,
                          style: titleStyle,
                        ),
                        Opacity(
                          opacity: widget.hideTxDetailsDialog ? 0 : 1,
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.of(context,rootNavigator: true).push(MaterialTransparentRoute(builder: (context) {
                              //   return SpendTxDetails();
                              // },fullscreenDialog: true));
                              Navigator.of(context, rootNavigator: true).push(
                                  PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return StagingTxDetails();
                                      },
                                      transitionDuration:
                                          Duration(milliseconds: 100),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      opaque: false,
                                      fullscreenDialog: true));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (uneconomicSpends)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: EnvoySpacing.xs),
                                    child: EnvoyIcon(EnvoyIcons.info,
                                        color: EnvoyColors.solidWhite),
                                  ),
                                Text(
                                  S().coincontrol_tx_detail_amount_details,
                                  style: trailingStyle,
                                ),
                                Icon(
                                  Icons.chevron_right_outlined,
                                  color: EnvoyColors.textPrimaryInverse,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  _whiteContainer(
                      child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            alignment: Alignment(0, 0),
                            child: SizedBox.square(
                                dimension: 12,
                                child: SvgPicture.asset(
                                  unit == DisplayUnit.btc
                                      ? "assets/icons/ic_bitcoin_straight.svg"
                                      : "assets/icons/ic_sats.svg",
                                  color: EnvoyColors.textSecondary,
                                )),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(
                                left: unit == DisplayUnit.btc ? 4 : 0,
                                right: unit == DisplayUnit.btc ? 0 : 8),
                            child: Text(
                              "${getFormattedAmount(amount.toInt(), trailingZeroes: true, unit: formatUnit)}",
                              style: contentLeadingStyle,
                            ),
                          ),
                        ],
                      ),
                      Text(
                          ExchangeRate().getFormattedAmount(amount.toInt(),
                              wallet: account.wallet),
                          style: contentTrailingStyle),
                    ],
                  )),
                  Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.xs,
                        horizontal: EnvoySpacing.small),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S().coincontrol_tx_detail_destination,
                          style: titleStyle,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showFullAddress = !_showFullAddress;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                S().coincontrol_tx_detail_destination_details,
                                style: trailingStyle,
                              ),
                              AnimatedRotation(
                                duration: Duration(milliseconds: 200),
                                turns: _showFullAddress ? -.25 : 0,
                                child: Icon(
                                  Icons.chevron_right_outlined,
                                  color: EnvoyColors.textPrimaryInverse,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 120),
                    height: _showFullAddress ? 56 : 44,
                    child: _whiteContainer(
                      child: SingleChildScrollView(
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: AddressWidget(
                            widgetKey: ValueKey<bool>(_showFullAddress),
                            address: address,
                            short: !_showFullAddress,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.xs,
                        horizontal: EnvoySpacing.small),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.feeTitle,
                          style: titleStyle,
                        ),
                        Padding(padding: EdgeInsets.all(12)),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Opacity(
                                opacity: widget.loading ? 1 : 0,
                                child: SizedBox.square(
                                  dimension: 8,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1,
                                    color: EnvoyColors.textPrimaryInverse,
                                  ),
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(4)),
                              Opacity(
                                child: widget.feeChooserWidget,
                                opacity: widget.psbtFinalized ? 0.0 : 1,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  _whiteContainer(
                      child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            alignment: Alignment(0, 0),
                            child: SizedBox.square(
                                dimension: 12,
                                child: SvgPicture.asset(
                                  unit == DisplayUnit.btc
                                      ? "assets/icons/ic_bitcoin_straight.svg"
                                      : "assets/icons/ic_sats.svg",
                                  color: EnvoyColors.textSecondary,
                                )),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: unit == DisplayUnit.btc ? 4 : 0,
                                right: unit == DisplayUnit.btc ? 0 : 8),
                            alignment: Alignment.centerRight,
                            child: Text(
                              getFormattedAmount(psbt.fee, unit: formatUnit),
                              style: contentLeadingStyle,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${ExchangeRate().getFormattedAmount(
                              psbt.fee,
                              wallet: account.wallet,
                            )}",
                            textAlign: unit == DisplayUnit.btc
                                ? TextAlign.start
                                : TextAlign.end,
                            style: contentTrailingStyle,
                          )
                        ],
                      ),
                    ],
                  )),
                  Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.small,
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
                              Icon(
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
                      child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            alignment: Alignment(0, 0),
                            child: SizedBox.square(
                                dimension: 12,
                                child: SvgPicture.asset(
                                  unit == DisplayUnit.btc
                                      ? "assets/icons/ic_bitcoin_straight.svg"
                                      : "assets/icons/ic_sats.svg",
                                  color: EnvoyColors.textSecondary,
                                )),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(
                                left: unit == DisplayUnit.btc ? 4 : 0,
                                right: unit == DisplayUnit.btc ? 0 : 8),
                            child: Text(
                              "${getFormattedAmount(totalSpendAmount, trailingZeroes: true, unit: formatUnit)}",
                              style: contentLeadingStyle,
                            ),
                          ),
                        ],
                      ),
                      Text(
                          ExchangeRate().getFormattedAmount(
                              totalSpendAmount.toInt(),
                              wallet: account.wallet),
                          style: contentTrailingStyle),
                    ],
                  )),
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
      return Container(
        constraints: BoxConstraints(
          minHeight: 44,
        ),
        alignment: Alignment.centerLeft,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(constraints.maxWidth)),
            color: EnvoyColors.textPrimaryInverse),
        padding:
            EdgeInsets.symmetric(vertical: 6, horizontal: EnvoySpacing.small),
        child: child,
      );
    });
  }
}