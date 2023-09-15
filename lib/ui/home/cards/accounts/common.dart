// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:go_router/go_router.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/settings.dart';
import 'package:flutter/material.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/generated/l10n.dart';

void broadcast(
    Psbt psbt, BuildContext context, Wallet wallet) {
  wallet
      .broadcastTx(
          Settings().electrumAddress(wallet.network), Tor().port, psbt.rawTx)
      .then((_) {
    GoRouter.of(context).push(ROUTE_ACCOUNTS_HOME);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S().envoy_psbt_transaction_sent),
    ));
  }, onError: (_) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S().envoy_psbt_transaction_not_sent),
    ));
  });
}
