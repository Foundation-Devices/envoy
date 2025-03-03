// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:core';

import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/util/amount.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/bip21.dart';
import 'package:envoy/business/locale.dart';

class ParseResult {
  String? address;
  int? amountSats;
  AmountDisplayUnit? unit;
  double? displayFiat;

  ParseResult({this.address, this.amountSats, this.displayFiat, this.unit});
}

// Extract payment data from a random string
class BitcoinParser {
  static Future<ParseResult> parse(String data,
      {double? fiatExchangeRate,
      Wallet? wallet,
      String? selectedFiat,
      AmountDisplayUnit? currentUnit}) async {
    bool isBip21 = true;

    String? address;
    int? amountInSats;
    double? displayFiat;
    AmountDisplayUnit? unit;

    bool isFiatSelected =
        (selectedFiat == null || selectedFiat == "") ? false : true;

    String urnScheme = "bitcoin";
    if (wallet != null && await wallet.validateAddress(data)) {
      return ParseResult(
        address: data,
        amountSats: null,
        displayFiat: 0,
        unit: null,
      );
    }

    if (data.indexOf(urnScheme) != 0 || data[urnScheme.length] != ":") {
      isBip21 = false;
    }

    if (isBip21) {
      var bip21 = Bip21.decode(data);
      address = bip21.address;

      if (wallet != null && !await wallet.validateAddress(address)) {
        address = null;
      }

      // BIP-21 amounts are in BTC
      amountInSats = convertBtcStringToSats(bip21.amount.toString());
      displayFiat = convertSatsToFiat(amountInSats, fiatExchangeRate);

      unit = AmountDisplayUnit.btc;

      return ParseResult(
        address: address,
        amountSats: amountInSats,
        displayFiat: displayFiat,
        unit: unit,
      );
    }
    if (data.contains(",")) {
      data = data.replaceAll(",", ".");
    }

    if (data.contains("\$") && isFiatSelected) {
      unit = AmountDisplayUnit.fiat;
      data = data.replaceAll("\$", "");
      displayFiat = double.tryParse(data);
      amountInSats = getSatsFromFiat(data, fiatExchangeRate);
      return ParseResult(
        address: address,
        amountSats: amountInSats,
        displayFiat: displayFiat,
        unit: unit,
      );
    }
    bool isError = !isNumber(data);
    if (isError) {
      return ParseResult(
          address: null, amountSats: null, displayFiat: 0, unit: null);
    } else {
      var copiedStringParsed = double.parse(data);
      String numberAsString = copiedStringParsed.toString();
      int decimalPlaces = numberAsString.length -
          numberAsString.indexOf(fiatDecimalSeparator) -
          1;

      if (copiedStringParsed >= 21000000) {
        if ((copiedStringParsed % 1) == 0) {
          unit = (currentUnit == AmountDisplayUnit.btc)
              ? AmountDisplayUnit.sat
              : currentUnit;

          if (unit == AmountDisplayUnit.sat) {
            amountInSats = int.parse(data);
            displayFiat = convertSatsToFiat(amountInSats, fiatExchangeRate);
          }
          if (currentUnit == AmountDisplayUnit.fiat) {
            amountInSats = getSatsFromFiat(data, fiatExchangeRate);
            displayFiat = double.tryParse(data);
          }
        } else {
          if (!isFiatSelected) {
            return ParseResult(
                address: null, amountSats: null, displayFiat: 0, unit: unit);
          } else {
            unit = AmountDisplayUnit.fiat;
            amountInSats = getSatsFromFiat(data, fiatExchangeRate);
            displayFiat = double.tryParse(data);
          }
        }
        return ParseResult(
            address: null,
            amountSats: amountInSats,
            displayFiat: displayFiat,
            unit: unit);
      }

      if ((copiedStringParsed % 1) == 0) {
        // check is int
        unit = currentUnit;

        switch (unit) {
          case AmountDisplayUnit.sat:
            amountInSats = int.parse(data);
            displayFiat = convertSatsToFiat(amountInSats, fiatExchangeRate);

            break;

          case AmountDisplayUnit.btc:
            amountInSats = convertBtcStringToSats(data);
            displayFiat = convertSatsToFiat(amountInSats, fiatExchangeRate);

            break;

          case AmountDisplayUnit.fiat:
            amountInSats = getSatsFromFiat(data, fiatExchangeRate);
            displayFiat = double.tryParse(data);
            break;
          case null:
            break;
        }
        return ParseResult(
            address: null,
            amountSats: amountInSats,
            displayFiat: displayFiat,
            unit: unit);
      }

      if (!isFiatSelected || decimalPlaces >= 3) {
        unit = AmountDisplayUnit.btc;
        amountInSats = convertBtcStringToSats(data);
        displayFiat = convertSatsToFiat(amountInSats, fiatExchangeRate);

        return ParseResult(
            address: null,
            amountSats: amountInSats,
            displayFiat: displayFiat,
            unit: unit);
      }

      if (copiedStringParsed < 1 && copiedStringParsed >= 0.01) {
        unit = currentUnit;

        switch (unit) {
          case AmountDisplayUnit.sat:
            unit = AmountDisplayUnit.btc;
            amountInSats = convertBtcStringToSats(data);
            displayFiat = convertSatsToFiat(amountInSats, fiatExchangeRate);

            break;

          case AmountDisplayUnit.btc:
            amountInSats = convertBtcStringToSats(data);
            displayFiat = convertSatsToFiat(amountInSats, fiatExchangeRate);

            break;

          case AmountDisplayUnit.fiat:
            amountInSats = getSatsFromFiat(data, fiatExchangeRate);
            displayFiat = double.tryParse(data);
            break;
          case null:
            break;
        }
        return ParseResult(
          address: null,
          amountSats: amountInSats,
          displayFiat: displayFiat,
          unit: unit,
        );
      }
      var copiedInBtc = copiedStringParsed;

      int amountInWalletBtc;
      if (wallet == null) {
        amountInWalletBtc = 0;
      } else {
        amountInWalletBtc = wallet.balance ~/ 100000000;
      }

      if (copiedInBtc < amountInWalletBtc) {
        amountInSats = convertBtcStringToSats(data);
        displayFiat = convertSatsToFiat(amountInSats, fiatExchangeRate);
        unit = AmountDisplayUnit.btc;
      } else {
        amountInSats = getSatsFromFiat(data, fiatExchangeRate);
        displayFiat = double.tryParse(data);
        unit = AmountDisplayUnit.fiat;
      }
    }
    return ParseResult(
        address: address,
        amountSats: amountInSats,
        displayFiat: displayFiat,
        unit: unit);
  }

  static bool isNumber(String string) {
    if (string.isEmpty) {
      return false;
    }

    if (string[0] == "-") return false;
    final number = num.tryParse(string);

    if (number == null) {
      return false;
    }

    return true;
  }

  static int getSatsFromFiat(String amountFiat, double? fiatRate) {
    amountFiat =
        amountFiat.replaceAll(RegExp('[^0-9.]'), '').replaceAll(",", "");

    if (amountFiat.isEmpty) {
      return 0;
    }

    return double.parse(amountFiat) * 100000000 ~/ fiatRate!;
  }

  // SATS to double FIAT
  static double convertSatsToFiat(
      int amountSats, double? selectedCurrencyRate) {
    if (selectedCurrencyRate == null) {
      return 0;
    }

    return (amountSats / 100000000) * selectedCurrencyRate;
  }
}
