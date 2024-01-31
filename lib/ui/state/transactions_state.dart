// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
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

final filteredTransactionsProvider =
    Provider.family<List<Transaction>, String?>((ref, String? accountId) {
  final txFilterState = ref.watch(txFilterStateProvider);
  final txSortState = ref.watch(txSortStateProvider);

  List<Transaction> transactions = ref.watch(transactionsProvider(accountId));

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

  switch (txSortState) {
    case TransactionSortTypes.newestFirst:
      transactions.ancestralSort();
      transactions = transactions.reversed.toList();
      break;
    case TransactionSortTypes.oldestFirst:
      transactions.ancestralSort();
      break;
    case TransactionSortTypes.amountLowToHigh:
      transactions.sort(
        (a, b) {
          return a.amount.abs().toInt().compareTo(b.amount.abs());
        },
      );
      break;
    case TransactionSortTypes.amountHighToLow:
      transactions.sort(
        (a, b) {
          return b.amount.abs().toInt().compareTo(a.amount.abs());
        },
      );
      break;
  }
  if (txFilterState.isEmpty) {
    transactions = [];
  }

  return transactions;
});

final transactionsProvider =
    Provider.family<List<Transaction>, String?>((ref, String? accountId) {
  List<Transaction> pendingTransactions =
      ref.watch(pendingTransactionsProvider(accountId));
  List<Transaction> transactions = [];
  List<Transaction> walletTransactions =
      ref.watch(accountStateProvider(accountId))?.wallet.transactions ?? [];

  transactions.addAll(walletTransactions);
  transactions.addAll(pendingTransactions);

  return transactions;
});

final isThereAnyTransactionsProvider = Provider<bool>((ref) {
  var accounts = ref.watch(accountsProvider);
  for (var account in accounts) {
    if (ref.watch(filteredTransactionsProvider(account.id)).isNotEmpty) {
      return true;
    }
  }

  return false;
});

final getTransactionProvider = Provider.family<Transaction?, String>(
  (ref, param) {
    final selectedAccount = ref.watch(selectedAccountProvider);
    final tx = ref
        .watch(transactionsProvider(selectedAccount?.id ?? ""))
        .firstWhereOrNull((element) => element.txId == param);

    if (tx == null) {
      return null;
    }
    return Transaction.fromJson(tx.toJson());
  },
);

final RBFTxStateProvider = FutureProvider.family<Map?, String>(
  (ref, param) {
    final account = ref.watch(selectedAccountProvider);
    if (account == null) {
      return null;
    }
    return EnvoyStorage().getRBFBoostState(param, account.id!);
  },
);

final isTxBoostedProvider = Provider.family<bool?, String>(
  (ref, param) {
    return ref.watch(RBFTxStateProvider(param)).when(
          data: (data) {
            if (data != null) {
              return true;
            }
            return null;
          },
          loading: () => null,
          error: (err, stack) => null,
        );
  },
);
