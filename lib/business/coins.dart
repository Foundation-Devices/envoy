// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:wallet/wallet.dart';

//Wrapper class for Wallet.Utxo
class Coin {
  final Utxo utxo;
  bool locked = false;

  Coin(this.utxo, {this.locked = false});

  String get id => utxo.id;

  int get amount => utxo.value;
}

/**Extension that adds id getter to Wallet.Utxo
 * Utxo is a freezed class, so we can't add the getter
 * directly to the class
 */
extension utxoExtension on Utxo {
  get id => '$txid:$vout';
}
