// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LearnFilters { all, videos, faqs, blogs }

enum DeviceFilters { all, envoy, passport, passportPrime }

enum LearnSortTypes {
  newestFirst,
  oldestFirst,
}

final deviceFilterStateProvider = StateProvider<Set<DeviceFilters>>(
    (ref) => {}..addAll(DeviceFilters.values));

final learnFilterStateProvider =
    StateProvider<Set<LearnFilters>>((ref) => {}..addAll(LearnFilters.values));

final learnSortStateProvider =
    StateProvider<LearnSortTypes>((ref) => LearnSortTypes.newestFirst);
