// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:collection/collection.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

final accountManagerProvider =
    ChangeNotifierProvider((ref) => NgAccountManager());

final _transactionsProvider =
    FutureProvider.family<List<BitcoinTransaction>, EnvoyAccount>(
        (ref, account) async {
  return await account.transactions();
});

final accountsProvider = Provider<List<EnvoyAccount>>((ref) {
  var testnetEnabled = ref.watch(showTestnetAccountsProvider);
  var signetEnabled = ref.watch(showSignetAccountsProvider);
  var taprootEnabled = ref.watch(showTaprootAccountsProvider);
  var accountManager = ref.watch(accountManagerProvider);

  return accountManager.accounts.where((account) {
    if (!testnetEnabled && account.config().network == Network.testnet) {
      return false;
    }

    if (!signetEnabled && account.config().network == Network.signet) {
      return false;
    }

    if (!taprootEnabled && account.config().addressType == AddressType.p2Tr) {
      return false;
    }
    return true;
  }).toList();
});

final mainnetAccountsProvider =
    Provider.family<List<EnvoyAccount>, EnvoyAccount?>(
        (ref, selectedEnvoyAccount) {
  final accounts = ref.watch(accountsProvider);

  // We filter everything but mainnet
  final filteredEnvoyAccounts = accounts
      .where((account) => account.config().network == Network.bitcoin)
      .toList();

  return filteredEnvoyAccounts;
});

final accountStateProvider = Provider.family<EnvoyAccount?, String?>((ref, id) {
  final accountManager = ref.watch(accountManagerProvider);
  return accountManager.accounts
      .singleWhereOrNull((element) => element.config().id == id);
});

final accountBalanceProvider = Provider.family<int, String?>((ref, id) {
  final account = ref.watch(accountStateProvider(id));

  if (account == null) {
    return 0;
  }

  //TODO: accomodate for pending transactions
  // final pendingTransactions = ref.watch(pendingTransactionsProvider(id));
  //
  // List<BitcoinTransaction> walletTransactions =
  //     ref.watch(accountStateProvider(id)).transactions() ?? [];
  //
  // List<BitcoinTransaction> transactionsToSum = [];
  //
  // for (var tx in pendingTransactions) {
  //   final isTxIdExist = walletTransactions.any((tx) => tx.txId == tx.txId);
  //   if (!isTxIdExist) transactionsToSum.add(tx);
  // }
  //
  // final pendingTxSum = transactionsToSum
  //     .where((tx) => tx.type == TransactionType.pending)
  //     .map((tx) => tx.amount)
  //     .toList()
  //     .sum;
  //
  // return account.wallet.balance + pendingTxSum;

  return account.balance().toInt();
});

// True if all the accounts have 0 balance
final accountsZeroBalanceProvider = Provider<bool>((ref) {
  final accounts = ref.watch(accountsProvider);
  for (final account in accounts) {
    //TODO: use EnvoyAccount
    // if (account.balance > 0) {
    //   return false;
    // }
  }

  return true;
});
