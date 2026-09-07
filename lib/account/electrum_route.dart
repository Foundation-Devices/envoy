// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

class ElectrumRoute {
  final bool requiresTor;
  final int? port;
  final int generation;

  const ElectrumRoute({
    required this.requiresTor,
    required this.port,
    required this.generation,
  });

  bool get isReady => !requiresTor || port != null;

  bool isSameRoute(ElectrumRoute other) {
    if (requiresTor != other.requiresTor) return false;
    if (!requiresTor) return true;
    return port == other.port && generation == other.generation;
  }

  bool canRetryOn(ElectrumRoute replacement) {
    return requiresTor &&
        replacement.requiresTor &&
        replacement.isReady &&
        !isSameRoute(replacement);
  }
}
