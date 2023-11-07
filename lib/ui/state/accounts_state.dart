// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';
import 'package:collection/collection.dart';

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
  return accountManager.accounts
      .singleWhereOrNull((element) => element.id == id);
});

final accountBalanceProvider = Provider.family<int, String?>((ref, id) {
  final account = ref.watch(accountStateProvider(id));

  if (account == null) {
    return 0;
  }

  final pendingTransactions = ref.watch(pendingTransactionsProvider(id));

  List<Transaction> walletTransactions =
      ref.watch(accountStateProvider(id))?.wallet.transactions ?? [];

  List<Transaction> transactionsToSum = [];

  pendingTransactions.forEach((element) async {
    final isTxIdExist = walletTransactions.any((tx) => tx.txId == element.txId);
    if (!isTxIdExist) transactionsToSum.add(element);
  });

  final pendingTxSum = transactionsToSum
      .where((tx) => tx.type == TransactionType.pending)
      .map((tx) => tx.amount)
      .toList()
      .sum;

  return account.wallet.balance + pendingTxSum;
});

// True if all the accounts have 0 balance
final accountsZeroBalanceProvider = Provider<bool>((ref) {
  final accounts = ref.watch(accountsProvider);
  for (final account in accounts) {
    if (account.wallet.balance > 0) {
      return false;
    }
  }

  return true;
});
