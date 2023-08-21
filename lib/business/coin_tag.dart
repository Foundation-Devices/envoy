// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'coin_tag.g.dart';

@JsonSerializable(ignoreUnannotated: true)
class CoinTag {
  @JsonKey(name: 'id', defaultValue: generateNewId)
  String id;
  @JsonKey(name: 'name')
  String name;

  // any utxo that are not associated a will categorized as untagged
  // this field will denote if this tag is for untagged coins
  // the Tag that marked as untagged will not be saved to the database
  bool untagged = false;

  //Account id that this coin tag belongs to
  @JsonKey(name: 'account')
  String account;

  // Ignore coins when serializing, we only want to serialize the ids
  List<Coin> coins = [];

  @JsonKey(name: 'coins_id')
  Set<String> coins_id = Set();

  CoinTag(
      {required this.id,
      required this.name,
      required this.account,
      this.untagged = false});

  int get numOfLockedCoins => coins.where((element) => element.locked).length;

  int get numOfUnLockedCoins =>
      coins.where((element) => !element.locked).length;

  int get numOfCoins => coins.length;

  int get totalAmount =>
      coins.fold(0, (prevVal, element) => prevVal + element.utxo.value);

  bool get isAllCoinsLocked =>
      this.numOfCoins == 0 ? false : this.numOfCoins == this.numOfLockedCoins;

  List<Coin> get selectableCoins =>
      coins.where((element) => !element.locked).toList();

  int getSelectedAmount(Set<String> selectedCoins) {
    return coins.where((element) => selectedCoins.contains(element.id)).fold(
        0, (previousValue, element) => previousValue + element.utxo.value);
  }

  int getNumSelectedCoins(Set<String> selectedCoins) {
    return coins.where((element) => selectedCoins.contains(element.id)).length;
  }

  factory CoinTag.fromJson(Map<String, dynamic> json) =>
      _$CoinTagFromJson(json);

  Map<String, dynamic> toJson() => _$CoinTagToJson(this);

  void addCoin(Coin coin) {
    coins.add(coin);
    coins_id.add(coin.id);
  }

  void removeCoin(Coin coin) {
    coins.remove(coin);
    coins_id.remove(coin.id);
  }

  void addCoins(List<Coin> coins) => coins.forEach(addCoin);

  toJsonCoin() {
    return this.coins.map((e) => e.id);
  }

  Account? getAccount() {
    return AccountManager()
        .accounts
        .firstWhereOrNull((account) => this.account == account.id);
  }

  static generateNewId() {
    return Uuid().v4();
  }

  void updateLockState(bool bool) {
    coins.forEach((element) {
      element.setLock(bool);
    });
  }
}
