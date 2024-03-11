// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountToggleState {
  tx,
  coins,
}

enum TransactionFilters {
  sent,
  received,
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
    (ref) => {}..addAll(TransactionFilters.values));
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
    StateProvider<AccountToggleState>((ref) => AccountToggleState.tx);

///clears existing filter states. this will be called when the user navigates to account detail page
clearFilterState(WidgetRef ref) {
  ref.read(txSortStateProvider.notifier).state =
      TransactionSortTypes.newestFirst;
  ref.read(txFilterStateProvider.notifier).state = {}
    ..addAll(TransactionFilters.values);
  ref.read(coinTagSortStateProvider.notifier).state =
      CoinTagSortTypes.sortByTagNameAsc;
  ref.read(accountToggleStateProvider.notifier).state = AccountToggleState.tx;
}
