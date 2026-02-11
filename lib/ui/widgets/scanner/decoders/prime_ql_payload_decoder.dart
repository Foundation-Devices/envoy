// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class PrimeQlPayloadDecoder extends ScannerDecoder {
  final Function(XidDocument binary) onScan;
  final Future<ArcMutexDecoder> Function()? refreshDecoder;
  ArcMutexDecoder decoder;
  bool successfullyDecoded = false;
  bool _needsDecoderRefresh = false;

  PrimeQlPayloadDecoder({
    required this.decoder,
    required this.onScan,
    this.refreshDecoder,
  });

  @override
  void reset() {
    super.reset();
    successfullyDecoded = false;
    _needsDecoderRefresh = true;
  }

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    final String code = barCode.code?.toLowerCase() ?? "";
    if (code.startsWith("ur:") == true) {
      kPrint(code);
      try {
        // Refresh decoder if needed (after reset due to error)
        if (_needsDecoderRefresh && refreshDecoder != null) {
          decoder = await refreshDecoder!();
          _needsDecoderRefresh = false;
        }
        final decoderStatus = await decodeQr(decoder: decoder, qr: code);
        progressCallBack?.call(decoderStatus.progress);
        if (decoderStatus.payload != null && !successfullyDecoded) {
          progressCallBack?.call(1);
          kPrint("Got the xidDoc ${decoderStatus.payload}");
          onScan(decoderStatus.payload!);
          successfullyDecoded = true;
        }
      } catch (e) {
        kPrint(e);
        rethrow;
      }
    }
    return;
  }

  @override
  void onDecodeError(
    BuildContext context,
    Exception e, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    EnvoyToast(
      replaceExisting: true,
      message: "Invalid Pair Payload",
      actionButtonText: S().component_retry,
      isDismissible: false,
      onActionTap: () {
        EnvoyToast.dismissPreviousToasts(context);
        reset();
        if (onRetry != null) onRetry();
      },
      icon: const Icon(
        Icons.info_outline,
        color: EnvoyColors.white95,
      ),
    ).show(context);
  }
}
