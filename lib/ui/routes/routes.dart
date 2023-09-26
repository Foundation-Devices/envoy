// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/ui/routes/home_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const ROUTE_SPLASH = '/splash';
const ROUTE_ONBOARD_PASSPORT = '/onboard';
const ROUTE_ONBOARD_ENVOY = '/onboard/envoy';
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
        return ROUTE_SPLASH;
      } else {}
    }
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: ROUTE_SPLASH,
      builder: (context, state) => WelcomeScreen(),
    ),
    homeRouter,
    GoRoute(
        path: "/",
        redirect: (context, state) {
          if (LocalStorage().prefs.getBool(PREFS_ONBOARDED) != true) {
            return ROUTE_SPLASH;
          } else {
            return ROUTE_ACCOUNTS_HOME;
          }
        }),
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

final modalModeRoutes = [
  ROUTE_ACCOUNT_SEND,
  ROUTE_ACCOUNT_RECEIVE,
  ROUTE_ACCOUNT_DESCRIPTOR
];

final hideAppBarRoutes = [
  // ROUTE_ACCOUNT_SEND_REVIEW,
  // ROUTE_ACCOUNT_SEND_CONFIRM,
];
