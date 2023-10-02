// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';

final coinBlockStateStreamProvider =
    StreamProvider((ref) => CoinRepository().getCoinBlockStateStream());
final coinTagsStreamProvider = StreamProvider.family<List<CoinTag>, String>(
    (ref, accountId) =>
        CoinRepository().getCoinTagStream(accountId: accountId));

class CoinStateNotifier extends StateNotifier<Set<String>> {
  CoinStateNotifier(super.state);

  add(String coinId) {
    //Creates new state from existing state,
    //this is required for state notifier to notify the state change
    final newState = {...state}..add(coinId);
    state = newState;
  }

  addAll(List<String> coinIds) {
    //Creates new state from existing state,
    //this is required for state notifier to notify the state change
    final newState = {...state}..addAll(coinIds);
    state = newState;
  }

  remove(String coinId) {
    if (state.contains(coinId)) {
      final newState = {...state}..remove(coinId);
      state = newState;
    }
  }

  void removeAll(List<String> list) {
    bool changed = false;
    Set<String> newState = {...state};
    list.forEach((element) {
      if (state.contains(element)) {
        changed = true;
        newState.remove(element);
      }
    });
    if (changed) state = newState;
  }

  void reset() {
    state = {};
  }
}

final coinSelectionStateProvider =
    StateNotifierProvider<CoinStateNotifier, Set<String>>(
  (ref) => CoinStateNotifier(Set()),
);

final isCoinSelectedProvider = Provider.family<bool, String>(
    (ref, coinId) => ref.watch(coinSelectionStateProvider).contains(coinId));

/**
 * Provider for [Coin] list for specific account
 * @param accountId [Account.id]
 * @return list of coins
 * any changes to account or utxo block state will re calculate the list
 */
final coinsProvider = Provider.family<List<Coin>, String>((ref, accountId) {
  //Watch for any account changes
  final accounts = ref.watch(accountsProvider);
  final account =
      accounts.firstWhereOrNull((element) => element.id == accountId);
  //if account is null, return empty list
  if (account == null) {
    return [];
  }

  //Watch for any utxo block state changes, state is a map of utxo id to locked status
  // eg : {'hash1': true, 'hash2': false}
  final utxoBlockState = (ref.watch(coinBlockStateStreamProvider).value ?? {});

  List<Utxo> utxos = account.wallet.utxos;
  //Map utxos to coins with locked status
  List<Coin> coins = utxos
      .map((e) =>
          Coin(e, locked: utxoBlockState[e.id] ?? false, account: accountId))
      .toList();
  return coins;
});

final coinsTagProvider =
    Provider.family<List<CoinTag>, String>((ref, accountId) {
  final existingTags = ref.watch(coinTagsStreamProvider(accountId)).value ?? [];
  final sortType = ref.watch(coinTagSortStateProvider);
  final existingCoins = ref.watch(coinsProvider(accountId));
  //Make deep copies so it wont affect existing data sets, any array operations like
  //removeWhere or Add needs to be done in deep copies.
  List<Coin> coins = [...existingCoins];
  List<CoinTag> tags = [...existingTags];
  //Map coins to tags
  tags.forEach((tag) {
    //filter coins that are associated with the tag
    final coinsAssociated =
        coins.where((coin) => tag.coins_id.contains(coin.id)).toList();
    tag.coins = coinsAssociated;
    coins.removeWhere((element) => tag.coins_id.contains(element.id));
  });
  //add coins that are not associated with any tag
  if (coins.isNotEmpty)
    tags.add(CoinTag(
        id: CoinTag.generateNewId(),
        name: "Untagged", // TODO: FIGMA
        account: accountId,
        untagged: true)
      ..addCoins(coins));

  switch (sortType) {
    case CoinTagSortTypes.sortByTagNameAsc:
      tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case CoinTagSortTypes.sortByTagNameDesc:
      tags.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      break;
    case CoinTagSortTypes.amountLowToHigh:
      tags.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
      break;
    case CoinTagSortTypes.amountHighToLow:
      tags.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      break;
  }

  return tags;
});

//Provider for [CoinTag] list for specific account and txId
final tagsFilteredByTxIdProvider =
    Provider.family<List<CoinTag>, FilterTagPayload>((ref, filters) {
  final accountId = filters.accountId;
  final txId = filters.txId;
  if (txId == null || accountId == null) {
    return [];
  }

  final List<CoinTag> tags = ref.watch(coinsTagProvider(accountId));
  final List<CoinTag> associatedTags = [];
  tags.forEach((element) {
    if (element.coins.any((coin) => coin.utxo.txid == txId)) {
      associatedTags.add(element);
    }
  });

  return associatedTags;
});

final coinTagLockStateProvider = Provider.family<bool, CoinTag>((ref, tag) {
  ref.watch(coinsTagProvider(tag.account));
  return tag.isAllCoinsLocked;
});

//[tagsFilteredByTxIdProvider] require two parameters,
//accountId and txId, this class is used to pass those parameters
//Why not use Map<String, String> ? because provider needs an equatable object
//to cache the result, Map<String, String> is not equatable
class FilterTagPayload {
  final String? accountId;
  final String? txId;
  FilterTagPayload(this.accountId, this.txId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterTagPayload &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          txId == other.txId;

  @override
  int get hashCode => accountId.hashCode ^ txId.hashCode;
}
