// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScvDecoder extends ScannerDecoder {
  final Function(CryptoResponse cryptoResponse) onScan;

  ScvDecoder({required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    final String code = barCode.code?.toLowerCase() ?? "";
    if (code.startsWith("ur:") == true) {
      final payload = processUr(barCode);
      if (payload is CryptoResponse) {
        onScan(payload);
      } else {
        throw UnableToDecodeException();
      }
    } else {
      throw UnableToDecodeException();
    }
  }

  /// Custom error handling for SCV QR decoding
  @override
  void onDecodeError(BuildContext context, Exception e,
      {VoidCallback? onRetry, VoidCallback? onCancel}) {
    showEnvoyPopUp(
      context,
      title: S().scv_cameraModalUnexpectedQrFormat_header,
      S().scv_cameraModalUnexpectedQrFormat_content,
      S().component_retry,
      (BuildContext context) {
        if (onRetry != null) onRetry();
      },
      icon: EnvoyIcons.alert,
      showCloseButton: false,
      typeOfMessage: PopUpState.warning,
      secondaryButtonLabel: S().component_cancel,
      onSecondaryButtonTap: (BuildContext context) {
        if (onCancel != null) onCancel();
      },
    );
  }
}
