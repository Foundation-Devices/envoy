// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CryptoTxDecoder extends ScannerDecoder {
  final Function(CryptoPsbt cryptoPsbt) onScan;
  bool _invoked = false;
  CryptoTxDecoder({required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    if (barCode.code != null &&
        barCode.code?.toLowerCase().startsWith("ur:") == true) {
      final payload = processUr(barCode);
      if (payload != null && !_invoked) {
        _invoked = true;
        onScan(payload as CryptoPsbt);
      }
    }
    return;
  }
}
