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

final routePathProvider = Provider<String>((ref) {
  RouteMatchList paths = ref.watch(_routerStreamProvider).value ??
      mainRouter.routerDelegate.currentConfiguration;
  return paths.fullPath;
});
