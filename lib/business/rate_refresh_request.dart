// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

/// Serializes timer refreshes while allowing a currency change to supersede one.
class RateRefreshRequest {
  Object? _activeRequest;

  Future<void> run({
    required bool triggeredByTimer,
    required Future<void> Function(bool Function() isCurrent) fetch,
  }) async {
    if (triggeredByTimer && _activeRequest != null) {
      return;
    }

    final request = Object();
    _activeRequest = request;
    try {
      await fetch(() => identical(_activeRequest, request));
    } finally {
      // An older request must not release a newer request's timer guard.
      if (identical(_activeRequest, request)) {
        _activeRequest = null;
      }
    }
  }
}
