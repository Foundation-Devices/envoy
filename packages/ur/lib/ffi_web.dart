// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'js.dart' as js;
import 'dart:typed_data';

class Ur {
  Ur();

  UrEncoder encoder(Uint8List message, int maxFragmentLen) {
    return UrEncoder(message, maxFragmentLen);
  }

  UrDecoder decoder() {
    return UrDecoder();
  }
}

String _extractString(Uint8List buf) {
  String s = "";
  int i = 0;
  while (true) {
    if (buf[i] == 0) {
      break;
    } else {
      s += String.fromCharCode(buf[i]);
    }
    i++;
  }
  return s;
}

class UrEncoder {
  late int _self;

  UrEncoder(Uint8List message, int maxFragmentLen) {
    var buf = js.buffer as ByteBuffer;
    buf.asUint8List().setRange(0, message.length, message);
    _self = js.urEncoder(0, message.length, maxFragmentLen);
  }

  String nextPart() {
    var pointer = js.urEncoderNextPart(_self);
    var buf = js.buffer as ByteBuffer;
    return _extractString(buf.asUint8List(pointer));
  }
}

class UrDecoder {
  late int _self;

  UrDecoder() {
    _self = js.urDecoder();
  }

  Uint8List receive(String value) {
    List<int> cString = [];
    cString.addAll(value.codeUnits);
    cString.add(0);

    var buf = js.buffer as ByteBuffer;
    buf.asUint8List().setRange(0, cString.length, cString);

    var ptr = js.urDecoderReceive(_self, 0);

    var list32 = buf.asUint32List(ptr, 2);
    int len = list32[0];
    int data = list32[1];

    return buf.asUint8List(data, len);
  }
}
