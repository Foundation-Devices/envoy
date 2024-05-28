// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/business/account.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/locale.dart';

//ignore: must_be_immutable
class AmountDisplay extends ConsumerStatefulWidget {
  final bool inputMode;
  final int? amountSats;
  String displayedAmount;
  final bool testnet;
  final Function? onLongPress;
  final Account? account;

  final Function(String)? onUnitToggled;

  AmountDisplay(
      {this.displayedAmount = "",
      this.amountSats,
      this.onUnitToggled,
      this.testnet = false,
      this.inputMode = false,
      this.onLongPress,
      required this.account,
      super.key});

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
    if (Settings().selectedFiat == null ||
        widget.account?.wallet.network == Network.Testnet) {
      length--;
    }

    if (currentIndex < length - 1) {
      ref.read(sendScreenUnitProvider.notifier).state =
          AmountDisplayUnit.values[currentIndex + 1];
    }
    if (currentIndex >= length - 1) {
      ref.read(sendScreenUnitProvider.notifier).state =
          AmountDisplayUnit.values[0];
    }
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

    bool renderGhostZeros = unit == AmountDisplayUnit.fiat &&
        widget.displayedAmount.contains(fiatDecimalSeparator);

    String ghostDigits = renderGhostZeros
        ? "0" *
            (2 - // TODO: use actual fractions of that fiat (some have as much as 10k -> 4 zeroes)
                (widget.displayedAmount.length -
                    widget.displayedAmount.indexOf(fiatDecimalSeparator) -
                    1))
        : "";

    bool isFormattedAmountEmpty = ExchangeRate().getFormattedAmount(
          widget.amountSats ?? 0,
          wallet: widget.account?.wallet,
        ) ==
        "";

    return TextButton(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: displayIcon(widget.account!, unit),
              ),
              Text(
                  widget.displayedAmount.isEmpty ? "0" : widget.displayedAmount,
                  style: EnvoyTypography.largeAmount
                      .copyWith(color: EnvoyColors.textPrimary)),
              if (renderGhostZeros)
                Text(ghostDigits,
                    style: widget.inputMode
                        ? Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: EnvoyColors.textInactive)
                        : Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          isFormattedAmountEmpty
              ? const SizedBox.shrink()
              : RichText(
                  text: TextSpan(
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: EnvoyColors.accentPrimary, fontSize: 16),
                      children: [
                      if (unit == AmountDisplayUnit.fiat)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: SizedBox(
                              height: 20, child: getUnitIcon(widget.account!)),
                        ),
                      TextSpan(
                        text: unit != AmountDisplayUnit.fiat
                            ? ExchangeRate().getFormattedAmount(
                                widget.amountSats ?? 0,
                                wallet: widget.account?.wallet)
                            : (Settings().displayUnit == DisplayUnit.btc
                                ? getDisplayAmount(
                                    widget.amountSats ?? 0,
                                    AmountDisplayUnit.btc,
                                  )
                                : getDisplayAmount(
                                    widget.amountSats ?? 0,
                                    AmountDisplayUnit.sat,
                                  )),
                      ),
                    ])),
        ],
      ),
      onPressed: () {
        nextUnit();
      },
      onLongPress: () async {
        if (widget.onLongPress != null) {
          widget.onLongPress!();
        }
      },
    );
  }
}
