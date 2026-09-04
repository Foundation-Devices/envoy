// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/electrum_sync_health.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('aggregateElectrumSyncReachability', () {
    test('collapses descriptor failures into one unreachable result', () {
      final result = aggregateElectrumSyncReachability(
        List.filled(6, ElectrumSyncReachability.unreachable),
      );

      expect(result, ElectrumSyncReachability.unreachable);
    });

    test('reports reachable when any attempted sync reached Electrum', () {
      final result = aggregateElectrumSyncReachability([
        ElectrumSyncReachability.unreachable,
        ElectrumSyncReachability.reachable,
        ElectrumSyncReachability.unreachable,
      ]);

      expect(result, ElectrumSyncReachability.reachable);
    });

    test('does not report health when no sync was attempted', () {
      final result = aggregateElectrumSyncReachability([
        ElectrumSyncReachability.notAttempted,
        ElectrumSyncReachability.notAttempted,
      ]);

      expect(result, ElectrumSyncReachability.notAttempted);
    });
  });
}
