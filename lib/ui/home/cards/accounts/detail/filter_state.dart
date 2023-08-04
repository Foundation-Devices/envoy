// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountToggleState {
  Tx,
  Coins,
}

enum FilterButtonState { up, down, none }

extension FilterStateToggleExtension on FilterButtonState {
  toggle() {
    if (this == FilterButtonState.none) {
      return FilterButtonState.up;
    } else if (this == FilterButtonState.up) {
      return FilterButtonState.down;
    } else if (this == FilterButtonState.down) {
      return FilterButtonState.none;
    }
  }
}

class TxFilterState {
  FilterButtonState filterByDate = FilterButtonState.none;
  FilterButtonState filterByAmount = FilterButtonState.none;
  FilterButtonState filterBySpend = FilterButtonState.none;

  TxFilterState(
      {this.filterByDate = FilterButtonState.none,
      this.filterByAmount = FilterButtonState.none,
      this.filterBySpend = FilterButtonState.none});

  TxFilterState copy() => copyWith(this);

  static TxFilterState copyWith(TxFilterState filterState) {
    return TxFilterState(
      filterByAmount: filterState.filterByAmount,
      filterByDate: filterState.filterByDate,
      filterBySpend: filterState.filterBySpend,
    );
  }
}

class CoinFilterState {
  FilterButtonState filterByNumberOfCoins = FilterButtonState.none;
  FilterButtonState filterByAmount = FilterButtonState.none;
  FilterButtonState filterByTagName = FilterButtonState.none;

  CoinFilterState(
      {this.filterByNumberOfCoins = FilterButtonState.none,
      this.filterByAmount = FilterButtonState.none,
      this.filterByTagName = FilterButtonState.none});

  CoinFilterState copy() => copyWith(this);

  static CoinFilterState copyWith(CoinFilterState filterState) {
    return CoinFilterState(
      filterByAmount: filterState.filterByAmount,
      filterByNumberOfCoins: filterState.filterByNumberOfCoins,
      filterByTagName: filterState.filterByTagName,
    );
  }
}

final accountToggleStateProvider =
    StateProvider<AccountToggleState>((ref) => AccountToggleState.Tx);
final coinFilterStateProvider =
    StateProvider<CoinFilterState>((ref) => CoinFilterState());
final txFilterStateProvider =
    StateProvider<TxFilterState>((ref) => TxFilterState());
