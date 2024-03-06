// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LearnFilters { All, Videos, FAQs, Blogs }

enum LearnSortTypes {
  newestFirst,
  oldestFirst,
}

final learnFilterStateProvider = StateProvider<Set<LearnFilters>>(
    (ref) =>  {}..addAll(LearnFilters.values));

final learnSortStateProvider =
    StateProvider<LearnSortTypes>((ref) => LearnSortTypes.newestFirst);
