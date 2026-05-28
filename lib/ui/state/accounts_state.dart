// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

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

final _fullScanningAccountsStream = StreamProvider<Set<String>>(((ref) {
  return SyncManager().fullScanningAccountsStream;
}));

/// True for the entire duration of `SyncManager.initiateAccountFullScan` for
/// this account id — including across all descriptors. Unlike the global
/// [accountSync] stream, this isn't clobbered by unrelated `Syncing` events
/// from the periodic auto-sync, so the rescan loader stays visible until the
/// scan really finishes.
final accountFullScanInProgressProvider =
    Provider.family<bool, String>((ref, accountId) {
  final scanningSet = ref.watch(_fullScanningAccountsStream).value ??
      SyncManager().fullScanningAccounts;
  return scanningSet.contains(accountId);
});

final _accountSyncStatusStream =
    StreamProvider.family<bool, (String, AddressType)>(((ref, params) {
  return EnvoyStorage().getAccountScanStatusStream(params.$1, params.$2);
}));
final isAccountRequiredScan = Provider.family<bool, EnvoyAccount>((
  ref,
  account,
) {
  for (var descriptor in account.descriptors) {
    bool isScanned = ref
            .watch(
              _accountSyncStatusStream((account.id, descriptor.addressType)),
            )
            .value ??
        false;
    if (!isScanned) {
      return true;
    }
  }
  return false;
});

final accountManagerNotifier = ChangeNotifierProvider((ref) {
  final accountManager = NgAccountManager();
  ref.onDispose(() {
    accountManager.dispose();
  });
  return accountManager;
});

final accountsListStreamProvider = StreamProvider<List<EnvoyAccount>>((
  ref,
) async* {
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

final _accountListProvider = Provider<List<EnvoyAccount>>((ref) {
  final accountManager = ref.watch(accountsListStreamProvider);
  return accountManager.value ?? [];
});

final accountsProvider = Provider<List<EnvoyAccount>>((ref) {
  var testnetEnabled = ref.watch(showTestnetAccountsProvider);
  var signetEnabled = ref.watch(showSignetAccountsProvider);
  final accounts = ref.watch(_accountListProvider);

  final visibleItem = accounts.where((account) {
    if (account.archived) {
      return false;
    }

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
    Provider.family<List<EnvoyAccount>, EnvoyAccount?>((
  ref,
  selectedEnvoyAccount,
) {
  final accounts = ref.watch(accountsProvider);
  final order = ref.watch(accountOrderStream);

  // We filter everything but mainnet
  final filteredEnvoyAccounts =
      accounts.where((account) => account.network == Network.bitcoin).toList();

  sortByAccountOrder(filteredEnvoyAccounts, order, (account) => account.id);

  return filteredEnvoyAccounts;
});

final signetAccountsProvider =
    Provider.family<List<EnvoyAccount>, EnvoyAccount?>(
        (ref, selectedEnvoyAccount) {
  final accounts = ref.watch(accountsProvider);
  final order = ref.watch(accountOrderStream);

// We filter everything but signet
  final filteredEnvoyAccounts =
      accounts.where((account) => account.network == Network.signet).toList();

  sortByAccountOrder(filteredEnvoyAccounts, order, (account) => account.id);

  return filteredEnvoyAccounts;
});

final testnetAccountsProvider =
    Provider.family<List<EnvoyAccount>, EnvoyAccount?>(
        (ref, selectedEnvoyAccount) {
  final accounts = ref.watch(accountsProvider);
  final order = ref.watch(accountOrderStream);

// We filter everything but testnet
  final filteredEnvoyAccounts =
      accounts.where((account) => account.network == Network.testnet4).toList();

  sortByAccountOrder(filteredEnvoyAccounts, order, (account) => account.id);

  return filteredEnvoyAccounts;
});

final mainnetAccountsCountProvider = Provider<int>((ref) {
  final accounts = ref.watch(mainnetAccountsProvider(null));
  return accounts.length;
});

final signetAccountsCountProvider = Provider<int>((ref) {
  final accounts = ref.watch(signetAccountsProvider(null));
  return accounts.length;
});

final testnetAccountsCountProvider = Provider<int>((ref) {
  final accounts = ref.watch(testnetAccountsProvider(null));
  return accounts.length;
});

final accountsCountByNetworkProvider =
    Provider.family<int, Network>((ref, network) {
  final accounts = switch (network) {
    Network.bitcoin => ref.watch(mainnetAccountsProvider(null)),
    Network.signet => ref.watch(signetAccountsProvider(null)),
    Network.testnet4 => ref.watch(testnetAccountsProvider(null)),
    _ => <EnvoyAccount>[],
  };
  return accounts.length;
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

// True if hot wallet account have 0 balance
final hotWalletAccountsEmptyProvider = Provider<bool>((ref) {
  final accounts = ref.watch(accountsProvider);
  for (final account in accounts) {
    if (account.isHot &&
        account.network == Network.bitcoin &&
        account.balance != BigInt.zero) {
      return false;
    }
  }
  return true;
});

final showDefaultAccountProvider = StateProvider<bool>((ref) => true);

final qlConnectionsStreamProvider = StreamProvider<List<QLConnection>>((ref) {
  return BluetoothChannel().deviceChannelsStream;
});

typedef _PrimePassphrase = ({
  QLConnection connection,
  String fingerprint,
});

typedef _PrimePassphraseEvent = ({
  QLConnection connection,
  String? fingerprint,
});

final _primePassphrasesProvider =
    StreamProvider<List<_PrimePassphrase>>((ref) async* {
  final connections = ref.watch(qlConnectionsStreamProvider).value ??
      BluetoothChannel().deviceChannels;
  final fingerprints = <QLConnection, String>{};

  List<_PrimePassphrase> activePassphrases() {
    return [
      for (final entry in fingerprints.entries)
        (connection: entry.key, fingerprint: entry.value),
    ];
  }

  void setFingerprint(QLConnection connection, String? fingerprint) {
    if (fingerprint == null) {
      fingerprints.remove(connection);
    } else {
      fingerprints[connection] = fingerprint.toLowerCase();
    }
  }

  for (final connection in connections) {
    if (!_isDisconnected(connection.lastDeviceStatus)) {
      final fingerprint = connection
          .qlHandler.bleAccountHandler.latestApplyPassphrase?.fingerprint;
      if (fingerprint != null) {
        fingerprints[connection] = fingerprint.toLowerCase();
      }
    }
  }

  yield activePassphrases();

  final events = StreamGroup.merge<_PrimePassphraseEvent>([
    for (final connection in connections)
      connection.qlHandler.bleAccountHandler.applyPassphraseStream
          .map<_PrimePassphraseEvent>(
        (event) => (connection: connection, fingerprint: event?.fingerprint),
      ),
    for (final connection in connections)
      connection.deviceStatusStream
          .where(_isDisconnected)
          .map<_PrimePassphraseEvent>(
            (_) => (connection: connection, fingerprint: null),
          ),
  ]);

  await for (final event in events) {
    setFingerprint(event.connection, event.fingerprint);
    yield activePassphrases();
  }
});

final passphraseEventHandlerProvider = Provider<void>((ref) {
  ref.listen<List<EnvoyAccount>>(
    primePassphraseAccountsProvider,
    (previous, next) {
      final wasEmpty = previous?.isEmpty ?? true;
      final isEmpty = next.isEmpty;
      if (wasEmpty == isEmpty) return;

      ref.read(showDefaultAccountProvider.notifier).state = isEmpty;
    },
    fireImmediately: true,
  );
});

bool _isDisconnected(DeviceStatus status) {
  return status.type == BluetoothConnectionEventType.deviceDisconnected ||
      status.type == BluetoothConnectionEventType.connectionError;
}

bool _matchesActivePrimePassphraseAccount(
  EnvoyAccount account,
  QLConnection connection,
  String fingerprint,
) {
  if (!account.seedHasPassphrase) {
    return false;
  }
  if (account.xfp.toLowerCase() != fingerprint.toLowerCase()) {
    return false;
  }

  final deviceSerial = account.deviceSerial;
  return deviceSerial == null ||
      deviceSerial.isEmpty ||
      deviceSerial == "prime" ||
      deviceSerial == _primeDeviceKey(connection);
}

String _primeDeviceKey(QLConnection connection) {
  return connection.getDevice()?.serial ??
      connection.primeSerial ??
      connection.deviceId;
}

final primePassphraseAccountsProvider = Provider<List<EnvoyAccount>>((ref) {
  final accounts = ref.watch(accountsProvider);
  final activePrimePassphrases =
      ref.watch(_primePassphrasesProvider).value ?? const <_PrimePassphrase>[];

  return accounts.where((account) {
    return activePrimePassphrases.any((passphrase) {
      return _matchesActivePrimePassphraseAccount(
        account,
        passphrase.connection,
        passphrase.fingerprint,
      );
    });
  }).toList();
});
