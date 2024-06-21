// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';

// Generated
part 'fee_rates.g.dart';

@JsonSerializable()
class FeeRates {
  FeeRates();

  // Fee rate cannot be lower than 1 sat/byte
  // Expressed here in BTC/kb because we used to depend on Electrum for this
  double mempoolFastestRate = 0.00001;
  double mempoolHalfHourRate = 0.00001;
  double mempoolHourRate = 0.00001;
  double mempoolEconomyRate = 0.00001;
  double mempoolMinimumRate = 0.00001;

  double electrumFastRate = 0.00001;
  double electrumSlowRate = 0.00001;

  @JsonKey(defaultValue: [])
  List<double> mempoolBlocksMedianFeeRate = [];

  // Generated
  factory FeeRates.fromJson(Map<String, dynamic> json) =>
      _$FeeRatesFromJson(json);

  Map<String, dynamic> toJson() => _$FeeRatesToJson(this);
}
