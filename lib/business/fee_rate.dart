// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

/// Represents a Bitcoin fee rate.
///
/// Stored internally as **sat/kvB** (integer) — the unit ngwallet uses —
/// so the value is always exact with no floating-point rounding.
///
/// Sub-sat rates are representable: 0.5 sat/vB = 500 sat/kvB (still an int).
///
/// ```dart
/// // From display input
/// FeeRate.fromSatPerVb(5)       // 5 sat/vB
/// FeeRate.fromSatPerVb(0.99)    // 0.99 sat/vB (sub-sat)
///
/// // From ngwallet BigInt
/// FeeRate.fromBigInt(tx.feeRate.field0)
///
/// // From internal int sat/kvB
/// FeeRate.fromSatPerKvb(1000)   // 1 sat/vB
///
/// // Read back
/// rate.satPerVb       // double — for display
/// rate.satPerKvb      // int   — for state arithmetic
/// rate.asBigInt       // BigInt — for ngwallet API calls
/// rate.displayString  // "1", "5", "0.99", "0.5"
/// ```
class FeeRate {
  final int _satPerKvb;

  FeeRate._(this._satPerKvb);

  /// From sat/vB — the human-visible unit. Accepts int or double.
  factory FeeRate.fromSatPerVb(num satPerVb) =>
      FeeRate._((satPerVb * 1000).round());

  /// From sat/kvB integer — the internal arithmetic unit.
  FeeRate.fromSatPerKvb(int satPerKvb) : _satPerKvb = satPerKvb;

  /// From ngwallet's BigInt sat/kvB.
  FeeRate.fromBigInt(BigInt satPerKvb) : _satPerKvb = satPerKvb.toInt();

  /// sat/vB as double — use for display only.
  double get satPerVb => _satPerKvb / 1000.0;

  /// sat/kvB as int — use for state and arithmetic.
  int get satPerKvb => _satPerKvb;

  /// sat/kvB as BigInt — use when calling ngwallet.
  BigInt get asBigInt => BigInt.from(_satPerKvb);

  /// True when the rate is below 1 sat/vB.
  bool get isSubSat => _satPerKvb < 1000;

  /// Formatted sat/vB for display: 1000 → "1", 990 → "0.99", 500 → "0.5".
  String get displayString {
    if (_satPerKvb % 1000 == 0) return '${_satPerKvb ~/ 1000}';
    return (_satPerKvb / 1000.0)
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '');
  }

  FeeRate operator +(FeeRate other) => FeeRate._(_satPerKvb + other._satPerKvb);

  bool operator <(FeeRate other) => _satPerKvb < other._satPerKvb;
  bool operator <=(FeeRate other) => _satPerKvb <= other._satPerKvb;
  bool operator >(FeeRate other) => _satPerKvb > other._satPerKvb;
  bool operator >=(FeeRate other) => _satPerKvb >= other._satPerKvb;

  /// Clamps this fee rate to the [min]..[max] range.
  FeeRate clamp(FeeRate min, FeeRate max) =>
      FeeRate._(_satPerKvb.clamp(min._satPerKvb, max._satPerKvb));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeRate && other._satPerKvb == _satPerKvb;

  @override
  int get hashCode => _satPerKvb.hashCode;

  @override
  String toString() => '$displayString sat/vB';
}
