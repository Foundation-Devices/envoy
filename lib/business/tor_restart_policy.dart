// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

class TorRestartPolicy {
  /// How long after an automatic restart before another may be attempted, so
  /// a restart that didn't fix Tor cannot wedge recovery permanently.
  static const Duration restartCooldown = Duration(minutes: 10);

  static final Stopwatch _monotonicClock = Stopwatch()..start();

  TorRestartPolicy({
    required this.failureThreshold,
    Duration Function()? elapsed,
  }) : _elapsed = elapsed ?? (() => _monotonicClock.elapsed) {
    if (failureThreshold < 1) {
      throw ArgumentError.value(
        failureThreshold,
        'failureThreshold',
        'must be positive',
      );
    }
  }

  final int failureThreshold;

  final Duration Function() _elapsed;

  int _consecutiveFailures = 0;
  Duration? _lastRestartAt;

  int get consecutiveFailures => _consecutiveFailures;
  bool get restartAttempted => _lastRestartAt != null;
  Duration get restartCooldownRemaining {
    final lastRestart = _lastRestartAt;
    if (lastRestart == null) return Duration.zero;

    final remaining = restartCooldown - (_elapsed() - lastRestart);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool recordFailure() {
    if (_consecutiveFailures < failureThreshold) {
      _consecutiveFailures++;
    }

    if (_consecutiveFailures < failureThreshold) {
      return false;
    }

    return _claimRestartIfAllowed();
  }

  bool recordConfirmedFailure() {
    _consecutiveFailures = failureThreshold;
    return _claimRestartIfAllowed();
  }

  bool _claimRestartIfAllowed() {
    final now = _elapsed();
    final lastRestart = _lastRestartAt;
    if (lastRestart != null && now - lastRestart < restartCooldown) {
      return false;
    }

    _lastRestartAt = now;
    return true;
  }

  void recordSuccess() {
    _consecutiveFailures = 0;
    _lastRestartAt = null;
  }
}
