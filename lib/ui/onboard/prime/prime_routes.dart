// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ui/onboard/prime/onboard_prime.dart';
import 'package:envoy/ui/onboard/prime/onboard_prime_ble.dart';
import 'package:envoy/ui/onboard/prime/firmware%20_update/prime_fw_update.dart';
import 'package:envoy/ui/onboard/prime/prime_onboard_connection.dart';
import 'package:go_router/go_router.dart';

const ONBOARD_PRIME = "prime";
const ONBOARD_PRIME_BLUETOOTH = "bluetooth";
const ONBOARD_PRIME_PAIR = "pairing";
const ONBOARD_PRIME_FIRMWARE_UPDATE = "update";

final primeRoutes = GoRoute(
  path: "prime",
  name: ONBOARD_PRIME,
  routes: [
    GoRoute(
      path: "bluetooth",
      name: ONBOARD_PRIME_BLUETOOTH,
      routes: [
        GoRoute(
            path: "pairing",
            builder: (context, state) => const PrimeOnboardParing(),
            name: ONBOARD_PRIME_PAIR),
        GoRoute(
            path: "update",
            builder: (context, state) => const OnboardPrimeFwUpdate(),
            name: ONBOARD_PRIME_FIRMWARE_UPDATE),
      ],
      builder: (context, state) => const OnboardPrimeBluetooth(),
    )
  ],
  builder: (context, state) => const OnboardPrimeWelcome(),
);
