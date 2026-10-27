// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/channels/ql_connection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State Provider for the current onboarding device.
///
/// Different onboarding steps watch this provider to get the current
/// onboarding device and listen to its various state streams.
final onboardingDeviceProvider = StateProvider<QLConnection?>((ref) {
  return null;
});
