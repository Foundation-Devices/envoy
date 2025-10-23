// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

/// Cache rive file to avoid loading it multiple times
final riveLoaderProvider = FutureProvider.family<File?, String>(
    (ref, asset) async => File.asset(asset, riveFactory: Factory.rive));

final coinLockRiveProvider = Provider<File?>((ref) {
  return ref.watch(riveLoaderProvider('assets/coin_lock.riv')).value;
});

final animatedQrScannerRiveProvider = Provider<File?>((ref) {
  return ref
      .watch(riveLoaderProvider('assets/anim/animated_qr_scanner.riv'))
      .value;
});
