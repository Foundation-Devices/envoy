// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

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
