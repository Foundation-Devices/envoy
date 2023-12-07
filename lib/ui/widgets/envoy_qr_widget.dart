// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// general QR widget for various use-cases
class EnvoyQR extends StatefulWidget {
  ///QR widget siz
  final double? dimension;

  ///QR size, this size will be used as canvas size for qr
  final double? qrSize;
  final ImageProvider? embeddedImage;

  ///Size for embedded image
  final Size? embeddedImageSize;

  final String data;

  const EnvoyQR(
      {super.key,
      this.dimension,
      this.embeddedImage,
      this.embeddedImageSize,
      this.qrSize,
      required this.data});

  @override
  State<EnvoyQR> createState() => _EnvoyQRState();
}

class _EnvoyQRState extends State<EnvoyQR> {
  @override
  Widget build(BuildContext context) {
    Widget qrWidget = QrImageView(
        data: widget.data,
        gapless: true,
        embeddedImage: widget.embeddedImage,
        embeddedImageStyle:
            QrEmbeddedImageStyle(size: widget.embeddedImageSize),
        backgroundColor: Colors.transparent,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        size: widget.qrSize);
    return widget.dimension == null
        ? SizedBox.expand(
            child: qrWidget,
          )
        : SizedBox.square(
            dimension: widget.dimension,
            child: qrWidget,
          );
  }
}
