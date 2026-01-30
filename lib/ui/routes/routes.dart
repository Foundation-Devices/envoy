// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/business/bip21.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/home/cards/accounts/spend/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/send_qr_review.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/home/settings/backup/erase_warning.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/pages/legal/passport_tou.dart';
import 'package:envoy/ui/pages/pp/pp_setup_intro.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/ui/routes/home_router.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

const ROUTE_SPLASH = 'onboard';
const WALLET_SUCCESS = "wallet_ready";
const SEED_INTRO = "seed_intro";
const WALLET_BACKUP_WARNING = "backup_warning";
const PASSPORT_INTRO = "passport_intro";
const PREFS_ONBOARDED = 'onboarded';
const PSBT_QR_EXCHANGE_STANDALONE = '"psbt_qr_exchange';
const TOU_EXTERNAL = 'tou_external';
const PSBT_SCAN_QR = 'psbt_scan_qr';

/// this key can be used in nested GoRoute to leverage main router
/// for example:
/// GoRoute( path: "account/details/new",parentNavigatorKey: mainNavigatorKey)
/// here even if the route is nested it will use root navigator to show the widget
final GlobalKey<NavigatorState> mainNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: "rootNavigator");

/// The main router for the app.
/// all the routes defined here will take the whole screen
final GoRouter mainRouter = GoRouter(
  navigatorKey: mainNavigatorKey,
  initialLocation: ROUTE_ACCOUNTS_HOME,
  debugLogDiagnostics: true,
  onException: (context, state, router) {
    try {
      final uri = GoRouter.of(context).state.uri;
      final bip21 = Bip21.decode(uri.toString());

      ///TODO handle account selection for spend, ENV-2024
      if (context.mounted) {
        router.go(ROUTE_ACCOUNTS_HOME, extra: bip21);
      }
    } catch (e) {
      router.go(ROUTE_ACCOUNTS_HOME);
    }
  },

  /// this is a redirect to check if the user is onboarded or not
  /// null means no redirect
  redirect: (context, state) async {
    final uri = state.uri;
    // Check if this is a Bitcoin URI
    if (uri.scheme == 'bitcoin') {
      return null;
    }

    final bool isOnboardingComplete =
        LocalStorage().prefs.getBool(PREFS_ONBOARDED) ?? false;

    // If user tries to access home but hasn't onboarded yet → redirect to onboarding
    if (state.fullPath == ROUTE_ACCOUNTS_HOME && !isOnboardingComplete) {
      await WakelockPlus.enable(); // keep screen awake during onboarding
      isCurrentlyOnboarding = true;
      return state.namedLocation(ROUTE_SPLASH);
    }

    // If user has completed onboarding and goes to home → disable wakelock
    if (isOnboardingComplete && state.fullPath == ROUTE_ACCOUNTS_HOME) {
      isCurrentlyOnboarding = false;
      await WakelockPlus.disable();
    }

    return null;
  },
  routes: <RouteBase>[
    onboardRoutes,
    homeRouter,
    GoRoute(
      path: "/",
      name: "/",
      redirect: (context, state) {
        final params = state.uri.queryParameters;
        //resets any home shell navs
        try {
          ProviderScope.containerOf(context)
              .read(homePageBackgroundProvider.notifier)
              .state = HomePageBackgroundState.hidden;
        } catch (e) {
          kPrint("Could not reset home shell nav state: $e");
        }

        if (params.containsKey("p")) {
          WakelockPlus.enable();
          isCurrentlyOnboarding = true;
          return state.namedLocation(ONBOARD_PRIME, queryParameters: params);
        }

        if (params.containsKey("t")) {
          WakelockPlus.enable();
          isCurrentlyOnboarding = true;
          return state.namedLocation(TOU_EXTERNAL, queryParameters: params);
        }

        if (LocalStorage().prefs.getBool(PREFS_ONBOARDED) != true) {
          isCurrentlyOnboarding = true;
          return ROUTE_SPLASH;
        } else {
          isCurrentlyOnboarding = false;
          return ROUTE_ACCOUNTS_HOME;
        }
      },
    ),
    fwRoutes,
    GoRoute(
      path: "/tou_external",
      name: TOU_EXTERNAL,
      builder: (context, state) => const TouPage(
        fromExternal: true,
      ),
    ),
    GoRoute(
      path: "/passport_intro",
      name: PASSPORT_INTRO,
      builder: (context, state) => const PpSetupIntroPage(),
    ),
    GoRoute(
      path: "/wallet_success",
      name: WALLET_SUCCESS,
      builder: (context, state) => const WalletSetupSuccess(),
    ),
    GoRoute(
      path: "/android_backup_warning",
      name: WALLET_BACKUP_WARNING,
      builder: (context, state) {
        return AndroidBackupWarning(skipSuccess: state.extra as bool);
      },
    ),
    GoRoute(
        path: "/seed_intro",
        name: SEED_INTRO,
        builder: (context, state) {
          var type = SeedIntroScreenType.verify;
          for (var element in SeedIntroScreenType.values) {
            if (element.toString() == state.extra) {
              type = element;
            }
          }
          return SeedIntroScreen(
            mode: type,
          );
        }),
    GoRoute(
        path: "/psbt_qr_exchange",
        name: PSBT_QR_EXCHANGE_STANDALONE,
        builder: (context, state) {
          return Stack(
            children: [
              const Positioned.fill(
                  child: AppBackground(
                showRadialGradient: true,
              )),
              Positioned(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 8),
                        child: Shield(
                          child:
                              PsbtCard(state.extra as DraftTransaction, true),
                        )),
                  ),
                ),
              ),
            ],
          );
        },
        routes: [
          GoRoute(
            name: PSBT_SCAN_QR,
            path: "qr_review",
            pageBuilder: (context, state) {
              return wrapWithEnvoyPageAnimation(
                  child: Stack(
                children: [
                  const Positioned.fill(
                      child: AppBackground(
                    showRadialGradient: true,
                  )),
                  Positioned(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: SafeArea(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 8),
                            child: Shield(
                              child:
                                  SendQrReview(state.extra as DraftTransaction),
                            )),
                      ),
                    ),
                  ),
                ],
              ));
            },
          )
        ]),
  ],
);

///important to keep this in sync with the routes in home_router.dart
///routes order is important, this will be used to determine the index of the bottom navigation bar
final homeTabRoutes = [
  ROUTE_DEVICES,
  ROUTE_PRIVACY,
  ROUTE_ACCOUNTS_HOME,
  ROUTE_ACTIVITY,
  ROUTE_LEARN,
  "/",
];

/// Any routes that required hiding bottombar and keeping the appbar
final modalModeRoutes = [
  ROUTE_ACCOUNT_SEND,
  ROUTE_ACCOUNT_RECEIVE,
  ROUTE_ACCOUNT_DESCRIPTOR,
  ROUTE_BUY_BITCOIN,
  ROUTE_PEER_TO_PEER,
  ROUTE_SELECT_ACCOUNT,
  ROUTE_SELECT_REGION,
];

///Any routes that required the app bar and bottom navigation bar to be hidden
final hideAppBarRoutes = [
  // ROUTE_ACCOUNT_SEND,
  ROUTE_ACCOUNT_SEND_CONFIRM,
  ROUTE_ACCOUNT_SEND_REVIEW
];
