// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_tor/http_tor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/fee_rates.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/util/tuple.dart';

// Generated
part 'fees.g.dart';

final mempoolBlocksMedianFeeRateProvider =
    Provider.family<List<double>, Network>((ref, network) {
  return Fees().fees[network]?.mempoolBlocksMedianFeeRate ?? [];
});

final txEstimatedConfirmationTimeProvider =
    Provider.family<int, Tuple<Transaction, Network>>((ref, txNetwork) {
  final tx = txNetwork.item1;
  final network = txNetwork.item2;

  if (tx.vsize == null) {
    return 10;
  }

  final feeRate = tx.fee / tx.vsize!;
  final medianFeeRates = ref.watch(mempoolBlocksMedianFeeRateProvider(network));

  int minutesToConfirmation = 10;
  for (final blockFeeRate in medianFeeRates) {
    if (feeRate > blockFeeRate) {
      return minutesToConfirmation;
    }
    minutesToConfirmation += 10;
  }

  return minutesToConfirmation;
});

LocalStorage _ls = LocalStorage();

@JsonSerializable()
class Fees {
  // All in BTC per kb
  double fastRate(Network network) {
    return fees[network]!.mempoolFastestRate;
  }

  double slowRate(Network network) {
    return fees[network]!.mempoolHourRate;
  }

  static _defaultFees() {
    return {
      Network.Mainnet: FeeRates(),
      Network.Testnet: FeeRates(),
      Network.Signet: FeeRates()
    };
  }

  static _feesToJson(Map<Network, FeeRates> fees) {
    Map<String, dynamic> jsonMap = {};
    for (var entry in fees.entries) {
      jsonMap[entry.key.name] = entry.value.toJson();
    }

    return jsonMap;
  }

  static _feesFromJson(Map<String, dynamic> fees) {
    Map<Network, FeeRates> map = {};
    for (var entry in fees.entries) {
      map[Network.values.byName(entry.key)] = FeeRates.fromJson(entry.value);
    }

    return map;
  }

  @JsonKey(
      defaultValue: _defaultFees, toJson: _feesToJson, fromJson: _feesFromJson)
  Map<Network, FeeRates> fees = _defaultFees();

  static const String FEE_RATE_PREFS = "fees";
  static final Fees _instance = Fees._internal();

  static const mempoolFoundationInstance = "https://mempool.foundation.xyz";
  static const testnetMempoolFoundationInstance =
      "https://mempool.foundation.xyz/testnet";
  static const _mempoolRecommendedFeesEndpoints = {
    Network.Mainnet: "$mempoolFoundationInstance/api/v1/fees/recommended",
    Network.Testnet:
        "$testnetMempoolFoundationInstance/api/v1/fees/recommended",
    Network.Signet:
        "$mutinynetMempoolFoundationInstance/api/v1/fees/recommended"
  };
  static const mutinynetMempoolFoundationInstance =
      "https://mutiny.foundation.xyz";

  static const _mempoolBlocksFeesEndpoints = {
    Network.Mainnet: "$mempoolFoundationInstance/api/v1/fees/mempool-blocks",
    Network.Testnet:
        "$testnetMempoolFoundationInstance/api/v1/fees/mempool-blocks",
    Network.Signet:
        "$mutinynetMempoolFoundationInstance/api/v1/fees/mempool-blocks"
  };

  factory Fees() {
    return _instance;
  }

  static Future<Fees> init() async {
    var singleton = Fees._instance;
    return singleton;
  }

  Fees._internal() {
    kPrint("Instance of Fees created!");

    // Fetch the latest from mempool.space
    _getRates();

    // Refresh from time to time
    Timer.periodic(const Duration(minutes: 5), (_) {
      _getRates();
    });
  }

  void _getRates() {
    _getMempoolRecommendedRates(Network.Mainnet);
    _getMempoolRecommendedRates(Network.Testnet);
    _getMempoolRecommendedRates(Network.Signet);

    _getMempoolBlocksFees(Network.Mainnet);
    _getMempoolBlocksFees(Network.Testnet);
    _getMempoolBlocksFees(Network.Signet);
  }

  static restore() {
    if (_ls.prefs.containsKey(FEE_RATE_PREFS)) {
      var storedFees = jsonDecode(_ls.prefs.getString(FEE_RATE_PREFS)!);
      Fees.fromJson(storedFees);
    }

    Fees.init();
  }

  _storeRates() {
    String json = jsonEncode(this);
    _ls.prefs.setString(FEE_RATE_PREFS, json);
  }

  _getMempoolRecommendedRates(Network network) {
    HttpTor(Tor.instance, EnvoyScheduler().parallel)
        .get(_mempoolRecommendedFeesEndpoints[network]!)
        .then((response) {
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        fees[network]!.mempoolFastestRate =
            json["fastestFee"].toDouble() / 100000.0;
        fees[network]!.mempoolHalfHourRate =
            json["halfHourFee"].toDouble() / 100000.0;
        fees[network]!.mempoolHourRate = json["hourFee"].toDouble() / 100000.0;
        fees[network]!.mempoolEconomyRate =
            json["economyFee"].toDouble() / 100000.0;
        fees[network]!.mempoolMinimumRate =
            json["minimumFee"].toDouble() / 100000.0;

        _storeRates();
      } else {
        throw Exception("Couldn't get mempool.space fees");
      }
    });
  }

  _getMempoolBlocksFees(Network network) {
    HttpTor(Tor.instance, EnvoyScheduler().parallel)
        .get(_mempoolBlocksFeesEndpoints[network]!)
        .then((response) {
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        for (final block in json) {
          fees[network]!
              .mempoolBlocksMedianFeeRate
              .add(block["medianFee"].toDouble());
        }
        _storeRates();
      } else {
        throw Exception("Couldn't get mempool.space blocks fees");
      }
    });
  }

  // Generated
  factory Fees.fromJson(Map<String, dynamic> json) => _$FeesFromJson(json);

  Map<String, dynamic> toJson() => _$FeesToJson(this);
}
