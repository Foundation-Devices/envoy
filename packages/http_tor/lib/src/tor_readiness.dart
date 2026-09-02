// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

Future<void> waitForTorReadiness({
  required Stream<Object?> stateChanges,
  required bool Function() isEnabled,
  required bool Function() isBootstrapped,
  required Duration timeout,
}) async {
  if (!isEnabled() || isBootstrapped()) return;

  await stateChanges
      .where((_) => !isEnabled() || isBootstrapped())
      .timeout(timeout)
      .first;
}
