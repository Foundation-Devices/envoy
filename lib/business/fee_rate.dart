// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

/// A fee rate value that converts between the units used across the stack:
///
/// - **sat/vB**  — the human-readable unit shown in the UI and stored in [FeeRates].
/// - **sat/kvB** — the API boundary unit accepted/returned by ngwallet (BigInt).
///
/// Relationship: 1 sat/vB = 1 000 sat/kvB
///
/// Usage:
/// ```dart
/// // UI → ngwallet API
/// final rate = FeeRate.fromSatPerVb(feeRate);
/// params = TransactionParams(feeRate: rate.satPerKvb, ...);
///
/// // ngwallet API → UI
/// final rate = FeeRate.fromSatPerKvb(transaction.feeRate);
/// display(rate.satPerVb);
/// ```
class FeeRate {
  final double _satPerVb;

  /// Construct from the UI/display unit (sat/vB).
  const FeeRate.fromSatPerVb(double satPerVb) : _satPerVb = satPerVb;

  /// Construct from the ngwallet API unit (sat/kvB).
  FeeRate.fromSatPerKvb(BigInt satPerKvb)
      : _satPerVb = satPerKvb.toDouble() / 1000;

  /// Rate for display in the UI (sat/vB).
  double get satPerVb => _satPerVb;

  /// Rate for the ngwallet API boundary (sat/kvB).
  BigInt get satPerKvb => BigInt.from((_satPerVb * 1000).round());

  /// True when the rate is below 1 sat/vB (sub-sat transaction).
  bool get isSubSat => _satPerVb < 1.0;
}
