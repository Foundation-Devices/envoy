// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'src/rust/api/ur.dart' as rust;
import 'src/rust/frb_generated.dart';

export 'src/rust/api/ur.dart' show DecoderOutput;

class InvalidScheme implements Exception {}

class Ur {
  Ur();

  UrEncoder encoder(String urType, Uint8List message, int maxFragmentLen) {
    return UrEncoder(urType, message, maxFragmentLen);
  }

  UrDecoder decoder() {
    return UrDecoder();
  }

  static Uint8List decodeSinglePart(String value) {
    return rust.decodeSinglePart(value: value);
  }

  /// Initialize the Rust library. Call this once before using the UR library.
  static Future<void> init() async {
    await RustLib.init();
  }
}

class UrEncoder {
  final rust.UrEncoderWrapper _encoder;

  UrEncoder(String urType, Uint8List message, int maxFragmentLen)
      : _encoder = rust.UrEncoderWrapper(
          urType: urType,
          message: message,
          maxFragmentLen: BigInt.from(maxFragmentLen),
        );

  String nextPart() {
    return _encoder.nextPart();
  }
}

class UrDecoder {
  final rust.UrDecoderWrapper _decoder;

  double progress = 0.0;

  UrDecoder() : _decoder = rust.UrDecoderWrapper();

  Uint8List receive(String value) {
    List<String> allowedSchemes = [
      "bytes",
      "crypto-response",
      "crypto-hdkey",
      "crypto-request",
      "crypto-psbt"
    ];

    if (value.startsWith("ur:")) {
      // Extract the scheme by splitting at '/'
      String scheme = value.substring(3).split('/').first;

      if (!allowedSchemes.contains(scheme)) {
        throw Exception("Invalid BIP21 URI");
      }
    }

    try {
      final output = _decoder.receive(value: value);
      progress = output.progress;
      return output.message;
    } catch (e) {
      throw _getRustException(e.toString());
    }
  }

  Exception _getRustException(String rustError) {
    if (rustError.contains('scheme')) {
      return InvalidScheme();
    } else {
      return Exception(rustError);
    }
  }
}
