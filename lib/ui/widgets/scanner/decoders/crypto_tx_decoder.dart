// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:envoy/util/bug_report_helper.dart';
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
      EnvoyReport().log(
        "CryptoTxDecoder",
        "Non-UR QR rejected | "
            "code_prefix='${_codePrefix(code)}' code_len=${code.length}",
      );
      throw InvalidPsbtQrException();
    }

    final payload = processUr(barCode);

    // Check if the UR decoded successfully and is a CryptoPsbt
    if (payload != null && !_invoked) {
      if (payload is! CryptoPsbt) {
        EnvoyReport().log(
          "CryptoTxDecoder",
          "Decoded UR is not CryptoPsbt | "
              "ur_type=${_urType(code)} "
              "progress=${progress.toStringAsFixed(2)} "
              "decoded=${payload.runtimeType} "
              "first_byte=${_firstPayloadByte(payload)}",
        );
        throw InvalidPsbtQrException();
      }
      _invoked = true;
      onScan(payload);
    }
  }

  String _codePrefix(String code) =>
      code.length > 24 ? code.substring(0, 24) : code;

  String _urType(String code) {
    final colon = code.indexOf(":");
    final slash = code.indexOf("/");
    if (colon < 0 || slash < 0 || slash <= colon + 1) return "?";
    return code.substring(colon + 1, slash);
  }

  // CBOR major type lives in the top 3 bits of the first byte:
  //   2 (0x40-0x5f) = byte string — what a valid CryptoPsbt payload should be.
  String _firstPayloadByte(Object payload) {
    try {
      final bytes = (payload as dynamic).payload;
      if (bytes is List<int> && bytes.isNotEmpty) {
        return "0x${bytes[0].toRadixString(16).padLeft(2, '0')}";
      }
    } catch (_) {}
    return "n/a";
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
