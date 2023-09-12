import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/onboard/onboard_welcome_passport.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/home_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const ROUTE_SPLASH = '/splash';
const ROUTE_ONBOARD_PASSPORT = '/onboard';
const ROUTE_ONBOARD_ENVOY = '/onboard/envoy';

final GlobalKey<NavigatorState> mainNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: "rootNavigator");

final GoRouter mainRouter = GoRouter(
  navigatorKey: mainNavigatorKey,
  initialLocation: ROUTE_ACCOUNTS_HOME,
  debugLogDiagnostics: kDebugMode,
  redirect: (context, state) {
    if (state.fullPath == ROUTE_ACCOUNTS_HOME) {
      if (LocalStorage().prefs.getBool("onboarded") != true) {
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
    ...accountFullScreenRoute,
    GoRoute(
        path: "/",
        redirect: (context, state) {
          if (LocalStorage().prefs.getBool("onboarded") != true) {
            return ROUTE_SPLASH;
          } else {
            return ROUTE_ACCOUNTS_HOME;
          }
        }),
  ],
);

final homeTabRoutes = [
  ROUTE_ACCOUNTS_HOME,
  ROUTE_PRIVACY,
  ROUTE_DEVICES,
  ROUTE_ACTIVITY,
  ROUTE_LEARN,
  "/",
];

final modalModeRoutes = [ROUTE_ACCOUNT_SEND, ROUTE_ACCOUNT_RECEIVE];
