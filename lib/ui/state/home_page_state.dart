// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomePageTabState { devices, accounts, learn }

enum HomePageBackgroundState {
  hidden,
  menu,
  notifications,
  settings,
  backups,
  support,
  about
}

final homePageTab =
    StateProvider<HomePageTabState>((ref) => HomePageTabState.devices);

final homePageBackground = StateProvider<HomePageBackgroundState>(
    (ref) => HomePageBackgroundState.hidden);
