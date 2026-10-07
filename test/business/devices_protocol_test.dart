// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';
import 'dart:ui';

import 'package:envoy/business/devices.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> legacyJson() => {
        'name': 'Prime',
        'type': 'passportPrime',
        'serial': 'prime-1',
        'datePaired': '2026-10-05T00:00:00.000Z',
        'firmwareVersion': '2.0.0',
        'color': '4278190080',
      };

  test('legacy device JSON defaults to QLv1', () {
    final device = Device.fromJson(legacyJson());

    expect(device.protocol, PrimeConnectionProtocol.qlV1);
    expect(device.qlv2Identity, isNull);
    expect(device.qlv2PeerBundle, isNull);
    expect(device.xid, isNull);
    expect(device.senderXid, isNull);
    expect(device.hasQlPairingCredentials, isFalse);

    device.xid = Uint8List.fromList([1]);
    expect(device.hasQlPairingCredentials, isTrue);
  });

  test('QLv2 credentials round-trip separately from QLv1 credentials', () {
    final device = Device(
      'Prime',
      DeviceType.passportPrime,
      'prime-2',
      DateTime.utc(2026, 10, 5),
      '2.0.0',
      const Color(0xff000000),
      protocol: PrimeConnectionProtocol.qlV2,
      qlv2Identity: Uint8List.fromList([1, 2, 3]),
      qlv2PeerBundle: Uint8List.fromList([4, 5, 6]),
    );

    final restored = Device.fromJson(device.toJson());

    expect(restored.protocol, PrimeConnectionProtocol.qlV2);
    expect(restored.qlv2Identity, [1, 2, 3]);
    expect(restored.qlv2PeerBundle, [4, 5, 6]);
    expect(restored.xid, isNull);
    expect(restored.senderXid, isNull);
    expect(restored.hasQlPairingCredentials, isTrue);

    restored.qlv2PeerBundle = null;
    expect(restored.hasQlPairingCredentials, isFalse);
  });
}
