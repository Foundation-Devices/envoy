// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update.dart';
import 'package:envoy/ui/onboard/prime/onboard_prime.dart';
import 'package:envoy/ui/onboard/prime/onboard_prime_ble.dart';
import 'package:envoy/ui/onboard/prime/prime_magic_backup.dart';
import 'package:envoy/ui/onboard/prime/prime_onboard_connection.dart';
import 'package:envoy/ui/onboard/prime/prime_reconnect.dart';
import 'package:envoy/ui/onboard/prime/setup/prime_continuing_setup.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:go_router/go_router.dart';

const ONBOARD_PRIME = "prime";
const ONBOARD_PRIME_BLUETOOTH = "bluetooth";
const ONBOARD_PRIME_PAIR = "pairing";
const ONBOARD_PRIME_FIRMWARE_UPDATE = "update";
const ONBOARD_PRIME_MAGIC_BACKUP = "magic";
const ONBOARD_PRIME_CONTINUING_SETUP = "continuing_setup";
const ONBOARD_PRIME_CONNECTED_SUCCESS = "connected_success";
const ONBOARD_BLUETOOTH_DENIED = "bluetooth_denied";
const ONBOARD_REPAIRING = "prime_repair";

final primeRoutes = GoRoute(
  path: "prime",
  onExit: (context, state) {
    return true;
  },
  name: ONBOARD_PRIME,
  routes: [
    GoRoute(
      path: "bluetooth_denied",
      name: ONBOARD_BLUETOOTH_DENIED,
      builder: (context, state) => const OnboardBluetoothDenied(),
    ),
    GoRoute(
      path: "bluetooth",
      name: ONBOARD_PRIME_BLUETOOTH,
      routes: [
        GoRoute(
          path: "pairing",
          builder: (context, state) => const PrimeOnboardParing(),
          name: ONBOARD_PRIME_PAIR,
        ),
        GoRoute(
          path: "update",
          builder: (context, state) => const OnboardPrimeFwUpdate(),
          name: ONBOARD_PRIME_FIRMWARE_UPDATE,
        ),
        GoRoute(
          path: "continuing_setup",
          builder: (context, state) => const PrimeContinuingSetup(),
          name: ONBOARD_PRIME_CONTINUING_SETUP,
        ),
        GoRoute(
          path: "magic",
          name: ONBOARD_PRIME_MAGIC_BACKUP,
          builder: (context, state) => const PrimeMagicBackup(),
        ),
        GoRoute(
          path: "connected_success",
          name: ONBOARD_PRIME_CONNECTED_SUCCESS,
          builder: (context, state) =>
              const WalletSetupSuccess(isPrimeWallet: true),
        ),
      ],
      builder: (context, state) => const OnboardPrimeBluetooth(),
    ),
    GoRoute(
      path: "repair",
      name: ONBOARD_REPAIRING,
      builder: (context, state) {
        return const PrimeReconnect();
      },
    ),
  ],
  builder: (context, state) => const OnboardPrimeWelcome(),
);
