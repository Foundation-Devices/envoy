// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GlobalState {
  normal,
  nuclearDelete,
}

final globalStateProvider =
    StateProvider.autoDispose<GlobalState>((ref) => GlobalState.normal);
