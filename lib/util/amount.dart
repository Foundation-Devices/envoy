// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:intl/intl.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/business/exchange_rate.dart';

// To be replaced with whatever is in locale
NumberFormat satsFormatter = NumberFormat("###,###,###,###,###,###,###");
String decimalPoint = ".";
String thousandsSeparator = ",";

String getDisplayAmount(int amountSats, AmountDisplayUnit unit,
    {bool includeUnit = false, bool testnet = false}) {
  String? unitString;

  switch (unit) {
    case AmountDisplayUnit.btc:
      unitString = getBtcUnitString(testnet: testnet);
      break;
    case AmountDisplayUnit.sat:
      unitString = getSatsUnitString(testnet: testnet);
      break;
    case AmountDisplayUnit.fiat:
      unitString = null;
      break;
  }
  ;

  switch (unit) {
    case AmountDisplayUnit.btc:
      return convertSatsToBtcString(amountSats) +
          (includeUnit ? " " + unitString! : "");
    case AmountDisplayUnit.sat:
      return satsFormatter.format(amountSats) +
          (includeUnit ? " " + unitString! : "");
    case AmountDisplayUnit.fiat:
      return ExchangeRate().getSymbol() +
          convertFiatToFiatString(double.parse(ExchangeRate()
              .getFormattedAmount(amountSats, includeSymbol: false)
              .replaceAll(thousandsSeparator, "")));
  }
}

String convertSatsToBtcString(int amountSats, {bool trailingZeroes = false}) {
  final amountBtc = amountSats / 100000000;

  NumberFormat formatter = NumberFormat();
  formatter.minimumFractionDigits = trailingZeroes ? 8 : 0;
  formatter.maximumFractionDigits = 8;

  return formatter.format(amountBtc);
}

String convertFiatToFiatString(double Fiat, {bool trailingZeroes = false}) {
  NumberFormat formatter = NumberFormat();
  formatter.minimumFractionDigits = trailingZeroes ? 2 : 0;
  formatter.maximumFractionDigits = 2;

  return formatter.format(Fiat);
}

int convertSatsStringToSats(String amountSats) {
  if (amountSats.isEmpty) {
    return 0;
  }

  try {
    return int.parse(amountSats
        .replaceAll(decimalPoint, "")
        .replaceAll(thousandsSeparator, ""));
  } catch (e) {
    return 0;
  }
}

int convertBtcStringToSats(String amountBtc) {
  if (amountBtc.isEmpty) {
    return 0;
  }

  // There are 8 digits after the decimal point
  String sanitized = amountBtc.replaceAll(thousandsSeparator, "");
  int dotIndex = sanitized.indexOf(decimalPoint);
  int missingZeros = dotIndex < 0 ? 8 : 8 - (sanitized.length - dotIndex - 1);

  String dotRemoved = sanitized.replaceAll(decimalPoint, "");

  if (missingZeros < 0) {
    dotRemoved = dotRemoved.substring(0, dotRemoved.length + missingZeros);
    missingZeros = 0;
  }

  String satsString =
      dotRemoved.padRight(missingZeros + dotRemoved.length, "0");
  return convertSatsStringToSats(satsString);
}

String getFormattedAmount(int amountSats,
    {bool includeUnit = false, bool testnet = false}) {
  // TODO: this should be locale dependent?
  String text = Settings().displayUnit == DisplayUnit.btc
      ? convertSatsToBtcString(amountSats, trailingZeroes: true) +
          (includeUnit ? " " + getBtcUnitString(testnet: testnet) : "")
      : satsFormatter.format(amountSats) +
          (includeUnit ? " " + getSatsUnitString(testnet: testnet) : "");

  return text;
}

String getSatsUnitString({testnet = false}) {
  return testnet ? "TSATS".toLowerCase() : "SATS".toLowerCase();
}

String getBtcUnitString({testnet = false}) {
  return testnet ? "TBTC" : "BTC";
}
