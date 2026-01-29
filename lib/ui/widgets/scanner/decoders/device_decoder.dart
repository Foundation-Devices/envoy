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

  //to avoid sending invalid code through onScan when scanning UR codes
  String previousCode = "";

  DeviceDecoder(
      {required this.onScan, required this.pairPayloadDecoder, this.onXidScan});

  @override
  void reset() {
    super.reset();
    previousCode = "";
    pairPayloadDecoder.reset();
    // Reset prime decoder by setting to null so it gets recreated with fresh ArcMutexDecoder
    primeQlPayloadDecoder = null;
    qrDecoder = null;
  }

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    if (barCode.code == null) {
      return;
    }
    if (barCode.code?.toUpperCase().startsWith("UR:ENVELOPE") == true ||
        primeQlPayloadDecoder != null) {
      if (primeQlPayloadDecoder == null) {
        qrDecoder = await getQrDecoder();
        primeQlPayloadDecoder = PrimeQlPayloadDecoder(
          decoder: qrDecoder!,
          refreshDecoder: getQrDecoder,
          onScan: (xidDocument) {
            if (onXidScan != null) {
              onXidScan!(xidDocument);
            }
          },
        )..onProgressUpdates((progress) {
            progressCallBack?.call(progress);
          });
      }
      await primeQlPayloadDecoder!.onDetectBarCode(barCode);
      progressCallBack
          ?.call(primeQlPayloadDecoder!.urDecoder.urDecoder.progress);
    } else if (barCode.code?.toLowerCase().startsWith("ur:") == true) {
      await pairPayloadDecoder.onDetectBarCode(barCode);
      progressCallBack?.call(pairPayloadDecoder.urDecoder.urDecoder.progress);
    } else {
      if (!previousCode.toLowerCase().startsWith("ur:")) {
        onScan(barCode.code!);
      }
    }
    previousCode = barCode.code ?? "";
  }
}
