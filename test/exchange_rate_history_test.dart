// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts non-empty history for the requested currency', () {
    final points = [RatePoint(price: 100000, timestamp: 1)];

    expect(
        ExchangeRateHistory(currency: 'USD', points: points).isUsableFor('USD'),
        isTrue);
    expect(ExchangeRateHistory(currency: 'USD', points: []).isUsableFor('USD'),
        isFalse);
    expect(
        ExchangeRateHistory(currency: 'EUR', points: points).isUsableFor('USD'),
        isFalse);
  });
}
