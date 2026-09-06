// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/account/electrum_sync_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ElectrumPermitWaitBudget waitBudget([
    Duration duration = const Duration(minutes: 1),
  ]) =>
      ElectrumPermitWaitBudget(duration);

  test('ownership waits share admission budget without cancelling owners',
      () async {
    final budget = waitBudget(const Duration(milliseconds: 10));
    final firstOwner = Completer<void>();
    final secondOwner = Completer<void>();

    await expectLater(
      budget.waitForOwner(firstOwner.future),
      throwsA(isA<TimeoutException>()),
    );
    expect(budget.remaining, Duration.zero);
    final secondWait = budget.waitForOwner(secondOwner.future).then(
      (_) => 'completed',
      onError: (Object error) {
        expect(error, isA<TimeoutException>());
        return 'timed out';
      },
    );
    // With no budget left the timeout is already scheduled for this turn,
    // before this next-turn marker. A fresh full timeout would lose the race.
    expect(
      await Future.any([
        secondWait,
        Future.delayed(Duration.zero, () => 'waited again'),
      ]),
      'timed out',
    );
    await secondWait;
    expect(firstOwner.isCompleted, isFalse);
    expect(secondOwner.isCompleted, isFalse);

    // A free descriptor/endpoint can still run without spending more wait time.
    final gate = ElectrumRequestGate(maxConcurrent: 1);
    expect(await gate.run('free', () async => 42, waitBudget: budget), 42);
    firstOwner.complete();
    secondOwner.complete();
  });

  test('limits concurrent requests independently per endpoint', () async {
    final gate = ElectrumRequestGate(maxConcurrent: 2);
    final releases = List.generate(4, (_) => Completer<void>());
    final starts = List.generate(4, (_) => Completer<void>());
    var activeA = 0;
    var peakA = 0;

    Future<void> request(String endpoint, int index) => gate.run(
          endpoint,
          () async {
            if (endpoint == 'a') {
              activeA++;
              if (activeA > peakA) {
                peakA = activeA;
              }
            }
            starts[index].complete();
            await releases[index].future;
            if (endpoint == 'a') {
              activeA--;
            }
          },
          waitBudget: waitBudget(),
        );

    final requests = [
      request('a', 0),
      request('a', 1),
      request('a', 2),
      request('b', 3),
    ];

    await Future.wait([starts[0].future, starts[1].future, starts[3].future]);
    expect(starts[2].isCompleted, isFalse);
    expect(peakA, 2);

    releases[0].complete();
    await starts[2].future;
    expect(peakA, 2);

    for (final index in [1, 2, 3]) {
      releases[index].complete();
    }
    await Future.wait(requests);
  });

  test('releases a request permit after an error', () async {
    final gate = ElectrumRequestGate(maxConcurrent: 1);
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    final secondStarted = Completer<void>();

    final first = gate.run<void>(
      'a',
      () async {
        firstStarted.complete();
        await releaseFirst.future;
        throw StateError('request failed');
      },
      waitBudget: waitBudget(),
    );
    await firstStarted.future;

    final second = gate.run<void>(
      'a',
      () async {
        secondStarted.complete();
      },
      waitBudget: waitBudget(),
    );
    expect(secondStarted.isCompleted, isFalse);

    releaseFirst.complete();
    await expectLater(first, throwsStateError);
    await secondStarted.future;
    await second;
  });

  test('removes a waiter that times out before acquiring a permit', () async {
    final gate = ElectrumRequestGate(maxConcurrent: 1);
    final releaseFirst = Completer<void>();
    final firstStarted = Completer<void>();
    var timedOutRequestStarted = false;
    final timedOutBudget = waitBudget(const Duration(milliseconds: 10));

    final first = gate.run<void>(
      'a',
      () async {
        firstStarted.complete();
        await releaseFirst.future;
      },
      waitBudget: waitBudget(),
    );
    await firstStarted.future;

    final timedOut = gate.run<void>(
      'a',
      () async {
        timedOutRequestStarted = true;
      },
      waitBudget: timedOutBudget,
    );
    await expectLater(timedOut, throwsA(isA<ElectrumRequestPermitTimeout>()));
    expect(timedOutRequestStarted, isFalse);
    expect(timedOutBudget.remaining, Duration.zero);

    releaseFirst.complete();
    await first;
    await gate.run<void>('a', () async {}, waitBudget: waitBudget());
  });

  test('an expired old-route wait can enter a free replacement route',
      () async {
    final gate = ElectrumRequestGate(maxConcurrent: 1);
    final releaseOld = Completer<void>();
    final oldStarted = Completer<void>();
    final old = gate.run<void>(
      ('onion', 19050, 1),
      () async {
        oldStarted.complete();
        await releaseOld.future;
      },
      waitBudget: waitBudget(),
    );
    await oldStarted.future;
    final budget = waitBudget(const Duration(milliseconds: 10));
    await expectLater(
      gate.run<void>(('onion', 19050, 1), () async {}, waitBudget: budget),
      throwsA(isA<ElectrumRequestPermitTimeout>()),
    );
    expect(budget.remaining, Duration.zero);
    expect(
      await gate.run(('onion', 19050, 2), () async => 42, waitBudget: budget),
      42,
    );
    releaseOld.complete();
    await old;
  });

  test('does not spend permit budget while a request is executing', () async {
    final gate = ElectrumRequestGate(maxConcurrent: 1);
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    final secondStarted = Completer<void>();
    final releaseSecond = Completer<void>();
    final budget = waitBudget();

    final first = gate.run<void>(
      'a',
      () async {
        firstStarted.complete();
        await releaseFirst.future;
      },
      waitBudget: waitBudget(),
    );
    await firstStarted.future;

    final second = gate.run<void>(
      'a',
      () async {
        secondStarted.complete();
        await releaseSecond.future;
      },
      waitBudget: budget,
    );

    releaseFirst.complete();
    await secondStarted.future;
    final remainingAfterAdmission = budget.remaining;
    expect(
      remainingAfterAdmission,
      lessThanOrEqualTo(const Duration(minutes: 1)),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(budget.remaining, remainingAfterAdmission);

    releaseSecond.complete();
    await Future.wait([first, second]);
  });

  test('rejects a saturated request with an exhausted budget', () async {
    final gate = ElectrumRequestGate(maxConcurrent: 1);
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    var exhaustedRequestStarted = false;

    final first = gate.run<void>(
      'a',
      () async {
        firstStarted.complete();
        await releaseFirst.future;
      },
      waitBudget: waitBudget(),
    );
    await firstStarted.future;

    final exhausted = gate.run<void>(
      'a',
      () async {
        exhaustedRequestStarted = true;
      },
      waitBudget: waitBudget(Duration.zero),
    );
    await expectLater(exhausted, throwsA(isA<ElectrumRequestPermitTimeout>()));
    expect(exhaustedRequestStarted, isFalse);

    releaseFirst.complete();
    await first;
  });

  test('removes a prioritized waiter when its budget expires', () async {
    final gate = ElectrumRequestGate(maxConcurrent: 1);
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    final backgroundStarted = Completer<void>();
    var prioritizedRequestStarted = false;

    final first = gate.run<void>(
      'a',
      () async {
        firstStarted.complete();
        await releaseFirst.future;
      },
      waitBudget: waitBudget(),
    );
    await firstStarted.future;

    final background = gate.run<void>(
      'a',
      () async {
        backgroundStarted.complete();
      },
      waitBudget: waitBudget(),
    );
    final prioritized = gate.run<void>(
      'a',
      () async {
        prioritizedRequestStarted = true;
      },
      waitBudget: waitBudget(const Duration(milliseconds: 10)),
      prioritize: true,
    );

    await expectLater(
      prioritized,
      throwsA(isA<ElectrumRequestPermitTimeout>()),
    );
    expect(prioritizedRequestStarted, isFalse);

    releaseFirst.complete();
    await backgroundStarted.future;
    await Future.wait([first, background]);
  });

  test('prioritizes foreground work while preserving its FIFO order', () async {
    final gate = ElectrumRequestGate(maxConcurrent: 1);
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    final backgroundStarted = Completer<void>();
    final foregroundOneStarted = Completer<void>();
    final releaseForegroundOne = Completer<void>();
    final foregroundTwoStarted = Completer<void>();
    final releaseForegroundTwo = Completer<void>();

    final first = gate.run<void>(
      'a',
      () async {
        firstStarted.complete();
        await releaseFirst.future;
      },
      waitBudget: waitBudget(),
    );
    await firstStarted.future;

    final background = gate.run<void>(
      'a',
      () async {
        backgroundStarted.complete();
      },
      waitBudget: waitBudget(),
    );
    final foregroundOne = gate.run<void>(
      'a',
      () async {
        foregroundOneStarted.complete();
        await releaseForegroundOne.future;
      },
      waitBudget: waitBudget(),
      prioritize: true,
    );
    final foregroundTwo = gate.run<void>(
      'a',
      () async {
        foregroundTwoStarted.complete();
        await releaseForegroundTwo.future;
      },
      waitBudget: waitBudget(),
      prioritize: true,
    );

    releaseFirst.complete();
    await foregroundOneStarted.future;
    expect(foregroundTwoStarted.isCompleted, isFalse);
    expect(backgroundStarted.isCompleted, isFalse);

    releaseForegroundOne.complete();
    await foregroundTwoStarted.future;
    expect(backgroundStarted.isCompleted, isFalse);

    releaseForegroundTwo.complete();
    await Future.wait([first, foregroundOne, foregroundTwo, background]);
    expect(backgroundStarted.isCompleted, isTrue);
  });

  test('rotates the single mainnet recovery probe between rounds', () {
    const candidates = ['testnet-a', 'mainnet-a', 'mainnet-b', 'testnet-b'];

    final first = selectElectrumSyncCandidates(
      candidates: candidates,
      isMainnet: (candidate) => candidate.startsWith('mainnet'),
      mainnetProbeOnly: true,
      mainnetProbeAllowed: true,
      probeIndex: 0,
    );
    expect(first.selected, ['testnet-a', 'mainnet-a', 'testnet-b']);
    expect(first.probeSelected, isTrue);

    final second = selectElectrumSyncCandidates(
      candidates: candidates,
      isMainnet: (candidate) => candidate.startsWith('mainnet'),
      mainnetProbeOnly: true,
      mainnetProbeAllowed: true,
      probeIndex: first.nextProbeIndex,
    );
    expect(second.selected, ['testnet-a', 'mainnet-b', 'testnet-b']);

    final coolingDown = selectElectrumSyncCandidates(
      candidates: candidates,
      isMainnet: (candidate) => candidate.startsWith('mainnet'),
      mainnetProbeOnly: true,
      mainnetProbeAllowed: false,
      probeIndex: second.nextProbeIndex,
    );
    expect(coolingDown.selected, ['testnet-a', 'testnet-b']);
    expect(coolingDown.probeSelected, isFalse);

    final connected = selectElectrumSyncCandidates(
      candidates: candidates,
      isMainnet: (candidate) => candidate.startsWith('mainnet'),
      mainnetProbeOnly: false,
      mainnetProbeAllowed: true,
      probeIndex: coolingDown.nextProbeIndex,
    );
    expect(connected.selected, candidates);

    final nextConnected = selectElectrumSyncCandidates(
      candidates: candidates,
      isMainnet: (candidate) => candidate.startsWith('mainnet'),
      mainnetProbeOnly: false,
      mainnetProbeAllowed: true,
      probeIndex: connected.nextProbeIndex,
    );
    expect(nextConnected.selected, [
      'testnet-a',
      'mainnet-b',
      'mainnet-a',
      'testnet-b',
    ]);
  });

  test('connected rotation advances by the permit window', () {
    final selection = selectElectrumSyncCandidates(
      candidates: ['mainnet-a', 'mainnet-b', 'mainnet-c', 'mainnet-d'],
      isMainnet: (_) => true,
      mainnetProbeOnly: false,
      mainnetProbeAllowed: true,
      probeIndex: 0,
      connectedRotationStep: 3,
    );

    expect(selection.nextProbeIndex, 3);
    expect(selection.selected.first, 'mainnet-a');

    final next = selectElectrumSyncCandidates(
      candidates: ['mainnet-a', 'mainnet-b', 'mainnet-c', 'mainnet-d'],
      isMainnet: (_) => true,
      mainnetProbeOnly: false,
      mainnetProbeAllowed: true,
      probeIndex: selection.nextProbeIndex,
      connectedRotationStep: 3,
    );
    expect(next.selected.first, 'mainnet-d');
  });

  test('connected rotation cannot orbit a subset of candidates', () {
    for (final candidateCount in [3, 6]) {
      final candidates = [
        for (var index = 0; index < candidateCount; index++) 'mainnet-$index',
      ];
      final selection = selectElectrumSyncCandidates(
        candidates: candidates,
        isMainnet: (_) => true,
        mainnetProbeOnly: false,
        mainnetProbeAllowed: true,
        probeIndex: 0,
        connectedRotationStep: 3,
      );

      expect(selection.nextProbeIndex, 1);
      final next = selectElectrumSyncCandidates(
        candidates: candidates,
        isMainnet: (_) => true,
        mainnetProbeOnly: false,
        mainnetProbeAllowed: true,
        probeIndex: selection.nextProbeIndex,
        connectedRotationStep: 3,
      );
      expect(next.selected.first, 'mainnet-1');
    }
  });

  test('failed probes wait for the cooldown and success clears it', () {
    var elapsed = Duration.zero;
    final cooldown = ElectrumProbeCooldown(
      cooldown: const Duration(minutes: 1),
      elapsed: () => elapsed,
    );

    expect(cooldown.canProbe('a'), isTrue);
    cooldown.recordFailure('a');
    expect(cooldown.canProbe('a'), isFalse);
    expect(cooldown.canProbe('b'), isTrue);

    elapsed += const Duration(seconds: 59);
    expect(cooldown.canProbe('a'), isFalse);
    elapsed += const Duration(seconds: 1);
    expect(cooldown.canProbe('a'), isTrue);

    cooldown.recordFailure('a');
    cooldown.recordSuccess();
    expect(cooldown.canProbe('a'), isTrue);
  });
}
