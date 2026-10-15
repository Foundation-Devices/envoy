// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:envoy/ble/qlv2/protocol_handler.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/ui/onboard/prime/state/qlv2/prime_onboarding_qlv2_device_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

void main() {
  test('fresh QLv2 pairing keeps only the serial in memory', () async {
    final device = _FakeQLConnection();
    final handler = _FakeQLV2ProtocolHandler(
      const qlv2.PassportDetailsResponse(
        deviceName: 'Prime',
        model: qlv2.PassportModel.prime,
        firmwareVersion: qlv2.PassportFirmwareVersion(field0: '2.0.0'),
        serial: qlv2.PassportSerial(field0: 'prime-1'),
        color: qlv2.PassportColor.light,
        onboardingComplete: false,
      ),
    );

    final persisted = await prepareQlv2PassportDeviceAfterPairing(
      device: device,
      handler: handler,
    );

    expect(persisted, isFalse);
    expect(device.primeSerial, 'prime-1');
    expect(handler.readPairingCredentials, isFalse);
  });
}

class _FakeQLConnection extends Mock implements QLConnection {
  @override
  String? primeSerial;
}

class _FakeQLV2ProtocolHandler extends Mock implements QLV2ProtocolHandler {
  _FakeQLV2ProtocolHandler(this.details);

  final qlv2.PassportDetailsResponse details;
  bool readPairingCredentials = false;

  @override
  Future<qlv2.PassportDetailsResponse> fetchPassportDetails() async => details;

  @override
  Future<Uint8List> ownIdentity() async {
    readPairingCredentials = true;
    return Uint8List(0);
  }

  @override
  Future<Uint8List?> getPersistedPeer() async {
    readPairingCredentials = true;
    return null;
  }
}
