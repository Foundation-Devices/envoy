// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

/// Serializes native Tor failure recovery and remembers one follow-up signal.
class TorFailureRecoveryCoordinator {
  TorFailureRecoveryCoordinator({
    required this.activeOperation,
    required this.recover,
  });

  final Future<void>? Function() activeOperation;
  final Future<void> Function() recover;

  Future<void>? _inFlight;
  bool _recheckRequested = false;

  Future<void> queue() {
    _recheckRequested = true;
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;

    final recovery = Future<void>.microtask(_drain);
    _inFlight = recovery;
    return recovery;
  }

  Future<void> _drain() async {
    try {
      while (_recheckRequested) {
        _recheckRequested = false;
        await _waitForActiveOperation();
        await recover();
      }
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _waitForActiveOperation() async {
    while (true) {
      final operation = activeOperation();
      if (operation == null) return;
      try {
        await operation;
      } catch (_) {
        // A failed operation still has to be followed by recovery.
      }
    }
  }
}
