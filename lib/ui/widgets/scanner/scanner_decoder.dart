// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class UnableToDecodeException implements Exception {
  @override
  toString() => "Couldn't decode UR!";
}

abstract class ScannerDecoder {
  Function(double progress)? _progressCallBack;
  UniformResourceReader _urDecoder = UniformResourceReader();
  bool _processing = false;

  ScannerDecoder();

  void onProgressUpdates(Function(double progress) progressCallBack) {
    _progressCallBack = progressCallBack;
  }

  UniformResourceReader get urDecoder => _urDecoder;

  double get progress => _urDecoder.urDecoder.progress;

  Function(double progress)? get progressCallBack => _progressCallBack;

  Future<void> onDetectBarCode(Barcode barCode);

  Object? processUr(Barcode barCode) {
    if (_urDecoder.decoded == null && !_processing) {
      _processing = true;
      try {
        _urDecoder.receive(barCode.code?.toLowerCase() ?? "");
        progressCallBack?.call(_urDecoder.urDecoder.progress);
      } catch (e) {
        reset(); // clear bad partial state so next scan can work
        throw UnableToDecodeException();
      } finally {
        _processing = false;
      }
    }
    return urDecoder.decoded;
  }

  void reset() {
    _processing = false;
    _urDecoder = UniformResourceReader();
  }

  /// Allow subclasses to handle decoding errors in their own way
  void onDecodeError(
    BuildContext context,
    Exception e, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    // Default behavior: show EnvoyToast and reset scanning when retry is tapped
    EnvoyToast(
      replaceExisting: true,
      message: e.toString(),
      actionButtonText: S().component_retry,
      isDismissible: false,
      onActionTap: () {
        EnvoyToast.dismissPreviousToasts(context);
        if (onRetry != null) onRetry();
      },
      icon: const Icon(
        Icons.info_outline,
        color: EnvoyColors.white95,
      ),
    ).show(context);
  }
}
