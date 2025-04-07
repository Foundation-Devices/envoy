// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class GenericQrDecoder extends ScannerDecoder {
  final Function(String code) onScan;

  GenericQrDecoder({required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    onScan(barCode.code!);
  }
}
