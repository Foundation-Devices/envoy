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
  int mempoolFastestRate = 2;
  int mempoolHalfHourRate = 1;
  int mempoolHourRate = 1;
  int mempoolEconomyRate = 1;
  int mempoolMinimumRate = 1;

  int electrumFastRate = 2;
  int electrumSlowRate = 1;

  @JsonKey(defaultValue: [])
  List<double> mempoolBlocksMedianFeeRate = [];

  // Generated
  factory FeeRates.fromJson(Map<String, dynamic> json) =>
      _$FeeRatesFromJson(json);

  Map<String, dynamic> toJson() => _$FeeRatesToJson(this);
}
