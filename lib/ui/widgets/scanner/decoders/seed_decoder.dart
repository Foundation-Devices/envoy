// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/seed_qr_extract.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class InvalidSeedQRException implements Exception {
  @override
  toString() => "Not a valid seed";
}

class SeedQrDecoder extends ScannerDecoder {
  final Function(String seed)? onSeedValidated;

  SeedQrDecoder({required this.onSeedValidated});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    final String code = barCode.code?.toLowerCase() ?? "";
    if (code.isEmpty) {
      return;
    }
    final seed = extractSeedFromQRCode(code, rawBytes: barCode.rawBytes);
    if (isValidSeedLength(seed) &&
        await EnvoyBip39.validateSeed(seedWords: seed)) {
      onSeedValidated!(seed);
      return;
    } else {
      throw InvalidSeedQRException();
    }
  }
}
