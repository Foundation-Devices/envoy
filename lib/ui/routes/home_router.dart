// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/activity/activity_card.dart';
import 'package:envoy/ui/home/cards/learn/learn_card.dart';
import 'package:envoy/ui/home/cards/privacy/privacy_card.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const ROUTE_PRIVACY = '/privacy';
const ROUTE_ACTIVITY = '/activity';
const ROUTE_LEARN = '/learn';

/// home router is responsible for showing shell like ui ( bottom navigation with center widget that changes based on the selected tab)
/// in order to maintain the state of the selected tab we use StatefulShellRoute
/// this will keep the state of the selected tab even if the user navigated to a nested route
final homeRouter = StatefulShellRoute.indexedStack(
    restorationScopeId: "homeShellNavRoot",
    parentNavigatorKey: mainNavigatorKey,
    builder: (context, state, navigationShell) {
      return HomePage(mainNavigationShell: navigationShell);
    },
    branches: <StatefulShellBranch>[
      devicesRouter,
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
        ),
      ]),
      StatefulShellBranch(restorationScopeId: 'learnScopeId', routes: [
        GoRoute(
          path: ROUTE_LEARN,
          pageBuilder: (context, state) => MaterialPage(child: LearnCard()),
        ),
      ]),
    ]);
