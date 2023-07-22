import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
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

  remove(String coinId) {
    if (state.contains(coinId)) {
      final newState = {...state}..remove(coinId);
      state = newState;
    }
  }
}

final coinSelectionStateProvider =
    StateNotifierProvider<CoinStateNotifier, Set>(
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
  List<Coin> coins =
      utxos.map((e) => Coin(e, locked: utxoBlockState[e.id] ?? false)).toList();
  return coins;
});

final coinsTagProvider =
    Provider.family<List<CoinTag>, String>((ref, accountId) {
  final existingTags = ref.watch(coinTagsStreamProvider(accountId)).value ?? [];
  final coins = ref.watch(coinsProvider(accountId));
  List<CoinTag> tags = [...existingTags];
  //Map coins to tags
  tags.forEach((tag) {
    //filter coins that are associated with the tag
    final coinsAssociated =
        coins.where((coin) => tag.coins_id.contains(coin.id)).toList();
    tag.coins = coinsAssociated;
    coins.removeWhere((element) => tag.coins_id.contains(element.id));
  });

  if (coins.isNotEmpty)
    tags.add(CoinTag(
        id: CoinTag.generateNewId(),
        name: "Untagged",
        account: accountId,
        untagged: true)
      ..addCoins(coins));
  //add coins that are not associated with any tag
  return tags;
});
