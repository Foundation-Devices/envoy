// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:collection';

import 'package:envoy/util/console.dart';

class ElectrumRequestPermitTimeout implements Exception {
  const ElectrumRequestPermitTimeout(this.timeout);

  final Duration timeout;

  @override
  String toString() =>
      'Timed out after $timeout waiting for an Electrum request permit';
}

/// A shared admission budget spent waiting for descriptor ownership or a permit.
///
/// Callers sharing a budget must wait sequentially. Concurrent
/// waits would charge their overlapping queue time more than once.
class ElectrumPermitWaitBudget {
  ElectrumPermitWaitBudget(Duration budget)
      : assert(!budget.isNegative),
        _remaining = budget;

  Duration _remaining;

  Duration get remaining => _remaining;

  /// Wait for the existing descriptor owner without cancelling its operation.
  Future<T> waitForOwner<T>(Future<T> operation) async {
    final waitTime = Stopwatch()..start();
    try {
      return await operation.timeout(_remaining);
    } finally {
      _consume(waitTime.elapsed);
    }
  }

  void _consume(Duration elapsed) {
    final remaining = _remaining - elapsed;
    _remaining = remaining.isNegative ? Duration.zero : remaining;
  }
}

class ElectrumRequestGate {
  ElectrumRequestGate({required this.maxConcurrent})
      : assert(maxConcurrent > 0);

  final int maxConcurrent;
  final Map<Object, _EndpointGate> _endpoints = {};

  Future<T> run<T>(
    Object endpoint,
    Future<T> Function() request, {
    required ElectrumPermitWaitBudget waitBudget,
    bool prioritize = false,
  }) async {
    final gate = _endpoints.putIfAbsent(endpoint, _EndpointGate.new);
    final label = '[ElectrumSync] request=${identityHashCode(request)} '
        'gate=${identityHashCode(gate)}';
    final waitTime = Stopwatch()..start();
    if (gate.active >= maxConcurrent) {
      kPrint('$label queued active=${gate.active}/$maxConcurrent '
          'waiting=${gate.prioritizedWaiters.length + gate.waiters.length + 1} '
          'priority=$prioritize waitBudgetMs=${waitBudget.remaining.inMilliseconds}');
    }
    try {
      await _acquire(gate, waitBudget, prioritize);
    } on ElectrumRequestPermitTimeout {
      kPrint('$label queue-timeout waitedMs=${waitTime.elapsedMilliseconds}');
      rethrow;
    }
    kPrint('$label admitted active=${gate.active}/$maxConcurrent '
        'waiting=${gate.prioritizedWaiters.length + gate.waiters.length} '
        'waitedMs=${waitTime.elapsedMilliseconds}');

    try {
      return await request();
    } finally {
      _release(endpoint, gate);
      kPrint('$label released active=${gate.active}/$maxConcurrent '
          'waiting=${gate.prioritizedWaiters.length + gate.waiters.length}');
    }
  }

  Future<void> _acquire(
    _EndpointGate gate,
    ElectrumPermitWaitBudget waitBudget,
    bool prioritize,
  ) async {
    if (gate.active < maxConcurrent) {
      gate.active++;
      return;
    }

    final waitTimeout = waitBudget.remaining;
    if (waitTimeout <= Duration.zero) {
      throw ElectrumRequestPermitTimeout(waitTimeout);
    }

    final waiter = Completer<void>();
    final queue = prioritize ? gate.prioritizedWaiters : gate.waiters;
    queue.addLast(waiter);
    final waitTime = Stopwatch()..start();

    try {
      await waiter.future.timeout(waitTimeout);
    } on TimeoutException {
      if (queue.remove(waiter)) {
        throw ElectrumRequestPermitTimeout(waitTimeout);
      }

      // The permit was transferred at the timeout boundary. Observe that
      // transfer instead of dropping a permit that no other waiter owns.
      await waiter.future;
    } finally {
      waitBudget._consume(waitTime.elapsed);
    }
  }

  void _release(Object endpoint, _EndpointGate gate) {
    if (gate.prioritizedWaiters.isNotEmpty) {
      // Foreground work jumps the background queue but remains FIFO relative
      // to other foreground requests.
      gate.prioritizedWaiters.removeFirst().complete();
      return;
    }
    if (gate.waiters.isNotEmpty) {
      // Transfer the released permit directly to the oldest waiter.
      gate.waiters.removeFirst().complete();
      return;
    }

    gate.active--;
    if (gate.active == 0) {
      _endpoints.remove(endpoint);
    }
  }
}

typedef ElectrumSyncSelection<T> = ({
  List<T> selected,
  int nextProbeIndex,
  bool probeSelected,
});

ElectrumSyncSelection<T> selectElectrumSyncCandidates<T>({
  required List<T> candidates,
  required bool Function(T candidate) isMainnet,
  required bool mainnetProbeOnly,
  required bool mainnetProbeAllowed,
  required int probeIndex,
  int connectedRotationStep = 1,
}) {
  final mainnetCandidates = candidates.where(isMainnet).toList();
  final mainnetCount = mainnetCandidates.length;
  if (!mainnetProbeOnly) {
    if (mainnetCount == 0) {
      return (
        selected: List<T>.of(candidates),
        nextProbeIndex: probeIndex,
        probeSelected: false,
      );
    }

    final firstMainnetIndex = probeIndex % mainnetCount;
    final rotatedMainnet = [
      ...mainnetCandidates.skip(firstMainnetIndex),
      ...mainnetCandidates.take(firstMainnetIndex),
    ];
    final requestedRotationStep = connectedRotationStep.abs() % mainnetCount;
    final rotationStep = requestedRotationStep != 0 &&
            requestedRotationStep.gcd(mainnetCount) == 1
        ? requestedRotationStep
        : 1;
    var currentMainnetIndex = 0;
    return (
      selected: [
        for (final candidate in candidates)
          if (isMainnet(candidate))
            rotatedMainnet[currentMainnetIndex++]
          else
            candidate,
      ],
      nextProbeIndex: (firstMainnetIndex + rotationStep) % mainnetCount,
      probeSelected: false,
    );
  }

  if (!mainnetProbeAllowed || mainnetCount == 0) {
    return (
      selected: candidates.where((candidate) => !isMainnet(candidate)).toList(),
      nextProbeIndex: probeIndex,
      probeSelected: false,
    );
  }

  final selectedProbeIndex = probeIndex % mainnetCount;
  var currentMainnetIndex = 0;

  return (
    selected: candidates
        .where((candidate) =>
            !isMainnet(candidate) ||
            currentMainnetIndex++ == selectedProbeIndex)
        .toList(),
    nextProbeIndex: (selectedProbeIndex + 1) % mainnetCount,
    probeSelected: true,
  );
}

class ElectrumProbeCooldown {
  ElectrumProbeCooldown({
    this.cooldown = const Duration(minutes: 1),
    Duration Function()? elapsed,
  })  : _elapsed = elapsed,
        _stopwatch = elapsed == null ? (Stopwatch()..start()) : null;

  final Duration cooldown;
  final Duration Function()? _elapsed;
  final Stopwatch? _stopwatch;
  Duration? _retryAfter;
  Object? _endpoint;

  Duration get _now => _elapsed?.call() ?? _stopwatch!.elapsed;

  bool canProbe(Object endpoint) {
    final retryAfter = _retryAfter;
    return retryAfter == null || _endpoint != endpoint || _now >= retryAfter;
  }

  void recordFailure(Object endpoint) {
    _endpoint = endpoint;
    _retryAfter = _now + cooldown;
  }

  void recordSuccess() {
    _endpoint = null;
    _retryAfter = null;
  }
}

class _EndpointGate {
  int active = 0;
  final Queue<Completer<void>> prioritizedWaiters = Queue();
  final Queue<Completer<void>> waiters = Queue();
}
