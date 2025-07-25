// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/account.dart';

enum HomePageTabState { devices, privacy, accounts, activity, learn }

enum HomePageAccountsNavigationState { list, details, receive, send }

class HomePageAccountsState {
  final Account? currentAccount;
  final HomePageAccountsNavigationState navigationState;

  HomePageAccountsState(this.navigationState, {this.currentAccount});
}

enum HomePageDevicesState { list, details }

enum HomePageBackgroundState {
  hidden,
  menu,
  notifications,
  settings,
  backups,
  support,
  about
}

enum DismissiblePrompt {
  hideAmount,
  userInteractedWithAccDetail,
  secureWallet,
  dragAndDrop,
  createCoinTagWarning,
  coinUnlockWarning,
  coinLockWarning,
  copyTxId,
  rbfWarning,
  leavingEnvoy,
  copyAddressWarning,
  openTxDetailsInExplorer,
  buyTxWarning,
  scanToConnect,

  ///warning for exiting manual coin selection
  txDiscardWarning,
  addTxNoteWarning
}

final homePageTabProvider =
    StateProvider<HomePageTabState>((ref) => HomePageTabState.accounts);

final homePageBackgroundProvider = StateProvider<HomePageBackgroundState>(
  (ref) => HomePageBackgroundState.hidden,
);

final homePageOptionsVisibilityProvider = StateProvider<bool>((ref) => false);

final homePageAccountsProvider = StateProvider<HomePageAccountsState>(
    (ref) => HomePageAccountsState(HomePageAccountsNavigationState.list));

final homePageDevicesProvider =
    StateProvider<HomePageDevicesState>((ref) => HomePageDevicesState.list);

//returns prompt dismiss state as stream
final promptStreamProvider =
    StreamProvider.family((ref, DismissiblePrompt prompt) {
  return EnvoyStorage().isPromptDismissed(prompt);
});

//returns prompt dismiss state
//if the prompt is not dismissed, returns false otherwise returns true
//this is better than using stream based provider because this wont require stream builder
final arePromptsDismissedProvider =
    Provider.family<bool, DismissiblePrompt>((ref, DismissiblePrompt prompt) {
  var value = ref.watch(promptStreamProvider(prompt));
  if (value.isLoading || value.value == null) {
    return false;
  } else {
    return value.value!;
  }
});
