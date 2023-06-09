// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomePageTabState { devices, accounts, learn }

enum HomePageAccountsState { list, details, receive, send }

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

enum DismissiblePrompt { hideAmount, userInteractedWithReceive }

final homePageTabProvider =
    StateProvider<HomePageTabState>((ref) => HomePageTabState.devices);

final homePageBackgroundProvider = StateProvider<HomePageBackgroundState>(
  (ref) => HomePageBackgroundState.hidden,
);

final homePageOptionsVisibilityProvider = StateProvider<bool>((ref) => false);

final homePageAccountsProvider =
    StateProvider<HomePageAccountsState>((ref) => HomePageAccountsState.list);

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
