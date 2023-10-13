// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/settings.dart';
import 'package:http_tor/http_tor.dart';
import 'package:intl/intl.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';

final String userLocale = Platform.localeName;
NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: userLocale);

String get fiatDecimalSeparator {
  return numberFormat.symbols.DECIMAL_SEP;
}

// Usually this is a thousands separator
String get fiatGroupSeparator {
  return numberFormat.symbols.GROUP_SEP;
}

class FiatCurrency {
  final String code;
  final String symbol;
  final int decimalPoints;

  FiatCurrency(this.code, this.symbol, {this.decimalPoints = 2});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FiatCurrency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

final List<FiatCurrency> supportedFiat = [
  FiatCurrency('USD', '\$'),
  FiatCurrency('EUR', '€'),
  FiatCurrency('GBP', '£'),
  FiatCurrency('JPY', '¥', decimalPoints: 0),
  FiatCurrency('AUD', '\$'),
  FiatCurrency('CAD', '\$'),
  FiatCurrency('CHF', 'fr.'),
  FiatCurrency('MYR', 'RM'),
  FiatCurrency('BRL', 'R\$'),
];

class ExchangeRate extends ChangeNotifier {
  final String RATE_KEY = "rate";
  final String USD_RATE_KEY = "usdRate";
  final String CURRENCY_KEY = "currency";

  double _selectedCurrencyRate = 0;
  double? get selectedCurrencyRate => _selectedCurrencyRate;

  double? _usdRate = 0;
  double? get usdRate => _usdRate;
  FiatCurrency? _currency;

  HttpTor _http = HttpTor(Tor.instance);
  String _serverAddress = Settings().nguServerAddress;

  static final ExchangeRate _instance = ExchangeRate._internal();

  factory ExchangeRate() {
    return _instance;
  }

  static Future<ExchangeRate> init() async {
    var singleton = ExchangeRate._instance;
    return singleton;
  }

  ExchangeRate._internal() {
    print("Instance of ExchangeRate created!");

    // First get whatever we saved last
    _restoreRate();

    // Double check that that's still the choice
    setCurrency(Settings().selectedFiat ?? "USD");

    // Refresh from time to time
    Timer.periodic(Duration(seconds: 30), (_) {
      _getRate();
    });
  }

  _restoreRate() async {
    final storedExchangeRate = await EnvoyStorage().getExchangeRate();

    if (storedExchangeRate != null) {
      _selectedCurrencyRate = storedExchangeRate[RATE_KEY] ?? 0;
      _usdRate = storedExchangeRate[USD_RATE_KEY];
      setCurrency(storedExchangeRate[CURRENCY_KEY] ?? "USD");
    }
  }

  void setCurrency(String currencyCode) {
    // If code is wrong (for whatever reason) go with default
    _currency = supportedFiat.firstWhere(
        (element) => element.code == currencyCode,
        orElse: () => supportedFiat[0]);

    // Fetch rates for this session
    _getRate();
  }

  _storeRate(double rate, String currencyCode) {
    if (currencyCode == "USD") {
      _usdRate = rate;
    }

    if (Settings().selectedFiat == currencyCode) {
      _selectedCurrencyRate = rate;
    }

    notifyListeners();

    Map exchangeRateMap = {
      CURRENCY_KEY: currencyCode,
      RATE_KEY: rate,
      USD_RATE_KEY: _usdRate
    };

    EnvoyStorage().setExchangeRate(exchangeRateMap);
  }

  _getRate() {
    String currencyCode = Settings().selectedFiat ?? "USD";
    _getRateForCode("USD");

    if (Settings().selectedFiat != "USD") {
      _getRateForCode(currencyCode);
    }
  }

  void _getRateForCode(String currencyCode) {
    _http.get(_serverAddress + '/price/' + currencyCode).then((response) {
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        var rate = json['reply']['BTC' + currencyCode]["last"];
        _storeRate(rate, currencyCode);
        ConnectivityManager().nguSuccess();
      } else {
        throw Exception("Couldn't get exchange rate");
      }
    }).onError((e, s) {
      ConnectivityManager().nguFailure();
    });
  }

  double getUsdValue(int amountSats) {
    return _usdRate! * amountSats / 100000000;
  }

  // SATS to FIAT
  String getFormattedAmount(int amountSats,
      {bool includeSymbol = true, Wallet? wallet}) {
    if (Settings().selectedFiat == null || wallet?.network == Network.Testnet) {
      return "";
    }

    NumberFormat currencyFormatter = NumberFormat.currency(
        locale: userLocale,
        name: _currency!.symbol,
        symbol: includeSymbol ? null : "");

    String formattedAmount = currencyFormatter
        .format(_selectedCurrencyRate * amountSats / 100000000);

    if (!includeSymbol) {
      // NumberFormat still adds a non-breaking space if symbol is empty
      const int $nbsp = 0x00A0;
      formattedAmount =
          formattedAmount.replaceAll(String.fromCharCode($nbsp), "");
    }

    return formattedAmount;
  }

  String getSymbol() {
    if (Settings().selectedFiat == null) {
      return "";
    }

    return _currency!.symbol;
  }

  int convertFiatStringToSats(String amountFiat) {
    amountFiat = amountFiat
        .replaceAll(RegExp('[^0-9$fiatDecimalSeparator]'), '')
        .replaceAll(fiatGroupSeparator, "");

    amountFiat = amountFiat.replaceAll(fiatDecimalSeparator, ".");

    if (Settings().selectedFiat == null) {
      return 0;
    }

    if (amountFiat.isEmpty) {
      return 0;
    }

    return double.parse(amountFiat) * 100000000 ~/ _selectedCurrencyRate;
  }

  String getCode() {
    if (_currency?.code != null) {
      return _currency!.code;
    }
    return "";
  }
}
