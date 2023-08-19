// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:wallet/wallet.dart';

//Wrapper class for Wallet.Utxo
class Coin {
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
}

/**
 * Extension that adds id getter to Wallet.Utxo
 * Utxo is a freezed class, so we can't add the getter directly to
 * the class
 */
extension utxoExtension on Utxo {
  get id => '$txid:$vout';
}
