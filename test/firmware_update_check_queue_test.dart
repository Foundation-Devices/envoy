// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/handlers/firmware_update_check_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('same-version repeats share the successful in-flight check', () {
    final queue = FirmwareUpdateCheckQueue()..add('1.4.0');
    final request = queue.takeNext()!;
    queue.add('1.4.0');
    queue.add('1.4.0');

    expect(queue.isCurrent(request.id), isTrue);
    queue.complete(request, FirmwareUpdateCheckDelivery.sent);
    expect(queue.takeNext(), isNull);
  });

  test('a newer version invalidates the old response and is checked next', () {
    final queue = FirmwareUpdateCheckQueue()..add('1.4.0');
    final old = queue.takeNext()!;
    queue.add('1.4.0');
    queue.add('1.4.1');
    queue.add('1.4.1');

    expect(queue.isCurrent(old.id), isFalse);
    queue.complete(old, FirmwareUpdateCheckDelivery.abandoned);
    final next = queue.takeNext()!;
    expect(next.currentVersion, '1.4.1');
    expect(next.id, greaterThan(old.id));
    expect(queue.isCurrent(next.id), isTrue);
    queue.complete(next, FirmwareUpdateCheckDelivery.sent);
    expect(queue.takeNext(), isNull);
  });

  for (final delivery in [
    FirmwareUpdateCheckDelivery.failed,
    FirmwareUpdateCheckDelivery.abandoned,
  ]) {
    test('$delivery retries a recorded repeat only once', () {
      final queue = FirmwareUpdateCheckQueue()..add('1.4.0');
      final first = queue.takeNext()!;
      queue.add('1.4.0');
      queue.add('1.4.0');
      queue.complete(first, delivery);

      final retry = queue.takeNext()!;
      expect(retry.currentVersion, '1.4.0');
      expect(retry.id, greaterThan(first.id));
      queue.complete(retry, delivery);
      expect(queue.takeNext(), isNull);
    });
  }

  test('a failed check without a repeat does not invent a retry', () {
    final queue = FirmwareUpdateCheckQueue()..add('1.4.0');
    queue.complete(queue.takeNext()!, FirmwareUpdateCheckDelivery.failed);
    expect(queue.takeNext(), isNull);
  });

  test('clear invalidates late completion and its recorded repeat', () {
    final queue = FirmwareUpdateCheckQueue()..add('1.4.0');
    final old = queue.takeNext()!;
    queue.add('1.4.0');
    queue.clear();

    expect(queue.isCurrent(old.id), isFalse);
    queue.complete(old, FirmwareUpdateCheckDelivery.failed);
    expect(queue.takeNext(), isNull);
  });
}
