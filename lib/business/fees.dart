// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_tor/http_tor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tor/tor.dart';
import 'package:ngwallet/ngwallet.dart';
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
    Provider.family<int, Tuple<EnvoyTransaction, Network>>((ref, txNetwork) {
  final tx = txNetwork.item1;
  final network = txNetwork.item2;

  final feeRate = tx.fee / tx.vsize;
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
    return fees[network]?.mempoolFastestRate ?? 1;
  }

  double slowRate(Network network) {
    return fees[network]?.mempoolHourRate ?? 1;
  }

  static _defaultFees() {
    return {
      Network.bitcoin: FeeRates(),
      Network.testnet: FeeRates(),
      Network.signet: FeeRates()
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
      "https://testnet-mempool.foundation.xyz";
  static const _mempoolRecommendedFeesEndpoints = {
    Network.bitcoin: "$mempoolFoundationInstance/api/v1/fees/recommended",
    Network.testnet:
        "$testnetMempoolFoundationInstance/api/v1/fees/recommended",
    Network.signet:
        "$mutinynetMempoolFoundationInstance/api/v1/fees/recommended"
  };
  static const mutinynetMempoolFoundationInstance =
      "https://mutiny.foundation.xyz";

  static const _mempoolBlocksFeesEndpoints = {
    Network.bitcoin: "$mempoolFoundationInstance/api/v1/fees/mempool-blocks",
    Network.testnet:
        "$testnetMempoolFoundationInstance/api/v1/fees/mempool-blocks",
    Network.signet:
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
    _getMempoolRecommendedRates(Network.bitcoin);
    _getMempoolRecommendedRates(Network.testnet);
    _getMempoolRecommendedRates(Network.signet);

    _getMempoolBlocksFees(Network.bitcoin);
    _getMempoolBlocksFees(Network.testnet);
    _getMempoolBlocksFees(Network.signet);
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
    }).onError(
      (error, stackTrace) {
        EnvoyReport().log("Fees", "Cannot get Fees ${error.toString()}");
      },
    );
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
    }).onError(
      (error, stackTrace) {
        EnvoyReport().log("Fees", "Cannot get BlocksFees ${error.toString()}");
      },
    );
  }

  // Generated
  factory Fees.fromJson(Map<String, dynamic> json) => _$FeesFromJson(json);

  Map<String, dynamic> toJson() => _$FeesToJson(this);
}
