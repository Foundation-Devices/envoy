// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

//based on https://github.com/gskinnerTeam/flutter-wonderous-app/blob/master/lib/ui/common/utils/app_haptics.dart
class Haptics {
  static bool debugLog = kDebugMode;

  static void buttonPress() {
    // Android/Fuchsia expect haptics on all button presses, iOS does not.
    if (defaultTargetPlatform != TargetPlatform.android ||
        defaultTargetPlatform != TargetPlatform.fuchsia) {
      lightImpact();
    }
  }

  static Future<void> lightImpact() {
    _debug('lightImpact');
    return HapticFeedback.lightImpact();
  }

  static Future<void> mediumImpact() {
    _debug('mediumImpact');
    return HapticFeedback.mediumImpact();
  }

  static Future<void> heavyImpact() {
    _debug('heavyImpact');
    return HapticFeedback.heavyImpact();
  }

  static Future<void> selectionClick() {
    _debug('selectionClick');
    return HapticFeedback.selectionClick();
  }

  static Future<void> vibrate() {
    _debug('vibrate');
    return HapticFeedback.vibrate();
  }

  static void _debug(String label) {
    if (debugLog) debugPrint('Haptic.$label');
  }
}
