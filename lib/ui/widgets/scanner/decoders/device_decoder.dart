// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/widgets/scanner/decoders/pair_decoder.dart';
import 'package:envoy/ui/widgets/scanner/decoders/prime_ql_payload_decoder.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class DeviceDecoder extends ScannerDecoder {
  final Function(String code) onScan;
  final Function(XidDocument onXid)? onXidScan;
  PairPayloadDecoder pairPayloadDecoder;
  ArcMutexDecoder? qrDecoder;
  PrimeQlPayloadDecoder? primeQlPayloadDecoder;

  DeviceDecoder(
      {required this.onScan, required this.pairPayloadDecoder, this.onXidScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    if (barCode.code == null) {
      return;
    }
    if (barCode.code?.toUpperCase().startsWith("UR:ENVELOPE") == true) {
      if (primeQlPayloadDecoder == null) {
        qrDecoder = await getQrDecoder();
        primeQlPayloadDecoder = PrimeQlPayloadDecoder(
          decoder: qrDecoder!,
          onScan: (xidDocument) {
            if (onXidScan != null) {
              onXidScan!(xidDocument);
            }
          },
        )..onProgressUpdates((progress) {
            progressCallBack?.call(progress);
          });
      }
      primeQlPayloadDecoder!.onDetectBarCode(barCode);
      progressCallBack
          ?.call(primeQlPayloadDecoder!.urDecoder.urDecoder.progress);
      return;
    } else if (barCode.code?.toLowerCase().startsWith("ur:") == true) {
      pairPayloadDecoder.onDetectBarCode(barCode);
      progressCallBack?.call(pairPayloadDecoder.urDecoder.urDecoder.progress);
    } else {
      onScan(barCode.code!);
    }
  }
}
