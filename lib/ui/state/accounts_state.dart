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
  var signetEnabled = ref.watch(showSignetAccountsProvider);
  var taprootEnabled = ref.watch(showTaprootAccountsProvider);
  var accountManager = ref.watch(accountManagerProvider);

  return accountManager.accounts.where((account) {
    if (!testnetEnabled && account.wallet.network == Network.Testnet) {
      return false;
    }

    if (!signetEnabled && account.wallet.network == Network.Signet) {
      return false;
    }

    if (!taprootEnabled && account.wallet.type == WalletType.taproot) {
      return false;
    }

    return true;
  }).toList();
});

final mainnetAccountsProvider =
    Provider.family<List<Account>, Account?>((ref, selectedAccount) {
  final accounts = ref.watch(accountsProvider);

  // We filter everything but mainnet
  final filteredAccounts = accounts
      .where((account) => account.wallet.network == Network.Mainnet)
      .toList();

  return filteredAccounts;
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

  for (var tx in pendingTransactions) {
    final isTxIdExist = walletTransactions.any((tx) => tx.txId == tx.txId);
    if (!isTxIdExist) transactionsToSum.add(tx);
  }

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
