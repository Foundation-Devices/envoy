// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';

abstract final class QLV2RouteScopes {
  static const global = 'global';
  static const primeOnboarding = 'prime_onboarding';
  static const spend = 'spend';
}

class QLV2RouteScope {
  QLV2RouteScope._({
    required this.name,
    QLV2RpcRegistration? registration,
  }) : _registration = registration;

  final String name;
  final QLV2RpcRegistration? _registration;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _disposed = false;

  bool get isDisposed => _disposed;

  void replaceSubscriptions(
    Iterable<StreamSubscription<dynamic>> subscriptions,
  ) {
    if (_disposed) {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
      return;
    }
    disposeSubscriptions();
    _subscriptions.addAll(subscriptions);
  }

  void disposeSubscriptions() {
    for (final subscription in List<StreamSubscription<dynamic>>.of(
      _subscriptions,
    )) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _registration?.dispose();
    disposeSubscriptions();
  }
}

class QLV2SessionController {
  QLV2SessionController(this._dispatcher);

  final QLV2RpcDispatcher _dispatcher;
  final Map<String, QLV2RouteScope> _scopes = {};
  bool _disposed = false;

  QLV2RouteScope registerScope(
    String name,
    QLV2RpcRouter router,
  ) {
    if (_disposed) {
      throw StateError('Cannot register QL v2 route scope after dispose');
    }

    disposeScope(name);

    final scope = QLV2RouteScope._(
      name: name,
      registration: _dispatcher.registerRoutes(router),
    );
    _scopes[name] = scope;
    return scope;
  }

  QLV2RouteScope registerSubscriptions(
    String name,
    Iterable<StreamSubscription<dynamic>> subscriptions,
  ) {
    if (_disposed) {
      throw StateError('Cannot register QL v2 subscriptions after dispose');
    }

    final scope = _scopes.putIfAbsent(
      name,
      () => QLV2RouteScope._(name: name),
    );
    scope.replaceSubscriptions(subscriptions);
    return scope;
  }

  bool disposeSubscriptions(String name) {
    final scope = _scopes[name];
    if (scope == null) {
      return false;
    }
    scope.disposeSubscriptions();
    return true;
  }

  bool disposeScope(String name) {
    final scope = _scopes.remove(name);
    if (scope == null) {
      return false;
    }
    scope.dispose();
    return true;
  }

  QLV2RouteScope? scope(String name) => _scopes[name];

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final scope in List<QLV2RouteScope>.of(_scopes.values)) {
      scope.dispose();
    }
    _scopes.clear();
  }
}
