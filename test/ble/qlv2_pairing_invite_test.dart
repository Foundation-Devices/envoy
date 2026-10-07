// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/pairing_invite.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('selectPrimeQrProtocol', () {
    test('selects QLv1 when k is absent', () {
      expect(selectPrimeQrProtocol(null), PrimeQrProtocolSelection.qlV1);
    });

    test('selects only QLv2 when k is present', () {
      expect(selectPrimeQrProtocol('00'), PrimeQrProtocolSelection.qlV2);
      expect(selectPrimeQrProtocol(''), PrimeQrProtocolSelection.qlV2);
      expect(selectPrimeQrProtocol('  '), PrimeQrProtocolSelection.qlV2);
    });
  });

  group('decodeQlv2PairingInvite', () {
    test('decodes URL-encoded hexadecimal tokens', () {
      expect(decodeQlv2PairingInvite('01%32a'), [0x01, 0x2a]);
    });

    test('accepts an optional hexadecimal prefix', () {
      expect(decodeQlv2PairingInvite('0xCAFE'), [0xca, 0xfe]);
    });

    test('does not impose a legacy fixed length', () {
      expect(decodeQlv2PairingInvite('00'), [0]);
      expect(decodeQlv2PairingInvite('000102030405'), [0, 1, 2, 3, 4, 5]);
    });

    for (final token in ['', '0', 'xyz', '0x']) {
      test('rejects invalid token "$token"', () {
        expect(
          () => decodeQlv2PairingInvite(token),
          throwsA(isA<FormatException>()),
        );
      });
    }
  });
}
