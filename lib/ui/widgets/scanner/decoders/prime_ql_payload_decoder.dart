// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class PrimeQlPayloadDecoder extends ScannerDecoder {
  final Function(Binary binary) onScan;

  PrimeQlPayloadDecoder({required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    final String code = barCode.code?.toLowerCase() ?? "";
    if (code.startsWith("ur:") == true) {
      //TODO: implement xifdoc parsing
      final payload = processUr(barCode);
      // if (payload is xid.Document) {
      //
      // } else if (urDecoder.urDecoder.progress == 1) {
      //  // invalid UR
      // }
    }
    return;
  }
}
