// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class InvalidPsbtQrException implements Exception {
  @override
  String toString() => "Invalid PSBT QR";
}

class CryptoTxDecoder extends ScannerDecoder {
  final Function(CryptoPsbt cryptoPsbt) onScan;
  bool _invoked = false;
  bool _errorDialogShown = false;

  CryptoTxDecoder({required this.onScan});

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    if (barCode.code == null) {
      return;
    }

    final code = barCode.code!.toLowerCase();

    // Check if it's a UR code
    if (!code.startsWith("ur:")) {
      throw InvalidPsbtQrException();
    }

    final payload = processUr(barCode);

    // Check if the UR decoded successfully and is a CryptoPsbt
    if (payload != null && !_invoked) {
      if (payload is! CryptoPsbt) {
        throw InvalidPsbtQrException();
      }
      _invoked = true;
      onScan(payload);
    }
  }

  @override
  void onDecodeError(
    BuildContext context,
    Exception e, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    if (e is InvalidPsbtQrException) {
      if (_errorDialogShown) return;
      _errorDialogShown = true;

      showEnvoyPopUp(
          context,
          S().invalid_qr_subheading,
          S().component_retry,
          (context) {
            Navigator.of(context).pop();
          },
          title: S().invalid_qr_heading,
          typeOfMessage: PopUpState.warning,
          icon: EnvoyIcons.alert,
          dismissible: false,
          showCloseButton: false,
          secondaryButtonLabel: S().component_back,
          onSecondaryButtonTap: (context) {
            Navigator.of(context).pop();
          }).then((_) {
        _errorDialogShown = false;
        reset();
        onRetry?.call();
      });
    } else {
      super.onDecodeError(context, e, onRetry: onRetry, onCancel: onCancel);
    }
  }
}
