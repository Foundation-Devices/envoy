// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountToggleState {
  Tx,
  Coins,
}

enum TransactionFilters {
  Sent,
  Received,
}

enum TransactionSortTypes {
  newestFirst,
  oldestFirst,
  amountLowToHigh,
  amountHighToLow,
}

enum CoinTagSortTypes {
  sortByTagNameAsc,
  sortByTagNameDesc,
  amountLowToHigh,
  amountHighToLow,
}

final txFilterStateProvider = StateProvider<Set<TransactionFilters>>(
    (ref) => Set()..addAll(TransactionFilters.values));
final txSortStateProvider = StateProvider<TransactionSortTypes>(
    (ref) => TransactionSortTypes.newestFirst);

//provider to determine if the transaction filters are enabled
final isTransactionFiltersEnabled = Provider<bool>((ref) {
  final filters = ref.watch(txFilterStateProvider);
  final TransactionSortTypes sort = ref.watch(txSortStateProvider);
  return filters.length != 2 || sort != TransactionSortTypes.newestFirst;
});

final coinTagSortStateProvider =
    StateProvider<CoinTagSortTypes>((ref) => CoinTagSortTypes.sortByTagNameAsc);

final accountToggleStateProvider =
    StateProvider<AccountToggleState>((ref) => AccountToggleState.Tx);

///clears existing filter states. this will be called when the user navigates to account detail page
clearFilterState(WidgetRef ref) {
  ref.read(txSortStateProvider.notifier).state =
      TransactionSortTypes.newestFirst;
  ref.read(txFilterStateProvider.notifier).state = Set()
    ..addAll(TransactionFilters.values);
  ref.read(coinTagSortStateProvider.notifier).state =
      CoinTagSortTypes.sortByTagNameAsc;
  ref.read(accountToggleStateProvider.notifier).state = AccountToggleState.Tx;
}
