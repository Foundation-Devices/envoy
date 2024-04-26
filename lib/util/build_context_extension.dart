// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  bool get isSmallScreen => MediaQuery.sizeOf(this).width < 380;
}
