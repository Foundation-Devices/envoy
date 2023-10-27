// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tor/tor.dart';
import 'package:schedulers/schedulers.dart';

enum Verb { Get, Post }

class Request {
  Verb verb;
  String uri;
  int torPort;
  String? body;
  Map<String, String>? headers;

  Request(this.verb, this.uri, this.torPort, {this.body, this.headers});
}

class GetFileRequest {
  String path;
  String uri;
  int torPort;

  GetFileRequest(this.path, this.uri, this.torPort);
}

class NativeResponse extends Struct {
  @Int32()
  external int responseCode;
  @Uint32()
  external int bodyLen;
  external Pointer<Uint8> body;
}

class Response {
  final int code;
  final List<int> bodyBytes;

  int get statusCode {
    return code;
  }

  get body {
    return utf8.decode(bodyBytes);
  }

  Response(this.code, this.bodyBytes);

  factory Response.fromNative(NativeResponse response) {
    Uint8List body = response.body.asTypedList(response.bodyLen);
    List<int> bytes = new List.from(body);
    return Response(response.responseCode, bytes);
  }
}

typedef DartPostCObject = Pointer Function(
    Pointer<NativeFunction<Int8 Function(Int64, Pointer<Dart_CObject>)>>);

typedef HttpRequestRust = NativeResponse Function(
    Int16 verb,
    Pointer<Utf8> url,
    Int32 torPort,
    Pointer<Utf8> body,
    Uint8 headerNumber,
    Pointer<Pointer<Utf8>> headers);
typedef HttpRequestDart = NativeResponse Function(
    int verb,
    Pointer<Utf8> url,
    int torPort,
    Pointer<Utf8> body,
    int headerLen,
    Pointer<Pointer<Utf8>> headers);

typedef HttpGetFileRust = Pointer<Uint8> Function(
    Pointer<Utf8> path, Pointer<Utf8> url, Int32 torPort, Int64);
typedef HttpGetFileDart = Pointer<Uint8> Function(
    Pointer<Utf8> path, Pointer<Utf8> url, int torPort, int);

typedef HttpGetFileCancelRust = Void Function(Pointer<Uint8>);
typedef HttpGetFileCancelDart = void Function(Pointer<Uint8>);

//typedef HttpProgressCallbackRust = Void Function(Uint64, Uint64);

typedef HttpHelloRust = Void Function();
typedef HttpHelloDart = void Function();

typedef HttpGetIpRust = Pointer<Utf8> Function(Int32 torPort);
typedef HttpGetIpDart = Pointer<Utf8> Function(int torPort);

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

typedef LastErrorMessageRust = Pointer<Utf8> Function();
typedef LastErrorMessageDart = Pointer<Utf8> Function();

throwRustException(DynamicLibrary lib) {
  String rustError = _lastErrorMessage(lib);
  throw _getRustException(rustError);
}

Exception _getRustException(String rustError) {
  if (rustError.contains('timed out')) {
    return TimeoutException("Timed out");
  } else
    return Exception(rustError);
}

String _lastErrorMessage(DynamicLibrary lib) {
  final rustFunction = lib
      .lookup<NativeFunction<LastErrorMessageRust>>('http_last_error_message');
  final dartFunction = rustFunction.asFunction<LastErrorMessageDart>();

  return dartFunction().cast<Utf8>().toDartString();
}

class NotSupportedPlatform implements Exception {
  NotSupportedPlatform(String s);
}

class Progress {
  final int downloaded;
  final int total;

  Progress(this.downloaded, this.total);
}

class Download {
  final Stream<Progress> progress;
  final SendPort mainToIsolateStream;

  Download(this.progress, this.mainToIsolateStream);

  cancel() {
    mainToIsolateStream.send("cancel");
  }
}

class HttpTor {
  static late String _libName = "http_ffi";
  final Tor tor;
  final ParallelScheduler scheduler;

  HttpTor(this.tor, this.scheduler);

  static Future<Response> _makeRequest(Request request) async {
    var lib = load(_libName);
    final rustFunction =
        lib.lookup<NativeFunction<HttpRequestRust>>('http_request');
    final dartFunction = rustFunction.asFunction<HttpRequestDart>();

    Pointer<Utf8> nativeBody;
    if (request.body != null) {
      nativeBody = request.body!.toNativeUtf8();
    } else {
      nativeBody = "".toNativeUtf8();
    }

    int headersNumber = 0;
    Pointer<Pointer<Utf8>> nativeHeaders = nullptr;

    if (request.headers != null) {
      headersNumber = request.headers!.length;
      nativeHeaders = calloc(headersNumber * 2);

      int i = 0;
      for (var header in request.headers!.entries) {
        nativeHeaders[i] = header.key.toNativeUtf8();
        nativeHeaders[i + 1] = header.value.toNativeUtf8();
        i = i + 2;
      }
    }

    // Workaround as isolates lack type safety
    String uri = request.uri;

    NativeResponse response = dartFunction(
        request.verb.index,
        uri.toNativeUtf8(),
        request.torPort,
        nativeBody,
        headersNumber,
        nativeHeaders);

    if (response.body == nullptr) {
      throwRustException(lib);
    }

    return Response.fromNative(response);
  }

  // Callbacks need to be static: https://github.com/dart-lang/sdk/issues/47405
  // static void _progress(int downloaded, int total) {
  //   print("$downloaded / $total");
  // }

  Future<Response> _makeHttpRequest(Verb verb, String uri,
      {String? body, Map<String, String>? headers}) async {
    await tor.isReady();
    int torPort = tor.port;
    return scheduler
        .run(() => Isolate.run(() => _makeRequest(
            Request(verb, uri, torPort, body: body, headers: headers))))
        .result
        .then((response) => response, onError: (e) {
      if (e is TimeoutException) {
        throw TimeoutException("Timed out");
      }
      throw Exception(e.message);
    });
  }

  Future<Response> get(String uri,
      {String? body, Map<String, String>? headers}) async {
    return _makeHttpRequest(Verb.Get, uri, body: body, headers: headers);
  }

  Future<Response> post(String uri,
      {String? body, Map<String, String>? headers}) async {
    return _makeHttpRequest(Verb.Post, uri, body: body, headers: headers);
  }

  static Future<String> _getIp(int torPort) async {
    var lib = load(_libName);
    final rustFunction =
        lib.lookup<NativeFunction<HttpGetIpRust>>('http_get_ip');
    final dartFunction = rustFunction.asFunction<HttpGetIpDart>();

    return dartFunction(torPort).cast<Utf8>().toDartString();
  }

  Future<String> getIp() async {
    return compute(_getIp, tor.port);
  }

  Future<Download> getFile(String path, String uri) async {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }

    await tor.isReady();

    var streamController = StreamController<Progress>.broadcast();
    SendPort mainToIsolateStream = await _initGetFileIsolate(streamController);
    mainToIsolateStream.send(GetFileRequest(path, uri, tor.port));

    return Download(streamController.stream, mainToIsolateStream);
  }

  Future<SendPort> _initGetFileIsolate(
      StreamController<Progress> progressStream) async {
    Completer<SendPort> completer = new Completer<SendPort>();
    ReceivePort isolateToMainStream = ReceivePort();

    isolateToMainStream.listen((data) {
      if (data is SendPort) {
        SendPort mainToIsolateStream = data;
        completer.complete(mainToIsolateStream);
      } else if (data is String) {
        List<String> split = data.split("/");

        int downloaded = int.parse(split[0]);
        int total = int.parse(split[1]);

        progressStream.add(Progress(downloaded, total));
      }
    });

    await Isolate.spawn(_getFileIsolate, isolateToMainStream.sendPort,
        errorsAreFatal: false);
    return completer.future;
  }

  static void _getFileIsolate(SendPort isolateToMainStream) {
    ReceivePort mainToIsolateStream = ReceivePort();
    isolateToMainStream.send(mainToIsolateStream.sendPort);

    Pointer<Uint8>? joinHandlePointer;

    mainToIsolateStream.listen((data) async {
      if (data is GetFileRequest) {
        joinHandlePointer = await _getFile(
            data.path, data.uri, data.torPort, isolateToMainStream.nativePort);
      } else if (data == "cancel") {
        if (joinHandlePointer != null) {
          _getFileCancel(joinHandlePointer!);
        }
      }
    });
  }

  static Future<Pointer<Uint8>> _getFile(
      String path, String uri, int torPort, int isolatePort) async {
    var lib = load(_libName);
    final storeDartPostCObject =
        lib.lookupFunction<DartPostCObject, DartPostCObject>(
      'store_dart_post_cobject',
    );

    storeDartPostCObject(NativeApi.postCObject);

    final rustFunction =
        lib.lookup<NativeFunction<HttpGetFileRust>>('http_get_file');
    final dartFunction = rustFunction.asFunction<HttpGetFileDart>();

    // Pointer<NativeFunction<HttpProgressCallbackRust>> progressCallback =
    // Pointer.fromFunction(_progress);

    return dartFunction(
        path.toNativeUtf8(), uri.toNativeUtf8(), torPort, isolatePort);
  }

  static Future<void> _getFileCancel(Pointer<Uint8> handle) async {
    var lib = load(_libName);

    final rustFunction = lib
        .lookup<NativeFunction<HttpGetFileCancelRust>>('http_get_file_cancel');
    final dartFunction = rustFunction.asFunction<HttpGetFileCancelDart>();

    return dartFunction(handle);
  }
}
