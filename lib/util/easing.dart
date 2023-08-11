// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/animation.dart';

class EnvoyEasing {
  static const double epsilon = 1e-9;

  static Cubic easeIn = Cubic(0.42, 0, 1, 1);
  static Cubic easeOut = Cubic(0, 0, 0.58, 1);
  static Cubic easeInOut = Cubic(0.42, 0, 0.58, 1);
  static Cubic defaultEasing = Cubic(0.25, 0.1, 0.25, 1);
}
