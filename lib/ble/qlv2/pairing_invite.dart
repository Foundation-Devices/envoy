// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

enum PrimeQrProtocolSelection { qlV1, qlV2 }

PrimeQrProtocolSelection selectPrimeQrProtocol(String? pairingToken) {
  return pairingToken == null
      ? PrimeQrProtocolSelection.qlV1
      : PrimeQrProtocolSelection.qlV2;
}

Uint8List decodeQlv2PairingInvite(String token) {
  final decoded = Uri.decodeComponent(token.trim());
  final value =
      decoded.toLowerCase().startsWith('0x') ? decoded.substring(2) : decoded;
  if (value.isEmpty || value.length.isOdd) {
    throw const FormatException('Invalid QL v2 pairing token encoding.');
  }
  if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(value)) {
    throw const FormatException('Invalid QL v2 pairing token encoding.');
  }
  final bytes = Uint8List(value.length ~/ 2);
  for (var index = 0; index < value.length; index += 2) {
    bytes[index ~/ 2] = int.parse(value.substring(index, index + 2), radix: 16);
  }
  return bytes;
}
