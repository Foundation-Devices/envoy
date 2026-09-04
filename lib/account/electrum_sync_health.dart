// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

enum ElectrumSyncReachability { notAttempted, reachable, unreachable }

ElectrumSyncReachability aggregateElectrumSyncReachability(
  Iterable<ElectrumSyncReachability> results,
) {
  var aggregate = ElectrumSyncReachability.notAttempted;

  for (final result in results) {
    if (result == ElectrumSyncReachability.reachable) {
      return ElectrumSyncReachability.reachable;
    }

    if (result == ElectrumSyncReachability.unreachable) {
      aggregate = ElectrumSyncReachability.unreachable;
    }
  }

  return aggregate;
}
