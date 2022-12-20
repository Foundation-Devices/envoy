// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:test/test.dart';
import 'package:pow/pow.dart';


void main() {
  test('Pow test', () {
    //int chunk = 4294967295 ~/ 100000000;

    // Reasonable difficulty
    for(int i = 1; i < 100000000; i++) {
      var difficulty = 4294960000 + i;
      var stopwatch = Stopwatch()..start();
      Pow.solve(difficulty);
      print('Diffi: $difficulty, all hashes found in ${stopwatch.elapsed}');
    }
  });
}
