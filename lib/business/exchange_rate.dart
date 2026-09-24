// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/rate_refresh_request.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:envoy/business/settings.dart';
import 'package:flutter/services.dart';
import 'package:http_tor/http_tor.dart';
import 'package:intl/intl.dart';
import 'package:ngwallet/ngwallet.dart';
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

  static FiatCurrency fromCode(String code) {
    return FiatCurrency(
      code: code,
      title: "",
      symbol: "",
      flag: "",
      decimalPoints: 2,
    );
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
      title: "British Pound",
      code: 'GBP',
      symbol: '£',
      flag: "🇬🇧",
    ),
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
  final String HISTORY_KEY = "history";

  double? _selectedCurrencyRate;

  double? get selectedCurrencyRate => _selectedCurrencyRate;

  double? _usdRate;
  DateTime? _usdRateTimestamp;

  final _nonUsdRateRequest = RateRefreshRequest();

  double? get usdRate => _usdRate;

  DateTime? get usdRateTimestamp => _usdRateTimestamp;
  FiatCurrency? _selectedCurrency;

  final HttpTor _http = HttpTor();

  static String get _serverAddress {
    return Settings().nguServerAddress;
  }

  ExchangeRateHistory _history = ExchangeRateHistory(currency: "", points: []);

  ExchangeRateHistory get history => _history;

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
    rootBundle.loadString("assets/currencies.json").then(
      (value) {
        final List<dynamic> json = jsonDecode(value);
        _supportedFiat = json.map((e) => FiatCurrency.fromJson(e)).toList();
        kPrint("Currencies loaded");
        // Get rate from storage and set currency from Settings
        restore();
      },
      onError: (e, stackTrace) {
        kPrint("ExchangeRate", stackTrace: stackTrace);
        EnvoyReport().log("ExchangeRate", "Error loading currencies: $e");
        // Get rate from storage and set currency from Settings
        restore();
      },
    );

    // Refresh from time to time
    Timer.periodic(const Duration(seconds: 30), (_) async {
      await _getNonUsdRate(true);
    });

    // *Always* get USD
    Timer.periodic(const Duration(seconds: 30), (_) async {
      await _getUsdRate();
      if (_selectedCurrency != null && _selectedCurrency!.code == "USD") {
        _selectedCurrencyRate = _usdRate;
      }
      notifyListeners();
    });
  }

  Future<void> restore() async {
    // First get whatever we saved last
    _restoreRate();
    // Double check that that's still the choice
    setCurrency(Settings().selectedFiat);
  }

  Future<void> _restoreRate() async {
    final storedExchangeRate = await EnvoyStorage().getExchangeRate();

    if (storedExchangeRate != null &&
        storedExchangeRate["currency"] == Settings().selectedFiat) {
      _selectedCurrencyRate = storedExchangeRate[RATE_KEY] ?? 0;
      _usdRate = storedExchangeRate[USD_RATE_KEY];
    }
    if (storedExchangeRate != null && storedExchangeRate[HISTORY_KEY] != null) {
      _history = ExchangeRateHistory.fromJson(
        Map<String, dynamic>.from(storedExchangeRate[HISTORY_KEY]),
      );
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
    } else {
      _getUsdRate();
    }

    notifyListeners();
  }

  void _storeRate(double? selectedRate, String? currencyCode, double? usdRate) {
    Map exchangeRateMap = {
      CURRENCY_KEY: currencyCode,
      RATE_KEY: selectedRate,
      USD_RATE_KEY: usdRate,
      HISTORY_KEY: _history.toJson(),
    };

    EnvoyStorage().setExchangeRate(exchangeRateMap);
  }

  Future<void> _getNonUsdRate(bool triggeredByTimer) async {
    // We have a separate function for USD
    final selectedCurrencyCode = _selectedCurrency?.code;
    if (selectedCurrencyCode == null || selectedCurrencyCode == "USD") {
      return;
    }

    try {
      await _nonUsdRateRequest.run(
        triggeredByTimer: triggeredByTimer,
        fetch: (isCurrentRequest) async {
          bool isCurrent() =>
              isCurrentRequest() &&
              selectedCurrencyCode == _selectedCurrency?.code;

          final selectedRate = await _getRateForCode(selectedCurrencyCode);
          if (!isCurrent()) return;
          // A slow history request must not hide a freshly fetched price.
          _selectedCurrencyRate = selectedRate;
          notifyListeners();
          await _fetchRateHistory(selectedCurrencyCode, shouldApply: isCurrent);
          if (!isCurrent()) return;

          _storeRate(selectedRate, selectedCurrencyCode, _usdRate);
        },
      );
    } catch (e, stack) {
      // Dynamic response parsing can throw Errors as well as Exceptions.
      EnvoyReport().log("connectivity", e.toString(), stackTrace: stack);
    }
  }

  Future<void> _getUsdRate() async {
    try {
      final selected = _selectedCurrency?.code;
      if (selected == null || selected == "USD") {
        await _fetchRateHistory(
          "USD",
          shouldApply: () =>
              _selectedCurrency == null || _selectedCurrency?.code == "USD",
        );
      }
      _usdRate = await _getRateForCode("USD");
      _usdRateTimestamp = DateTime.now();
      _storeRate(_selectedCurrencyRate, _selectedCurrency?.code, _usdRate);
    } catch (e, stack) {
      EnvoyReport().log("connectivity", e.toString(), stackTrace: stack);
    }
  }

  Future<double> getRateForCode(String currencyCode) =>
      _getRateForCode(currencyCode);

  Future<double> _getRateForCode(String currencyCode) async {
    try {
      final response = await _http.get('$_serverAddress/price/$currencyCode');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        var rate = json['reply']['BTC$currencyCode']["last"];
        ConnectivityManager().nguSuccess();
        return rate.toDouble();
      } else {
        ConnectivityManager().nguFailure();
        throw Exception("Couldn't get exchange rate");
      }
    } catch (e) {
      kPrint("Couldn't get exchange rate: $e");
      ConnectivityManager().nguFailure();
      rethrow;
    }
  }

  Future<void> _fetchRateHistory(
    String currency, {
    required bool Function() shouldApply,
  }) async {
    try {
      final response = await _http.get('$_serverAddress/history/$currency');

      if (response.statusCode != 200) {
        kPrint(
            "History fetch failed for $currency: HTTP ${response.statusCode}");
        return;
      }

      final jsonData = jsonDecode(response.body);

      final history = ExchangeRateHistory.fromJson({
        "currency": jsonData['fiat'],
        "points": jsonData["points"],
      });
      if (!history.isUsableFor(currency)) {
        kPrint("Invalid history for $currency");
        return;
      }

      if (!shouldApply()) return;
      _history = history;
      notifyListeners();
    } catch (e) {
      kPrint("History fetch failed for $currency: $e");
    }
  }

  /// Fetches history for [currencyCode] without mutating the
  /// cached `_history`, so Envoy's own fiat selection isn't disturbed.
  Future<ExchangeRateHistory?> fetchHistoryForCode(String currencyCode) async {
    try {
      final response = await _http.get('$_serverAddress/history/$currencyCode');
      if (response.statusCode != 200) {
        kPrint(
            "History fetch failed for $currencyCode: HTTP ${response.statusCode}");
        return null;
      }
      final jsonData = jsonDecode(response.body);
      final history = ExchangeRateHistory.fromJson({
        "currency": jsonData['fiat'],
        "points": jsonData["points"],
      });
      if (!history.isUsableFor(currencyCode)) {
        kPrint("Invalid history for $currencyCode");
        return null;
      }
      return history;
    } catch (e) {
      kPrint("History fetch failed for $currencyCode: $e");
      return null;
    }
  }

  double getUsdValue(int amountSats) {
    return (_usdRate ?? 0) * amountSats / 100000000;
  }

  Future<void> refreshHistory() async {
    await _getUsdRate();
  }

  // double FIAT to string FIAT
  String formatFiatToString(double amount, {bool isPrimaryValue = false}) {
    if (isPrimaryValue && amount == 0) {
      return "0";
    }
    // format via Settings().selectedFiat
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: currentLocale,
      symbol: "",
      name: Settings().selectedFiat,
    );

    return currencyFormatter.format(amount);
  }

  // SATS to double FIAT
  double convertSatsToFiat(int amountSats) {
    if (_selectedCurrencyRate == null) {
      return 0;
    }

    return (amountSats / 100000000) * _selectedCurrencyRate!;
  }

  // SATS to FIAT
  String getFormattedAmount(
    int amountSats, {
    bool includeSymbol = true,
    Network? network,
    double? displayFiat,
    bool useFiatFormatting = false,
  }) {
    // Hide test coins on production builds only
    if (!kDebugMode && network != null && network != Network.bitcoin) {
      return "";
    }

    if (_selectedCurrency == null || _selectedCurrencyRate == null) {
      return "";
    }

    final currencyFormatter = useFiatFormatting
        ? NumberFormat.currency(
            locale: currentLocale,
            symbol: "",
            name: Settings().selectedFiat,
          )
        : NumberFormat.decimalPattern(currentLocale);

    String formattedAmount;

    if (displayFiat != null) {
      formattedAmount = currencyFormatter.format(displayFiat);
    } else {
      formattedAmount = currencyFormatter.format(
        _selectedCurrencyRate! * amountSats / 100000000,
      );

      // NumberFormat still adds a non-breaking space if symbol is empty
      const int nonBreakingSpace = 0x00A0;
      formattedAmount = formattedAmount.replaceAll(
        String.fromCharCode(nonBreakingSpace),
        "",
      );
    }

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

class RatePoint {
  final double price;
  final int timestamp;

  RatePoint({required this.price, required this.timestamp});

  factory RatePoint.fromJson(Map<String, dynamic> json) {
    return RatePoint(
      price: (json["price"] as num).toDouble(),
      timestamp: json["ts"],
    );
  }

  Map<String, dynamic> toJson() => {"price": price, "ts": timestamp};
}

class ExchangeRateHistory {
  final String currency;
  final List<RatePoint> points;

  bool isUsableFor(String code) => currency == code && points.isNotEmpty;

  ExchangeRateHistory({required this.currency, required this.points});

  factory ExchangeRateHistory.fromJson(Map<String, dynamic> json) {
    return ExchangeRateHistory(
      currency: json["currency"],
      points: (json["points"] as List<dynamic>)
          .map((e) => RatePoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "currency": currency,
        "points": points.map((p) => p.toJson()).toList(),
      };
}
