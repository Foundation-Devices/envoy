// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/business/exchange_rate.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/settings.dart';

import 'envoy_colors.dart';

class AmountEntry extends StatefulWidget {
  final Wallet? wallet;
  final Function(int)? onAmountChanged;
  final int initalSatAmount;

  AmountEntry(
      {this.wallet, this.onAmountChanged, this.initalSatAmount = 0, Key? key})
      : super(key: key);

  @override
  State<AmountEntry> createState() => AmountEntryState();
}

class AmountEntryState extends State<AmountEntry> {
  String _enteredAmount = "";

  get amountSats => Settings().displayUnit == DisplayUnit.btc
      ? convertBtcStringToSats(_enteredAmount)
      : convertSatsStringToSats(_enteredAmount);

  @override
  void initState() {
    super.initState();

    if (widget.initalSatAmount > 0) {
      _enteredAmount = Settings().displayUnit == DisplayUnit.btc
          ? convertSatsToBtcString(widget.initalSatAmount)
          : widget.initalSatAmount.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    Numpad numpad = Numpad();
    numpad.events.stream.listen((event) {
      switch (event) {
        case NumpadEvents.backspace:
          {
            setState(() {
              if (_enteredAmount.length > 0) {
                _enteredAmount =
                    _enteredAmount.substring(0, _enteredAmount.length - 1);
              }
            });
          }
          break;
        case NumpadEvents.dot:
          {
            if (Settings().displayUnit == DisplayUnit.sat) {
              break;
            }

            if (_enteredAmount.isEmpty) {
              setState(() {
                _enteredAmount = "0.";
              });
            }
            if (!_enteredAmount.contains(".")) {
              setState(() {
                _enteredAmount = _enteredAmount + ".";
              });
            }
          }
          break;
        default:
          {
            setState(() {
              if (_enteredAmount == "0") {
                _enteredAmount = event;
              } else {
                _enteredAmount = _enteredAmount + event;
              }
            });
          }
      }

      if (widget.onAmountChanged != null) {
        widget.onAmountChanged!(amountSats);
      }
    });

    return Column(
      children: [
        FittedBox(
            fit: BoxFit.fitWidth,
            child: AmountDisplay.entered(
              _enteredAmount,
            )),
        SizedBox(height: 35),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: numpad,
        )
      ],
    );
  }
}

class AmountDisplay extends StatelessWidget {
  final int? amountSats;
  late final String displayAmountText;

  AmountDisplay.sats(int amount)
      : amountSats = amount,
        displayAmountText = Settings().displayUnit == DisplayUnit.btc
            ? convertSatsToBtcString(amount)
            : getFormattedAmount(amount);

  AmountDisplay.entered(String amountText)
      : amountSats = Settings().displayUnit == DisplayUnit.btc
            ? convertBtcStringToSats(amountText)
            : convertSatsStringToSats(amountText) {
    displayAmountText = Settings().displayUnit == DisplayUnit.btc
        ? amountText
        : getFormattedAmount(amountSats!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayAmountText.isEmpty ? "0" : displayAmountText,
              style: Theme.of(context).textTheme.headline4,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                  Settings().displayUnit == DisplayUnit.btc ? "BTC" : "SATS"),
            )
          ],
        ),
        Text(
          ExchangeRate().getFormattedAmount(amountSats ?? 0),
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: EnvoyColors.darkTeal),
        ),
      ],
    );
  }
}

enum NumpadEvents { dot, ok, backspace }

class Numpad extends StatefulWidget {
  // Dart linter is reporting a false positive here
  // https://github.com/dart-lang/linter/issues/1381
  // Sink is closed on widget disposal
  //ignore: close_sinks
  final StreamController events = StreamController();

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
      children: [
        ...(List.generate(9, (index) {
          String digit = (index + 1).toString();
          return NumpadButton(
            digit,
            onTap: () {
              widget.events.sink.add(digit);
            },
          );
        })),
        Settings().displayUnit == DisplayUnit.btc
            ? NumpadButton(
                ".",
                onTap: () {
                  widget.events.sink.add(NumpadEvents.dot);
                },
              )
            : SizedBox.shrink(),
        NumpadButton(
          "0",
          onTap: () {
            widget.events.sink.add("0");
          },
        ),
        NumpadButton(
          "<",
          onTap: () {
            widget.events.sink.add(NumpadEvents.backspace);
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
  final bool backspace;

  const NumpadButton(this.text,
      {Key? key, required this.onTap, this.backspace = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      // Don't ignore invisible children
      behavior: HitTestBehavior.translucent,

      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EnvoyColors.grey22,
            // gradient: LinearGradient(
            //     begin: Alignment.bottomCenter,
            //     end: Alignment.topCenter,
            //     colors: [EnvoyColors.grey22, EnvoyColors.grey22])
          ),
          child: Center(
              child: !backspace
                  ? NeumorphicText(
                      text,
                      style: NeumorphicStyle(
                        depth: 3,
                        color: Typography.blackHelsinki.headline4!
                            .color, // TODO: add black helsinki as EnvoyColor
                      ),
                      textStyle: NeumorphicTextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 25,
                          fontWeight: FontWeight.w300),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 3, top: 2),
                      child: SvgPicture.asset(
                        "assets/backspace.svg",
                        color: Typography.blackHelsinki.headline4!.color,
                      ),
                    )),
        ),
      ),
    );
  }
}

String convertSatsToBtcString(int amountSats, {bool trailingZeroes = false}) {
  final amountBtc = amountSats / 100000000;

  NumberFormat formatter = NumberFormat();
  formatter.minimumFractionDigits = trailingZeroes ? 8 : 0;
  formatter.maximumFractionDigits = 8;

  return formatter.format(amountBtc);
}

int convertSatsStringToSats(String amountSats) {
  if (amountSats.isEmpty) {
    return 0;
  }
  return int.parse(amountSats);
}

int convertBtcStringToSats(String amountBtc) {
  if (amountBtc.isEmpty) {
    return 0;
  }
  return (double.parse(amountBtc) * 100000000).toInt();
}

String getFormattedAmount(int amountSats, {bool includeUnit = false}) {
  // TODO: this should be locale dependent?
  NumberFormat satsFormatter = NumberFormat("###,###,###,###,###,###,###");

  String text = Settings().displayUnit == DisplayUnit.btc
      ? convertSatsToBtcString(amountSats, trailingZeroes: true) +
          (includeUnit ? " BTC" : "")
      : satsFormatter.format(amountSats) + (includeUnit ? " SATS" : "");

  return text;
}
