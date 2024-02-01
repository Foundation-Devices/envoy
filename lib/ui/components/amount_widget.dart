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
import 'package:envoy/ui/theme/envoy_spacing.dart';

enum AmountWidgetStyle { normal, large, singleLine, sendScreen }

class AmountWidget extends StatelessWidget {
  final int amountSats;
  final AmountDisplayUnit primaryUnit;
  final AmountWidgetStyle style;
  final AmountDisplayUnit? secondaryUnit;
  final bool decimalDot;
  final String symbolFiat;
  final double fxRateFiat;
  final Color? badgeColor;
  final bool alignToEnd;

  AmountWidget({
    required this.amountSats,
    required this.primaryUnit,
    this.style = AmountWidgetStyle.normal,
    this.secondaryUnit = null,
    this.symbolFiat = "",
    this.fxRateFiat = 0.0,
    this.decimalDot = true,
    this.badgeColor,
    this.alignToEnd = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case AmountWidgetStyle.large:
        return Column(
          children: [
            PrimaryAmountWidget(
              unit: primaryUnit,
              style: PrimaryAmountWidgetStyle.large,
              amountSats: amountSats,
              decimalDot: decimalDot,
              symbolFiat: symbolFiat,
              fxRateFiat: fxRateFiat,
              badgeColor: badgeColor,
            ),
            if (secondaryUnit != null)
              SecondaryAmountWidget(
                  unit: secondaryUnit!,
                  style: SecondaryAmountWidgetStyle.large,
                  amountSats: amountSats,
                  symbolFiat: symbolFiat,
                  fxRateFiat: fxRateFiat,
                  decimalDot: decimalDot,
                  badgeColor: badgeColor),
          ],
        );
      case AmountWidgetStyle.normal:
        return Column(
          crossAxisAlignment:
              alignToEnd ? CrossAxisAlignment.end : CrossAxisAlignment.center,
          children: [
            PrimaryAmountWidget(
              unit: primaryUnit,
              style: PrimaryAmountWidgetStyle.normal,
              amountSats: amountSats,
              decimalDot: decimalDot,
              symbolFiat: symbolFiat,
              fxRateFiat: fxRateFiat,
              badgeColor: badgeColor,
            ),
            if (secondaryUnit != null)
              SecondaryAmountWidget(
                  unit: secondaryUnit!,
                  style: SecondaryAmountWidgetStyle.normal,
                  amountSats: amountSats,
                  symbolFiat: symbolFiat,
                  fxRateFiat: fxRateFiat,
                  decimalDot: decimalDot,
                  badgeColor: badgeColor),
          ],
        );
      case AmountWidgetStyle.singleLine:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PrimaryAmountWidget(
              unit: primaryUnit,
              style: PrimaryAmountWidgetStyle.normal,
              amountSats: amountSats,
              decimalDot: decimalDot,
              symbolFiat: symbolFiat,
              fxRateFiat: fxRateFiat,
              badgeColor: badgeColor,
            ),
            if (secondaryUnit != null)
              Padding(
                padding: const EdgeInsets.only(left: EnvoySpacing.small),
                child: SecondaryAmountWidget(
                    unit: secondaryUnit!,
                    style: SecondaryAmountWidgetStyle.normal,
                    amountSats: amountSats,
                    symbolFiat: symbolFiat,
                    fxRateFiat: fxRateFiat,
                    decimalDot: decimalDot,
                    badgeColor: badgeColor),
              ),
          ],
        );

      case AmountWidgetStyle.sendScreen:
        return PrimaryAmountWidget(
          unit: primaryUnit,
          style: PrimaryAmountWidgetStyle.normal,
          amountSats: amountSats,
          decimalDot: decimalDot,
          symbolFiat: symbolFiat,
          fxRateFiat: fxRateFiat,
          badgeColor: badgeColor,
          sendScreen: true,
        );
    }
  }
}

enum PrimaryAmountWidgetStyle { normal, large }

class PrimaryAmountWidget extends StatelessWidget {
  final AmountDisplayUnit unit;
  final int amountSats;
  final bool decimalDot;
  final int fiatDecimals;
  final String symbolFiat;
  final double fxRateFiat;
  final PrimaryAmountWidgetStyle style;
  final Color? badgeColor;
  final bool sendScreen;

  final EnvoyIcons iconBtc = EnvoyIcons.btc;
  final EnvoyIcons iconSat = EnvoyIcons.sats;

  final TextStyle textStyleFiatSymbol = EnvoyTypography.body
      .copyWith(color: EnvoyColors.textPrimary, fontSize: 24);

  PrimaryAmountWidget({
    super.key,
    required this.unit,
    required this.amountSats,
    this.decimalDot = true,
    this.fiatDecimals = 2,
    this.symbolFiat = "",
    this.fxRateFiat = 0.0,
    this.style = PrimaryAmountWidgetStyle.normal,
    this.badgeColor,
    this.sendScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyleBlack = style == PrimaryAmountWidgetStyle.normal
        ? EnvoyTypography.body.copyWith(
            color: EnvoyColors.textPrimary,
          )
        : EnvoyTypography.largeAmount.copyWith(
            color: EnvoyColors.textPrimary,
          );

    final TextStyle textStyleGray = style == PrimaryAmountWidgetStyle.normal
        ? EnvoyTypography.body.copyWith(color: EnvoyColors.textTertiary)
        : EnvoyTypography.largeAmount.copyWith(color: EnvoyColors.textTertiary);

    final iconSize = style == PrimaryAmountWidgetStyle.normal
        ? EnvoyIconSize.small
        : EnvoyIconSize.normal;

    final iconColor = style == PrimaryAmountWidgetStyle.normal
        ? EnvoyColors.textTertiary
        : EnvoyColors.textPrimary;

    final unitSpacing =
        style == PrimaryAmountWidgetStyle.normal ? 2.0 : EnvoySpacing.xs;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(right: unitSpacing),
            child: unit == AmountDisplayUnit.fiat
                ? Text(
                    symbolFiat,
                    style: sendScreen
                        ? EnvoyTypography.body
                            .copyWith(color: EnvoyColors.textSecondary)
                        : textStyleFiatSymbol,
                  )
                : (badgeColor == null
                    ? EnvoyIcon(
                        unit == AmountDisplayUnit.btc ? iconBtc : iconSat,
                        size: iconSize,
                        color: iconColor,
                      )
                    : displayTestnetIcon(unit, badgeColor!,
                        iconSize: iconSize, iconColor: iconColor))),
        RichText(
          text: TextSpan(
            children: unit == AmountDisplayUnit.btc
                ? buildPrimaryBtcTextSpans(
                    amountSats, decimalDot, textStyleBlack, textStyleGray)
                : unit == AmountDisplayUnit.fiat
                    ? buildPrimaryFiatTextSpans(amountSats, fxRateFiat,
                        decimalDot, fiatDecimals, textStyleBlack, textStyleGray)
                    : buildPrimarySatsTextSpans(
                        amountSats, decimalDot, textStyleBlack, textStyleGray),
          ),
        ),
      ],
    );
  }
}

enum SecondaryAmountWidgetStyle { normal, large }

class SecondaryAmountWidget extends StatelessWidget {
  final AmountDisplayUnit unit;
  final int amountSats;
  final String symbolFiat;
  final double fxRateFiat;
  final bool decimalDot;
  final SecondaryAmountWidgetStyle style;
  final Color? badgeColor;

  final EnvoyIcons iconBtc = EnvoyIcons.btc;

  SecondaryAmountWidget(
      {super.key,
      required this.unit,
      required this.amountSats,
      this.symbolFiat = "",
      this.fxRateFiat = 0.0,
      this.decimalDot = true,
      this.style = SecondaryAmountWidgetStyle.normal,
      this.badgeColor});

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = EnvoyTypography.info.copyWith(
      color: style == SecondaryAmountWidgetStyle.normal
          ? EnvoyColors.textPrimary
          : EnvoyColors.accentPrimary,
    );
    final iconColor = style == PrimaryAmountWidgetStyle.normal
        ? EnvoyColors.textPrimary
        : EnvoyColors.accentPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: unit == AmountDisplayUnit.btc
                ? (badgeColor == null
                    ? EnvoyIcon(
                        iconBtc,
                        size: EnvoyIconSize.extraSmall,
                        color: iconColor,
                      )
                    : getTestnetBtcIcon(badgeColor!,
                        iconSize: EnvoyIconSize.extraSmall,
                        iconColor: iconColor))
                : Text(
                    symbolFiat,
                    style: textStyle,
                  )),
        RichText(
          text: TextSpan(
              children: unit == AmountDisplayUnit.fiat
                  ? buildSecondaryFiatTextSpans(
                      amountSats, fxRateFiat, decimalDot, textStyle)
                  : buildSecondaryBtcTextSpans(
                      amountSats, decimalDot, textStyle, textStyle)),
        ),
      ],
    );
  }
}

List<TextSpan> buildPrimaryBtcTextSpans(int amountSats, bool decimalDot,
    TextStyle? textStyleBlack, TextStyle? textStyleGray) {
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
      buildTextSpansWithSpaces(isAmountBtcUnder1, textSpans, textStyleBlack),
      textStyleBlack,
      textStyleGray);
}

List<TextSpan> buildTextSpansWithSpaces(bool isAmountBtcUnder1,
    List<TextSpan> textSpans, TextStyle? textStyleSpace) {
  List<TextSpan> textSpansWithSpaces = [];
  bool negativeAmount = false;
  if (textSpans[0].text == "-") {
    textSpans.removeAt(0);
    negativeAmount = true;
  }
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
          textSpansWithSpaces.add(_createTextSpan(' ', textStyleSpace!));
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
          textSpansWithSpaces.add(_createTextSpan(' ', textStyleSpace!));
        } else if ((numCountAfterDot - 2) % 3 == 0) {
          textSpansWithSpaces.add(_createTextSpan(' ', textStyleSpace!));
        }
      } else {
        textSpansWithSpaces.add(char);
      }
    }
  }
  if (negativeAmount)
    textSpansWithSpaces.insert(0, _createTextSpan('-', textStyleSpace!));

  return textSpansWithSpaces;
}

List<TextSpan> buildPrimarySatsTextSpans(int amountSats, bool decimalDot,
    TextStyle? textStyleBlack, TextStyle? textStyleGray) {
  List<TextSpan> textSpans = [];
  String satsString = amountSats.toString();
  bool negativeAmount = false;
  if (satsString.startsWith("-")) {
    satsString = satsString.substring(1);
    negativeAmount = true;
  }

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
  if (negativeAmount)
    textSpans.insert(0, _createTextSpan("-", textStyleBlack!));

  return changeDecimalMark(
      AmountDisplayUnit.sat,
      decimalDot,
      false, // place false here if not BTC or if the BTC < 1
      textSpans,
      textStyleBlack,
      textStyleGray);
}

List<TextSpan> buildPrimaryFiatTextSpans(
    int amountSats,
    double fxRateFiat,
    bool decimalDot,
    int decimals,
    TextStyle? textStyleBlack,
    TextStyle? textStyleGray) {
  List<TextSpan> textSpans = [];

  double amountValue =
      convertSatsToFiat(amountSats, fxRateFiat, decimals: decimals);
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

List<TextSpan> buildSecondaryFiatTextSpans(int amountSats, double fxRateFiat,
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

List<TextSpan> buildSecondaryBtcTextSpans(int amountSats, bool decimalDot,
    TextStyle? textStyle, TextStyle? textStyleSpace) {
  List<TextSpan> textSpans = [];
  double amountBTC = convertSatsToBTC(amountSats);
  bool isAmountBtcUnder1 = amountBTC < 1;

  String stringBtcAmount = convertSatsToBtcString(amountSats);

  // Add characters to textSpans without commas
  for (int i = 0; i < stringBtcAmount.length; i++) {
    String char = stringBtcAmount[i];
    if (char == ',') {
      textSpans.add(_createTextSpan(' ', textStyle!));
    } else {
      textSpans.add(_createTextSpan(char, textStyle!));
    }
  }

  return changeDecimalMark(
      AmountDisplayUnit.btc,
      decimalDot,
      false, // it is false because it does not matter for the lower number
      buildTextSpansWithSpaces(isAmountBtcUnder1, textSpans, textStyleSpace),
      textStyle,
      textStyle); // no secondary color for lower number
}

TextSpan _createTextSpan(String text, TextStyle textStyle) {
  return TextSpan(text: text, style: textStyle);
}

double convertSatsToBTC(int sats) {
  return sats / 100000000;
}

String convertSatsToBtcString(int sats, {bool trailingZeroes = true}) {
  // Divide by 100,000,000 to convert to BTC
  double btcAmount = sats / 100000000;

  // Format the BTC amount with commas for thousands and trailing zeroes
  String formattedAmount = formatAmountWithCommas(btcAmount, trailingZeroes);

  return formattedAmount;
}

String formatAmountWithCommas(double amount, bool trailingZeroes) {
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

  // Add trailing zeroes if specified
  if (trailingZeroes) {
    int currentDecimalLength = decimalPart.length;
    int targetDecimalLength = 8; // BTC has up to 8 decimal places

    for (int i = currentDecimalLength; i < targetDecimalLength; i++) {
      formattedAmount += '0';
    }
  }

  return formattedAmount;
}

double convertSatsToFiat(int amountSats, double fxRateFiat,
    {int decimals = 2}) {
  double fiatValue = fxRateFiat * amountSats / 100000000;

  fiatValue = double.parse(fiatValue.toStringAsFixed(decimals));

  return fiatValue;
}

String convertSatsToFiatString(int amountSats, double fxRateFiat) {
  NumberFormat currencyFormatter =
      NumberFormat.currency(locale: currentLocale, symbol: "");

  String formattedAmount =
      currencyFormatter.format(fxRateFiat * amountSats / 100000000);

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

Widget getTestnetBtcIcon(Color badgeColor,
    {EnvoyIconSize? iconSize, Color? iconColor}) {
  return TestnetIcon(
    EnvoyIcons.btc,
    badgeColor: badgeColor,
    size: iconSize ?? EnvoyIconSize.normal,
    iconColor: iconColor,
  );
}

Widget getTestnetSatsIcon(Color badgeColor,
    {EnvoyIconSize? iconSize, Color? iconColor}) {
  return TestnetIcon(
    EnvoyIcons.sats,
    badgeColor: badgeColor,
    size: iconSize ?? EnvoyIconSize.normal,
    iconColor: iconColor,
  );
}

Widget displayTestnetIcon(AmountDisplayUnit unit, Color color,
    {EnvoyIconSize? iconSize, Color? iconColor}) {
  if (unit == AmountDisplayUnit.btc)
    return getTestnetBtcIcon(color, iconSize: iconSize, iconColor: iconColor);
  else
    return getTestnetSatsIcon(color, iconSize: iconSize, iconColor: iconColor);
}
