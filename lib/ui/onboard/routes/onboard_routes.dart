// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/onboard/magic/magic_recover_wallet.dart';
import 'package:envoy/ui/onboard/magic/magic_setup_generate.dart';
import 'package:envoy/ui/onboard/magic/magic_setup_tutorial.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/onboard/onboard_privacy_setup.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/onboard/onboard_welcome_envoy.dart';
import 'package:envoy/ui/onboard/onboard_welcome_passport.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:go_router/go_router.dart';

const ONBOARD_PASSPORT_SETUP = 'welcome_passport_setup';
const ONBOARD_PRIVACY_SETUP = 'welcome_privacy_setup';
const ONBOARD_ENVOY_SETUP = 'welcome_envoy_setup';
const ONBOARD_ENVOY_MANUAL_SETUP = 'welcome_envoy_manual_setup';
const ONBOARD_ENVOY_MAGIC_SETUP = 'welcome_envoy_magic_setup';
const ONBOARD_ENVOY_MAGIC_GENERATE_SETUP = 'welcome_envoy_magic_generate_setup';
const ONBOARD_ENVOY_MAGIC_RECOVER_SETUP = 'welcome_envoy_magic_recover_setup';
const ONBOARD_ENVOY_MAGIC_RECOVER_INFO = 'welcome_envoy_magic_recovery_info';
const ONBOARD_ENVOY_MAGIC_WALLET_READY = 'welcome_envoy_magic_wallet_ready';

final onboardRoutes = GoRoute(
  path: ROUTE_SPLASH,
  routes: [
    GoRoute(
      path: "device",
      redirect: (context, state) {
        if (LocalStorage().prefs.getBool(PREFS_ONBOARDED) != true) {
          return state.namedLocation(ONBOARD_PRIVACY_SETUP,
              queryParameters: {"redirect": ONBOARD_PASSPORT_SETUP});
        }
        return null;
      },
      name: ONBOARD_PASSPORT_SETUP,
      builder: (context, state) => const OnboardPassportWelcomeScreen(),
    ),
    GoRoute(
      path: "wallet",
      redirect: (context, state) {
        if (LocalStorage().prefs.getBool(PREFS_ONBOARDED) != true) {
          return state.namedLocation(ONBOARD_PRIVACY_SETUP,
              queryParameters: {"redirect": ONBOARD_ENVOY_SETUP});
        }
        return null;
      },
      name: ONBOARD_ENVOY_SETUP,
      routes: [
        GoRoute(
          path: "manual",
          name: ONBOARD_ENVOY_MANUAL_SETUP,
          builder: (context, state) => const ManualSetup(),
        ),
        GoRoute(
          path: "magic",
          name: ONBOARD_ENVOY_MAGIC_SETUP,
          routes: [
            GoRoute(
              path: "generate",
              name: ONBOARD_ENVOY_MAGIC_GENERATE_SETUP,
              builder: (context, state) => const MagicSetupGenerate(),
            ),
            GoRoute(
              path: "recover",
              name: ONBOARD_ENVOY_MAGIC_RECOVER_SETUP,
              builder: (context, state) => const MagicRecoverWallet(),
            ),
            GoRoute(
              path: "recovery_info",
              name: ONBOARD_ENVOY_MAGIC_RECOVER_INFO,
              builder: (context, state) {
                return MagicRecoveryInfo(
                    skipSuccessScreen:
                        state.uri.queryParameters.containsKey("skip"));
              },
            ),
            GoRoute(
              path: "success",
              name: ONBOARD_ENVOY_MAGIC_WALLET_READY,
              builder: (context, state) {
                return const WalletSetupSuccess();
              },
            )
          ],
          builder: (context, state) => const MagicSetupTutorial(),
        ),
      ],
      builder: (context, state) => const OnboardEnvoyWelcomeScreen(),
    ),
    GoRoute(
      path: "privacy",
      name: ONBOARD_PRIVACY_SETUP,
      builder: (context, state) {
        return const OnboardPrivacySetup(setUpEnvoyWallet: false);
      },
    ),
  ],
  builder: (context, state) => const WelcomeScreen(),
);
