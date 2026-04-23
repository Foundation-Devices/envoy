// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:envoy/ui/amount_entry.dart';

/// unit on app level (except send and staging)
final appUnitProvider = Provider<AmountDisplayUnit>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.displayUnit == DisplayUnit.btc
      ? AmountDisplayUnit.btc
      : AmountDisplayUnit.sat;
});
