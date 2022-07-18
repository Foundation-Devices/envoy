// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'package:envoy/business/local_storage.dart';
import 'package:http_tor/http_tor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tor/tor.dart';

// Generated
part 'fees.g.dart';

LocalStorage _ls = LocalStorage();

@JsonSerializable()
class Fees {
  // All in BTC per kb
  double get fastRate => mempoolFastestRate;
  double get slowRate => mempoolHourRate;

  double mempoolFastestRate = 0;
  double mempoolHalfHourRate = 0;
  double mempoolHourRate = 0;
  double mempoolEconomyRate = 0;
  double mempoolMinimumRate = 0;

  double electrumFastRate = 0;
  double electrumSlowRate = 0;

  static const String _FEE_RATE_PREFS = "fees";
  static final Fees _instance = Fees._internal();

  factory Fees() {
    return _instance;
  }

  static Future<Fees> init() async {
    var singleton = Fees._instance;
    return singleton;
  }

  Fees._internal() {
    print("Instance of Fees created!");

    // Fetch the latest from mempool.space
    _getMempoolRates();

    // Refresh from time to time
    Timer.periodic(Duration(minutes: 5), (_) {
      _getMempoolRates();
    });
  }

  static restore() {
    if (_ls.prefs.containsKey(_FEE_RATE_PREFS)) {
      var storedFees = jsonDecode(_ls.prefs.getString(_FEE_RATE_PREFS)!);
      Fees.fromJson(storedFees);
    }

    Fees.init();
  }

  _storeRates() {
    String json = jsonEncode(this);
    _ls.prefs.setString(_FEE_RATE_PREFS, json);
  }

  _getMempoolRates() {
    HttpTor(Tor())
        .get("https://mempool.space/api/v1/fees/recommended")
        .then((response) {
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        mempoolFastestRate = json["fastestFee"].toDouble() / 100000.0;
        mempoolHalfHourRate = json["halfHourFee"].toDouble() / 100000.0;
        mempoolHourRate = json["hourFee"].toDouble() / 100000.0;
        mempoolEconomyRate = json["economyFee"].toDouble() / 100000.0;
        mempoolMinimumRate = json["minimumFee"].toDouble() / 100000.0;

        _storeRates();
      } else {
        throw Exception("Couldn't get mempool.space fees");
      }
    });
  }

  // Generated
  factory Fees.fromJson(Map<String, dynamic> json) => _$FeesFromJson(json);

  Map<String, dynamic> toJson() => _$FeesToJson(this);
}
