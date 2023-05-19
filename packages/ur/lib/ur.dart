// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'dart:io' show Platform;
import 'dart:typed_data';

class StringArray extends Struct {
  @Uint32()
  external int len;
  external Pointer<Pointer<Uint8>> strings;
}

class CharArray extends Struct {
  @Uint32()
  external int len;
  external Pointer<Uint8> string;
}

typedef UrEncoderRust = Pointer<Uint8> Function(
    Pointer<Utf8>, Pointer<Uint8>, Int32, Int32);
typedef UrEncoderDart = Pointer<Uint8> Function(
    Pointer<Utf8>, Pointer<Uint8>, int, int);

typedef UrEncoderNextPartRust = Pointer<Uint8> Function(Pointer<Uint8>);
typedef UrEncoderNextPartDart = Pointer<Uint8> Function(Pointer<Uint8>);

typedef UrDecoderRust = Pointer<Uint8> Function();
typedef UrDecoderDart = Pointer<Uint8> Function();

typedef UrDecoderReceiveRust = Pointer<CharArray> Function(
    Pointer<Uint8>, Pointer<Utf8>);
typedef UrDecoderReceiveDart = Pointer<CharArray> Function(
    Pointer<Uint8>, Pointer<Utf8>);

typedef DecodeSinglePartRust = Pointer<CharArray> Function(Pointer<Utf8>);
typedef DecodeSinglePartDart = Pointer<CharArray> Function(Pointer<Utf8>);

DynamicLibrary load(name) {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('lib$name.so');
  } else if (Platform.isLinux) {
    return DynamicLibrary.open('target/debug/lib$name.so');
  } else if (Platform.isIOS || Platform.isMacOS) {
    // iOS and MacOS are statically linked, so it is the same as the current process
    return DynamicLibrary.process();
  } else {
    throw NotSupportedPlatform('${Platform.operatingSystem} is not supported!');
  }
}

class NotSupportedPlatform implements Exception {
  NotSupportedPlatform(String s);
}

class Ur {
  static late String _libName = "ur_ffi";
  static late DynamicLibrary _lib;

  Ur() {
    _lib = load(_libName);
  }

  UrEncoder encoder(String urType, Uint8List message, int maxFragmentLen) {
    return UrEncoder(_lib, urType, message, maxFragmentLen);
  }

  UrDecoder decoder() {
    return UrDecoder(_lib);
  }

  static Uint8List decodeSinglePart(String value) {
    final rustFunction = load(_libName)
        .lookup<NativeFunction<DecodeSinglePartRust>>('decode_single_part');
    final dartFunction = rustFunction.asFunction<DecodeSinglePartDart>();

    final ptr = dartFunction(value.toNativeUtf8());

    var len = ptr.ref.len;
    var str = ptr.ref.string;

    return str.asTypedList(len);
  }
}

class UrEncoder {
  Pointer<Uint8> _self = Pointer<Uint8>.fromAddress(0);
  static late DynamicLibrary _lib;

  UrEncoder(DynamicLibrary lib, String urType, Uint8List message,
      int maxFragmentLen) {
    _lib = lib;
    final rustFunction =
        _lib.lookup<NativeFunction<UrEncoderRust>>('ur_encoder');
    final dartFunction = rustFunction.asFunction<UrEncoderDart>();

    final Pointer<Uint8> messagePointer =
        malloc.allocate<Uint8>(message.length);
    final pointerList = messagePointer.asTypedList(message.length);
    pointerList.setAll(0, message);

    _self = dartFunction(
        urType.toNativeUtf8(), messagePointer, message.length, maxFragmentLen);
  }

  String nextPart() {
    final rustFunction = _lib
        .lookup<NativeFunction<UrEncoderNextPartRust>>('ur_encoder_next_part');
    final dartFunction = rustFunction.asFunction<UrEncoderNextPartDart>();

    var pointer = dartFunction(_self);
    String part = pointer.cast<Utf8>().toDartString();

    malloc.free(pointer);

    return part;
  }
}

class UrDecoder {
  Pointer<Uint8> _self = Pointer<Uint8>.fromAddress(0);
  static late DynamicLibrary _lib;

  UrDecoder(DynamicLibrary lib) {
    _lib = lib;
    final rustFunction =
        _lib.lookup<NativeFunction<UrDecoderRust>>('ur_decoder');
    final dartFunction = rustFunction.asFunction<UrDecoderDart>();

    _self = dartFunction();
  }

  Uint8List receive(String value) {
    final rustFunction =
        _lib.lookup<NativeFunction<UrDecoderReceiveRust>>('ur_decoder_receive');
    final dartFunction = rustFunction.asFunction<UrDecoderReceiveDart>();

    final ptr = dartFunction(_self, value.toNativeUtf8());

    var len = ptr.ref.len;
    var str = ptr.ref.string;

    return str.asTypedList(len);
  }
}
