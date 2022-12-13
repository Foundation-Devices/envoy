// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:test/test.dart';
import 'package:randomx/randomx.dart';


void main() {
  test('RandomX test', () {
    //int chunk = 4294967295 ~/ 100000000;

    // Reasonable difficulty
    for(int i = 1; i < 100000000; i++) {
      var difficulty = 4290000000 + i;
      var stopwatch = Stopwatch()..start();
      RandomX.mineMonero(difficulty);
      print('Diffi: $difficulty, all hashes found in ${stopwatch.elapsed}');
    }
  });
}
