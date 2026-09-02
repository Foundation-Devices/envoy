// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http_tor/src/tor_readiness.dart';

void main() {
  test('returns immediately when Tor is already bootstrapped', () async {
    final changes = StreamController<Object?>.broadcast();

    await waitForTorReadiness(
      stateChanges: changes.stream,
      isEnabled: () => true,
      isBootstrapped: () => true,
      timeout: const Duration(seconds: 1),
    );

    expect(changes.hasListener, isFalse);
    await changes.close();
  });

  test('completes when Tor broadcasts bootstrap readiness', () async {
    final changes = StreamController<Object?>.broadcast();
    var bootstrapped = false;

    final readiness = waitForTorReadiness(
      stateChanges: changes.stream,
      isEnabled: () => true,
      isBootstrapped: () => bootstrapped,
      timeout: const Duration(seconds: 1),
    );
    bootstrapped = true;
    changes.add(null);

    await readiness;
    await Future<void>.delayed(Duration.zero);
    expect(changes.hasListener, isFalse);
    await changes.close();
  });

  test('completes when Tor is disabled while waiting', () async {
    final changes = StreamController<Object?>.broadcast();
    var enabled = true;

    final readiness = waitForTorReadiness(
      stateChanges: changes.stream,
      isEnabled: () => enabled,
      isBootstrapped: () => false,
      timeout: const Duration(seconds: 1),
    );
    enabled = false;
    changes.add(null);

    await readiness;
    await Future<void>.delayed(Duration.zero);
    expect(changes.hasListener, isFalse);
    await changes.close();
  });

  test('a timeout cancels the state subscription', () async {
    final changes = StreamController<Object?>.broadcast();

    final readiness = waitForTorReadiness(
      stateChanges: changes.stream,
      isEnabled: () => true,
      isBootstrapped: () => false,
      timeout: const Duration(milliseconds: 10),
    );

    await expectLater(readiness, throwsA(isA<TimeoutException>()));
    await Future<void>.delayed(Duration.zero);
    expect(changes.hasListener, isFalse);
    await changes.close();
  });
}
