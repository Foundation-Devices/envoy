// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'app_unit_state.dart';

/// send and staging unit !!!
final sendUnitProvider = StateProvider<AmountDisplayUnit>((ref) {
  final appUnit = ref.watch(appUnitProvider);
  final account = ref.watch(selectedAccountProvider);

  // Fiat is available on non-mainnet only in debug builds; keep this in sync
  // with the button's fiat-visibility check in amount_display.dart.
  final fiatAllowed = account?.network == Network.bitcoin || kDebugMode;
  final settingsUnit = Settings().sendUnit;

  if (fiatAllowed) {
    return settingsUnit ?? appUnit;
  }
  if (settingsUnit != null && settingsUnit != AmountDisplayUnit.fiat) {
    return settingsUnit;
  }
  return appUnit;
});
