// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/uniform_resource.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class UnableToDecodeException implements Exception {
  @override
  toString() => "Couldn't decode UR!";
}

abstract class ScannerDecoder {
  Function(double progress)? _progressCallBack;
  final UniformResourceReader _urDecoder = UniformResourceReader();
  bool _processing = false;

  ScannerDecoder();

  onProgressUpdates(Function(double progress) progressCallBack) {
    _progressCallBack = progressCallBack;
  }

  UniformResourceReader get urDecoder => _urDecoder;

  Function(double progress)? get progressCallBack => _progressCallBack;

  Future<void> onDetectBarCode(Barcode barCode);

  Object? processUr(Barcode barCode) {
    if (_urDecoder.decoded != null && !_processing) {
      _processing = true;
      try {
        _urDecoder.receive(barCode.code?.toLowerCase() ?? "");
      } catch (e) {
        throw UnableToDecodeException();
      } finally {
        _processing = false;
      }
    }
    return urDecoder.decoded;
  }
}
