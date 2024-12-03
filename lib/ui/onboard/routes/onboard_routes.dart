// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/onboard/magic/magic_recover_wallet.dart';
import 'package:envoy/ui/onboard/magic/magic_setup_generate.dart';
import 'package:envoy/ui/onboard/magic/magic_setup_tutorial.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_import_backup.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_import_seed.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboard_privacy_setup.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/onboard/onboard_welcome_envoy.dart';
import 'package:envoy/ui/onboard/onboard_welcome_passport.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_scan.dart';
import 'package:envoy/ui/pages/legal/passport_tou.dart';
import 'package:envoy/ui/pages/wallet/single_wallet_pair_success.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/wallet.dart';

/*
* named onboarding routes
* use goNamed
*/
const ONBOARD_PRIVACY_SETUP = 'welcome_privacy_setup';

const ONBOARD_PASSPORT_SETUP = 'welcome_passport_setup';
const ONBOARD_PASSPORT_NEW = 'welcome_passport_new';
const ONBOARD_PASSPORT_TOU = 'welcome_passport_tou';
const ONBOARD_PASSPORT_SCV_SUCCESS = 'welcome_passport_scv_success';
const ONBOARD_PASSPORT_SCV_QR = 'welcome_passport_scv_qr';
const ONBOARD_PASSPORT_SCV_SCAN = 'welcome_passport_scv_scan';

const ONBOARD_PASSPORT_EXISTING = 'welcome_passport_exist';
const ONBOARD_PASSPORT_EXISTING_SCAN = 'welcome_passport_exist_scan';

const ONBOARD_ENVOY_SETUP = 'welcome_envoy_setup';
const ONBOARD_ENVOY_MANUAL_SETUP = 'welcome_envoy_manual_setup';
const ONBOARD_ENVOY_MANUAL_IMPORT = 'welcome_envoy_manual_import';
const ONBOARD_ENVOY_MANUAL_IMPORT_12 = 'welcome_envoy_manual_import_12';
const ONBOARD_ENVOY_MANUAL_IMPORT_24 = 'welcome_envoy_manual_import_24';
const ONBOARD_ENVOY_MANUAL_IMPORT_SEED = 'welcome_envoy_manual_import_seed';

const ONBOARD_ENVOY_MANUAL_GENERATE = 'welcome_envoy_manual_generate';
const ONBOARD_ENVOY_MAGIC_SETUP = 'welcome_envoy_magic_setup';
const ONBOARD_ENVOY_MAGIC_GENERATE_SETUP = 'welcome_envoy_magic_generate_setup';
const ONBOARD_ENVOY_MAGIC_RECOVER_SETUP = 'welcome_envoy_magic_recover_setup';
const ONBOARD_ENVOY_MAGIC_RECOVER_INFO = 'welcome_envoy_magic_recovery_info';
const ONBOARD_ENVOY_MAGIC_WALLET_READY = 'welcome_envoy_magic_wallet_ready';

final onboardRoutes = GoRoute(
  path: "/onboard",
  name: ROUTE_SPLASH,
  routes: [
    primeRoutes,
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
      routes: [
        GoRoute(
          path: "tou",
          name: ONBOARD_PASSPORT_TOU,
          builder: (context, state) => const TouPage(),
        ),
        GoRoute(
          path: "scv_success",
          name: ONBOARD_PASSPORT_SCV_SUCCESS,
          builder: (context, state) =>
              SingleWalletPairSuccessPage(state.extra as Wallet),
        ),
        GoRoute(
          path: "pair",
          name: ONBOARD_PASSPORT_EXISTING,
          routes: [
            GoRoute(
                path: "scan",
                builder: (context, state) => const SingleImportPpScanPage(),
                name: ONBOARD_PASSPORT_EXISTING_SCAN)
          ],
          builder: (context, state) => const SingleImportPpIntroPage(),
        ),
      ],
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
          routes: [
            GoRoute(
              path: "generate",
              name: ONBOARD_ENVOY_MANUAL_GENERATE,
              builder: (context, state) =>
                  const SeedIntroScreen(mode: SeedIntroScreenType.generate),
            ),
            GoRoute(
              path: "import",
              name: ONBOARD_ENVOY_MANUAL_IMPORT,
              routes: [
                GoRoute(
                  path: "12",
                  name: ONBOARD_ENVOY_MANUAL_IMPORT_12,
                  builder: (context, state) {
                    return const ManualSetupImportSeed(
                      seedLength: SeedLength.mnemonic_12,
                    );
                  },
                ),
                GoRoute(
                  path: "24",
                  name: ONBOARD_ENVOY_MANUAL_IMPORT_24,
                  builder: (context, state) {
                    return const ManualSetupImportSeed(
                      seedLength: SeedLength.mnemonic_24,
                    );
                  },
                ),
                GoRoute(
                  path: "seed",
                  name: ONBOARD_ENVOY_MANUAL_IMPORT_SEED,
                  builder: (context, state) {
                    return RecoverFromSeedLoader(
                      seed: state.extra as String,
                    );
                  },
                ),
              ],
              builder: (context, state) =>
                  const SeedIntroScreen(mode: SeedIntroScreenType.import),
            ),
          ],
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
