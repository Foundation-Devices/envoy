// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:envoy/business/rate_refresh_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a malformed price cannot disable subsequent timer refreshes', () async {
    final request = RateRefreshRequest();
    double? rate = 65000;

    await expectLater(
      request.run(
        triggeredByTimer: true,
        fetch: (_) async {
          final dynamic response = jsonDecode('{"reply":{"BTCEUR":{}}}');
          rate = response['reply']['BTCEUR']['last'].toDouble();
        },
      ),
      throwsA(isA<NoSuchMethodError>()),
    );
    expect(rate, 65000);

    await request.run(triggeredByTimer: true, fetch: (_) async => rate = 66000);
    expect(rate, 66000);
  });

  test('an ordinary request exception also releases the timer guard', () async {
    final request = RateRefreshRequest();
    await expectLater(
      request.run(
        triggeredByTimer: false,
        fetch: (_) async => throw Exception('Request failed'),
      ),
      throwsException,
    );
    var refreshed = false;
    await request.run(
      triggeredByTimer: true,
      fetch: (_) async => refreshed = true,
    );
    expect(refreshed, isTrue);
  });

  test('timer refresh resumes only after an in-flight request completes',
      () async {
    final request = RateRefreshRequest();
    final completeFirst = Completer<void>();
    var fetches = 0;

    final first = request.run(
      triggeredByTimer: true,
      fetch: (_) async {
        fetches++;
        await completeFirst.future;
      },
    );
    await request.run(
      triggeredByTimer: true,
      fetch: (_) async => fetches++,
    );
    expect(fetches, 1);

    completeFirst.complete();
    await first;
    await request.run(
      triggeredByTimer: true,
      fetch: (_) async => fetches++,
    );
    expect(fetches, 2);
  });

  for (final olderFails in [false, true]) {
    test(
      'older completion (failure: $olderFails) keeps newer fetch guarded',
      () async {
        final request = RateRefreshRequest();
        final olderResponse = Completer<void>();
        final newerResponse = Completer<void>();
        final applied = <String>[];
        final older = request.run(
          triggeredByTimer: false,
          fetch: (isCurrent) async {
            await olderResponse.future;
            if (isCurrent()) applied.add('older');
          },
        );
        final olderResult = expectLater(
          older,
          olderFails ? throwsA(isA<StateError>()) : completes,
        );

        await request.run(
          triggeredByTimer: true,
          fetch: (_) async => fail('Timer overlapped the first request'),
        );
        final newer = request.run(
          triggeredByTimer: false,
          fetch: (isCurrent) async {
            await newerResponse.future;
            if (isCurrent()) applied.add('newer');
          },
        );
        if (olderFails) {
          olderResponse.completeError(StateError('Old request failed'));
        } else {
          olderResponse.complete();
        }
        await olderResult;

        await request.run(
          triggeredByTimer: true,
          fetch: (_) async => fail('Old cleanup released the newer guard'),
        );
        newerResponse.complete();
        await newer;
        expect(applied, ['newer']);

        await request.run(
          triggeredByTimer: true,
          fetch: (_) async => applied.add('timer'),
        );
        expect(applied, ['newer', 'timer']);
      },
    );
  }

  test(
    'a late older response cannot overwrite a completed newer refresh',
    () async {
      final request = RateRefreshRequest();
      final olderResponse = Completer<void>();
      double? rate;
      final older = request.run(
        triggeredByTimer: false,
        fetch: (isCurrent) async {
          await olderResponse.future;
          if (isCurrent()) rate = 65000;
        },
      );
      await request.run(
        triggeredByTimer: false,
        fetch: (isCurrent) async {
          if (isCurrent()) rate = 66000;
        },
      );
      olderResponse.complete();
      await older;
      expect(rate, 66000);
    },
  );
}
