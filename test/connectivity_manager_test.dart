// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/connectivity_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final manager = ConnectivityManager();
  tearDown(() {
    manager.electrumConnected = true;
    manager.nguConnected = true;
    manager.resetFailureCounters();
  });

  test('resume counter reset preserves observed service state', () {
    manager.electrumConnected = false;
    manager.nguConnected = false;
    manager.failedFoundationServerAttempts = 3;

    manager.resetFailureCounters();

    expect(manager.electrumConnected, isFalse);
    expect(manager.nguConnected, isFalse);
    expect(manager.failedFoundationServerAttempts, isZero);
  });

  test('resume counter reset clears accumulated service strikes', () {
    manager.electrumFailure();
    manager.electrumFailure();
    manager.nguFailure();
    manager.nguFailure();
    expect(manager.serviceFailureCounters, (electrum: 2, ngu: 2));

    manager.resetFailureCounters();
    expect(manager.serviceFailureCounters, (electrum: 0, ngu: 0));
  });

  test('Tor recovery waits for temporary disablement to expire', () {
    final now = DateTime(2026, 9, 3);

    expect(
      torTemporaryDisablementRemaining(
        now.add(const Duration(hours: 24)),
        now.add(const Duration(minutes: 10)),
      ),
      const Duration(hours: 23, minutes: 50),
    );
  });
}
