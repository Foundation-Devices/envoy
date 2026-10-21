// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/tor_failure_recovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coalesces signals queued before recovery starts', () async {
    var recoveries = 0;
    final coordinator = TorFailureRecoveryCoordinator(
      activeOperation: () => null,
      recover: () async {
        recoveries++;
      },
    );

    final first = coordinator.queue();
    final second = coordinator.queue();
    expect(identical(first, second), isTrue);
    await first;

    expect(recoveries, 1);
  });

  test('rechecks after a signal arrives during recovery', () async {
    var recoveries = 0;
    final started = Completer<void>();
    final release = Completer<void>();
    final coordinator = TorFailureRecoveryCoordinator(
      activeOperation: () => null,
      recover: () async {
        recoveries++;
        if (recoveries == 1) {
          started.complete();
          await release.future;
        }
      },
    );

    final first = coordinator.queue();
    await started.future;
    final second = coordinator.queue();
    expect(identical(first, second), isTrue);

    release.complete();
    await first;

    expect(recoveries, 2);
  });

  test('handles synchronous re-entry', () async {
    var recoveries = 0;
    late TorFailureRecoveryCoordinator coordinator;
    coordinator = TorFailureRecoveryCoordinator(
      activeOperation: () => null,
      recover: () async {
        recoveries++;
        if (recoveries == 1) {
          unawaited(coordinator.queue());
        }
      },
    );

    await coordinator.queue();

    expect(recoveries, 2);
  });

  test('recovers after another lifecycle operation fails', () async {
    var active = true;
    var recoveries = 0;
    final operation = Completer<void>();
    final coordinator = TorFailureRecoveryCoordinator(
      activeOperation: () => active ? operation.future : null,
      recover: () async {
        recoveries++;
      },
    );

    final recovery = coordinator.queue();
    await Future<void>.delayed(Duration.zero);
    expect(recoveries, 0);

    active = false;
    operation.completeError(StateError('start failed'));
    await recovery;

    expect(recoveries, 1);
  });
}
