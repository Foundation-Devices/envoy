// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/state/accounts_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';

final aztecoTransactionsProvider = Provider<List<Transaction>>((ref) {
  //read from envoy storage and return list of azteco transactions
  return [];
});

final transactionsProvider =
    Provider.family<List<Transaction>, String?>((ref, String? id) {
  List<Transaction> aztecoTransactions = ref.watch(aztecoTransactionsProvider);
  List<Transaction> transactions =
      ref.watch(accountStateProvider(id))?.wallet.transactions ?? [];
  transactions.addAll(aztecoTransactions);
  transactions.sort(
    (a, b) => b.date.compareTo(a.date),
  );
  return transactions;
});
