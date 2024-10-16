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
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/locale.dart';

enum AmountDisplayUnit { btc, sat, fiat }

class AmountEntry extends ConsumerStatefulWidget {
  final Account? account;
  final Function(int)? onAmountChanged;
  final int initalSatAmount;
  final Function(ParseResult)? onPaste;

  const AmountEntry(
      {this.account,
      this.onAmountChanged,
      this.initalSatAmount = 0,
      this.onPaste,
      super.key});

  @override
  ConsumerState<AmountEntry> createState() => AmountEntryState();
}

class AmountEntryState extends ConsumerState<AmountEntry> {
  String _enteredAmount = "";
  int _amountSats = 0;
  final GlobalKey _fittedBoxKey = GlobalKey();
  double? _fittedBoxHeight;
  bool _addTrailingZeros = true;

  @override
  void initState() {
    super.initState();

    if (widget.initalSatAmount > 0) {
      _amountSats = widget.initalSatAmount;
      _enteredAmount = getDisplayAmount(
          _amountSats, ref.read(sendScreenUnitProvider),
          trailingZeroes: true);
    }

    WidgetsBinding.instance.addPostFrameCallback(_getFittedBoxHeight);
  }

  void _getFittedBoxHeight(Duration _) {
    final context = _fittedBoxKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      setState(() {
        _fittedBoxHeight = box.size.height;
      });
    }
  }

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

    String? text = cdata?.text;
    if (text != null) {
      var decodedInfo = await BitcoinParser.parse(text,
          fiatExchangeRate: ExchangeRate().selectedCurrencyRate,
          wallet: widget.account?.wallet,
          selectedFiat: Settings().selectedFiat,
          currentUnit: unit);
      ref.read(sendScreenUnitProvider.notifier).state =
          decodedInfo.unit ?? unit;

      setState(() {
        unit = decodedInfo.unit ?? unit;
      });

      if (widget.onPaste != null) {
        widget.onPaste!(decodedInfo);
      }
    }
  }

  void onNumPadEvents(dynamic event) {
    TransactionModel tx = ref.read(spendTransactionProvider);
    // Lock numpad while loading after tapping confirm
    if (tx.loading) {
      return;
    }
    var unit = ref.read(sendScreenUnitProvider);
    _addTrailingZeros =
        false; // Do not add trailing zeros when manually typing the amount
    switch (event) {
      case NumPadEvents.backspace:
        {
          setState(() {
            if (_enteredAmount.isNotEmpty) {
              _enteredAmount =
                  _enteredAmount.substring(0, _enteredAmount.length - 1);
            }

            if (_enteredAmount.isEmpty) {
              _enteredAmount = "0";
            }
          });
        }
        break;
      case NumPadEvents.clearAll:
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
      case NumPadEvents.separator:
        {
          if (unit == AmountDisplayUnit.sat) {
            break;
          }
        }
        break;
      case NumPadEvents.clipboard:
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

    bool addDot = (event == NumPadEvents.separator) &&
        (unit == AmountDisplayUnit.fiat &&
                !_enteredAmount.contains(fiatDecimalSeparator) ||
            unit == AmountDisplayUnit.btc &&
                !_enteredAmount.contains(fiatDecimalSeparator));

    bool removeZero = (event == NumPadEvents.backspace) &&
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
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider);
    var unit = ref.watch(sendScreenUnitProvider);

    NumPad numpad = NumPad(unit,
        isAmountZero: _enteredAmount.isEmpty || _enteredAmount == "0",
        onDigitEntered: (digit) {
      onNumPadEvents(digit);
    }, onNumPadEvents: (event) {
      onNumPadEvents(event);
    }, isDecimalSeparator: _enteredAmount.contains(fiatDecimalSeparator));

    return Column(
      children: [
        SizedBox(
          height: _fittedBoxHeight,
          child: FittedBox(
            key: _fittedBoxKey,
            fit: BoxFit.fitWidth,
            child: AmountDisplay(
              account: widget.account,
              inputMode: true,
              displayedAmount: _enteredAmount,
              amountSats: _amountSats,
              onUnitToggled: (enteredAmount) {
                // SFT-2508: special rule for circling through is to pad fiat with last 0
                final unit = ref.watch(sendScreenUnitProvider);
                if (unit == AmountDisplayUnit.fiat &&
                    enteredAmount.contains(fiatDecimalSeparator) &&
                    ((enteredAmount.length -
                            enteredAmount.indexOf(fiatDecimalSeparator)) ==
                        2)) {
                  enteredAmount = "${enteredAmount}0";
                }
                if (_addTrailingZeros && unit == AmountDisplayUnit.btc) {
                  enteredAmount = getDisplayAmount(
                      _amountSats, AmountDisplayUnit.btc,
                      trailingZeroes: true);
                }
                _enteredAmount = enteredAmount;
              },
              onLongPress: () async {
                pasteAmount();
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.sizeOf(context).width <= 390
                ? EnvoySpacing.medium1
                : EnvoySpacing.medium2,
          ),
          child: SpendableAmountWidget(widget.account!),
        ),
        numpad,
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

    String text = isCoinsSelected
        ? S().coincontrol_edit_transaction_selectedAmount
        : S().coincontrol_edit_transaction_available_balance;

    TextStyle textStyle =
        EnvoyTypography.info.copyWith(color: EnvoyColors.textSecondary);

    double infoTextHeight = 15.0;
    TextScaler textScaler = MediaQuery.of(context).textScaler;
    double textHeight = calculateTextHeight(text, textStyle, textScaler);

    bool isBoomerMode = textHeight > infoTextHeight;

    return isBoomerMode
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: textStyle,
              ),
              EnvoyAmount(
                unit: sendScreenUnit,
                amountSats: totalAmount,
                amountWidgetStyle: AmountWidgetStyle.sendScreen,
                account: account,
                alignToEnd: true,
              )
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: textStyle,
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

  double calculateTextHeight(
      String text, TextStyle style, TextScaler textScaler) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    // Apply the text scaling
    return textScaler.scale(textPainter.size.height);
  }
}

enum NumPadEvents { separator, ok, backspace, clearAll, clipboard }

class NumPad extends StatefulWidget {
  // Dart linter is reporting a false positive here
  // https://github.com/dart-lang/linter/issues/1381
  final Function(String digit) onDigitEntered;
  final Function(NumPadEvents event) onNumPadEvents;
  final AmountDisplayUnit amountDisplayUnit;
  final bool isAmountZero;
  final bool isDecimalSeparator;

  const NumPad(this.amountDisplayUnit,
      {super.key,
      required this.isAmountZero,
      required this.onDigitEntered,
      required this.onNumPadEvents,
      required this.isDecimalSeparator});

  @override
  State<NumPad> createState() => _NumPadState();
}

class _NumPadState extends State<NumPad> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width * 0.8;
    //total height of the numpad,only .34 of the screen height will be used by the numpad
    final height = size.height * 0.34;

    const int crossAxisCount = 3;
    final int rowCount = (12 / crossAxisCount).ceil();

    // Calculate the child aspect ratio, based on the width and height
    final childAspectRatio = (width / crossAxisCount) / (height / rowCount);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      // For some reason GridView has a default padding
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...(List.generate(9, (index) {
          String digit = (index + 1).toString();
          return NumpadButton(
            NumpadButtonType.text,
            text: digit,
            onTap: () {
              Haptics.lightImpact();
              widget.onDigitEntered(digit);
            },
          );
        })),
        widget.amountDisplayUnit != AmountDisplayUnit.sat
            ? NumpadButton(
                NumpadButtonType.text,
                text: fiatDecimalSeparator,
                onTap: () {
                  if (!widget.isDecimalSeparator) {
                    Haptics.lightImpact();
                    widget.onNumPadEvents(NumPadEvents.separator);
                  }
                },
              )
            : const SizedBox.shrink(),
        NumpadButton(
          NumpadButtonType.text,
          text: "0",
          onTap: () {
            Haptics.lightImpact();
            widget.onDigitEntered("0");
          },
        ),
        widget.isAmountZero
            ? NumpadButton(
                NumpadButtonType.clipboard,
                onTap: () {
                  Haptics.lightImpact();
                  widget.onNumPadEvents(NumPadEvents.clipboard);
                },
              )
            : NumpadButton(
                NumpadButtonType.backspace,
                onTap: () {
                  Haptics.lightImpact();
                  widget.onNumPadEvents(NumPadEvents.backspace);
                },
                onLongPressDown: () {
                  Haptics.lightImpact();
                  widget.onNumPadEvents(NumPadEvents.clearAll);
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
    super.key,
    required this.onTap,
    this.onLongPressDown,
  });

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
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: EnvoyColors.border2,
          ),
          child: Center(child: () {
            switch (type) {
              case NumpadButtonType.text:
                return Text(
                  text!,
                  style: EnvoyTypography.body
                      .copyWith(
                        fontSize: 24,
                        color: EnvoyColors.textSecondary,
                      )
                      .setWeight(FontWeight.w400),
                );
              case NumpadButtonType.backspace:
                return const Padding(
                    padding: EdgeInsets.only(right: 3, top: 2),
                    child: EnvoyIcon(EnvoyIcons.delete,
                        color: EnvoyColors.accentPrimary));
              case NumpadButtonType.clipboard:
                return const EnvoyIcon(
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
