// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

typedef FirmwareUpdateCheckRequest = ({int id, String currentVersion});

enum FirmwareUpdateCheckDelivery { sent, failed, abandoned }

/// Request ownership for the firmware handler's single-flight check loop.
/// Network work and delivery remain in the handler; this only schedules it.
class FirmwareUpdateCheckQueue {
  int _requestId = 0;
  FirmwareUpdateCheckRequest? _active;
  FirmwareUpdateCheckRequest? _pending;
  String? _repeatedVersion;

  void add(String version) {
    if (_active?.id == _requestId && _active?.currentVersion == version) {
      // The in-flight response satisfies repeated requests for this version.
      _repeatedVersion = version;
      return;
    }
    if (_pending?.currentVersion == version) return;
    _pending = (id: ++_requestId, currentVersion: version);
  }

  FirmwareUpdateCheckRequest? takeNext() {
    assert(_active == null);
    _active = _pending;
    _pending = null;
    return _active;
  }

  bool isCurrent(int requestId) =>
      requestId == _requestId && requestId == _active?.id;

  void complete(
    FirmwareUpdateCheckRequest request,
    FirmwareUpdateCheckDelivery delivery,
  ) {
    // Clearing the queue invalidates even an operation that returns later.
    if (_active?.id != request.id) return;
    _active = null;
    if (_repeatedVersion == request.currentVersion) {
      _repeatedVersion = null;
      if (delivery != FirmwareUpdateCheckDelivery.sent && _pending == null) {
        _pending = (
          id: ++_requestId,
          currentVersion: request.currentVersion,
        );
      }
    }
  }

  void clear() {
    _requestId++;
    _active = null;
    _pending = null;
    _repeatedVersion = null;
  }
}
