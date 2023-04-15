// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HideStateNotifier extends ChangeNotifier {
  Set<String> amountHiddenAccounts = {};

  HideStateNotifier() {
    LocalStorage().readSecure("balance_hidden").then((value) {
      if (value != null) {
        List<dynamic> savedState = jsonDecode(value);
        savedState.forEach((element) {
          if (element is String) amountHiddenAccounts.add(element);
        });
        notifyListeners();
      }
    });
  }

  setHideState(bool hide, Account account) {
    if (hide && account.id != null) {
      amountHiddenAccounts.add(account.id!);
    } else {
      if (amountHiddenAccounts.contains(account.id)) {
        amountHiddenAccounts.remove(account.id);
      }
    }
    var stateAsList = amountHiddenAccounts.toList();
    notifyListeners();
    try {
      LocalStorage().saveSecure("balance_hidden", jsonEncode(stateAsList));
    } catch (e) {
      print(e);
    }
  }
}

final balanceHideNotifierProvider =
    ChangeNotifierProvider((ref) => HideStateNotifier());

//Provider for accessing hide state with account parameter
final balanceHideStateStatusProvider = Provider.family<bool, Account>(
  (ref, account) {
    var hideStates = ref.watch(balanceHideNotifierProvider);
    return hideStates.amountHiddenAccounts.contains(account.id);
  },
);
