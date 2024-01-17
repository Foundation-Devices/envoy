// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:intl/intl.dart';
import 'package:envoy/business/locale.dart';

class AmountWidget extends StatelessWidget {
  final int amountSats;
  final AmountDisplayUnit unit;
  final bool decimalDot;
  final String symbolFiat;
  final double fxRateFiat;

  AmountWidget({
    required this.amountSats,
    required this.unit,
    this.symbolFiat = "",
    this.fxRateFiat = 0.0,
    this.decimalDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomWidgetUnit = unit == AmountDisplayUnit.fiat
        ? AmountDisplayUnit.btc
        : AmountDisplayUnit.fiat;
    return Column(
      children: [
        LargeAmountWidget(
            unit: unit,
            amountSats: amountSats,
            decimalDot: decimalDot,
            symbolFiat: symbolFiat,
            fxRateFiat: fxRateFiat),
        SmallAmountWidget(
            unit: bottomWidgetUnit,
            amountSats: amountSats,
            symbolFiat: symbolFiat,
            fxRateFiat: fxRateFiat,
            decimalDot: decimalDot),
      ],
    );
  }
}

class SmallAmountWidget extends StatelessWidget {
  final AmountDisplayUnit unit;
  final int amountSats;
  final String symbolFiat;
  final double fxRateFiat;
  final bool decimalDot;

  final EnvoyIcons iconBtc = EnvoyIcons.btc;

  final TextStyle textStyle = EnvoyTypography.info.copyWith(
      color: EnvoyColors.accentPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w500);

  final TextStyle textStyleFiatSymbol = EnvoyTypography.body.copyWith(
      color: EnvoyColors.accentPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w500);

  SmallAmountWidget({
    super.key,
    required this.unit,
    required this.amountSats,
    this.symbolFiat = "",
    this.fxRateFiat = 0.0,
    this.decimalDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: unit == AmountDisplayUnit.btc
                ? EnvoyIcon(
                    iconBtc,
                    size: EnvoyIconSize.superSmall,
                    color: EnvoyColors.accentPrimary,
                  )
                : Text(
                    symbolFiat,
                    style: textStyleFiatSymbol,
                  )),
        RichText(
          text: TextSpan(
              children: unit == AmountDisplayUnit.fiat
                  ? buildFiatTextSpans(
                      amountSats, fxRateFiat, decimalDot, textStyle)
                  : _buildBtcLowerTextSpans(
                      amountSats, decimalDot, textStyle, textStyle)),
        ),
      ],
    );
  }
}

class LargeAmountWidget extends StatelessWidget {
  final AmountDisplayUnit unit;
  final int amountSats;
  final bool decimalDot;
  final String symbolFiat;
  final double fxRateFiat;

  final TextStyle textStyleBlack = EnvoyTypography.largeAmount.copyWith(
    color: EnvoyColors.textPrimary,
  );

  final TextStyle textStyleGray =
      EnvoyTypography.largeAmount.copyWith(color: EnvoyColors.textTertiary);

  final TextStyle textStyleSpaceBlack =
      EnvoyTypography.largeAmount.copyWith(fontSize: 24);

  final EnvoyIcons iconBtc = EnvoyIcons.btc;
  final EnvoyIcons iconSat = EnvoyIcons.sats;

  final TextStyle textStyleFiatSymbol = EnvoyTypography.body.copyWith(
      color: EnvoyColors.textPrimary,
      fontSize: 24,
      fontWeight: FontWeight.w500);

  LargeAmountWidget({
    super.key,
    required this.unit,
    required this.amountSats,
    this.decimalDot = true,
    this.symbolFiat = "",
    this.fxRateFiat = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: unit == AmountDisplayUnit.fiat
                ? Text(
                    symbolFiat,
                    style: textStyleFiatSymbol,
                  )
                : EnvoyIcon(
                    unit == AmountDisplayUnit.btc ? iconBtc : iconSat,
                    size: EnvoyIconSize.normal,
                  )),
        RichText(
          text: TextSpan(
            children: unit == AmountDisplayUnit.btc
                ? buildLargeBtcTextSpans(amountSats, decimalDot, textStyleBlack,
                    textStyleGray, textStyleSpaceBlack)
                : unit == AmountDisplayUnit.fiat
                    ? buildLargeFiatTextSpans(amountSats, fxRateFiat,
                        decimalDot, textStyleBlack, textStyleGray)
                    : buildLargeSatsTextSpans(
                        amountSats, decimalDot, textStyleBlack, textStyleGray),
          ),
        ),
      ],
    );
  }
}

List<TextSpan> buildLargeBtcTextSpans(
    int amountSats,
    bool decimalDot,
    TextStyle? textStyleBlack,
    TextStyle? textStyleGray,
    TextStyle? textStyleSpace) {
  List<TextSpan> textSpans = [];
  String btcString = convertSatsToBtcString(amountSats);
  double amountBTC = convertSatsToBTC(amountSats);
  bool isAmountBtcUnder1 = amountBTC < 1;

  if (isAmountBtcUnder1) {
    bool foundNum = false;

    for (int i = 0; i < btcString.length; i++) {
      String char = btcString[i];

      if (i == 0) {
        textSpans.add(_createTextSpan(char, textStyleGray!));
      } else {
        if (char == '.') {
          textSpans.add(_createTextSpan(char, textStyleGray!));
        } else if (char != '0') {
          foundNum = true;
          textSpans.add(_createTextSpan(char, textStyleBlack!));
        } else {
          if (foundNum) {
            textSpans.add(_createTextSpan(char, textStyleBlack!));
          } else {
            textSpans.add(_createTextSpan(char, textStyleGray!));
          }
        }
      }
    }
  }

  if (!isAmountBtcUnder1) {
    bool foundDot = false;
    bool foundNum = false;
    bool foundComma = false;

    for (int i = 0; i < btcString.length; i++) {
      String char = btcString[i];

      if (int.tryParse(char) != null) {
        foundNum = true;
      }
      if (char == '.') {
        foundDot = true;
        foundNum = false;
      }
      if (char == ',') {
        foundComma = true;
        foundNum = false;
      }
      if (foundNum && foundDot && foundComma) {
        textSpans.add(_createTextSpan(char, textStyleGray!));
      } else {
        textSpans.add(_createTextSpan(char, textStyleBlack!));
      }
    }
  }
  ;

  return changeDecimalMark(
      AmountDisplayUnit.btc,
      decimalDot,
      isAmountBtcUnder1,
      buildTextSpansWithSpaces(isAmountBtcUnder1, textSpans, textStyleSpace),
      textStyleBlack,
      textStyleGray);
}

List<TextSpan> buildTextSpansWithSpaces(bool isAmountBtcUnder1,
    List<TextSpan> textSpans, TextStyle? textStyleSpace) {
  List<TextSpan> textSpansWithSpaces = [];

  if (isAmountBtcUnder1) {
    int numCount = 0;
    for (int i = 0; i < textSpans.length; i++) {
      TextSpan char = textSpans[i];

      if (i == 0 || char.text == '.') {
        textSpansWithSpaces.add(char);
        if (char.text != '.') {
          numCount++;
        }
      } else {
        numCount++;
        textSpansWithSpaces.add(char);
        if (numCount % 3 == 0) {
          textSpansWithSpaces.add(_createTextSpan(' ', textStyleSpace!));
        }
      }
    }
  }
  if (!isAmountBtcUnder1) {
    int numCountAfterDot = 0;
    bool foundDot = false;

    for (int i = 0; i < textSpans.length; i++) {
      TextSpan char = textSpans[i];

      if (char.text == '.') {
        foundDot = true;
        numCountAfterDot = 0;
        textSpansWithSpaces.add(char);
      } else if (foundDot) {
        textSpansWithSpaces.add(char);
        numCountAfterDot++;

        if (numCountAfterDot == 2) {
          textSpansWithSpaces.add(_createTextSpan(' ', textStyleSpace!));
        } else if ((numCountAfterDot - 2) % 3 == 0) {
          textSpansWithSpaces.add(_createTextSpan(' ', textStyleSpace!));
        }
      } else {
        textSpansWithSpaces.add(char);
      }
    }
  }

  return textSpansWithSpaces;
}

List<TextSpan> buildLargeSatsTextSpans(int amountSats, bool decimalDot,
    TextStyle? textStyleBlack, TextStyle? textStyleGray) {
  List<TextSpan> textSpans = [];
  String satsString = amountSats.toString();

  // Reverse the string to make it easier to insert commas from the right
  satsString = satsString.split('').reversed.join();

  for (int i = 0; i < satsString.length; i++) {
    String char = satsString[i];
    textSpans.add(_createTextSpan(char, textStyleBlack!));

    // Insert commas after every three digits
    if (i % 3 == 2 && i != satsString.length - 1) {
      textSpans.add(_createTextSpan(',', textStyleBlack));
    }
  }

  // Reverse the list to get the original order
  textSpans = textSpans.reversed.toList();

  return changeDecimalMark(
      AmountDisplayUnit.sat,
      decimalDot,
      false, // place false here if not BTC or if the BTC < 1
      textSpans,
      textStyleBlack,
      textStyleGray);
}

List<TextSpan> buildLargeFiatTextSpans(int amountSats, double fxRateFiat,
    bool decimalDot, TextStyle? textStyleBlack, TextStyle? textStyleGray) {
  List<TextSpan> textSpans = [];

  double amountValue = convertSatsToFiat(amountSats, fxRateFiat);
  String amountValueString = convertSatsToFiatString(amountSats, fxRateFiat);

  if (amountValue >= 1000000000) {
    // Convert to billions and round to 1 decimal point
    double valueInBillion = amountValue / 1000000000.0;
    String formattedValue = valueInBillion.toStringAsFixed(1) + ' B';
    textSpans.add(_createTextSpan(formattedValue, textStyleBlack!));
  } else if (amountValue >= 1000000) {
    // Convert to millions and round to 1 decimal point
    double valueInMillion = amountValue / 1000000.0;
    String formattedValue = valueInMillion.toStringAsFixed(1) + ' M';
    textSpans.add(_createTextSpan(formattedValue, textStyleBlack!));
  } else {
    // Display the original amount
    for (int i = 0; i < amountValueString.length; i++) {
      String char = amountValueString[i];
      textSpans.add(_createTextSpan(char, textStyleBlack!));
    }
  }

  return changeDecimalMark(AmountDisplayUnit.fiat, decimalDot, false, textSpans,
      textStyleBlack, textStyleGray);
}

List<TextSpan> buildFiatTextSpans(int amountSats, double fxRateFiat,
    bool decimalDot, TextStyle? textStyleTeal) {
  List<TextSpan> textSpans = [];

  String amountFiat = convertSatsToFiatString(amountSats, fxRateFiat);

  for (int i = 0; i < amountFiat.length; i++) {
    String char = amountFiat[i];
    textSpans.add(_createTextSpan(char, textStyleTeal!));
  }

  return changeDecimalMark(
      AmountDisplayUnit.fiat,
      decimalDot,
      false, // place false here if not BTC or if the BTC < 1
      textSpans,
      textStyleTeal,
      textStyleTeal); // no secondary color for lower number
}

List<TextSpan> _buildBtcLowerTextSpans(int amountSats, bool decimalDot,
    TextStyle? textStyleTeal, TextStyle? textStyleSpaceTeal) {
  List<TextSpan> textSpans = [];
  double amountBTC = convertSatsToBTC(amountSats);
  bool isAmountBtcUnder1 = amountBTC < 1;

  String stringBtcAmount = convertSatsToBtcString(amountSats);

  // Add characters to textSpans without commas
  for (int i = 0; i < stringBtcAmount.length; i++) {
    String char = stringBtcAmount[i];
    if (char == ',') {
      textSpans.add(_createTextSpan(' ', textStyleTeal!));
    } else {
      textSpans.add(_createTextSpan(char, textStyleTeal!));
    }
  }

  return changeDecimalMark(
      AmountDisplayUnit.btc,
      decimalDot,
      false, // it is false because it does not matter for the lower number
      buildTextSpansWithSpaces(
          isAmountBtcUnder1, textSpans, textStyleSpaceTeal),
      textStyleTeal,
      textStyleTeal); // no secondary color for lower number
}

TextSpan _createTextSpan(String text, TextStyle textStyle) {
  return TextSpan(text: text, style: textStyle);
}

double convertSatsToBTC(int sats) {
  return sats / 100000000;
}

String convertSatsToBtcString(int sats) {
  // Divide by 100,000,000 to convert to BTC
  double btcAmount = sats / 100000000;

  // Format the BTC amount with commas for thousands
  String formattedAmount = formatAmountWithCommas(btcAmount);

  return formattedAmount;
}

String formatAmountWithCommas(double amount) {
  // Convert the double to a string and add commas for thousands
  String amountString = amount.toString();

  List<String> parts = amountString.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? parts[1] : '';

  // Add commas every three digits in the integer part
  List<String> integerDigits = integerPart.split('');
  for (int i = 0; i < integerDigits.length; i++) {
    if ((integerDigits.length - i - 1) % 3 == 0 &&
        i != integerDigits.length - 1) {
      integerDigits[i] += ',';
    }
  }

  // Join the integer and decimal parts
  String formattedAmount = integerDigits.join('') +
      (decimalPart.isNotEmpty ? '.' + decimalPart : '');

  return formattedAmount;
}

double convertSatsToFiat(int amountSats, double fxRateFiat) {
  double fiatValue = amountSats / fxRateFiat;

  fiatValue = double.parse(fiatValue.toStringAsFixed(2)); // TODO: is this ok ?

  return fiatValue;
}

String convertSatsToFiatString(int amountSats, double fxRateFiat) {
  NumberFormat currencyFormatter =
      NumberFormat.currency(locale: currentLocale, symbol: "");

  String formattedAmount = currencyFormatter.format(amountSats / fxRateFiat);

  return formattedAmount;
}

List<TextSpan> changeDecimalMark(
    AmountDisplayUnit unit,
    bool isDecimalPoint,
    bool isAmountBtcUnder1, // place false here if not BTC or if the BTC < 1
    List<TextSpan> textSpansWithSpaces,
    TextStyle? textStyleBlack,
    TextStyle? textStyleGray) {
  List<TextSpan> textSpans = [];

  if (isDecimalPoint) {
    return textSpansWithSpaces;
  } else {
    for (int i = 0; i < textSpansWithSpaces.length; i++) {
      TextSpan char = textSpansWithSpaces[i];

      if (char.text == '.') {
        if (isAmountBtcUnder1 && unit == AmountDisplayUnit.btc) {
          textSpans.add(_createTextSpan(',', textStyleGray!));
        } else {
          textSpans.add(_createTextSpan(',', textStyleBlack!));
        }
      } else if (char.text == ',') {
        if (isAmountBtcUnder1 && unit == AmountDisplayUnit.btc) {
          textSpans.add(_createTextSpan('.', textStyleGray!));
        } else {
          textSpans.add(_createTextSpan('.', textStyleBlack!));
        }
      } else {
        textSpans.add(char);
      }
    }
  }
  return textSpans;
}
