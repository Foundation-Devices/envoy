// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class InvalidPairPayloadException implements Exception {
  @override
  toString() => "Invalid Pair Payload";
}

class AccountAlreadyPairedException implements Exception {
  @override
  toString() => "Account already connected";
}

class InvalidNetworkException implements Exception {
  @override
  toString() => "Please use Testnet";
}

class PairPayloadDecoder extends ScannerDecoder {
  final Function(Binary binary) onScan;
  bool _scanFinished = false;

  PairPayloadDecoder({required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    final String code = barCode.code?.toLowerCase() ?? "";
    if (code.startsWith("ur:") == true) {
      final payload = processUr(barCode);
      //show progress if the code is UR
      progressCallBack?.call(urDecoder.urDecoder.progress);
      if (payload is Binary) {
        if (_validatePairData(payload)) {
          if (_scanFinished) return;
          onScan(payload);
          _scanFinished = true;
        } else {
          throw InvalidPairPayloadException();
        }
      } else if (urDecoder.urDecoder.progress == 1) {
        throw InvalidPairPayloadException();
      }
    } else {
      //handle new paring flow
    }
    return;
  }

  bool _validatePairData(Object? object) {
    if (object is Binary) {
      return true;
    }
    if (object is CryptoRequest) {
      var hdkey = ((object).objects[1]) as CryptoHdKey;
      if (hdkey.network! == HdKeyNetwork.testnet) {
        return true;
      }
    }
    return false;
  }
}
