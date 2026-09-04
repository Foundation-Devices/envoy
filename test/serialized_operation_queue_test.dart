// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/channels/serialized_operation_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('operations run one at a time in enqueue order', () async {
    final queue = SerializedOperationQueue<int>();
    final firstGate = Completer<void>();
    final events = <String>[];

    final first = queue.enqueue(() async {
      events.add('first started');
      await firstGate.future;
      events.add('first finished');
      return 1;
    });
    final second = queue.enqueue(() async {
      events.add('second started');
      events.add('second finished');
      return 2;
    });

    await Future<void>.delayed(Duration.zero);
    expect(events, ['first started']);

    firstGate.complete();
    expect(await first, 1);
    expect(await second, 2);
    expect(events, [
      'first started',
      'first finished',
      'second started',
      'second finished',
    ]);
  });

  test('a timeout does not overlap the next operation', () async {
    final queue = SerializedOperationQueue<bool>();
    final stalledOperation = Completer<bool>();
    var secondStarted = false;

    final firstResult = queue.enqueue(
      () => stalledOperation.future,
      timeout: const Duration(milliseconds: 20),
      onTimeout: () => false,
    );
    final secondResult = queue.enqueue(() async {
      secondStarted = true;
      return true;
    });

    expect(await firstResult, isFalse);
    expect(secondStarted, isFalse);

    stalledOperation.complete(true);
    expect(await secondResult, isTrue);
  });

  test('a failed operation does not block the next operation', () async {
    final queue = SerializedOperationQueue<int>();

    final firstResult = queue.enqueue(
      () => Future<int>.error(StateError('write failed')),
    );
    final secondResult = queue.enqueue(() async => 42);

    await expectLater(firstResult, throwsStateError);
    expect(await secondResult, 42);
  });

  test('a lost timed-out operation releases the queue after its grace period',
      () async {
    final queue = SerializedOperationQueue<bool>();
    final stalledOperation = Completer<bool>();
    var secondStarted = false;

    final firstResult = queue.enqueue(
      () => stalledOperation.future,
      timeout: const Duration(milliseconds: 10),
      timeoutCompletionGrace: const Duration(milliseconds: 20),
      onTimeout: () => false,
    );
    final secondResult = queue.enqueue(() async {
      secondStarted = true;
      return true;
    });

    expect(await firstResult, isFalse);
    expect(secondStarted, isFalse);
    expect(await secondResult, isTrue);
    expect(secondStarted, isTrue);
  });

  test('a synchronous exception does not block the next operation', () async {
    final queue = SerializedOperationQueue<int>();

    final firstResult = queue.enqueue(() => throw StateError('write failed'));
    final secondResult = queue.enqueue(() async => 42);

    await expectLater(firstResult, throwsStateError);
    expect(await secondResult, 42);
  });

  test('pending operations can be completed without running', () async {
    final queue = SerializedOperationQueue<bool>();
    final firstGate = Completer<bool>();
    var pendingStarted = false;

    final first = queue.enqueue(() => firstGate.future);
    final pending = queue.enqueue(() async {
      pendingStarted = true;
      return true;
    });

    await Future<void>.delayed(Duration.zero);
    queue.completePending(false);

    expect(await pending, isFalse);
    expect(pendingStarted, isFalse);
    firstGate.complete(true);
    expect(await first, isTrue);
  });
}
