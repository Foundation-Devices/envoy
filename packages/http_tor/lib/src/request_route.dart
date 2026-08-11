// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

int resolveScheduledProxyPort({
  required bool requiresTor,
  required int currentTorPort,
}) {
  if (!requiresTor) return -1;
  if (currentTorPort == -1) {
    throw StateError('Tor route is unavailable');
  }
  return currentTorPort;
}
