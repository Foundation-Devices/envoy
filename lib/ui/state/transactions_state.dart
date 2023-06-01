// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';

final transactionsProvider =
    Provider.family<List<Transaction>, String?>((ref, String? accountId) {
  List<Transaction> aztecoTransactions = [];
  // Listen to azteco transactions from database
  AsyncValue<List<Transaction>> asyncTx =
      ref.watch(aztecoTxStreamProvider(accountId));
  if (asyncTx.hasValue) {
    aztecoTransactions.addAll((asyncTx.value as List<Transaction>));
  }

  List<Transaction> transactions =
      ref.watch(accountStateProvider(accountId))?.wallet.transactions ?? [];

  transactions.addAll(aztecoTransactions);

  // Sort transactions by date
  transactions.sort((t1, t2) {
    // Mempool transactions go on top
    if (t1.date.isBefore(DateTime(2008)) && t2.date.isBefore(DateTime(2008))) {
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

  return transactions;
});
