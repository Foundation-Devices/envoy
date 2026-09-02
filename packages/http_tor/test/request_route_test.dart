// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:http_tor/src/request_route.dart';

void main() {
  test('direct failures are not retried', () async {
    final failure = StateError('request failed');
    var resolveCalls = 0;
    var runCalls = 0;

    final result = runWithRouteReplacement<void>(
      requiresTor: false,
      resolveRoute: () async {
        resolveCalls++;
        return -1;
      },
      run: (_) async {
        runCalls++;
        throw failure;
      },
    );

    await expectLater(result, throwsA(same(failure)));
    expect(resolveCalls, 1);
    expect(runCalls, 1);
  });

  test('a failure on the current Tor route is not retried', () async {
    final failure = StateError('request failed');
    var resolveCalls = 0;
    var runCalls = 0;

    final result = runWithRouteReplacement<void>(
      requiresTor: true,
      resolveRoute: () async {
        resolveCalls++;
        return 9050;
      },
      run: (_) async {
        runCalls++;
        throw failure;
      },
    );

    await expectLater(result, throwsA(same(failure)));
    expect(resolveCalls, 2);
    expect(runCalls, 1);
  });

  test('a route-resolution failure preserves the original stack', () async {
    final failure = StateError('request failed');
    StackTrace? originalStack;
    var resolveCalls = 0;

    Future<void> failOnOriginalRoute(int _) async {
      try {
        throw failure;
      } catch (_, stackTrace) {
        originalStack = stackTrace;
        rethrow;
      }
    }

    final result = runWithRouteReplacement<void>(
      requiresTor: true,
      resolveRoute: () async {
        resolveCalls++;
        if (resolveCalls == 2) throw StateError('route resolution failed');
        return 9050;
      },
      run: failOnOriginalRoute,
    );

    Object? caughtError;
    StackTrace? caughtStack;
    try {
      await result;
      fail('the original request failure should be rethrown');
    } catch (error, stackTrace) {
      caughtError = error;
      caughtStack = stackTrace;
    }

    expect(caughtError, same(failure));
    expect(originalStack, isNotNull);
    expect(caughtStack.toString(), originalStack.toString());
    expect(resolveCalls, 2);
  });

  test('a changed Tor route is retried once', () async {
    final ports = <int>[];
    final routes = [9050, 9051].iterator;

    final result = await runWithRouteReplacement<String>(
      requiresTor: true,
      resolveRoute: () async {
        routes.moveNext();
        return routes.current;
      },
      run: (port) async {
        ports.add(port);
        if (port == 9050) throw StateError('old route failed');
        return 'downloaded';
      },
    );

    expect(result, 'downloaded');
    expect(ports, [9050, 9051]);
  });

  test('an unavailable route can recover on a replacement route', () async {
    var resolveCalls = 0;

    final result = await runWithRouteReplacement<String>(
      requiresTor: true,
      resolveRoute: () async {
        resolveCalls++;
        if (resolveCalls == 1) throw StateError('route unavailable');
        return 9051;
      },
      run: (port) async => 'downloaded on $port',
    );

    expect(result, 'downloaded on 9051');
    expect(resolveCalls, 2);
  });

  test('a replacement route failure is not retried again', () async {
    final replacementFailure = StateError('replacement failed');
    final routes = [9050, 9051].iterator;
    var runCalls = 0;

    final result = runWithRouteReplacement<void>(
      requiresTor: true,
      resolveRoute: () async {
        routes.moveNext();
        return routes.current;
      },
      run: (_) async {
        runCalls++;
        if (runCalls == 1) throw StateError('old route failed');
        throw replacementFailure;
      },
    );

    await expectLater(result, throwsA(same(replacementFailure)));
    expect(runCalls, 2);
  });
}
