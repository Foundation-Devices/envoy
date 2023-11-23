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
import 'package:envoy/business/scheduler.dart';

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

  double? _selectedCurrencyRate = 0;
  double? get selectedCurrencyRate => _selectedCurrencyRate;

  double? _usdRate = 0;
  double? get usdRate => _usdRate;
  FiatCurrency? _currency;

  HttpTor _http = HttpTor(Tor.instance, EnvoyScheduler().parallel);
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
    restoreRate();

    // Double check that that's still the choice
    setCurrency(Settings().selectedFiat ?? "USD");

    // Refresh from time to time
    Timer.periodic(Duration(seconds: 30), (_) {
      _getRate();
    });
  }

  restoreRate() async {
    final storedExchangeRate = await EnvoyStorage().getExchangeRate();

    if (storedExchangeRate != null) {
      _selectedCurrencyRate = storedExchangeRate[RATE_KEY] ?? 0;
      _usdRate = storedExchangeRate[USD_RATE_KEY];
      setCurrency(storedExchangeRate[CURRENCY_KEY] ?? "USD");
    }
  }

  void setCurrency(String currencyCode) {
    if (_currency == null || currencyCode != _currency?.code) {
      _selectedCurrencyRate = null;
    }

    // If code is wrong (for whatever reason) go with default
    _currency = supportedFiat.firstWhere(
        (element) => element.code == currencyCode,
        orElse: () => supportedFiat[0]);

    notifyListeners();

    // Fetch rates for this session
    _getRate();
  }

  _storeRate(double selectedRate, String currencyCode, double usdRate) {
    _usdRate = usdRate;

    if (Settings().selectedFiat == currencyCode) {
      _selectedCurrencyRate = selectedRate;
    }

    notifyListeners();

    Map exchangeRateMap = {
      CURRENCY_KEY: currencyCode,
      RATE_KEY: selectedRate,
      USD_RATE_KEY: _usdRate
    };

    EnvoyStorage().setExchangeRate(exchangeRateMap);
  }

  _getRate() async {
    String currencyCode = Settings().selectedFiat ?? "USD";
    double usdRate = await _getRateForCode("USD");
    double selectedRate = usdRate;

    if (Settings().selectedFiat != "USD") {
      selectedRate = await _getRateForCode(currencyCode);
    }
    _storeRate(selectedRate, currencyCode, usdRate);
  }

  Future<double> _getRateForCode(String currencyCode) async {
    try {
      final response =
          await _http.get(_serverAddress + '/price/' + currencyCode);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        var rate = json['reply']['BTC' + currencyCode]["last"];
        ConnectivityManager().nguSuccess();
        return rate.toDouble();
      } else {
        throw Exception("Couldn't get exchange rate");
      }
    } catch (e) {
      ConnectivityManager().nguFailure();
      rethrow;
    }
  }

  double getUsdValue(int amountSats) {
    return _usdRate! * amountSats / 100000000;
  }

  // SATS to FIAT
  String getFormattedAmount(int amountSats,
      {bool includeSymbol = true, Wallet? wallet}) {
    if (Settings().selectedFiat == null ||
        wallet?.network == Network.Testnet ||
        _selectedCurrencyRate == null) {
      return "";
    }

    NumberFormat currencyFormatter =
        NumberFormat.currency(name: _currency!.code, symbol: "");

    String formattedAmount = currencyFormatter
        .format(_selectedCurrencyRate! * amountSats / 100000000);

    return (includeSymbol ? _currency!.symbol : "") + formattedAmount;
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

    if (_selectedCurrencyRate == null) {
      return 0;
    }

    return double.parse(amountFiat) * 100000000 ~/ _selectedCurrencyRate!;
  }

  String getCode() {
    if (_currency?.code != null) {
      return _currency!.code;
    }
    return "";
  }
}
