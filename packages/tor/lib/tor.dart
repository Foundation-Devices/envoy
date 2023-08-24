// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:ffi/ffi.dart';
import 'generated_bindings.dart';

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

class ServerUnreachable implements Exception {
  String? rustError;
  ServerUnreachable({this.rustError});
}

class NotSupportedPlatform implements Exception {
  NotSupportedPlatform(String s);
}

enum TorStatus {
  started,
  bootstrapped,
  stopped,
  error,
}

class Tor {
  static late String _libName = "tor_ffi";
  static late DynamicLibrary _lib;

  Pointer<Int> clientPtr = nullptr;

  bool enabled = true;
  bool started = false;
  bool bootstrapped = false;

  // This stream broadcast just the port for now (-1 if circuit not established)
  final StreamController events = StreamController.broadcast();

  int port = -1;
  static final Tor _instance = Tor._internal();

  factory Tor() {
    return _instance;
  }

  static Future<Tor> init() async {
    var singleton = Tor._instance;
    return singleton;
  }

  Tor._internal() {
    _lib = load(_libName);
    print("Instance of Tor created!");
  }

  enable() async {
    enabled = true;
    if (!started) {
      start();
    }
  }

  Future<int> _getRandomUnusedPort({List<int> excluded = const []}) async {
    var random = Random.secure();
    int potentialPort = 0;

    retry:
    while (potentialPort <= 0 || excluded.contains(potentialPort)) {
      potentialPort = random.nextInt(65535);
      try {
        var socket = await ServerSocket.bind("0.0.0.0", potentialPort);
        socket.close();
        return potentialPort;
      } catch (_) {
        continue retry;
      }
    }

    return -1;
  }

  start() async {
    events.add(port);

    int newPort = await _getRandomUnusedPort();
    int ptr = await Isolate.run(() async {
      var lib = NativeLibrary(load(_libName));
      final ptr = lib.tor_start(newPort);

      if (ptr == nullptr) {
        throwRustException(lib);
      }

      return ptr.address;
    });

    clientPtr = Pointer.fromAddress(ptr);
    started = true;
    bootstrap();
    port = newPort;
  }

  bootstrap() async {
    var lib = NativeLibrary(_lib);
    bootstrapped = await lib.tor_bootstrap(clientPtr);
    if (!bootstrapped) {
      throwRustException(lib);
    }
  }

  disable() {
    enabled = false;
    started = false;
    port = -1;
  }

  restart() {
    if (enabled && started && bootstrapped) {
      // _shutdown().then((_) {
      //   events.add(port);
      //   start();
      // });
    }
  }

  Stream<TorStatus> getTorStatus() {
    return events.stream.map((port) {
      if (!this.enabled) {
        return TorStatus.stopped;
      }
      if (started && !bootstrapped) {
        return TorStatus.started;
      }
      if (port == -1) {
        return TorStatus.stopped;
      }
      if (this.bootstrapped) {
        return TorStatus.bootstrapped;
      }
      return TorStatus.stopped;
    });
  }

  isReady() async {
    return await Future.doWhile(
        () => Future.delayed(Duration(seconds: 1)).then((_) {
              // We are waiting and making absolutely no request unless:
              // Tor is disabled
              if (!this.enabled) {
                return false;
              }

              // ...or Tor circuit is established
              if (this.bootstrapped) {
                return false;
              }

              // This way we avoid making clearnet req's while Tor is initialising
              return true;
            }));
  }

  static throwRustException(NativeLibrary lib) {
    String rustError = lib.tor_last_error_message().cast<Utf8>().toDartString();

    throw _getRustException(rustError);
  }

  static Exception _getRustException(String rustError) {
    if (rustError.contains('unreachable') || rustError.contains('dns error')) {
      return ServerUnreachable(rustError: rustError);
    } else {
      return Exception(rustError);
    }
  }

  hello() {
    NativeLibrary(_lib).tor_hello();
  }
}
