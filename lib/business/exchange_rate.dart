// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:envoy/business/settings.dart';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:intl/intl.dart';
import 'package:tor/tor.dart';

class FiatCurrency {
  final String code;
  final String symbol;
  final int decimalPoints;

  FiatCurrency(this.code, this.symbol, {this.decimalPoints: 2});

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
];

class ExchangeRate extends ChangeNotifier {
  LocalStorage _ls = LocalStorage();

  double _rate = 0;
  FiatCurrency? _currency;

  HttpTor _http = HttpTor(Tor());
  String _serverAddress = Settings().nguServerAddress;

  static const String _LAST_EXCHANGE_RATE_PREFS = "exchange_rate";
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
    setCurrency(Settings().selectedFiat!);

    // Refresh from time to time
    Timer.periodic(Duration(seconds: 30), (_) {
      _getRate();
    });
  }

  _restoreRate() {
    if (_ls.prefs.containsKey(_LAST_EXCHANGE_RATE_PREFS)) {
      var storedExchangeRate =
          jsonDecode(_ls.prefs.getString(_LAST_EXCHANGE_RATE_PREFS)!);
      _rate = storedExchangeRate["rate"];
      setCurrency(storedExchangeRate["currency"]);
    }
  }

  void setCurrency(String currencyCode) {
    _currency =
        supportedFiat.firstWhere((element) => element.code == currencyCode);

    // Fetch rates for this session
    _getRate();
  }

  _storeRate(double rate, String currencyCode) {
    _rate = rate;
    notifyListeners();

    Map exchangeRateMap = {"currency": currencyCode, "rate": rate};
    String json = jsonEncode(exchangeRateMap);
    _ls.prefs.setString(_LAST_EXCHANGE_RATE_PREFS, json);
  }

  _getRate() {
    String currencyCode = Settings().selectedFiat!;
    _http.get(_serverAddress + '/price/' + currencyCode).then((response) {
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        var rate = json['reply']['BTC' + currencyCode]["last"];
        _storeRate(rate, currencyCode);
      } else {
        throw Exception("Couldn't get exchange rate");
      }
    }, onError: (_) {
      // ENV-175
      if (Tor().enabled) {
        print("Restarting Tor");
        Tor().restart();
      }
    });
  }

  String getFormattedAmount(int amountSats) {
    if (Settings().selectedFiat == null) {
      return "";
    }

    NumberFormat currencyFormatter =
        NumberFormat.currency(name: _currency!.symbol);
    return currencyFormatter.format(_rate * amountSats / 100000000);
  }
}
