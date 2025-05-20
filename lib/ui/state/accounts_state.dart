// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

final _accountOrderStream = StreamProvider<List<String>>(((ref) {
  return NgAccountManager().order;
}));
final accountOrderStream = Provider<List<String>>(((ref) {
  return ref.watch(_accountOrderStream).value ?? [];
}));

final accountManagerNotifier = ChangeNotifierProvider(
  (ref) {
    final accountManager = NgAccountManager();
    ref.onDispose(() {
      accountManager.dispose();
    });
    return accountManager;
  },
);

final accountsListStreamProvider =
    StreamProvider<List<EnvoyAccount>>((ref) async* {
  final manager = ref.watch(accountManagerNotifier);
  //send the initial state
  yield manager.accounts;
  // create new list to avoid mutating the original
  final latestStates = List.from(manager.accounts);
  await for (EnvoyAccount state in StreamGroup.merge(manager.streams)) {
    // Replace or add the updated state in the list
    final index = latestStates.indexWhere((s) => s.id == state.id);
    if (index != -1) {
      latestStates[index] = state;
    } else {
      latestStates.add(state);
    }
    //send updated list as a new state
    yield List.from(latestStates);
  }
});

final _accountListProvider = Provider<List<EnvoyAccount>>(
  (ref) {
    final accountManager = ref.watch(accountsListStreamProvider);
    return accountManager.value ?? [];
  },
);

final accountsProvider = Provider<List<EnvoyAccount>>((ref) {
  var testnetEnabled = ref.watch(showTestnetAccountsProvider);
  var signetEnabled = ref.watch(showSignetAccountsProvider);
  final accounts = ref.watch(_accountListProvider);

  final visibleItem = accounts.where((account) {
    if (!testnetEnabled &&
        (account.network == Network.testnet ||
            account.network == Network.testnet4)) {
      return false;
    }

    if (!signetEnabled && account.network == Network.signet) {
      return false;
    }
    //TODO: fix for unified accounts
    // if (!taprootEnabled && account.preferredAddressType == AddressType.p2Tr) {
    //   return false;
    // }
    return true;
  }).toList();

  return [...visibleItem];
});

final mainnetAccountsProvider =
    Provider.family<List<EnvoyAccount>, EnvoyAccount?>(
        (ref, selectedEnvoyAccount) {
  final accounts = ref.watch(accountsProvider);

  // We filter everything but mainnet
  final filteredEnvoyAccounts =
      accounts.where((account) => account.network == Network.bitcoin).toList();

  return filteredEnvoyAccounts;
});

final accountStateProvider =
    StateProvider.family<EnvoyAccount?, String?>((ref, id) {
  final accounts = ref.watch(accountsProvider);
  final account = accounts.singleWhereOrNull((element) => element.id == id);
  if (account == null) {
    return null;
  }
  return account;
});

final accountBalanceProvider = Provider.family<int, String?>((ref, id) {
  final account = ref.watch(accountStateProvider(id));
  if (account == null) {
    return 0;
  }
  return account.balance.toInt();
});

// True if all the accounts have 0 balance
final accountsZeroBalanceProvider = Provider<bool>((ref) {
  final accounts = ref.watch(accountsProvider);
  for (final account in accounts) {
    if (account.balance.toInt() > 0) {
      return false;
    }
  }
  return true;
});
