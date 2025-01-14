// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/home/settings/backup/erase_warning.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/pages/pp/pp_setup_intro.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/ui/routes/home_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const ROUTE_SPLASH = 'onboard';
const WALLET_SUCCESS = "wallet_ready";
const SEED_INTRO = "seed_intro";
const WALLET_BACKUP_WARNING = "backup_warning";
const PASSPORT_INTRO = "passport_intro";
const PREFS_ONBOARDED = 'onboarded';

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
  debugLogDiagnostics: kDebugMode,

  /// this is a redirect to check if the user is onboarded or not
  /// null means no redirect
  redirect: (context, state) {
    if (state.fullPath == ROUTE_ACCOUNTS_HOME) {
      if (LocalStorage().prefs.getBool(PREFS_ONBOARDED) != true) {
        return state.namedLocation(ROUTE_SPLASH);
      } else {}
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
          if (state.uri.queryParameters.containsKey("p")) {
            return state.namedLocation(ONBOARD_PRIME);
          }
          if (LocalStorage().prefs.getBool(PREFS_ONBOARDED) != true) {
            return ROUTE_SPLASH;
          } else {
            return ROUTE_ACCOUNTS_HOME;
          }
        }),
    fwRoutes,
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
        })
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
