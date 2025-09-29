// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class GenericQrDecoder extends ScannerDecoder {
  bool _scanned = false;
  final Function(String code) onScan;

  GenericQrDecoder({required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    if (_scanned) return;
    onScan(barCode.code!);
    _scanned = true;
  }
}
