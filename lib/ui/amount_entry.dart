// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/util/amount.dart';

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
            : ExchangeRate().fiatToSats((_enteredAmount.replaceAll(",", ""))));
  }

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
        case NumpadEvents.dot:
          {
            if (unit == AmountDisplayUnit.sat) {
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

              // Limit entered amount
              if (_amountSats >= 2.1e15) {
                _enteredAmount =
                    _enteredAmount.substring(0, _enteredAmount.length - 1);
              }
            });
          }
      }

      _amountSats = getAmountSats();

      if (widget.onAmountChanged != null) {
        widget.onAmountChanged!(_amountSats);
      }
    });

    return Column(
      children: [
        FittedBox(
          fit: BoxFit.fitWidth,
          child: AmountDisplay(
            displayedAmount: _enteredAmount,
            amountSats: _amountSats,
            testnet: widget.wallet?.network == Network.Testnet,
            onUnitToggled: (enteredAmount) {
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

//ignore: must_be_immutable
class AmountDisplay extends ConsumerStatefulWidget {
  final int? amountSats;
  String displayedAmount;
  bool testnet;

  final Function(String)? onUnitToggled;

  AmountDisplay(
      {this.displayedAmount = "",
      this.amountSats,
      this.onUnitToggled,
      this.testnet = false});

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
  Widget build(context) {
    ref.listen(sendScreenUnitProvider, (_, next) {
      switch (next) {
        case AmountDisplayUnit.btc:
          widget.displayedAmount = convertSatsToBtcString(widget.amountSats!);
          break;
        case AmountDisplayUnit.sat:
          widget.displayedAmount = widget.amountSats.toString();
          break;
        case AmountDisplayUnit.fiat:
          widget.displayedAmount = ExchangeRate().getSymbol() +
              convertFiatToFiatString(double.parse(ExchangeRate()
                  .getFormattedAmount(widget.amountSats!, includeSymbol: false)
                  .replaceAll(",", "")));
          break;
      }

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
                    ? convertSatsToBtcString(widget.amountSats ?? 0) +
                        " " +
                        getBtcUnitString(testnet: widget.testnet)
                    : widget.amountSats.toString() +
                        " " +
                        getSatsUnitString(testnet: widget.testnet)),
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

enum NumpadEvents { dot, ok, backspace }

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
                ".",
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
          ),
          child: Center(
              child: !backspace
                  ? NeumorphicText(
                      text,
                      style: NeumorphicStyle(
                        depth: 3,
                        color: Typography.blackHelsinki.headlineMedium!
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
                        color: Typography.blackHelsinki.headlineMedium!.color,
                      ),
                    )),
        ),
      ),
    );
  }
}
