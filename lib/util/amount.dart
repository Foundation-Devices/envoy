// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:intl/intl.dart';
import 'package:envoy/business/settings.dart';

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
    return int.parse(amountSats.replaceAll(".", ""));
  } catch (e) {
    return 0;
  }
}

int convertBtcStringToSats(String amountBtc) {
  if (amountBtc.isEmpty) {
    return 0;
  }

  // There are 8 digits after the decimal point
  String sanitized = amountBtc.replaceAll(",", "");
  int dotIndex = sanitized.indexOf(".");
  int missingZeros = dotIndex < 0 ? 8 : 8 - (sanitized.length - dotIndex);

  String dotRemoved = sanitized.replaceAll(".", "");

  String satsString =
      dotRemoved.padRight(missingZeros + dotRemoved.length, "0");
  return convertSatsStringToSats(satsString);
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
