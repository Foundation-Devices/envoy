// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

/// Cache rive file to avoid loading it multiple times
final riveLoaderProvider = FutureProvider.family<RiveFile, String>(
    (ref, asset) async => RiveFile.import(await rootBundle.load(asset)));

final coinLockRiveProvider = Provider((ref) {
  return ref.watch(riveLoaderProvider('assets/coin_lock.riv')).value;
});
