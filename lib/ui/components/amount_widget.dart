// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:intl/intl.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:wallet/wallet.dart';

enum AmountWidgetStyle { normal, large, singleLine, sendScreen }

class AmountWidget extends StatelessWidget {
  final int amountSats;
  final AmountDisplayUnit primaryUnit;
  final AmountWidgetStyle style;
  final AmountDisplayUnit? secondaryUnit;
  final String symbolFiat;
  final double? fxRateFiat;
  final Color? badgeColor;
  final Network? network;
  final bool alignToEnd;
  final String locale;

  const AmountWidget({
    super.key,
    required this.amountSats,
    required this.primaryUnit,
    this.style = AmountWidgetStyle.normal,
    this.secondaryUnit,
    this.symbolFiat = "",
    this.fxRateFiat,
    this.badgeColor,
    this.network = Network.Mainnet,
    this.alignToEnd = true,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
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
                network: network,
                locale: locale),
            if (secondaryUnit != null)
              SecondaryAmountWidget(
                  unit: secondaryUnit!,
                  style: SecondaryAmountWidgetStyle.large,
                  amountSats: amountSats,
                  symbolFiat: symbolFiat,
                  fxRateFiat: fxRateFiat,
                  decimalSeparator: decimalSeparator,
                  groupSeparator: groupSeparator,
                  network: network,
                  locale: locale),
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
                network: network,
                locale: locale),
            if (secondaryUnit != null)
              SecondaryAmountWidget(
                  unit: secondaryUnit!,
                  style: SecondaryAmountWidgetStyle.normal,
                  amountSats: amountSats,
                  symbolFiat: symbolFiat,
                  fxRateFiat: fxRateFiat,
                  decimalSeparator: decimalSeparator,
                  groupSeparator: groupSeparator,
                  network: network,
                  locale: locale),
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
                network: network,
                locale: locale),
            if (secondaryUnit != null)
              Padding(
                padding: const EdgeInsets.only(left: EnvoySpacing.small),
                child: SecondaryAmountWidget(
                    unit: secondaryUnit!,
                    style: SecondaryAmountWidgetStyle.normal,
                    amountSats: amountSats,
                    symbolFiat: symbolFiat,
                    fxRateFiat: fxRateFiat,
                    decimalSeparator: decimalSeparator,
                    groupSeparator: groupSeparator,
                    network: network,
                    locale: locale),
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
          network: network,
          locale: locale,
          sendScreen: true,
        );
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
  final Network? network;
  final bool sendScreen;
  final String locale;

  final EnvoyIcons iconBtc = EnvoyIcons.btc;
  final EnvoyIcons iconSat = EnvoyIcons.sats;

  final TextStyle textStyleFiatSymbol = EnvoyTypography.body
      .copyWith(color: EnvoyColors.textPrimary, fontSize: 24);

  PrimaryAmountWidget({
    super.key,
    required this.unit,
    required this.amountSats,
    required this.locale,
    this.decimalSeparator = ".",
    this.groupSeparator = ",",
    this.symbolFiat = "",
    this.fxRateFiat,
    this.style = PrimaryAmountWidgetStyle.normal,
    this.badgeColor,
    this.network,
    this.sendScreen = false,
  });

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
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(right: unitSpacing),
            child: unit == AmountDisplayUnit.fiat
                ? Text(
                    symbolFiat,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: sendScreen
                        ? EnvoyTypography.body
                            .copyWith(color: EnvoyColors.textSecondary)
                        : textStyleFiatSymbol,
                  )
                : (network == Network.Mainnet
                    ? EnvoyIcon(
                        unit == AmountDisplayUnit.btc ? iconBtc : iconSat,
                        size: iconSize,
                        color: iconColor,
                      )
                    : getNonMainnetIcon(unit, badgeColor!, network!,
                        iconSize: iconSize, iconColor: iconColor))),
        RichText(
          text: TextSpan(
            children: unit == AmountDisplayUnit.btc
                ? buildPrimaryBtcTextSpans(amountSats, decimalSeparator,
                    groupSeparator, textStyleBlack, textStyleGray)
                : unit == AmountDisplayUnit.fiat
                    ? buildPrimaryFiatTextSpans(
                        amountSats,
                        fxRateFiat!,
                        textStyleBlack,
                        textStyleGray,
                        locale,
                        decimalSeparator,
                        groupSeparator)
                    : buildPrimarySatsTextSpans(amountSats, groupSeparator,
                        textStyleBlack, textStyleGray),
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
  final double? fxRateFiat;
  final String decimalSeparator;
  final String groupSeparator;
  final SecondaryAmountWidgetStyle style;
  final Color? badgeColor;
  final Network? network;
  final String locale;
  final EnvoyIcons iconBtc = EnvoyIcons.btc;

  const SecondaryAmountWidget({
    super.key,
    required this.unit,
    required this.amountSats,
    required this.locale,
    this.symbolFiat = "",
    this.fxRateFiat,
    this.decimalSeparator = ".",
    this.groupSeparator = ",",
    this.style = SecondaryAmountWidgetStyle.normal,
    this.badgeColor,
    this.network,
  });

  @override
  Widget build(BuildContext context) {
    if (unit == AmountDisplayUnit.fiat && fxRateFiat == null) {
      return const LoaderGhost(
        width: 30,
        height: 15,
        animate: true,
      );
    }

    final TextStyle textStyle = EnvoyTypography.info.copyWith(
      color: style == SecondaryAmountWidgetStyle.normal
          ? EnvoyColors.textPrimary
          : EnvoyColors.accentPrimary,
    );
    final iconColor = style == SecondaryAmountWidgetStyle.normal
        ? EnvoyColors.textPrimary
        : EnvoyColors.accentPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: unit == AmountDisplayUnit.btc
                ? (network == Network.Mainnet
                    ? EnvoyIcon(
                        iconBtc,
                        size: EnvoyIconSize.extraSmall,
                        color: iconColor,
                      )
                    : getNonMainnetBtcIcon(badgeColor!, network!,
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
        RichText(
          text: TextSpan(
              children: unit == AmountDisplayUnit.fiat
                  ? buildSecondaryFiatTextSpans(
                      amountSats, fxRateFiat!, textStyle, locale)
                  : buildSecondaryBtcTextSpans(amountSats, decimalSeparator,
                      groupSeparator, textStyle, textStyle)),
        ),
      ],
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

List<TextSpan> buildPrimaryFiatTextSpans(
    int amountSats,
    double fxRateFiat,
    TextStyle? textStyleBlack,
    TextStyle? textStyleGray,
    String locale,
    String decimalSeparator,
    String groupSeparator) {
  List<TextSpan> textSpans = [];

  String amountFiatString =
      convertSatsToFiatString(amountSats, fxRateFiat, locale);

  double amountFiatValue = convertFiatStringToFiat(
      amountFiatString, decimalSeparator, groupSeparator);

  if (amountFiatValue >= 1000000000) {
    // Convert to billions and round to 1 decimal point
    double valueInBillion = amountFiatValue / 1000000000.0;
    String formattedValue = '${valueInBillion.toStringAsFixed(1)} B';
    textSpans.add(_createTextSpan(formattedValue, textStyleBlack!));
  } else if (amountFiatValue >= 1000000) {
    // Convert to millions and round to 1 decimal point
    double valueInMillion = amountFiatValue / 1000000.0;
    String formattedValue = '${valueInMillion.toStringAsFixed(1)} M';
    textSpans.add(_createTextSpan(formattedValue, textStyleBlack!));
  } else {
    // Display the original amount
    for (int i = 0; i < amountFiatString.length; i++) {
      String char = amountFiatString[i];
      textSpans.add(_createTextSpan(char, textStyleBlack!));
    }
  }

  return textSpans;
}

List<TextSpan> buildSecondaryFiatTextSpans(int amountSats, double fxRateFiat,
    TextStyle? textStyleTeal, String locale) {
  List<TextSpan> textSpans = [];

  String amountFiatString =
      convertSatsToFiatString(amountSats, fxRateFiat, locale);

  for (int i = 0; i < amountFiatString.length; i++) {
    String char = amountFiatString[i];
    textSpans.add(_createTextSpan(char, textStyleTeal!));
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
  double btcAmount = sats / 100000000;

  // Format the BTC amount with commas for thousands and trailing zeroes
  String formattedAmount = formatAmountWithSeparators(
      btcAmount, trailingZeroes, decimalSeparator, groupSeparator);

  return formattedAmount;
}

String formatAmountWithSeparators(double amount, bool trailingZeroes,
    String decimalSeparator, String groupSeparator) {
  // Convert the double to a string and add commas for thousands
  String amountString = amount.toString();

  List<String> parts =
      amountString.split("."); // here amount always has decimal dot
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

  // Join the integer and decimal parts
  String formattedAmount =
      integerDigits.join('') + decimalSeparator + decimalPart;

  // Add trailing zeroes if specified and btcAmount is less than 999
  if (trailingZeroes && amount < 1000) {
    int currentDecimalLength = decimalPart.length;
    int targetDecimalLength = 8; // BTC has up to 8 decimal places

    for (int i = currentDecimalLength; i < targetDecimalLength; i++) {
      formattedAmount += '0';
    }
  }

  return formattedAmount;
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
  NumberFormat currencyFormatter =
      NumberFormat.currency(locale: locale, symbol: "");

  String formattedAmount =
      currencyFormatter.format(fxRateFiat * amountSats / 100000000);

  return formattedAmount;
}

Widget getNonMainnetBtcIcon(Color badgeColor, Network network,
    {EnvoyIconSize? iconSize, Color? iconColor}) {
  return NonMainnetIcon(
    EnvoyIcons.btc,
    badgeColor: badgeColor,
    size: iconSize ?? EnvoyIconSize.normal,
    iconColor: iconColor,
    network: network,
  );
}

Widget getNonMainnetSatsIcon(Color badgeColor, Network network,
    {EnvoyIconSize? iconSize, Color? iconColor}) {
  return NonMainnetIcon(
    EnvoyIcons.sats,
    badgeColor: badgeColor,
    size: iconSize ?? EnvoyIconSize.normal,
    iconColor: iconColor,
    network: network,
  );
}

Widget getNonMainnetIcon(AmountDisplayUnit unit, Color color, Network network,
    {EnvoyIconSize? iconSize, Color? iconColor}) {
  if (unit == AmountDisplayUnit.btc) {
    return getNonMainnetBtcIcon(color, network,
        iconSize: iconSize, iconColor: iconColor);
  } else {
    return getNonMainnetSatsIcon(color, network,
        iconSize: iconSize, iconColor: iconColor);
  }
}
