// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';

final pendingTransactionsProvider =
    Provider.family<List<Transaction>, String?>((ref, String? accountId) {
  List<Transaction> pendingTransactions = [];

  // Listen to Pending transactions from database
  AsyncValue<List<Transaction>> asyncPendingTx =
      ref.watch(pendingTxStreamProvider(accountId));

  if (asyncPendingTx.hasValue) {
    pendingTransactions.addAll((asyncPendingTx.value as List<Transaction>));
  }

  return pendingTransactions;
});

final transactionsProvider =
    Provider.family<List<Transaction>, String?>((ref, String? accountId) {
  List<Transaction> pendingTransactions =
      ref.watch(pendingTransactionsProvider(accountId));

  //Creates new list for all type of transactions
  List<Transaction> transactions = [];
  List<Transaction> walletTransactions =
      ref.watch(accountStateProvider(accountId))?.wallet.transactions ?? [];

  transactions.addAll(walletTransactions);
  transactions.addAll(pendingTransactions);

  transactions.hierarchicalSort();
  return List.from(transactions.reversed);
});

final isThereAnyTransactionsProvider = Provider<bool>((ref) {
  var accounts = ref.watch(accountsProvider);
  for (var account in accounts) {
    if (ref.watch(transactionsProvider(account.id)).isNotEmpty) {
      return true;
    }
  }

  return false;
});
