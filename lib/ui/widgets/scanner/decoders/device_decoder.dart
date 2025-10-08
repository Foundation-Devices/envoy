// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/widgets/scanner/decoders/pair_decoder.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class DeviceDecoder extends ScannerDecoder {
  final Function(String code) onScan;
  PairPayloadDecoder pairPayloadDecoder;

  DeviceDecoder({required this.onScan, required this.pairPayloadDecoder});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    if (barCode.code == null) {
      return;
    }
    if (barCode.code?.toLowerCase().startsWith("ur:") == true) {
      pairPayloadDecoder.onDetectBarCode(barCode);
      progressCallBack?.call(pairPayloadDecoder.urDecoder.urDecoder.progress);
    } else {
      onScan(barCode.code!);
    }
  }
}
