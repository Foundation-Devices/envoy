// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wallet/wallet.dart';

// Always use comma to group thousands of BTC and dot to separate the sats
NumberFormat satsFormatter = NumberFormat("###,###,###,###,###,###,###");
String btcSatoshiSeparator = ".";
String thousandSatSeparator = ",";

String getDisplayAmount(
  int amountSats,
  AmountDisplayUnit unit,
) {
  switch (unit) {
    case AmountDisplayUnit.btc:
      return convertSatsToBtcString(amountSats);
    case AmountDisplayUnit.sat:
      return satsFormatter.format(amountSats);
    case AmountDisplayUnit.fiat:
      var formattedString = ExchangeRate().getFormattedAmount(
        amountSats,
        includeSymbol: false,
      );
      return removeFiatTrailingZeros(formattedString);
  }
}

String removeFiatTrailingZeros(String fiatAmount) {
  if (fiatAmount.contains(fiatDecimalSeparator)) {
    while (fiatAmount[fiatAmount.length - 1] == "0") {
      fiatAmount = fiatAmount.substring(0, fiatAmount.length - 1);
    }

    if (fiatAmount[fiatAmount.length - 1] == fiatDecimalSeparator) {
      fiatAmount = fiatAmount.substring(0, fiatAmount.length - 1);
    }
  }
  return fiatAmount;
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

  try {
    return int.parse(amountSats
        .replaceAll(btcSatoshiSeparator, "")
        .replaceAll(thousandSatSeparator, ""));
  } catch (e) {
    return 0;
  }
}

int convertBtcStringToSats(String amountBtc) {
  if (amountBtc.isEmpty) {
    return 0;
  }

  // There are 8 digits after the decimal point
  String sanitized = amountBtc;
  int dotIndex = sanitized.indexOf(btcSatoshiSeparator);
  int missingZeros = dotIndex < 0 ? 8 : 8 - (sanitized.length - dotIndex - 1);

  String dotRemoved = sanitized.replaceAll(btcSatoshiSeparator, "");

  if (missingZeros < 0) {
    dotRemoved = dotRemoved.substring(0, dotRemoved.length + missingZeros);
    missingZeros = 0;
  }

  String satsString =
      dotRemoved.padRight(missingZeros + dotRemoved.length, "0");
  return convertSatsStringToSats(satsString);
}

String getFormattedAmount(int amountSats,
    {bool includeUnit = false,
    bool testnet = false,
    trailingZeroes = false,
    AmountDisplayUnit? unit}) {
  String text = "";
  if (unit != null) {
    text = (unit) == AmountDisplayUnit.btc
        ? convertSatsToBtcString(amountSats, trailingZeroes: trailingZeroes)
        : satsFormatter.format(amountSats);
  } else {
    text = Settings().displayUnit == DisplayUnit.btc
        ? convertSatsToBtcString(amountSats, trailingZeroes: trailingZeroes)
        : satsFormatter.format(amountSats);
  }

  return text;
}

Widget getSatsIcon(Account account, {EnvoyIconSize? iconSize}) {
  if (account.wallet.network != Network.Testnet) {
    return EnvoyIcon(
      EnvoyIcons.sats,
      size: iconSize ?? EnvoyIconSize.normal,
    );
  } else {
    return TestnetIcon(
      EnvoyIcons.sats,
      color: account.color,
      size: iconSize ?? EnvoyIconSize.normal,
    );
  }
}

Widget getBtcIcon(Account account, {EnvoyIconSize? iconSize}) {
  if (account.wallet.network != Network.Testnet) {
    return EnvoyIcon(
      EnvoyIcons.btc,
      size: iconSize ?? EnvoyIconSize.normal,
    );
  } else {
    return TestnetIcon(
      EnvoyIcons.btc,
      color: account.color,
      size: iconSize ?? EnvoyIconSize.normal,
    );
  }
}

String truncateWithEllipsisInCenter(String text, int maxLength) {
  if (text.length <= maxLength) {
    return text;
  }

  final ellipsis = '...';
  final ellipsisLength = ellipsis.length;

  final halfMaxLength = (maxLength - ellipsisLength) ~/ 2;
  final firstHalf = text.substring(0, halfMaxLength);
  final secondHalf = text.substring(text.length - halfMaxLength);

  return '$firstHalf$ellipsis$secondHalf';
}

Widget getUnitIcon(Account account, {EnvoyIconSize? iconSize}) {
  Widget iconUint = Settings().displayUnit == DisplayUnit.btc
      ? getBtcIcon(account, iconSize: iconSize)
      : getSatsIcon(account, iconSize: iconSize);

  return iconUint;
}

Widget displayIcon(Account account, AmountDisplayUnit unit) {
  if (unit == AmountDisplayUnit.fiat) {
    return Text(
      ExchangeRate().getSymbol(),
      style: EnvoyTypography.body.copyWith(color: Colors.black, fontSize: 20),
      // style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  if (unit == AmountDisplayUnit.btc) {
    return getBtcIcon(account);
  } else
    return getSatsIcon(account);
}
