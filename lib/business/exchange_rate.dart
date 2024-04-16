// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:envoy/business/settings.dart';
import 'package:http_tor/http_tor.dart';
import 'package:intl/intl.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/locale.dart';

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

  double? _selectedCurrencyRate = null;

  double? get selectedCurrencyRate => _selectedCurrencyRate;

  double? _usdRate = null;

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

    // Get rate from storage and set currency from Settings
    restore();

    // Refresh from time to time
    Timer.periodic(Duration(seconds: 30), (_) {
      _getRate();
    });
  }

  restore() {
    // First get whatever we saved last
    _restoreRate();

    // Double check that that's still the choice
    setCurrency(Settings().selectedFiat);
  }

  _restoreRate() async {
    final storedExchangeRate = await EnvoyStorage().getExchangeRate();

    if (storedExchangeRate != null &&
        storedExchangeRate["currency"] == Settings().selectedFiat) {
      _selectedCurrencyRate = storedExchangeRate[RATE_KEY] ?? 0;
      _usdRate = storedExchangeRate[USD_RATE_KEY];
    }
  }

  void setCurrency(String? currencyCode) {
    if (_currency == null || currencyCode != _currency?.code) {
      _selectedCurrencyRate = null;
    }

    if (currencyCode == null) {
      _currency = null;
      notifyListeners();
      return;
    }

    _currency = supportedFiat.firstWhere(
      (element) => element.code == currencyCode,
      // If code is wrong (for whatever reason) go with default
      orElse: () => supportedFiat[0],
    );

    notifyListeners();

    // Fetch rates for this session
    _getRate();
  }

  _storeRate(double selectedRate, String currencyCode, double usdRate) {
    _usdRate = usdRate;

    Map exchangeRateMap = {
      CURRENCY_KEY: currencyCode,
      RATE_KEY: selectedRate,
      USD_RATE_KEY: _usdRate
    };

    EnvoyStorage().setExchangeRate(exchangeRateMap);
  }

  _getRate() async {
    String selectedCurrencyCode = _currency?.code ?? ("USD");
    double? selectedRate = null;
    double? usdRate = null;

    try {
      if (selectedCurrencyCode != "USD") {
        selectedRate = await _getRateForCode(selectedCurrencyCode);
        _selectedCurrencyRate = selectedRate;
        notifyListeners();
      }

      usdRate = await _getRateForCode("USD");
      _usdRate = usdRate;
      if (selectedCurrencyCode == "USD") {
        _selectedCurrencyRate = usdRate;
      }
      notifyListeners();
    } on Exception catch (e) {
      EnvoyReport().log("connectivity", e.toString());
      return;
    }

    if (selectedRate == null) {
      selectedRate = usdRate;
    }

    _storeRate(selectedRate, selectedCurrencyCode, usdRate);
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
    return (_usdRate ?? 0) * amountSats / 100000000;
  }

  // SATS to FIAT
  String getFormattedAmount(int amountSats,
      {bool includeSymbol = true, Wallet? wallet}) {
    /// dont hide testnet fiat values on debug builds
    if (!kDebugMode) {
      /// hide testnet fiat values on production builds
      if (wallet?.network == Network.Testnet ||
          _currency == null ||
          _selectedCurrencyRate == null) {
        return "";
      }
    }

    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: currentLocale, symbol: "");

    String formattedAmount = currencyFormatter
        .format(_selectedCurrencyRate! * amountSats / 100000000);

    // NumberFormat still adds a non-breaking space if symbol is empty
    const int nonBreakingSpace = 0x00A0;
    formattedAmount =
        formattedAmount.replaceAll(String.fromCharCode(nonBreakingSpace), "");

    return (includeSymbol ? _currency?.symbol ?? '' : "") + formattedAmount;
  }

  String getSymbol() {
    if (_currency == null) {
      return "";
    }

    return _currency!.symbol;
  }

  int convertFiatStringToSats(String amountFiat) {
    amountFiat = amountFiat
        .replaceAll(RegExp('[^0-9$fiatDecimalSeparator]'), '')
        .replaceAll(fiatGroupSeparator, "");

    amountFiat = amountFiat.replaceAll(fiatDecimalSeparator, ".");

    if (_currency == null) {
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
