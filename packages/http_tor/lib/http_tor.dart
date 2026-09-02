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

import 'dart:convert';

import 'src/request_route.dart';
import 'src/tor_readiness.dart';

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
  static const _verifiedDownloadOverallTimeout = Duration(minutes: 20);

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

  bool _isRetryableStatus(int code) =>
      code == 429 || code == 502 || code == 503 || code == 504;

  Future<http.Response> getWithRetry(
    String uri, {
    String? body,
    Map<String, String>? headers,
    int maxAttempts = 5,
    Duration baseDelay = const Duration(seconds: 1),
  }) async {
    http.Response? lastResponse;
    Object? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final res = await get(uri, body: body, headers: headers);
        lastResponse = res;

        if (res.statusCode == 200) return res;

        if (!_isRetryableStatus(res.statusCode) || attempt == maxAttempts) {
          return res; // non-retryable or out of attempts
        }
      } catch (e) {
        lastError = e;
        if (attempt == maxAttempts) rethrow;
      }

      final backoffMs = baseDelay.inMilliseconds * (1 << (attempt - 1));
      final jitterMs = (backoffMs * 0.25).round(); // small jitter
      final waitMs = backoffMs + (DateTime.now().microsecond % (jitterMs + 1));
      await Future.delayed(Duration(milliseconds: waitMs));
    }

    // Should be unreachable, but just in case:
    if (lastResponse != null) return lastResponse;
    throw lastError ?? Exception('Request failed with no response');
  }

  Future<http.Response> get(
    String uri, {
    String? body,
    Map<String, String>? headers,
  }) async {
    return _makeHttpRequest(
      http.Verb.get_,
      uri,
      body: body == null ? null : utf8.encode(body),
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
      body: body == null ? null : utf8.encode(body),
      headers: headers,
    );
  }

  Future<http.Response> postBytes(
    String uri, {
    required List<int> body,
    Map<String, String>? headers,
  }) async {
    return _makeHttpRequest(
      http.Verb.post,
      uri,
      body: Uint8List.fromList(body),
      headers: headers,
    );
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

  Future<File> downloadVerifiedFile(
    String path,
    String uri, {
    required int expectedSize,
    required String expectedSha256,
    required http.DownloadCancellationToken cancellationToken,
    void Function(http.Progress progress)? onProgress,
  }) async {
    // The URI was selected for this route before the call. Keep that choice
    // stable and fail closed if Tor is disabled while the download is active.
    final requiresTor = tor.enabled;
    final elapsed = Stopwatch()..start();
    return runWithRouteReplacement(
      requiresTor: requiresTor,
      resolveRoute: () async {
        final remaining = _verifiedDownloadTimeRemaining(elapsed);
        if (requiresTor) {
          await _waitForTorReadiness(remaining);
        }
        return resolveScheduledProxyPort(
          requiresTor: requiresTor,
          currentTorPort: tor.port,
        );
      },
      run: (torPort) => _downloadVerifiedFileOnRoute(
        path,
        uri,
        torPort: torPort,
        expectedSize: expectedSize,
        expectedSha256: expectedSha256,
        cancellationToken: cancellationToken,
        overallTimeout: _verifiedDownloadTimeRemaining(elapsed),
        onProgress: onProgress,
      ),
    );
  }

  Future<void> _waitForTorReadiness(Duration timeout) async {
    // Tor.isReady polls after Future.timeout has stopped listening. Waiting on
    // state events lets a timeout cancel its subscription without an orphan.
    await waitForTorReadiness(
      stateChanges: tor.events.stream,
      isEnabled: () => tor.enabled,
      isBootstrapped: () => tor.bootstrapped,
      timeout: timeout,
    );
  }

  Duration _verifiedDownloadTimeRemaining(Stopwatch elapsed) {
    final remaining = _verifiedDownloadOverallTimeout - elapsed.elapsed;
    if (remaining.inMilliseconds <= 0) {
      throw TimeoutException('Verified download exceeded the overall timeout');
    }
    return remaining;
  }

  Future<File> _downloadVerifiedFileOnRoute(
    String path,
    String uri, {
    required int torPort,
    required int expectedSize,
    required String expectedSha256,
    required http.DownloadCancellationToken cancellationToken,
    required Duration overallTimeout,
    void Function(http.Progress progress)? onProgress,
  }) async {
    final progressStream = http.ProgressStream(field0: RustStreamSink());
    // FRB initializes the sink while serializing the Rust call arguments.
    final download = http.downloadVerifiedFile(
      path: path,
      url: uri,
      torPort: torPort,
      expectedSize: BigInt.from(expectedSize),
      expectedSha256: expectedSha256,
      progressStream: progressStream,
      overallTimeoutMs: BigInt.from(overallTimeout.inMilliseconds),
      cancellationToken: cancellationToken,
    );
    final progressSubscription = progressStream.field0.stream.listen(
      onProgress ?? (_) {},
    );
    try {
      // A long transfer must not occupy the shared request scheduler.
      await download;
      return File(path);
    } finally {
      await progressSubscription.cancel();
    }
  }

  Future<http.Response> _makeHttpRequest(
    http.Verb verb,
    String uri, {
    Uint8List? body,
    Map<String, String>? headers,
  }) async {
    final requiresTor = tor.enabled;
    if (requiresTor) {
      await tor.isReady();
    }

    var resolvedPort = -1;

    try {
      return await scheduler.run(() async {
        // A restart may have happened while this request waited in the queue.
        // Resolve the route immediately before starting network I/O.
        if (requiresTor && tor.port == -1) {
          await tor.isReady();
        }

        resolvedPort = resolveScheduledProxyPort(
          requiresTor: requiresTor,
          currentTorPort: tor.port,
        );
        return _makeRequest(
          verb,
          uri,
          resolvedPort,
          body: body,
          headers: headers,
        );
      }).result;
    } on TimeoutException {
      throw TimeoutException("Timed out $uri, torPort: $resolvedPort");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<http.Response> _makeRequest(
    http.Verb verb,
    String uri,
    int torPort, {
    Uint8List? body,
    Map<String, String>? headers,
  }) async {
    // pretend to be wget to avoid cloudflare captchas and other challenges
    headers ??= {"User-Agent": "Wget/1.12"};

    return http.request(
      verb: verb,
      url: uri,
      torPort: torPort,
      body: body,
      headers: headers,
    );
  }
}
