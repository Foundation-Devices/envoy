// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:envoy/business/settings.dart';
import 'package:flutter/services.dart';
import 'package:http_tor/http_tor.dart';
import 'package:intl/intl.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/locale.dart';

class FiatCurrency {
  final String code;
  final String title;
  final String symbol;
  final int decimalPoints;
  final String flag;

  FiatCurrency({
    this.decimalPoints = 2,
    required this.title,
    required this.code,
    required this.symbol,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FiatCurrency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  static fromCode(String code) {
    return FiatCurrency(
        code: code, title: "", symbol: "", flag: "", decimalPoints: 2);
  }

  static FiatCurrency fromJson(Map<String, dynamic> json) {
    return FiatCurrency(
      code: json['code'],
      title: json['title'],
      symbol: json['symbol'],
      flag: json['flag'],
    );
  }
}

// default/fallback fiat

class ExchangeRate extends ChangeNotifier {
  List<FiatCurrency> _supportedFiat = [
    FiatCurrency(title: "US Dollar", code: 'USD', symbol: '\$', flag: "🇺🇸"),
    FiatCurrency(title: "Euro", code: 'EUR', symbol: '€', flag: "🇪🇺"),
    FiatCurrency(
        title: "British Pound", code: 'GBP', symbol: '£', flag: "🇬🇧"),
  ];

  List<FiatCurrency> get supportedFiat => _supportedFiat;

  @override
  // ignore: must_call_super
  void dispose({bool? force}) {
    // prevents riverpods StateNotifierProvider from disposing it
    if (force == true) {
      super.dispose();
    }
  }

  final String RATE_KEY = "rate";
  final String USD_RATE_KEY = "usdRate";
  final String CURRENCY_KEY = "currency";

  double? _selectedCurrencyRate;

  double? get selectedCurrencyRate => _selectedCurrencyRate;

  double? _usdRate;

  bool _isFetchingData = false;

  double? get usdRate => _usdRate;
  FiatCurrency? _selectedCurrency;

  final HttpTor _http = HttpTor(Tor.instance, EnvoyScheduler().parallel);
  final String _serverAddress = Settings().nguServerAddress;

  static final ExchangeRate _instance = ExchangeRate._internal();

  factory ExchangeRate() {
    return _instance;
  }

  static Future<ExchangeRate> init() async {
    var singleton = ExchangeRate._instance;
    return singleton;
  }

  ExchangeRate._internal() {
    kPrint("Instance of ExchangeRate created!");

    //load supported currencies
    rootBundle.loadString("assets/currencies.json").then((value) {
      final List<dynamic> json = jsonDecode(value);
      _supportedFiat = json.map((e) => FiatCurrency.fromJson(e)).toList();
      kPrint("Currencies loaded");
      // Get rate from storage and set currency from Settings
      restore();
    }, onError: (e, stackTrace) {
      kPrint("ExchangeRate", stackTrace: stackTrace);
      EnvoyReport().log("ExchangeRate", "Error loading currencies: $e");
      // Get rate from storage and set currency from Settings
      restore();
    });

    // Refresh from time to time
    Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!_isFetchingData &&
          _selectedCurrency != null &&
          _selectedCurrency!.code != "USD") {
        await _getNonUsdRate(true);
      }
    });

    // *Always* get USD
    Timer.periodic(const Duration(seconds: 30), (_) async {
      await _getUsdRate();
      if (_selectedCurrency != null && _selectedCurrency!.code == "USD") {
        _selectedCurrencyRate = _usdRate;
        notifyListeners();
      }
    });
  }

  restore() async {
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

  void setCurrency(String? currencyCode) async {
    if (_selectedCurrency == null || currencyCode != _selectedCurrency?.code) {
      _selectedCurrencyRate = null;
    }

    if (currencyCode == null) {
      _selectedCurrency = null;
      notifyListeners();
      return;
    }
    _selectedCurrency = supportedFiat.firstWhere(
      (element) => element.code == currencyCode,
      // If code is wrong (for whatever reason) go with default
      orElse: () => supportedFiat[0],
    );

    if (_selectedCurrency!.code == "USD") {
      _selectedCurrencyRate = _usdRate;
    }

    // Fetch rates for this session
    if (currencyCode != "USD") {
      _getNonUsdRate(false);
    }

    notifyListeners();
  }

  _storeRate(double? selectedRate, String? currencyCode, double? usdRate) {
    Map exchangeRateMap = {
      CURRENCY_KEY: currencyCode,
      RATE_KEY: selectedRate,
      USD_RATE_KEY: usdRate
    };

    EnvoyStorage().setExchangeRate(exchangeRateMap);
  }

  _getNonUsdRate(bool triggeredByTimer) async {
    // We have a separate function for USD
    if (_selectedCurrency == null) {
      return;
    }

    // Exit if a fetch is already in progress and it's not a manual fetch
    if (_isFetchingData && triggeredByTimer) {
      return;
    }
    _isFetchingData = true;

    String selectedCurrencyCode = _selectedCurrency!.code;
    double selectedRate = 0;

    try {
      if (selectedCurrencyCode != "USD") {
        selectedRate = await _getRateForCode(selectedCurrencyCode);

        if (selectedCurrencyCode == _selectedCurrency?.code) {
          _selectedCurrencyRate = selectedRate;
          notifyListeners();
        } else {
          // If the currency code has changed during the fetch, reenter
          _getNonUsdRate(false);
          return;
        }
      }
    } on Exception catch (e) {
      EnvoyReport().log("connectivity", e.toString());
      _isFetchingData = false;
      return;
    }

    _storeRate(selectedRate, selectedCurrencyCode, _usdRate);
    _isFetchingData = false;
  }

  _getUsdRate() async {
    try {
      _usdRate = await _getRateForCode("USD");
      _storeRate(_selectedCurrencyRate, _selectedCurrency?.code, _usdRate);
    } on Exception catch (e) {
      EnvoyReport().log("connectivity", e.toString());
    }
  }

  Future<double> _getRateForCode(String currencyCode) async {
    try {
      final response = await _http.get('$_serverAddress/price/$currencyCode');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        var rate = json['reply']['BTC$currencyCode']["last"];
        ConnectivityManager().nguSuccess();
        return rate.toDouble();
      } else {
        throw Exception("Couldn't get exchange rate");
      }
    } catch (e) {
      kPrint("Couldn't get exchange rate: $e");
      ConnectivityManager().nguFailure();
      rethrow;
    }
  }

  double getUsdValue(int amountSats) {
    return (_usdRate ?? 0) * amountSats / 100000000;
  }

  // SATS to double FIAT
  double convertSatsToFiat(int amountSats) {

    if (_selectedCurrencyRate == null) {
      return 0;
    }

    return (amountSats / 100000000) * _selectedCurrencyRate!;
  }

  // SATS to FIAT
  String getFormattedAmount(int amountSats,
      {bool includeSymbol = true, Wallet? wallet}) {
    // Hide test coins on production builds only
    if (!kDebugMode && wallet != null && wallet.network != Network.Mainnet) {
      return "";
    }

    if (_selectedCurrency == null || _selectedCurrencyRate == null) {
      return "";
    }

    NumberFormat currencyFormatter =
        NumberFormat.currency(locale: currentLocale, symbol: "");

    if (_selectedCurrencyRate == null) {
      return "";
    }

    String formattedAmount = currencyFormatter
        .format(_selectedCurrencyRate! * amountSats / 100000000);

    // NumberFormat still adds a non-breaking space if symbol is empty
    const int nonBreakingSpace = 0x00A0;
    formattedAmount =
        formattedAmount.replaceAll(String.fromCharCode(nonBreakingSpace), "");

    return (includeSymbol ? _selectedCurrency?.symbol ?? '' : "") +
        formattedAmount;
  }

  String getSymbol() {
    if (_selectedCurrency == null) {
      return "";
    }

    return _selectedCurrency!.symbol;
  }

  int convertFiatStringToSats(String amountFiat) {
    amountFiat = amountFiat
        .replaceAll(RegExp('[^0-9$fiatDecimalSeparator]'), '')
        .replaceAll(fiatGroupSeparator, "");

    amountFiat = amountFiat.replaceAll(fiatDecimalSeparator, ".");

    if (_selectedCurrency == null) {
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
    if (_selectedCurrency?.code != null) {
      return _selectedCurrency!.code;
    }
    return "";
  }
}
