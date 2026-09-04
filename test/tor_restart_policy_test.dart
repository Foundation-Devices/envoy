// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/tor_restart_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('suppresses further restarts until the cooldown elapses', () {
    var elapsed = Duration.zero;
    final policy = TorRestartPolicy(
      failureThreshold: 1,
      elapsed: () => elapsed,
    );

    expect(policy.recordFailure(), isTrue);
    expect(policy.recordFailure(), isFalse);
    expect(policy.restartCooldownRemaining, const Duration(minutes: 10));

    elapsed += const Duration(minutes: 9);
    expect(policy.recordFailure(), isFalse);
    expect(policy.restartCooldownRemaining, const Duration(minutes: 1));

    elapsed += const Duration(minutes: 1);
    expect(policy.recordFailure(), isTrue);
    expect(policy.recordFailure(), isFalse);
    expect(policy.restartCooldownRemaining, const Duration(minutes: 10));
  });

  test('a confirmed failure bypasses the strike threshold', () {
    final policy = TorRestartPolicy(failureThreshold: 5);

    expect(policy.recordConfirmedFailure(), isTrue);
    expect(policy.consecutiveFailures, 5);
    expect(policy.recordConfirmedFailure(), isFalse);
  });

  test('a success re-arms the threshold and clears the cooldown', () {
    final policy = TorRestartPolicy(failureThreshold: 2);

    expect(policy.recordFailure(), isFalse);
    expect(policy.recordFailure(), isTrue);
    expect(policy.restartAttempted, isTrue);

    policy.recordSuccess();
    expect(policy.restartAttempted, isFalse);
    expect(policy.consecutiveFailures, 0);

    expect(policy.recordFailure(), isFalse);
    expect(policy.recordFailure(), isTrue);
  });
}
