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
  int fastRate(Network network) {
    return fees[network]?.mempoolFastestRate ?? 1;
  }

  int slowRate(Network network) {
    return fees[network]?.mempoolHourRate ?? 1;
  }

  static Map<Network, FeeRates> _defaultFees() {
    return {
      Network.bitcoin: FeeRates(),
      Network.testnet: FeeRates(),
      Network.signet: FeeRates()
    };
  }

  static Map<String, dynamic> _feesToJson(Map<Network, FeeRates> fees) {
    Map<String, dynamic> jsonMap = {};
    for (var entry in fees.entries) {
      jsonMap[entry.key.name] = entry.value.toJson();
    }

    return jsonMap;
  }

  static Map<Network, FeeRates> _feesFromJson(Map<String, dynamic> fees) {
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
  static const testnet4MempoolFoundationInstance =
      "https://mempool.foundation.xyz/testnet4";
  static const _mempoolRecommendedFeesEndpoints = {
    Network.bitcoin: "$mempoolFoundationInstance/api/v1/fees/recommended",
    Network.testnet:
        "$testnetMempoolFoundationInstance/api/v1/fees/recommended",
    Network.signet: "$signetMempoolFoundationInstance/api/v1/fees/recommended"
  };
  static const signetMempoolFoundationInstance =
      "https://mempool.foundation.xyz/signet";

  static const _mempoolBlocksFeesEndpoints = {
    Network.bitcoin: "$mempoolFoundationInstance/api/v1/fees/mempool-blocks",
    Network.testnet:
        "$testnetMempoolFoundationInstance/api/v1/fees/mempool-blocks",
    Network.signet:
        "$signetMempoolFoundationInstance/api/v1/fees/mempool-blocks"
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

  static void restore() {
    if (_ls.prefs.containsKey(FEE_RATE_PREFS)) {
      var storedFees = jsonDecode(_ls.prefs.getString(FEE_RATE_PREFS)!);
      try {
        Fees.fromJson(storedFees);
      } catch (e) {
        //ignore
      }
    }

    Fees.init();
  }

  void _storeRates() {
    String json = jsonEncode(this);
    _ls.prefs.setString(FEE_RATE_PREFS, json);
  }

  void _getMempoolRecommendedRates(Network network) {
    HttpTor().get(_mempoolRecommendedFeesEndpoints[network]!).then((response) {
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        fees[network]!.mempoolFastestRate = json["fastestFee"];
        fees[network]!.mempoolHalfHourRate = json["halfHourFee"];
        fees[network]!.mempoolHourRate = json["hourFee"];
        fees[network]!.mempoolEconomyRate = json["economyFee"];
        fees[network]!.mempoolMinimumRate = json["minimumFee"];
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

  void _getMempoolBlocksFees(Network network) {
    HttpTor().get(_mempoolBlocksFeesEndpoints[network]!).then((response) {
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
