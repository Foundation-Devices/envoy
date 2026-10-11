// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/ble/qlv2/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('replaces and disposes subscriptions owned by a session scope',
      () async {
    var firstCancelled = false;
    var secondCancelled = false;
    final first = StreamController<void>(
      onCancel: () => firstCancelled = true,
    );
    final second = StreamController<void>(
      onCancel: () => secondCancelled = true,
    );
    final controller = QLV2SessionController(QLV2RpcDispatcher());

    controller.registerSubscriptions('test', [first.stream.listen((_) {})]);
    controller.registerSubscriptions('test', [second.stream.listen((_) {})]);
    await Future<void>.delayed(Duration.zero);

    expect(firstCancelled, isTrue);
    expect(secondCancelled, isFalse);

    controller.disposeSubscriptions('test');
    await Future<void>.delayed(Duration.zero);
    expect(secondCancelled, isTrue);

    controller.dispose();
    await first.close();
    await second.close();
  });
}
