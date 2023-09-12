import 'package:envoy/ui/home/cards/activity/activity_card.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:envoy/ui/home/cards/learn/learn_card.dart';
import 'package:envoy/ui/home/cards/privacy/privacy_card.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const ROUTE_DEVICES = '/devices';
const ROUTE_PRIVACY = '/privacy';
const ROUTE_ACTIVITY = '/activity';
const ROUTE_LEARN = '/learn';

final homeRouter = StatefulShellRoute.indexedStack(
    restorationScopeId: "homeShellNavRoot",
    parentNavigatorKey: mainNavigatorKey,
    builder: (context, state, navigationShell) {
      return HomePage(mainNavigationShell: navigationShell);
    },
    branches: <StatefulShellBranch>[
      StatefulShellBranch(restorationScopeId: 'devicesScopeId', routes: [
        GoRoute(
          path: ROUTE_DEVICES,
          pageBuilder: (context, state) => MaterialPage(child: DevicesCard()),
        ),
      ]),
      StatefulShellBranch(restorationScopeId: "privacyScopeId", routes: [
        GoRoute(
          path: ROUTE_PRIVACY,
          pageBuilder: (context, state) => MaterialPage(child: PrivacyCard()),
        ),
      ]),
      accountsRouter,
      StatefulShellBranch(restorationScopeId: 'activityScopeId', routes: [
        GoRoute(
          path: ROUTE_ACTIVITY,
          pageBuilder: (context, state) => MaterialPage(child: ActivityCard()),
          //
          // builder: (context, state) => LearnCard(),
        ),
      ]),
      StatefulShellBranch(restorationScopeId: 'learnScopeId', routes: [
        GoRoute(
          path: ROUTE_LEARN,
          pageBuilder: (context, state) => MaterialPage(child: LearnCard()),
        ),
      ]),
    ]);
