// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

extension ColorExtension on Color {
  applyOpacity(double opacity) {
    return withAlpha((255.0 * opacity).round());
  }
}
