// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
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
  final txFilterState = ref.watch(txFilterStateProvider);
  final txSortState = ref.watch(txSortStateProvider);
  List<Transaction> pendingTransactions =
      ref.watch(pendingTransactionsProvider(accountId));
  //Creates new list for all type of transactions
  List<Transaction> transactions = [];

  List<Transaction> walletTransactions =
      ref.watch(accountStateProvider(accountId))?.wallet.transactions ?? [];

  transactions.addAll(walletTransactions);
  transactions.addAll(pendingTransactions);

  switch (txSortState) {
    case TransactionSortTypes.newestFirst:
      transactions.sort((t1, t2) {
        // Mempool transactions go on top
        if (t1.date.isBefore(DateTime(2008)) &&
            t2.date.isBefore(DateTime(2008))) {
          return 0;
        }

        if (t2.date.isBefore(DateTime(2008))) {
          return 1;
        }

        if (t1.date.isBefore(DateTime(2008))) {
          return -1;
        }
        return t2.date.compareTo(t1.date);
      });
      break;
    case TransactionSortTypes.oldestFirst:
      transactions.sort((t1, t2) {
        // Mempool transactions go on top
        if (t2.date.isBefore(DateTime(2008)) &&
            t1.date.isBefore(DateTime(2008))) {
          return 0;
        }

        if (t1.date.isBefore(DateTime(2008))) {
          return 1;
        }

        if (t1.date.isBefore(DateTime(2008))) {
          return -1;
        }
        return t1.date.compareTo(t2.date);
      });
      break;
    case TransactionSortTypes.amountLowToHigh:
      transactions.sort(
        (a, b) {
          if (b.amount > a.amount) {
            return 0;
          }
          return 1;
        },
      );
      break;
    case TransactionSortTypes.amountHighToLow:
      transactions.sort(
        (a, b) {
          if (a.amount > b.amount) {
            return 0;
          }
          return 1;
        },
      );
      break;
  }
  if (txFilterState.contains(TransactionFilters.Sent) &&
      txFilterState.contains(TransactionFilters.Received)) {
    //do nothing
  } else {
    if (txFilterState.contains(TransactionFilters.Sent)) {
      transactions =
          transactions.where((element) => element.amount < 0).toList();
    }
    if (txFilterState.contains(TransactionFilters.Received)) {
      transactions =
          transactions.where((element) => element.amount > 0).toList();
    }
  }

  if (txFilterState.isEmpty) {
    transactions = [];
  }

  return transactions;
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
