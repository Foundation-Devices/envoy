// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

class TorRestartPolicy {
  TorRestartPolicy({required this.failureThreshold}) {
    if (failureThreshold < 1) {
      throw ArgumentError.value(
        failureThreshold,
        'failureThreshold',
        'must be positive',
      );
    }
  }

  final int failureThreshold;

  int _consecutiveFailures = 0;
  bool _restartAttempted = false;

  int get consecutiveFailures => _consecutiveFailures;
  bool get restartAttempted => _restartAttempted;

  bool recordFailure() {
    if (_consecutiveFailures < failureThreshold) {
      _consecutiveFailures++;
    }

    if (_consecutiveFailures < failureThreshold || _restartAttempted) {
      return false;
    }

    _restartAttempted = true;
    return true;
  }

  void recordSuccess() {
    _consecutiveFailures = 0;
    _restartAttempted = false;
  }
}
