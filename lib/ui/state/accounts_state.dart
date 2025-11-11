// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/business/devices.dart';

final _accountOrderStream = StreamProvider<List<String>>(((ref) {
  return NgAccountManager().order;
}));
final _accountSync = StreamProvider<WalletProgress>(((ref) {
  return SyncManager().currentLoading;
}));

final accountOrderStream = Provider<List<String>>(((ref) {
  return ref.watch(_accountOrderStream).value ?? [];
}));

final accountSync = Provider<WalletProgress>(((ref) {
  return ref.watch(_accountSync).value ?? None();
}));

final _accountSyncStatusStream =
    StreamProvider.family<bool, (String, AddressType)>(((ref, params) {
  return EnvoyStorage().getAccountScanStatusStream(
    params.$1,
    params.$2,
  );
}));
final isAccountRequiredScan =
    Provider.family<bool, EnvoyAccount>((ref, account) {
  for (var descriptor in account.descriptors) {
    bool isScanned = ref
            .watch(
                _accountSyncStatusStream((account.id, descriptor.addressType)))
            .value ??
        false;
    if (!isScanned) {
      return true;
    }
  }
  return false;
});

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
  final order = ref.watch(accountOrderStream);

// We filter everything but mainnet
  final filteredEnvoyAccounts =
      accounts.where((account) => account.network == Network.bitcoin).toList();

  sortByAccountOrder(filteredEnvoyAccounts, order, (account) => account.id);

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

final showDefaultAccountProvider = StateProvider<bool>((ref) => true);

/// Stores the current passphrase fingerprint (XFP) for Prime devices.
/// Key: device serial, Value: XFP (null if no passphrase)
final primePassphraseFingerprintProvider =
    StateProvider<Map<String, String?>>((ref) => {});

/// Listens to ApplyPassphrase events from Prime and auto-switches view
final _passphraseEventStreamProvider =
    StreamProvider<api.ApplyPassphrase>((ref) {
  return BluetoothManager().passphraseEventStream;
});

/// Provider that handles ApplyPassphrase events and updates UI state
final passphraseEventHandlerProvider = Provider<void>((ref) {
  ref.listen(_passphraseEventStreamProvider, (previous, next) {
    final event = next.valueOrNull;
    if (event == null) return;

    final fingerprint = event.fingerprint;
    kPrint("ApplyPassphrase event received in UI: fingerprint=$fingerprint");

    // Update the fingerprint map
    final currentMap = ref.read(primePassphraseFingerprintProvider);
    final updatedMap = {...currentMap, 'prime': fingerprint};
    ref.read(primePassphraseFingerprintProvider.notifier).state = updatedMap;

    // Auto-switch view based on passphrase state
    if (fingerprint != null) {
      // Prime applied a passphrase - switch to passphrase view
      kPrint("Auto-switching to passphrase view");
      ref.read(showDefaultAccountProvider.notifier).state = false;
    } else {
      // Prime cleared passphrase - switch to default view
      kPrint("Auto-switching to default view");
      ref.read(showDefaultAccountProvider.notifier).state = true;
    }
  });
});

final primePassphraseAccountsProvider = Provider<List<EnvoyAccount>>((ref) {
  final accounts = ref.watch(accountsProvider);
  final primeSerials = Devices().getPrimeDevices.map((d) => d.serial).toSet();

  return accounts.where((account) {
    return account.seedHasPassphrase &&
        primeSerials.contains(account.deviceSerial);
  }).toList();
});
