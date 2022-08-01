// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:envoy/business/uniform_resource.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:ur/ur.dart';

class AnimatedQrImage extends StatefulWidget {
  // We can either iterate over a 'raw' UrEncoder (to send binary messages)...
  late final UrEncoder? urEncoder;

  // ...or a CryptoRequest object that has its own encoder within
  final CryptoRequest? cryptoRequest;

  final int refreshRate;
  final double? size;

  AnimatedQrImage(Uint8List message,
      {this.refreshRate: 3,
      int maxFragmentLength: 100,
      this.size,
      this.cryptoRequest,
      String urType: "bytes",
      bool binaryCborTag: false}) {
    List<int> tag = [];
    if (binaryCborTag) {
      // https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md#canonical-cbor
      int len = message.length;
      if (len <= 23) {
        tag = [0x40 + len];
      } else if (len <= 255) {
        tag = [0x58, len];
      } else if (len <= 65535) {
        var lenBytes = Uint8List(2)
          ..buffer.asByteData().setInt16(0, len, Endian.big);
        tag = [0x59, lenBytes[0], lenBytes[1]];
      }
    }

    List<int> completeMessage = tag + message;

    urEncoder = Ur().encoder(
        urType, Uint8List.fromList(completeMessage), maxFragmentLength);
  }

  AnimatedQrImage.fromUrCryptoRequest(CryptoRequest request,
      {this.refreshRate: 5, this.size, this.urEncoder})
      : cryptoRequest = request;

  void onLoad(BuildContext context) {}

  @override
  createState() {
    return AnimatedQrImageState();
  }
}

class AnimatedQrImageState extends State<AnimatedQrImage> {
  late Timer _timer;

  void startTimer() {
    var duration = Duration(milliseconds: 1000 ~/ widget.refreshRate);
    _timer = new Timer.periodic(duration, (Timer timer) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    widget.onLoad(context);
  }

  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QrImage(
      data: widget.urEncoder != null
          ? widget.urEncoder!.nextPart().toUpperCase()
          : widget.cryptoRequest!.nextPart().toUpperCase(),
      size: widget.size,
      backgroundColor: Colors.transparent,
    );
  }
}
