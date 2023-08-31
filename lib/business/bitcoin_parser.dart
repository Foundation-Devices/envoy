// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/util/amount.dart';
import 'package:wallet/wallet.dart';
import 'bip21.dart';

class ParseResult {
  String? address;
  int? amountSats;
  AmountDisplayUnit? unit;

  ParseResult({this.address, this.amountSats, this.unit});
}

// Extract payment data from a random string
class BitcoinParser {
  static Future<ParseResult> parse(String data,
      {double? fiatExchangeRate, Wallet? wallet, String? selectedFiat}) async {
    bool isBip21 = true;

    String? address;
    int? amountInSats;
    AmountDisplayUnit? unit;

    bool isFiatSelected =
        (selectedFiat == null || selectedFiat == "") ? false : true;

    String urnScheme = "bitcoin";
    if (wallet != null && await wallet.validateAddress(data)) {
      return ParseResult(
        address: data,
        amountSats: null,
        unit: null,
      );
    }

    if (data.indexOf(urnScheme) != 0 || data[urnScheme.length] != ":")
      isBip21 = false;

    if (isBip21) {
      var bip21 = Bip21.decode(data);
      address = bip21.address;

      if (wallet != null && !await wallet.validateAddress(address)) {
        address = null;
      }

      // BIP-21 amounts are in BTC
      amountInSats = convertBtcStringToSats(bip21.amount.toString());
      unit = AmountDisplayUnit.btc;
      return ParseResult(
        address: address,
        amountSats: amountInSats,
        unit: unit,
      );
    }
    if (data.contains(",")) {
      data = data.replaceAll(",", ".");
    }

    if (data.contains("\$") && isFiatSelected) {
      unit = AmountDisplayUnit.fiat;
      data = data.replaceAll("\$", "");
      amountInSats = getSatsFromUsd(data, fiatExchangeRate);
      return ParseResult(
        address: address,
        amountSats: amountInSats,
        unit: unit,
      );
    }
    bool isError = !isNumber(data);
    if (isError) {
      return ParseResult(address: null, amountSats: null, unit: null);
    } else {
      var copiedStringParsed = double.parse(data);

      if ((copiedStringParsed % 1) == 0) {
        // check is int
        unit = AmountDisplayUnit.sat;
        amountInSats = int.parse(data);

        return ParseResult(
            address: null,
            amountSats: amountInSats,
            unit: AmountDisplayUnit.sat);
      }
      if (!isFiatSelected) {
        unit = AmountDisplayUnit.btc;
        amountInSats = convertBtcStringToSats(data);
        return ParseResult(address: null, amountSats: amountInSats, unit: unit);
      }

      if (copiedStringParsed <= 0.001) {
        unit = AmountDisplayUnit.btc;
        amountInSats = convertBtcStringToSats(data);
        return ParseResult(
          address: null,
          amountSats: amountInSats,
          unit: unit,
        );
      }
      var copiedInBtc = copiedStringParsed;

      var amountInWalletBtc;
      if (wallet == null)
        amountInWalletBtc = 0;
      else
        amountInWalletBtc = (wallet.balance / 100000000);

      if (copiedInBtc < amountInWalletBtc) {
        amountInSats = convertBtcStringToSats(data);
        unit = AmountDisplayUnit.btc;
      } else {
        amountInSats = getSatsFromUsd(data, fiatExchangeRate);
        unit = AmountDisplayUnit.fiat;
      }
    }

    return ParseResult(address: address, amountSats: amountInSats, unit: unit);
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

  static int getSatsFromUsd(amountFiat, fiatRate) {
    amountFiat =
        amountFiat.replaceAll(RegExp('[^0-9.]'), '').replaceAll(",", "");

    if (amountFiat.isEmpty) {
      return 0;
    }

    return double.parse(amountFiat) * 100000000 ~/ fiatRate!;
  }
}
