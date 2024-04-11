// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/foundation.dart';
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

  if (txFilterState.contains(TransactionFilters.sent) &&
      txFilterState.contains(TransactionFilters.received)) {
    //do nothing
  } else {
    if (txFilterState.contains(TransactionFilters.sent)) {
      transactions =
          transactions.where((element) => element.amount < 0).toList();
    }
    if (txFilterState.contains(TransactionFilters.received)) {
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

//We keep a cache of RBFed transactions so that we can remove the original tx from the list unless they are confirmed
final rbfBroadCastedTxProvider = StateProvider<List<String>>((ref) => []);
final walletTransactionsProvider =
    Provider.family<List<Transaction>, String?>((ref, String? accountId) {
  return ref.watch(accountStateProvider(accountId))?.wallet.transactions ?? [];
});

final transactionsProvider =
    Provider.family<List<Transaction>, String?>((ref, String? accountId) {
  List<Transaction> pendingTransactions =
      ref.watch(pendingTransactionsProvider(accountId));
  List<Transaction> transactions = [];
  List<Transaction> walletTransactions =
      ref.watch(walletTransactionsProvider(accountId));
  transactions.addAll(walletTransactions);
  //avoid duplicates
  for (var pending in pendingTransactions) {
    final tx = transactions
        .firstWhereOrNull((element) => element.txId == pending.txId);
    final rbfOriginals = ref.watch(rbfBroadCastedTxProvider);
    if (tx == null && !rbfOriginals.contains(pending.txId)) {
      transactions.add(pending);
    }
  }

  ref.watch(rbfBroadCastedTxProvider).forEach((txId) {
    final tx = transactions.firstWhereOrNull((element) => element.txId == txId);
    if (tx != null && !tx.isConfirmed) {
      transactions.remove(tx);
    }
  });
  //listen to transactions changes, prune pending transactions if needed
  //we use provider to retrieve all types of transactions,
  //in this way less database calls are made,
  //since provider will cache the result
  ref.listenSelf((previous, next) {
    List<Transaction> pendingTransactions =
        ref.read(pendingTransactionsProvider(accountId));
    List<Transaction> walletTransactions =
        ref.read(walletTransactionsProvider(accountId));
    prunePendingTransactions(ref, [
      ...pendingTransactions,
      ...walletTransactions,
    ]);
  });

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

final rbfTxStateProvider = FutureProvider.family<RBFState?, String>(
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
    return ref.watch(rbfTxStateProvider(param)).when(
          data: (data) {
            if (data != null) {
              if (data.newTxId == param) {
                return true;
              } else {
                return false;
              }
            }
            return null;
          },
          loading: () => null,
          error: (err, stack) {
            if (kDebugMode) debugPrintStack(stackTrace: stack);
            return null;
          },
        );
  },
);

final cancelTxStateFutureProvider = FutureProvider.family<RBFState?, String>(
  (ref, param) {
    final account = ref.watch(selectedAccountProvider);
    if (account == null) {
      return null;
    }
    return EnvoyStorage().getCancelTxState(account.id!, param);
  },
);

final cancelTxStateProvider = Provider.family<RBFState?, String>(
  (ref, param) {
    return ref.watch(cancelTxStateFutureProvider(param)).when(
          data: (data) {
            if (data != null) {
              return data;
            }
            return null;
          },
          loading: () => null,
          error: (err, stack) {
            debugPrintStack(stackTrace: stack);
            return null;
          },
        );
  },
);

Future prunePendingTransactions(
  ProviderRef ref,
  List<Transaction> newTxList,
) async {
  List<Transaction> pending = newTxList
      .where((element) => element.type == TransactionType.pending)
      .toList();
  List<Transaction> azteco = newTxList
      .where((element) => element.type == TransactionType.azteco)
      .toList();
  List<Transaction> transactions = newTxList
      .where((element) => element.type == TransactionType.normal)
      .toList();

  List<Transaction> btcPay = newTxList
      .where((element) => element.type == TransactionType.btcPay)
      .toList();

  List<Transaction> ramp = newTxList
      .where((element) => element.type == TransactionType.ramp)
      .toList();

  if (pending.isEmpty) return;

  //prune azteco transactions
  for (var pendingTx in azteco) {
    transactions
        .where((tx) => tx.outputs!.contains(pendingTx.address))
        .forEach((actualAztecoTx) {
      kPrint("Pruning Azteco tx: ${actualAztecoTx.txId}");
      EnvoyStorage()
          .addTxNote("Azteco voucher", actualAztecoTx.txId); // TODO: FIGMA
      EnvoyStorage().deleteTxNote(pendingTx.address!);
      EnvoyStorage().deletePendingTx(pendingTx.address!);
    });
  }

  for (var pendingTx in btcPay) {
    transactions
        .where((tx) => tx.outputs!.contains(pendingTx.address))
        .forEach((actualBtcPayTx) {
      kPrint("Pruning BtcPay tx: ${actualBtcPayTx.txId}");
      EnvoyStorage()
          .addTxNote("BTCPay voucher", actualBtcPayTx.txId); // TODO: FIGMA
      EnvoyStorage().deleteTxNote(pendingTx.address!);
      EnvoyStorage().deletePendingTx(pendingTx.address!);
      actualBtcPayTx.setPullPaymentId(pendingTx.pullPaymentId);
    });
  }
  for (var pendingTx in ramp) {
    transactions
        .where((tx) => tx.outputs!.contains(pendingTx.address))
        .forEach((actualRampTx) {
      kPrint("Pruning Ramp tx: ${actualRampTx.txId}");
      EnvoyStorage()
          .addTxNote("Ramp Purchase", actualRampTx.txId); // TODO: FIGMA
      EnvoyStorage().deleteTxNote(pendingTx.address!);
      EnvoyStorage().deletePendingTx(pendingTx.address!);
    });
  }

  //prune pending transactions
  // this includes pending dummy transactions and RBF pending transactions
  for (var pendingTx in pending) {
    bool deleted = false;
    transactions.where((tx) => tx.txId == pendingTx.txId).forEach((actualRBF) {
      deleted = true;
      kPrint("Pruning pending tx: ${pendingTx.txId}");
      EnvoyStorage().deletePendingTx(pendingTx.txId);
    });

    //in case of a failed RBF we dont want to remove the pending RBF tx
    if (!deleted) {
      final cancelTxState = ref.read(cancelTxStateProvider(pendingTx.txId));
      final boostState = ref.read(rbfTxStateProvider(pendingTx.txId)).value;
      final rbfState = cancelTxState ?? boostState;
      if (rbfState != null) {
        //check if the RBF failed and the original tx is confirmed, if so, remove the pending RBF tx
        final rbfTx = transactions.firstWhereOrNull((element) =>
            element.txId == rbfState.originalTxId && element.isConfirmed);

        if (rbfTx != null && rbfState.newTxId == pendingTx.txId) {
          if (kDebugMode) {
            kPrint("Pruning orphan RBF tx : ${pendingTx.txId} ");
          }
          EnvoyStorage().deletePendingTx(pendingTx.txId);
        }
      }
    }
  }
}
