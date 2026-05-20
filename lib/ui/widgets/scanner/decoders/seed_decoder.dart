// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/seed_qr_extract.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:envoy/generated/l10n.dart';

class InvalidSeedQRException implements Exception {
  @override
  toString() => S().camera_toast_notAValidSeed;
}

class SeedQrDecoder extends ScannerDecoder {
  final Function(String seed)? onSeedValidated;
  bool _seedDetected = false;

  SeedQrDecoder({required this.onSeedValidated});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    // Once a valid seed has been detected, ignore any further scans so the
    // scanner doesn't throw/toast while the modal is being torn down.
    if (_seedDetected) {
      return;
    }
    final String code = barCode.code?.toLowerCase() ?? "";
    if (code.isEmpty) {
      return;
    }
    final seed = extractSeedFromQRCode(code, rawBytes: barCode.rawBytes);
    if (isValidSeedLength(seed) &&
        await EnvoyBip39.validateSeed(seedWords: seed)) {
      // Re-check after the async gap: a concurrent decode may have already
      // claimed the detection. Without this, onSeedValidated can fire twice,
      // which pops the caller's screen once too many.
      if (_seedDetected) {
        return;
      }
      _seedDetected = true;
      onSeedValidated!(seed);
      return;
    } else {
      throw InvalidSeedQRException();
    }
  }
}
