// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScvDecoder extends ScannerDecoder {
  final Function(CryptoResponse cryptoResponse) onScan;

  ScvDecoder({required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    final String code = barCode.code?.toLowerCase() ?? "";
    if (code.startsWith("ur:") == true) {
      final payload = processUr(barCode);
      if (payload is CryptoResponse) {
        onScan(payload);
      }
    }
    return;
  }
}
