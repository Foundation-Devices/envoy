// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

class Tag {
  String name;
  List<Output> utxo;
  final bool untagged;

  Tag({required this.name, required this.utxo, this.untagged = false});

  bool contains(String id) {
    return utxo.where((element) => element.getId() == id).isNotEmpty;
  }

  bool get isAllCoinsLocked {
    for (var element in utxo) {
      if (!element.doNotSpend) {
        return false;
      }
    }
    return true;
  }

  int get numOfLockedCoins {
    int count = 0;
    for (var element in utxo) {
      if (element.doNotSpend) {
        count++;
      }
    }
    return count;
  }

  int get totalAmount {
    int total = 0;
    for (var element in utxo) {
      total += element.amount.toInt();
    }
    return total;
  }
}

final coinBlockStateStreamProvider =
    StreamProvider((ref) => CoinRepository().getCoinBlockStateStream());
// final coinTagsStreamProvider = StreamProvider.family<List<NgCoinTag>, String>(
//     (ref, accountId) =>
//         CoinRepository().getCoinTagStream(accountId: accountId));

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
    for (var element in list) {
      if (state.contains(element)) {
        changed = true;
        newState.remove(element);
      }
    }
    if (changed) state = newState;
  }

  void reset() {
    state = {};
  }
}

final coinSelectionStateProvider =
    StateNotifierProvider<CoinStateNotifier, Set<String>>(
  (ref) => CoinStateNotifier({}),
);

final coinSelectionFromWallet =
    StateNotifierProvider<CoinStateNotifier, Set<String>>(
  (ref) => CoinStateNotifier({}),
);

final isCoinSelectedProvider = Provider.family<bool, String>(
    (ref, coinId) => ref.watch(coinSelectionStateProvider).contains(coinId));

//Provider for watching a single [Output] object
/// @param coinId [Output.getId]
final outputProvider = Provider.family<Output?, String>((ref, coinId) {
  final selectedAccount = ref.watch(selectedAccountProvider);
  final outputs = ref.watch(outputsProvider(selectedAccount?.id ?? ""));
  final output =
      outputs.firstWhereOrNull((element) => element.getId() == coinId);
  return output;
});

/// Provider for watching a single [Tag] object
/// @param coinId [Tag.name]
final tagProvider = Provider.family<Tag?, String>((ref, name) {
  final selectedAccount = ref.watch(selectedAccountProvider);
  final tags = ref.watch(tagsProvider(selectedAccount?.id ?? ""));
  return tags.firstWhereOrNull((element) => element.name.toLowerCase() == name);
});

/// Provider for watching a list of [Tag] objects that belongs to a specific account
/// @param accountId [EnvoyAccount.id]
final tagsProvider = Provider.family<List<Tag>, String>((ref, accountId) {
  final accounts = ref.watch(accountsProvider);
  final sortType = ref.watch(coinTagSortStateProvider);
  final account =
      accounts.firstWhereOrNull((element) => element.id == accountId);
  final List<Tag> tags = [];
  final untagged =
      Tag(name: S().account_details_untagged_card, utxo: [], untagged: true);
  for (String tag in account?.tags ?? []) {
    List<Output> utxo = [];
    account?.utxo
        .where(
            (element) => element.tag == tag && element.tag?.isNotEmpty == true)
        .forEach((element) {
      utxo.add(element);
    });
    if (tag.isNotEmpty) {
      tags.add(Tag(
        name: tag,
        utxo: utxo,
      ));
    }
  }
  for (Output utxo in account?.utxo ?? []) {
    final exist = tags
        .where((element) => element.contains(utxo.getId()))
        .toList()
        .isNotEmpty;
    if (!exist || utxo.tag?.isEmpty == true || utxo.tag == null) {
      untagged.utxo.add(utxo);
    }
  }
  if (untagged.utxo.isNotEmpty) {
    tags.add(untagged);
  }

  switch (sortType) {
    case CoinTagSortTypes.sortByTagNameAsc:
      tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case CoinTagSortTypes.sortByTagNameDesc:
      tags.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      break;
    case CoinTagSortTypes.amountLowToHigh:
      tags.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
      for (var tag in tags) {
        tag.utxo.sort(
          (Output a, Output b) => a.amount.toInt().compareTo(b.amount.toInt()),
        );
      }
      break;
    case CoinTagSortTypes.amountHighToLow:
      tags.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      break;
  }
  return tags;
});

final outputsProvider = Provider.family<List<Output>, String>((ref, accountId) {
  final accounts = ref.watch(accountsProvider);
  final account =
      accounts.firstWhereOrNull((element) => element.id == accountId);
  return account?.utxo ?? [];
});
final filteredTagsProvider =
    Provider.family<List<Tag>, String>((ref, accountId) {
  final accounts = ref.watch(accountsProvider);
  final account =
      accounts.firstWhereOrNull((element) => element.id == accountId);
  final List<Tag> tags = [];
  final untagged = Tag(name: "untagged", utxo: [], untagged: true);
  for (String tag in account?.tags ?? []) {
    List<Output> utxo = [];
    account?.utxo.where((element) => element.tag == tag).forEach((element) {
      utxo.add(element);
    });
    tags.add(Tag(
      name: tag,
      utxo: utxo,
    ));
  }
  for (Output utxo in account?.utxo ?? []) {
    final exist = tags
        .where((element) => element.contains(utxo.getId()))
        .toList()
        .isNotEmpty;
    if (!exist) {
      untagged.utxo.add(utxo);
    }
  }
  return tags;
});

/// Provider for [Coin] list for specific account
/// @param accountId [Account.id]
/// @return list of coins
/// any changes to account or utxo block state will re calculate the list
final coinsProvider = Provider.family<List<Output>, String>((ref, accountId) {
  //Watch for any account changes
  final accounts = ref.watch(accountsProvider);
  final account =
      accounts.firstWhereOrNull((element) => element.id == accountId);
  //if account is null, return empty list
  if (account == null) {
    return [];
  }
  return account.utxo;
});

// final coinTagLockStateProvider = Provider.family<bool, NgCoinTag>((ref, tag) {
//   ref.watch(coinsTagProvider(tag.account));
//   return tag.isAllCoinsLocked;
// });

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

// final lockedUtxosProvider = Provider.family<List<Utxo>, String>((ref, id) {
//   final utxos = ref.watch(coinsProvider(id));
//   return utxos.where((element) => element.doNotSpend).map((e) => e.).toList();
// });
