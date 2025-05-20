// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final txNoteProvider = Provider.family<String?, String>((ref, txId) {
  final selectedAccount = ref.watch(selectedAccountProvider);
  if (selectedAccount == null) {
    return null;
  }
  final transactions = ref.watch(transactionsProvider(selectedAccount.id));
  for (var tx in transactions) {
    if (tx.txId == txId) {
      return tx.note;
    }
  }
  return null;
});
