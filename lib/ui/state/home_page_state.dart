// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomePageState { devices, accounts, learn }

final homePageStateProvider =
    StateProvider<HomePageState>((ref) => HomePageState.devices);
