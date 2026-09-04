// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

enum ElectrumSyncReachability { notAttempted, reachable, unreachable }

ElectrumSyncReachability aggregateElectrumSyncReachability(
  Iterable<ElectrumSyncReachability> results,
) {
  if (results.contains(ElectrumSyncReachability.reachable)) {
    return ElectrumSyncReachability.reachable;
  }
  if (results.contains(ElectrumSyncReachability.unreachable)) {
    return ElectrumSyncReachability.unreachable;
  }
  return ElectrumSyncReachability.notAttempted;
}
