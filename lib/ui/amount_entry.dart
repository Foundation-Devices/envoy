// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/ui/amount_display.dart';

enum AmountDisplayUnit { btc, sat, fiat }

class AmountEntry extends ConsumerStatefulWidget {
  final Wallet? wallet;
  final Function(int)? onAmountChanged;
  final int initalSatAmount;

  AmountEntry(
      {this.wallet, this.onAmountChanged, this.initalSatAmount = 0, Key? key})
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
            : ExchangeRate().fiatToSats((_enteredAmount)));
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
    final unit = ref.watch(sendScreenUnitProvider);

    Numpad numpad = Numpad(unit);
    numpad.events.stream.listen((event) {
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
        default:
          {
            // No more than eight decimal digits for BTC
            if (unit == AmountDisplayUnit.btc &&
                _enteredAmount.contains(decimalPoint) &&
                ((_enteredAmount.length -
                        _enteredAmount.indexOf(decimalPoint)) >
                    8)) {
              break;
            }

            // No more than two decimal digits for fiat
            if (unit == AmountDisplayUnit.fiat &&
                _enteredAmount.contains(decimalPoint) &&
                ((_enteredAmount.length -
                        _enteredAmount.indexOf(decimalPoint)) >
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
          (_enteredAmount.contains(decimalPoint));

      bool addDot = (event == NumpadEvents.dot) &&
          (unit != AmountDisplayUnit.sat) &&
          (!_enteredAmount.contains(decimalPoint));

      bool removeZero = (event == NumpadEvents.backspace) &&
          (unit != AmountDisplayUnit.sat) &&
          (_enteredAmount.contains(decimalPoint));

      if (addZero || addDot || removeZero) {
        setState(() {
          _enteredAmount = _enteredAmount + (addDot ? decimalPoint : "");
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
            inputMode: true,
            displayedAmount: _enteredAmount,
            amountSats: _amountSats,
            testnet: widget.wallet?.network == Network.Testnet,
            onUnitToggled: (enteredAmount) {
              // SFT-2508: special rule for circling through is to pad fiat with last 0
              final unit = ref.watch(sendScreenUnitProvider);
              if (unit == AmountDisplayUnit.fiat &&
                  enteredAmount.contains(decimalPoint) &&
                  ((enteredAmount.length -
                          enteredAmount.indexOf(decimalPoint)) ==
                      2)) {
                enteredAmount = enteredAmount + "0";
              }

              _enteredAmount = enteredAmount;
            },
          ),
        ),
        SizedBox(height: 35),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: numpad,
        ),
      ],
    );
  }
}

enum NumpadEvents { dot, ok, backspace, clearAll }

class Numpad extends StatefulWidget {
  // Dart linter is reporting a false positive here
  // https://github.com/dart-lang/linter/issues/1381
  // Sink is closed on widget disposal
  //ignore: close_sinks
  final StreamController events = StreamController();
  late final AmountDisplayUnit amountDisplayUnit;

  Numpad(AmountDisplayUnit amountDisplayUnit) {
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
            digit,
            onTap: () {
              Haptics.lightImpact();
              widget.events.sink.add(digit);
            },
          );
        })),
        widget.amountDisplayUnit != AmountDisplayUnit.sat
            ? NumpadButton(
                decimalPoint,
                onTap: () {
                  Haptics.lightImpact();
                  widget.events.sink.add(NumpadEvents.dot);
                },
              )
            : SizedBox.shrink(),
        NumpadButton(
          "0",
          onTap: () {
            Haptics.lightImpact();
            widget.events.sink.add("0");
          },
        ),
        NumpadButton(
          "<",
          onTap: () {
            Haptics.lightImpact();
            widget.events.sink.add(NumpadEvents.backspace);
          },
          onLongPressDown: () {
            Haptics.lightImpact();
            widget.events.sink.add(NumpadEvents.clearAll);
          },
          backspace: true,
        )
      ],
    );
  }
}

class NumpadButton extends StatelessWidget {
  final String text;
  final void Function() onTap;
  final void Function()? onLongPressDown;
  final bool backspace;

  const NumpadButton(
    this.text, {
    Key? key,
    required this.onTap,
    this.onLongPressDown,
    this.backspace = false,
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
            color: EnvoyColors.grey22,
          ),
          child: Center(
            child: !backspace
                ? Text(
                    text,
                    style: TextStyle(
                      color: Typography.blackHelsinki.headlineMedium!.color,
                      // TODO: add black helsinki as EnvoyColor
                      fontFamily: "Montserrat",
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 3, top: 2),
                    child: SvgPicture.asset(
                      "assets/backspace.svg",
                      color: Typography.blackHelsinki.headlineMedium!.color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
