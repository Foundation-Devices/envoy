// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:math';
import 'package:envoy/util/console.dart';
import 'package:schedulers/schedulers.dart';

class EnvoyScheduler {
  static final EnvoyScheduler _instance = EnvoyScheduler._internal();

  static EnvoyScheduler get instance => _instance;

  // No less than 1 and no more than 8 but always leave 4 threads for UI and Tor
  final parallel =
      ParallelScheduler(min(max(Platform.numberOfProcessors - 4, 1), 8));

  factory EnvoyScheduler() {
    return _instance;
  }

  static Future<EnvoyScheduler> init() async {
    var singleton = EnvoyScheduler._instance;
    return singleton;
  }

  EnvoyScheduler._internal() {
    kPrint(
        "Instance of EnvoyScheduler created! Phone has ${Platform.numberOfProcessors} CPUs.");
  }
}
