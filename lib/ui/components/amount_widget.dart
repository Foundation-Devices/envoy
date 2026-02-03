// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:intl/intl.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:ngwallet/ngwallet.dart';

enum AmountWidgetStyle { normal, large, singleLine, sendScreen }

class AmountWidget extends StatelessWidget {
  final int amountSats;
  final AmountDisplayUnit primaryUnit;
  final AmountWidgetStyle style;
  final AmountDisplayUnit? secondaryUnit;
  final double? displayFiat;
  final String symbolFiat;
  final double? fxRateFiat;
  final Color? badgeColor;
  final EnvoyAccount? envoyAccount;
  final bool alignToEnd;
  final String locale;
  final bool millionaireMode;
  final String? semanticSuffix;

  const AmountWidget({
    super.key,
    required this.amountSats,
    required this.primaryUnit,
    this.displayFiat,
    this.style = AmountWidgetStyle.normal,
    this.secondaryUnit,
    this.symbolFiat = "",
    this.fxRateFiat,
    this.badgeColor,
    this.envoyAccount,
    this.alignToEnd = true,
    required this.locale,
    this.millionaireMode = true,
    this.semanticSuffix,
  });

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = MediaQuery.of(context).textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.6,
        );
    double baseFontScale = 1;
    double textScaleFactor = textScaler.scale(baseFontScale);

    String getDecimalSeparator(String locale) {
      // Get the decimal separator for the specified locale
      NumberFormat numberFormat = NumberFormat.decimalPattern(locale);
      return numberFormat.symbols.DECIMAL_SEP;
    }

    String getGroupSeparator(String locale) {
      // Get the group separator for the specified locale
      NumberFormat numberFormat = NumberFormat.decimalPattern(locale);
      return numberFormat.symbols.GROUP_SEP;
    }

    String decimalSeparator = getDecimalSeparator(locale);
    String groupSeparator = getGroupSeparator(locale);

    switch (style) {
      case AmountWidgetStyle.large:
        return Column(
          children: [
            PrimaryAmountWidget(
                unit: primaryUnit,
                style: PrimaryAmountWidgetStyle.large,
                amountSats: amountSats,
                decimalSeparator: decimalSeparator,
                groupSeparator: groupSeparator,
                symbolFiat: symbolFiat,
                fxRateFiat: fxRateFiat,
                badgeColor: badgeColor,
                envoyAccount: envoyAccount,
                locale: locale,
                textScaleFactor: textScaleFactor,
                millionaireMode: millionaireMode,
                semanticSuffix: semanticSuffix),
            if (secondaryUnit != null)
              SecondaryAmountWidget(
                  badgeColor: badgeColor,
                  unit: secondaryUnit!,
                  displayFiat: displayFiat,
                  style: SecondaryAmountWidgetStyle.large,
                  amountSats: amountSats,
                  symbolFiat: symbolFiat,
                  fxRateFiat: fxRateFiat,
                  decimalSeparator: decimalSeparator,
                  groupSeparator: groupSeparator,
                  envoyAccount: envoyAccount,
                  locale: locale,
                  textScaleFactor: textScaleFactor,
                  millionaireMode: millionaireMode),
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
                decimalSeparator: decimalSeparator,
                groupSeparator: groupSeparator,
                symbolFiat: symbolFiat,
                fxRateFiat: fxRateFiat,
                badgeColor: badgeColor,
                envoyAccount: envoyAccount,
                locale: locale,
                textScaleFactor: textScaleFactor,
                millionaireMode: millionaireMode,
                semanticSuffix: semanticSuffix),
            if (secondaryUnit != null)
              Padding(
                padding: const EdgeInsets.only(top: EnvoySpacing.xs),
                child: SecondaryAmountWidget(
                    badgeColor: badgeColor,
                    unit: secondaryUnit!,
                    displayFiat: displayFiat,
                    style: SecondaryAmountWidgetStyle.normal,
                    amountSats: amountSats,
                    symbolFiat: symbolFiat,
                    fxRateFiat: fxRateFiat,
                    decimalSeparator: decimalSeparator,
                    groupSeparator: groupSeparator,
                    envoyAccount: envoyAccount,
                    locale: locale,
                    textScaleFactor: textScaleFactor,
                    millionaireMode: millionaireMode),
              ),
          ],
        );
      case AmountWidgetStyle.singleLine:
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PrimaryAmountWidget(
                unit: primaryUnit,
                style: PrimaryAmountWidgetStyle.normal,
                amountSats: amountSats,
                decimalSeparator: decimalSeparator,
                groupSeparator: groupSeparator,
                symbolFiat: symbolFiat,
                fxRateFiat: fxRateFiat,
                badgeColor: badgeColor,
                envoyAccount: envoyAccount,
                locale: locale,
                textScaleFactor: textScaleFactor,
                millionaireMode: millionaireMode,
                semanticSuffix: semanticSuffix),
            if (secondaryUnit != null)
              Padding(
                padding: const EdgeInsets.only(left: EnvoySpacing.small),
                child: SecondaryAmountWidget(
                    badgeColor: badgeColor,
                    unit: secondaryUnit!,
                    displayFiat: displayFiat,
                    style: SecondaryAmountWidgetStyle.normal,
                    amountSats: amountSats,
                    symbolFiat: symbolFiat,
                    fxRateFiat: fxRateFiat,
                    decimalSeparator: decimalSeparator,
                    groupSeparator: groupSeparator,
                    envoyAccount: envoyAccount,
                    locale: locale,
                    textScaleFactor: textScaleFactor,
                    millionaireMode: millionaireMode),
              ),
          ],
        );

      case AmountWidgetStyle.sendScreen:
        return PrimaryAmountWidget(
            unit: primaryUnit,
            style: PrimaryAmountWidgetStyle.normal,
            amountSats: amountSats,
            decimalSeparator: decimalSeparator,
            groupSeparator: groupSeparator,
            symbolFiat: symbolFiat,
            fxRateFiat: fxRateFiat,
            badgeColor: badgeColor,
            envoyAccount: envoyAccount,
            locale: locale,
            sendScreen: true,
            textScaleFactor: textScaleFactor,
            millionaireMode: millionaireMode,
            semanticSuffix: semanticSuffix);
    }
  }
}

enum PrimaryAmountWidgetStyle { normal, large }

class PrimaryAmountWidget extends StatelessWidget {
  final AmountDisplayUnit unit;
  final int amountSats;
  final String decimalSeparator;
  final String groupSeparator;

  final String symbolFiat;
  final double? fxRateFiat;
  final PrimaryAmountWidgetStyle style;
  final Color? badgeColor;
  final EnvoyAccount? envoyAccount;
  final bool sendScreen;
  final String locale;
  final double textScaleFactor;
  final bool millionaireMode;
  final String? semanticSuffix;

  final EnvoyIcons iconBtc = EnvoyIcons.btc;
  final EnvoyIcons iconSat = EnvoyIcons.sats;

  final TextStyle textStyleFiatSymbol = EnvoyTypography.digitsMedium
      .copyWith(color: EnvoyColors.textPrimary, fontSize: 24);

  PrimaryAmountWidget(
      {super.key,
      required this.unit,
      required this.amountSats,
      required this.locale,
      this.decimalSeparator = ".",
      this.groupSeparator = ",",
      this.symbolFiat = "",
      this.fxRateFiat,
      this.style = PrimaryAmountWidgetStyle.normal,
      this.badgeColor,
      this.envoyAccount,
      this.sendScreen = false,
      this.textScaleFactor = 1,
      required this.millionaireMode,
      this.semanticSuffix});

  @override
  Widget build(BuildContext context) {
    if (unit == AmountDisplayUnit.fiat && fxRateFiat == null) {
      return const LoaderGhost(
        width: 30,
        height: 15,
        animate: true,
      );
    }

    final TextStyle textStyleBlack = style == PrimaryAmountWidgetStyle.normal
        ? EnvoyTypography.digitsMedium.copyWith(
            color: EnvoyColors.textPrimary,
          )
        : EnvoyTypography.digitsLarge.copyWith(
            color: EnvoyColors.textPrimary,
          );

    final TextStyle textStyleGray = style == PrimaryAmountWidgetStyle.normal
        ? EnvoyTypography.digitsMedium.copyWith(color: EnvoyColors.textTertiary)
        : EnvoyTypography.digitsLarge.copyWith(color: EnvoyColors.textTertiary);

    final iconSize = style == PrimaryAmountWidgetStyle.normal
        ? EnvoyIconSize.small
        : EnvoyIconSize.normal;

    final iconColor = style == PrimaryAmountWidgetStyle.normal
        ? EnvoyColors.textTertiary
        : EnvoyColors.textPrimary;

    final unitSpacing =
        style == PrimaryAmountWidgetStyle.normal ? 2.0 : EnvoySpacing.xs;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            container: true,
            identifier: 'primary_amount_icon',
            child: Padding(
                padding: EdgeInsets.only(right: unitSpacing),
                child: unit == AmountDisplayUnit.fiat
                    ? Text(
                        symbolFiat,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: sendScreen
                            ? EnvoyTypography.digitsMedium
                                .copyWith(color: EnvoyColors.textSecondary)
                            : textStyleFiatSymbol,
                      )
                    : (envoyAccount?.network == Network.bitcoin
                        ? EnvoyIcon(
                            unit == AmountDisplayUnit.btc ? iconBtc : iconSat,
                            size: iconSize,
                            color: iconColor,
                          )
                        : getNonMainnetIcon(unit, badgeColor!, envoyAccount!,
                            iconSize: iconSize, iconColor: iconColor))),
          ),
          Semantics(
            container: true,
            identifier: semanticSuffix != null
                ? 'primary_amount $semanticSuffix'
                : 'primary_amount_value',
            child: RichText(
              textScaler: TextScaler.linear(textScaleFactor),
              text: TextSpan(
                children: unit == AmountDisplayUnit.btc
                    ? buildPrimaryBtcTextSpans(amountSats, decimalSeparator,
                        groupSeparator, textStyleBlack, textStyleGray)
                    : unit == AmountDisplayUnit.fiat
                        ? buildFiatTextSpans(
                            amountSats,
                            fxRateFiat!,
                            textStyleBlack,
                            locale,
                            decimalSeparator,
                            groupSeparator,
                            millionaireMode: millionaireMode)
                        : buildPrimarySatsTextSpans(amountSats, groupSeparator,
                            textStyleBlack, textStyleGray),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum SecondaryAmountWidgetStyle { normal, large }

class SecondaryAmountWidget extends StatelessWidget {
  final AmountDisplayUnit unit;
  final int amountSats;
  final String symbolFiat;
  final double? fxRateFiat;
  final String decimalSeparator;
  final String groupSeparator;
  final double? displayFiat;
  final SecondaryAmountWidgetStyle style;
  final Color? badgeColor;
  final EnvoyAccount? envoyAccount;
  final String locale;
  final EnvoyIcons iconBtc = EnvoyIcons.btc;
  final double textScaleFactor;
  final bool millionaireMode;
  final String? semanticSuffix;

  const SecondaryAmountWidget(
      {super.key,
      required this.unit,
      required this.amountSats,
      this.displayFiat,
      required this.locale,
      this.symbolFiat = "",
      this.fxRateFiat,
      this.decimalSeparator = ".",
      this.groupSeparator = ",",
      this.style = SecondaryAmountWidgetStyle.normal,
      this.badgeColor,
      this.envoyAccount,
      this.textScaleFactor = 1,
      required this.millionaireMode,
      this.semanticSuffix});

  @override
  Widget build(BuildContext context) {
    if (unit == AmountDisplayUnit.fiat && fxRateFiat == null) {
      return const LoaderGhost(
        width: 30,
        height: 15,
        animate: true,
      );
    }

    final TextStyle textStyle = EnvoyTypography.digitsSmall.copyWith(
      color: style == SecondaryAmountWidgetStyle.normal
          ? EnvoyColors.textPrimary
          : EnvoyColors.accentPrimary,
    );
    final iconColor = style == SecondaryAmountWidgetStyle.normal
        ? EnvoyColors.textPrimary
        : EnvoyColors.accentPrimary;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            container: true,
            identifier: 'secondary_amount_icon',
            child: Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: unit == AmountDisplayUnit.btc
                    ? (envoyAccount?.network == Network.bitcoin
                        ? EnvoyIcon(
                            iconBtc,
                            size: EnvoyIconSize.extraSmall,
                            color: iconColor,
                          )
                        : getNonMainnetIcon(unit, badgeColor!, envoyAccount!,
                            iconSize: EnvoyIconSize.extraSmall,
                            iconColor: iconColor))
                    : Text(
                        symbolFiat,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: textStyle,
                      )),
          ),
          Semantics(
            container: true,
            identifier: semanticSuffix != null
                ? 'secondary_amount $semanticSuffix'
                : 'secondary_amount_value',
            child: RichText(
              textScaler: TextScaler.linear(textScaleFactor),
              text: TextSpan(
                  children: unit == AmountDisplayUnit.fiat
                      ? buildFiatTextSpans(
                          amountSats,
                          fxRateFiat!,
                          displayFiat: displayFiat,
                          textStyle,
                          locale,
                          decimalSeparator,
                          groupSeparator,
                          millionaireMode: millionaireMode)
                      : buildSecondaryBtcTextSpans(amountSats, decimalSeparator,
                          groupSeparator, textStyle, textStyle)),
            ),
          ),
        ],
      ),
    );
  }
}

List<TextSpan> buildPrimaryBtcTextSpans(
    int amountSats,
    String decimalSeparator,
    String groupSeparator,
    TextStyle? textStyleBlack,
    TextStyle? textStyleGray) {
  if (amountSats == 0) {
    return [_createTextSpan('0', textStyleGray!)];
  }

  List<TextSpan> textSpans = [];
  String btcString =
      convertSatsToBtcString(amountSats, decimalSeparator, groupSeparator);

  double amountBTC = convertSatsToBTC(amountSats);
  bool isAmountBtcUnder1 = amountBTC < 1;

  if (isAmountBtcUnder1) {
    bool foundNum = false;

    for (int i = 0; i < btcString.length; i++) {
      String char = btcString[i];

      if (i == 0) {
        textSpans.add(_createTextSpan(char, textStyleGray!));
      } else {
        if (char == decimalSeparator) {
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
    bool foundDecimalSeparator = false;
    bool foundNum = false;
    bool foundGroupSeparator = false;

    for (int i = 0; i < btcString.length; i++) {
      String char = btcString[i];

      if (int.tryParse(char) != null) {
        foundNum = true;
      }
      if (char == decimalSeparator) {
        foundDecimalSeparator = true;
        foundNum = false;
      }
      if (char == groupSeparator) {
        foundGroupSeparator = true;
        foundNum = false;
      }
      if (foundNum && foundDecimalSeparator && foundGroupSeparator) {
        textSpans.add(_createTextSpan(char, textStyleGray!));
      } else {
        textSpans.add(_createTextSpan(char, textStyleBlack!));
      }
    }
  }

  return buildTextSpansWithSpaces(
      isAmountBtcUnder1, decimalSeparator, textSpans, textStyleBlack);
}

List<TextSpan> buildTextSpansWithSpaces(
    bool isAmountBtcUnder1,
    String decimalSeparator,
    List<TextSpan> textSpans,
    TextStyle? textStyleSpace) {
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

      if (i == 0 || char.text == decimalSeparator) {
        textSpansWithSpaces.add(char);
        if (char.text != decimalSeparator) {
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
    int decimalMarkCount = 0;
    bool foundDot = false;

    for (int i = 0; i < textSpans.length; i++) {
      TextSpan char = textSpans[i];

      if (char.text == decimalSeparator) {
        foundDot = true;
        decimalMarkCount = 0;
        textSpansWithSpaces.add(char);
      } else if (foundDot) {
        textSpansWithSpaces.add(char);
        decimalMarkCount++;

        if (decimalMarkCount == 2) {
          textSpansWithSpaces.add(_createTextSpan(' ', textStyleSpace!));
        } else if ((decimalMarkCount - 2) % 3 == 0) {
          textSpansWithSpaces.add(_createTextSpan(' ', textStyleSpace!));
        }
      } else {
        textSpansWithSpaces.add(char);
      }
    }
  }
  if (negativeAmount) {
    textSpansWithSpaces.insert(0, _createTextSpan('-', textStyleSpace!));
  }

  return textSpansWithSpaces;
}

List<TextSpan> buildPrimarySatsTextSpans(int amountSats, String groupSeparator,
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

    // Insert commas or dots after every three digits
    if (i % 3 == 2 && i != satsString.length - 1) {
      textSpans.add(_createTextSpan(groupSeparator, textStyleBlack));
    }
  }

  // Reverse the list to get the original order
  textSpans = textSpans.reversed.toList();
  if (negativeAmount) {
    textSpans.insert(0, _createTextSpan("-", textStyleBlack!));
  }

  return textSpans;
}

List<TextSpan> buildFiatTextSpans(
    int amountSats,
    double fxRateFiat,
    TextStyle? textStyle,
    String locale,
    String decimalSeparator,
    String groupSeparator,
    {required bool millionaireMode,
    double? displayFiat}) {
  List<TextSpan> textSpans = [];

  String amountFiatString =
      convertSatsToFiatString(amountSats, fxRateFiat, locale);

  double amountFiatValue = convertFiatStringToFiat(
      amountFiatString, decimalSeparator, groupSeparator);

  if (millionaireMode) {
    if (amountFiatValue >= 1000000000) {
      // Convert to billions and round to 2 decimal points
      double valueInBillion = amountFiatValue / 1000000000.0;
      String formattedValue = '${valueInBillion.toStringAsFixed(2)} B';
      textSpans.add(_createTextSpan(formattedValue, textStyle!));
    } else if (amountFiatValue >= 1000000) {
      // Convert to millions and round to 2 decimal points
      double valueInMillion = amountFiatValue / 1000000.0;
      String formattedValue = '${valueInMillion.toStringAsFixed(2)} M';
      textSpans.add(_createTextSpan(formattedValue, textStyle!));
    } else {
      // Display the original amount
      for (int i = 0; i < amountFiatString.length; i++) {
        String char = amountFiatString[i];
        textSpans.add(_createTextSpan(char, textStyle!));
      }
    }
  } else {
    // Display the original amount

    if (displayFiat != null) {
      String formattedDisplayFiat =
          ExchangeRate().formatFiatToString(displayFiat);
      textSpans.add(_createTextSpan(formattedDisplayFiat, textStyle!));
    } else {
      for (int i = 0; i < amountFiatString.length; i++) {
        String char = amountFiatString[i];
        textSpans.add(_createTextSpan(char, textStyle!));
      }
    }
  }

  return textSpans;
}

List<TextSpan> buildSecondaryBtcTextSpans(
    int amountSats,
    String decimalSeparator,
    String groupSeparator,
    TextStyle? textStyle,
    TextStyle? textStyleSpace) {
  if (amountSats == 0) {
    return [_createTextSpan('0', textStyle!)];
  }

  List<TextSpan> textSpans = [];
  double amountBTC = convertSatsToBTC(amountSats);
  bool isAmountBtcUnder1 = amountBTC < 1;

  String stringBtcAmount =
      convertSatsToBtcString(amountSats, decimalSeparator, groupSeparator);

  // Add characters to textSpans without commas
  for (int i = 0; i < stringBtcAmount.length; i++) {
    String char = stringBtcAmount[i];
    if (char == ',') {
      textSpans.add(_createTextSpan(' ', textStyle!));
    } else {
      textSpans.add(_createTextSpan(char, textStyle!));
    }
  }

  return buildTextSpansWithSpaces(
      isAmountBtcUnder1, decimalSeparator, textSpans, textStyleSpace);
}

TextSpan _createTextSpan(String text, TextStyle textStyle) {
  return TextSpan(text: text, style: textStyle);
}

double convertSatsToBTC(int sats) {
  return sats / 100000000;
}

String convertSatsToBtcString(
    int sats, String decimalSeparator, String groupSeparator,
    {bool trailingZeroes = true}) {
  // Divide by 100,000,000 to convert to BTC
  double btcAmount = convertSatsToBTC(sats);

  // Format the BTC amount with commas for thousands and trailing zeroes
  String formattedAmount = formatAmountWithSeparators(
      btcAmount, trailingZeroes, decimalSeparator, groupSeparator);

  return formattedAmount;
}

String formatAmountWithSeparators(double amount, bool trailingZeroes,
    String decimalSeparator, String groupSeparator) {
  // Use .toStringAsFixed(8) for < 1000 BTC (ENV-2486)
  // Use .toString() (natural trimming) for >= 1000 BTC (ENV-2486)
  String amountString =
      amount < 1000 ? amount.toStringAsFixed(8) : amount.toString();

  // Standard decimal separator replacement
  amountString = amountString.replaceAll('.', decimalSeparator);

  List<String> parts = amountString.split(decimalSeparator);
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? parts[1] : '';

  // Add groupSeparator every three digits in the integer part
  List<String> integerDigits = integerPart.split('');
  for (int i = 0; i < integerDigits.length; i++) {
    if ((integerDigits.length - i - 1) % 3 == 0 &&
        i != integerDigits.length - 1) {
      integerDigits[i] += groupSeparator;
    }
  }

  // Only pad decimals if required (small BTC values ENV-2486)
  if (trailingZeroes && amount < 1000) {
    int currentDecimalLength = decimalPart.length;
    int targetDecimalLength = 8;
    if (currentDecimalLength < targetDecimalLength) {
      decimalPart = decimalPart.padRight(targetDecimalLength, '0');
    }
  }

  return integerDigits.join('') +
      (decimalPart.isNotEmpty ? "$decimalSeparator$decimalPart" : "");
}

double convertFiatStringToFiat(
    String formattedAmount, String decimalSeparator, String groupSeparator) {
  if (formattedAmount.isEmpty) {
    return 0.00;
  }

  formattedAmount = formattedAmount
      .replaceAll(RegExp('[^0-9$decimalSeparator]'), '')
      .replaceAll(groupSeparator, "");

  formattedAmount = formattedAmount.replaceAll(decimalSeparator, ".");

  try {
    double amount = double.parse(formattedAmount);
    return amount;
  } on FormatException {
    // Handle invalid format
    return 0.00;
  }
}

String convertSatsToFiatString(
    int amountSats, double fxRateFiat, String locale) {
  // format via Settings().selectedFiat
  NumberFormat currencyFormatter = NumberFormat.currency(
      locale: locale, symbol: "", name: Settings().selectedFiat);

  String formattedAmount =
      currencyFormatter.format(fxRateFiat * amountSats / 100000000);

  return formattedAmount;
}

Widget getNonMainnetIcon(
    AmountDisplayUnit unit, Color badgeColor, EnvoyAccount envoyAccount,
    {EnvoyIconSize? iconSize, Color? iconColor}) {
  return NonMainnetIcon(
    unit == AmountDisplayUnit.btc ? EnvoyIcons.btc : EnvoyIcons.sats,
    badgeColor: badgeColor,
    size: iconSize ?? EnvoyIconSize.normal,
    iconColor: iconColor,
    network: envoyAccount.network,
  );
}
