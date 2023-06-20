// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';

final accountManagerProvider =
    ChangeNotifierProvider((ref) => AccountManager());

final accountsProvider = Provider<List<Account>>((ref) {
  var testnetEnabled = ref.watch(showTestnetAccountsProvider);
  var accountManager = ref.watch(accountManagerProvider);

  return accountManager.accounts.where((account) {
    if (testnetEnabled) {
      return true;
    }
    return account.wallet.network != Network.Testnet;
  }).toList();
});

final accountStateProvider = Provider.family<Account?, String?>((ref, id) {
  final accountManager = ref.watch(accountManagerProvider);
  return accountManager.accounts.singleWhere((element) => element.id == id);
});
