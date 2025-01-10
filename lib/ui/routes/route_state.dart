// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ui/routes/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

StreamController<RouteMatchList> routeStreamController =
    StreamController<RouteMatchList>.broadcast();

void listenToRouteChanges() {
  mainRouter.routerDelegate.addListener(() {
    routeStreamController.sink
        .add(mainRouter.routerDelegate.currentConfiguration);
  });
}

final _routerStreamProvider =
    StreamProvider((ref) => routeStreamController.stream);

/// Returns the current route path.
final routePathProvider = Provider<String>((ref) {
  RouteMatchList paths = ref.watch(_routerStreamProvider).value ??
      mainRouter.routerDelegate.currentConfiguration;
  return paths.fullPath;
});

/// Returns a list of all the matched paths in the current route.
/// this is useful for checking nested routes state.
final routeMatchListProvider = Provider<List<String>>((ref) {
  RouteMatchList paths = ref.watch(_routerStreamProvider).value ??
      mainRouter.routerDelegate.currentConfiguration;
  return paths.matches.map((e) => e.matchedLocation).toSet().toList();
});
