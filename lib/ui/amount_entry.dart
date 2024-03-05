// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/bitcoin_parser.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_display.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/locale.dart';

enum AmountDisplayUnit { btc, sat, fiat }

class AmountEntry extends ConsumerStatefulWidget {
  final Account? account;
  final Function(int)? onAmountChanged;
  final int initalSatAmount;
  final Function(ParseResult)? onPaste;

  AmountEntry(
      {this.account,
      this.onAmountChanged,
      this.initalSatAmount = 0,
      this.onPaste,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<AmountEntry> createState() => AmountEntryState();
}

class AmountEntryState extends ConsumerState<AmountEntry> {
  String _enteredAmount = "";
  int _amountSats = 0;

  int getAmountSats() {
    final unit = ref.read(sendScreenUnitProvider);
    return unit == AmountDisplayUnit.btc
        ? convertBtcStringToSats(_enteredAmount)
        : (unit == AmountDisplayUnit.sat
            ? convertSatsStringToSats(_enteredAmount)
            : ExchangeRate().convertFiatStringToSats((_enteredAmount)));
  }

  Future<void> pasteAmount() async {
    var unit = ref.read(sendScreenUnitProvider);
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);

    String? text = cdata?.text ?? null;
    var decodedInfo = await BitcoinParser.parse(text,
        fiatExchangeRate: ExchangeRate().selectedCurrencyRate,
        wallet: widget.account?.wallet,
        selectedFiat: Settings().selectedFiat,
        currentUnit: unit);
    ref.read(sendScreenUnitProvider.notifier).state = decodedInfo.unit ?? unit;

    setState(() {
      unit = decodedInfo.unit ?? unit;
    });

    if (widget.onPaste != null) {
      widget.onPaste!(decodedInfo);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.initalSatAmount > 0) {
      _amountSats = widget.initalSatAmount;
      _enteredAmount =
          getDisplayAmount(_amountSats, ref.read(sendScreenUnitProvider));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider);
    var unit = ref.watch(sendScreenUnitProvider);

    Numpad numpad = Numpad(unit,
        isAmountZero: _enteredAmount.isEmpty || _enteredAmount == "0");
    numpad.events.stream.listen((event) async {
      switch (event) {
        case NumpadEvents.backspace:
          {
            setState(() {
              if (_enteredAmount.length > 0) {
                _enteredAmount =
                    _enteredAmount.substring(0, _enteredAmount.length - 1);
              }

              if (_enteredAmount.isEmpty) {
                _enteredAmount = "0";
              }
            });
          }
          break;
        case NumpadEvents.clearAll:
          {
            setState(() {
              _enteredAmount = "0";
              _amountSats = 0;
            });
            if (widget.onAmountChanged != null) {
              widget.onAmountChanged!(0);
            }
          }
          break;
        case NumpadEvents.dot:
          {
            if (unit == AmountDisplayUnit.sat) {
              break;
            }
          }
          break;
        case NumpadEvents.clipboard:
          {
            pasteAmount();
            break;
          }
        default:
          {
            // No more than eight decimal digits for BTC
            if (unit == AmountDisplayUnit.btc &&
                _enteredAmount.contains(fiatDecimalSeparator) &&
                ((_enteredAmount.length -
                        _enteredAmount.indexOf(fiatDecimalSeparator)) >
                    8)) {
              break;
            }

            // No more than two decimal digits for fiat
            if (unit == AmountDisplayUnit.fiat &&
                _enteredAmount.contains(fiatDecimalSeparator) &&
                ((_enteredAmount.length -
                        _enteredAmount.indexOf(fiatDecimalSeparator)) >
                    2)) {
              break;
            }

            setState(() {
              if (_enteredAmount == "0") {
                _enteredAmount = event;
              } else {
                _enteredAmount = _enteredAmount + event;
              }

              // Limit entered amount
              if (_amountSats >= 2.1e15) {
                _enteredAmount =
                    _enteredAmount.substring(0, _enteredAmount.length - 1);
              }
            });
          }
      }

      _amountSats = getAmountSats();

      // Make sure we don't do any formatting in certain situations
      bool addZero = (event == "0") &&
          (unit != AmountDisplayUnit.sat) &&
          (_enteredAmount.contains(fiatDecimalSeparator));

      bool addDot = (event == NumpadEvents.dot) &&
          (unit == AmountDisplayUnit.fiat &&
                  !_enteredAmount.contains(fiatDecimalSeparator) ||
              unit == AmountDisplayUnit.btc &&
                  !_enteredAmount.contains(fiatDecimalSeparator));

      bool removeZero = (event == NumpadEvents.backspace) &&
          (unit != AmountDisplayUnit.sat) &&
          (_enteredAmount.contains(fiatDecimalSeparator));

      if (addZero || addDot || removeZero) {
        setState(() {
          _enteredAmount = _enteredAmount == "" && addDot
              ? "0"
              : (_enteredAmount) + (addDot ? (fiatDecimalSeparator) : "");
        });
      } else {
        // Format it nicely
        setState(() {
          _enteredAmount = getDisplayAmount(_amountSats, unit);
        });
      }

      if (widget.onAmountChanged != null) {
        widget.onAmountChanged!(_amountSats);
      }
    });

    return Column(
      children: [
        FittedBox(
          fit: BoxFit.fitWidth,
          child: AmountDisplay(
            account: widget.account,
            inputMode: true,
            displayedAmount: _enteredAmount,
            amountSats: _amountSats,
            testnet: widget.account?.wallet.network == Network.Testnet,
            onUnitToggled: (enteredAmount) {
              // SFT-2508: special rule for circling through is to pad fiat with last 0
              final unit = ref.watch(sendScreenUnitProvider);
              if (unit == AmountDisplayUnit.fiat &&
                  enteredAmount.contains(fiatDecimalSeparator) &&
                  ((enteredAmount.length -
                          enteredAmount.indexOf(fiatDecimalSeparator)) ==
                      2)) {
                enteredAmount = enteredAmount + "0";
              }
              _enteredAmount = enteredAmount;
            },
            onLongPress: () async {
              pasteAmount();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: SpendableAmountWidget(widget.account!),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: numpad,
        ),
      ],
    );
  }
}

class SpendableAmountWidget extends ConsumerWidget {
  final Account account;

  const SpendableAmountWidget(this.account, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendScreenUnit = ref.watch(sendScreenUnitProvider);
    final totalAmount = ref.watch(totalSpendableAmountProvider);
    final isCoinsSelected = ref.watch(isCoinsSelectedProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isCoinsSelected
              ? S().coincontrol_edit_transaction_selectedAmount
              : S().coincontrol_edit_transaction_available_balance,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: EnvoyColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
        ),
        EnvoyAmount(
          unit: sendScreenUnit,
          amountSats: totalAmount,
          amountWidgetStyle: AmountWidgetStyle.sendScreen,
          account: account,
          alignToEnd: true,
        )
      ],
    );
  }
}

enum NumpadEvents { dot, ok, backspace, clearAll, clipboard }

class Numpad extends StatefulWidget {
  // Dart linter is reporting a false positive here
  // https://github.com/dart-lang/linter/issues/1381
  // Sink is closed on widget disposal
  //ignore: close_sinks
  final StreamController events = StreamController();
  late final AmountDisplayUnit amountDisplayUnit;
  final bool isAmountZero;

  Numpad(AmountDisplayUnit amountDisplayUnit, {required this.isAmountZero}) {
    this.amountDisplayUnit = amountDisplayUnit;
  }

  @override
  State<Numpad> createState() => _NumpadState();
}

class _NumpadState extends State<Numpad> {
  @override
  void dispose() {
    widget.events.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 4 / 3,
      shrinkWrap: true,
      // For some reason GridView has a default padding
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      children: [
        ...(List.generate(9, (index) {
          String digit = (index + 1).toString();
          return NumpadButton(
            NumpadButtonType.text,
            text: digit,
            onTap: () {
              Haptics.lightImpact();
              widget.events.sink.add(digit);
            },
          );
        })),
        widget.amountDisplayUnit != AmountDisplayUnit.sat
            ? NumpadButton(
                NumpadButtonType.text,
                text: fiatDecimalSeparator,
                onTap: () {
                  Haptics.lightImpact();
                  widget.events.sink.add(NumpadEvents.dot);
                },
              )
            : SizedBox.shrink(),
        NumpadButton(
          NumpadButtonType.text,
          text: "0",
          onTap: () {
            Haptics.lightImpact();
            widget.events.sink.add("0");
          },
        ),
        widget.isAmountZero
            ? NumpadButton(
                NumpadButtonType.clipboard,
                onTap: () {
                  Haptics.lightImpact();
                  widget.events.sink.add(NumpadEvents.clipboard);
                },
              )
            : NumpadButton(
                NumpadButtonType.backspace,
                onTap: () {
                  Haptics.lightImpact();
                  widget.events.sink.add(NumpadEvents.backspace);
                },
                onLongPressDown: () {
                  Haptics.lightImpact();
                  widget.events.sink.add(NumpadEvents.clearAll);
                },
              ),
      ],
    );
  }
}

enum NumpadButtonType { text, backspace, clipboard }

class NumpadButton extends StatelessWidget {
  final NumpadButtonType type;
  final String? text;
  final void Function() onTap;
  final void Function()? onLongPressDown;

  const NumpadButton(
    this.type, {
    this.text,
    Key? key,
    required this.onTap,
    this.onLongPressDown,
  }) : super(key: key);

  void _handleLongPress() {
    // Check if onLongPressDown is provided and call it if it is
    if (onLongPressDown != null) {
      onLongPressDown!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: _handleLongPress,
      // Don't ignore invisible children
      behavior: HitTestBehavior.translucent,

      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EnvoyColors.border2,
          ),
          child: Center(child: () {
            switch (type) {
              case NumpadButtonType.text:
                return Text(
                  text!,
                  style: TextStyle(
                    color: Typography.blackHelsinki.headlineMedium!.color,
                    // TODO: change to EnvoyColors and font
                    fontFamily: "Montserrat",
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                );
              case NumpadButtonType.backspace:
                return Padding(
                    padding: const EdgeInsets.only(right: 3, top: 2),
                    child: EnvoyIcon(EnvoyIcons.delete,
                        color: EnvoyColors.accentPrimary));
              case NumpadButtonType.clipboard:
                return EnvoyIcon(
                  EnvoyIcons.clipboard,
                  color: EnvoyColors.accentPrimary,
                );
            }
          }()),
        ),
      ),
    );
  }
}
