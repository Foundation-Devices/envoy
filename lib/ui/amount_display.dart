// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/envoy_colors.dart';

//ignore: must_be_immutable
class AmountDisplay extends ConsumerStatefulWidget {
  final int? amountSats;
  String displayedAmount;
  final bool testnet;
  String ghostDecimal;

  final Function(String)? onUnitToggled;

  AmountDisplay(
      {this.displayedAmount = "",
      this.amountSats,
      this.onUnitToggled,
      this.testnet = false,
      this.ghostDecimal = "",
      Key? key})
      : super(key: key);

  void setDisplayAmount(AmountDisplayUnit unit) {
    displayedAmount = getDisplayAmount(amountSats!, unit);
  }

  @override
  ConsumerState<AmountDisplay> createState() => _AmountDisplayState();
}

class _AmountDisplayState extends ConsumerState<AmountDisplay> {
  void nextUnit() {
    var unit = ref.read(sendScreenUnitProvider);

    int currentIndex = unit.index;
    int length = AmountDisplayUnit.values.length;

    // Fiat is always at the end of enum
    if (Settings().selectedFiat == null) {
      length--;
    }

    if (currentIndex < length - 1)
      ref.read(sendScreenUnitProvider.notifier).state =
          AmountDisplayUnit.values[currentIndex + 1];
    if (currentIndex >= length - 1)
      ref.read(sendScreenUnitProvider.notifier).state =
          AmountDisplayUnit.values[0];
  }

  @override
  void initState() {
    widget.setDisplayAmount(ref.read(sendScreenUnitProvider));

    super.initState();
  }

  @override
  Widget build(context) {
    ref.listen(sendScreenUnitProvider, (_, AmountDisplayUnit next) {
      widget.setDisplayAmount(next);

      if (widget.onUnitToggled != null) {
        widget.onUnitToggled!(widget.displayedAmount);
      }
    });

    var unit = ref.watch(sendScreenUnitProvider);

    return TextButton(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  widget.displayedAmount.isEmpty ? "0" : widget.displayedAmount,
                  style: Theme.of(context).textTheme.headlineMedium),
              if (unit == AmountDisplayUnit.fiat &&
                  widget.displayedAmount.contains(decimalPoint))
                Text(widget.ghostDecimal,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: EnvoyColors.grey85)),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  unit == AmountDisplayUnit.btc
                      ? getBtcUnitString(testnet: widget.testnet)
                      : (unit == AmountDisplayUnit.sat
                          ? getSatsUnitString(testnet: widget.testnet)
                          : ExchangeRate().getCode()),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              )
            ],
          ),
          Text(
            unit != AmountDisplayUnit.fiat
                ? ExchangeRate().getFormattedAmount(widget.amountSats ?? 0)
                : (Settings().displayUnit == DisplayUnit.btc
                    ? getDisplayAmount(
                        widget.amountSats ?? 0, AmountDisplayUnit.btc,
                        includeUnit: true, testnet: widget.testnet)
                    : getDisplayAmount(
                        widget.amountSats ?? 0, AmountDisplayUnit.sat,
                        includeUnit: true, testnet: widget.testnet)),
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: EnvoyColors.darkTeal),
          ),
        ],
      ),
      onPressed: () {
        nextUnit();
      },
    );
  }
}
