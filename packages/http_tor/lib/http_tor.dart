// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'package:tor/tor.dart';
import 'package:schedulers/schedulers.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

import 'src/rust/frb_generated.dart';
import 'src/rust/api/http.dart' as http;
export 'src/rust/api/http.dart';

class GetFileRequest {
  String path;
  String uri;
  int torPort;

  GetFileRequest(this.path, this.uri, this.torPort);
}

class FileDownload {
  final Stream<http.Progress> progress;
  final void Function() cancel;

  FileDownload({required this.progress, required this.cancel});
}

class HttpTor {
  late final Tor tor;
  late final ParallelScheduler scheduler;
  static final HttpTor _instance = HttpTor._internal();

  factory HttpTor() {
    return _instance;
  }

  static Future<HttpTor> init(Tor tor, ParallelScheduler scheduler) async {
    var singleton = HttpTor._instance;

    singleton.tor = tor;
    singleton.scheduler = scheduler;

    return singleton;
  }

  HttpTor._internal() {
    _init();
  }

  Future _init() async {
    await RustLib.init();
  }

  Future<http.Response> get(
    String uri, {
    String? body,
    Map<String, String>? headers,
  }) async {
    return _makeHttpRequest(
      http.Verb.get_,
      uri,
      body: body?.codeUnits,
      headers: headers,
    );
  }

  Future<http.Response> post(
    String uri, {
    String? body,
    Map<String, String>? headers,
  }) async {
    return _makeHttpRequest(
      http.Verb.post,
      uri,
      body: body?.codeUnits,
      headers: headers,
    );
  }

  Future<http.Response> postBytes(
    String uri, {
    List<int>? body,
    Map<String, String>? headers,
  }) async {
    return _makeHttpRequest(http.Verb.post, uri, body: body, headers: headers);
  }

  Future<String> getIp() async {
    return http.getIp(torPort: tor.port);
  }

  Future<FileDownload> getFile(String path, String uri) async {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }

    await tor.isReady();

    final progressStream = http.ProgressStream(field0: RustStreamSink());

    final download = await http.getFile(
      path: path,
      url: uri,
      torPort: tor.port,
      progressStream: progressStream,
    );

    return FileDownload(
      progress: progressStream.field0.stream,
      cancel: download.cancel,
    );
  }

  Future<http.Response> _makeHttpRequest(
    http.Verb verb,
    String uri, {
    List<int>? body,
    Map<String, String>? headers,
  }) async {
    await tor.isReady();
    int torPort = tor.port;
    return scheduler
        .run(
          () => _makeRequest(verb, uri, torPort, body: body, headers: headers),
        )
        .result
        .then(
          (response) => response,
          onError: (e) {
            if (e is TimeoutException) {
              throw TimeoutException("Timed out $uri, torPort: $torPort");
            }
            throw Exception(e.message);
          },
        );
  }

  static Future<http.Response> _makeRequest(
    http.Verb verb,
    String uri,
    int torPort, {
    List<int>? body,
    Map<String, String>? headers,
  }) async {
    // pretend to be wget to avoid cloudflare captchas and other challenges
    headers ??= {"User-Agent": "Wget/1.12"};

    return http.request(
      verb: verb,
      url: uri,
      torPort: torPort,
      body: body != null ? Uint8List.fromList(body) : null,
      headers: headers,
    );
  }
}
