// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_unit_state.dart';

/// send and staging unit !!!
final sendUnitProvider = StateProvider<AmountDisplayUnit>((ref) {
  final appUnit = ref.read(appUnitProvider);
  return Settings().sendUnit ?? appUnit;
});
