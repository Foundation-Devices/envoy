// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class PrimeQlPayloadDecoder extends ScannerDecoder {
  final Function(XidDocument binary) onScan;
  final ArcMutexDecoder decoder;

  PrimeQlPayloadDecoder({required this.decoder, required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    final String code = barCode.code?.toLowerCase() ?? "";
    if (code.startsWith("ur:") == true) {
      kPrint(code);
      try {
        final decoderStatus = await decodeQr(decoder: decoder, qr: code);
        progressCallBack?.call(decoderStatus.progress);
        if (decoderStatus.payload != null) {
          progressCallBack?.call(1);
          kPrint("Got the xidDoc ${decoderStatus.payload}");
          onScan(decoderStatus.payload!);
        }
      } catch (e) {
        kPrint(e);
      }
    }
    return;
  }
}
