// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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

  PairPayloadDecoder({required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    final String code = barCode.code?.toLowerCase() ?? "";
    if (code.startsWith("ur:") == true) {
      final payload = processUr(barCode);
      //show progress if the code is UR
      progressCallBack?.call(urDecoder.urDecoder.progress);
      if (payload is Binary) {
        if (_validatePairData(payload) && await _binaryValidated(payload)) {
          onScan(payload);
        } else {
          throw InvalidPairPayloadException();
        }
      } else if (urDecoder.urDecoder.progress == 1) {
        throw InvalidPairPayloadException();
      }
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

  Future<bool> _binaryValidated(Binary object) async {
    try {
      EnvoyAccountHandler? pairedAccount =
          await NgAccountManager().processPassportAccounts(object);
      if (pairedAccount == null) {
        return true;
      } else {
        throw AccountAlreadyPairedException();
      }
    } on AccountAlreadyPaired catch (_) {
      throw AccountAlreadyPairedException();
    }
  }
}
