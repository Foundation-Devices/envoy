// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet/wallet.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'coins.g.dart';

_utxoToJson(Utxo utxo) {
  return utxo.toJson();
}

//Wrapper class for Wallet.Utxo
@JsonSerializable()
class Coin {
  @JsonKey(
    toJson: _utxoToJson,
    fromJson: Utxo.fromJson,
  )
  final Utxo utxo;
  bool locked = false;
  String account;

  Coin(this.utxo, {this.locked = false, required this.account});

  String get id => utxo.id;

  int get amount => utxo.value;

  void setLock(bool bool) async {
    this.locked = bool;
    CoinRepository().addUtxoBlockState(id, bool);
  }

  factory Coin.fromJson(Map<String, dynamic> json) => _$CoinFromJson(json);

  Map<String, dynamic> toJson() => _$CoinToJson(this);
}

/// Extension that adds id getter to Wallet.Utxo
/// Utxo is a freezed class, so we can't add the getter directly to
/// the class
extension utxoExtension on Utxo {
  get id => '$txid:$vout';
}

_coinToJson(Coin coin) {
  return coin.toJson();
}

@JsonSerializable()
class InputCoinHistory {
  final String accountId;
  final String tagName;
  final String txId;

  @JsonKey(
    toJson: _coinToJson,
    fromJson: Coin.fromJson,
  )
  final Coin coin;

  InputCoinHistory(this.accountId, this.tagName, this.txId, this.coin);

  factory InputCoinHistory.fromJson(Map<String, dynamic> json) =>
      _$InputCoinHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$InputCoinHistoryToJson(this);
}
