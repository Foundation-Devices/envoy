// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';

// Generated
part 'fee_rates.g.dart';

@JsonSerializable()
class FeeRates {
  FeeRates();

  double mempoolFastestRate = 0;
  double mempoolHalfHourRate = 0;
  double mempoolHourRate = 0;
  double mempoolEconomyRate = 0;
  double mempoolMinimumRate = 0;

  double electrumFastRate = 0;
  double electrumSlowRate = 0;

  // Generated
  factory FeeRates.fromJson(Map<String, dynamic> json) =>
      _$FeeRatesFromJson(json);

  Map<String, dynamic> toJson() => _$FeeRatesToJson(this);
}
