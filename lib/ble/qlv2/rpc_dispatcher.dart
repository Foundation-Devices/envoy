// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/rpc_handler.dart';
import 'package:envoy/ble/qlv2/rpc_route.dart';
import 'package:envoy/ble/qlv2/rpc_router.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

export 'package:envoy/ble/qlv2/rpc_handler.dart';
export 'package:envoy/ble/qlv2/rpc_route.dart';
export 'package:envoy/ble/qlv2/rpc_router.dart';

typedef QLV2UnhandledRpcCallback = void Function(qlv2.InboundRpc rpc);

class QLV2RpcRegistration {
  QLV2RpcRegistration._(this._dispose);

  final void Function() _dispose;
  bool _disposed = false;

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _dispose();
  }
}

class QLV2RpcDispatcher {
  QLV2RpcDispatcher({
    QLV2UnhandledRpcCallback? onUnhandledRpc,
    bool logUnhandledRpcs = true,
  })  : _onUnhandledRpc = onUnhandledRpc,
        _logUnhandledRpcs = logUnhandledRpcs;

  final List<_QLV2RouteRegistration> _registrations = [];
  final Map<QLV2RpcHandler, QLV2RpcRegistration> _legacyHandlers = {};
  final QLV2UnhandledRpcCallback? _onUnhandledRpc;
  final bool _logUnhandledRpcs;

  bool _disposed = false;

  List<QLV2RpcRoute> get routes {
    return List.unmodifiable(
      _registrations.expand((registration) => registration.routes),
    );
  }

  List<QLV2RpcHandler> get handlers {
    return List.unmodifiable(_legacyHandlers.keys);
  }

  QLV2RpcRegistration registerRoutes(QLV2RpcRouter router) {
    if (_disposed) {
      throw StateError('Cannot register QL v2 RPC routes after dispose');
    }

    final registration = _QLV2RouteRegistration(router.routes);
    _registrations.add(registration);

    return QLV2RpcRegistration._(() {
      if (_registrations.remove(registration)) {
        registration.dispose();
      }
    });
  }

  void registerHandler(QLV2RpcHandler handler) {
    if (_legacyHandlers.containsKey(handler)) {
      return;
    }

    final registration = registerRoutes(
      QLV2RpcRouter.builder()
          .legacyHandler(handler, debugName: handler.runtimeType.toString())
          .build(),
    );
    _legacyHandlers[handler] = registration;
  }

  bool unregisterHandler(QLV2RpcHandler handler) {
    final registration = _legacyHandlers.remove(handler);
    if (registration == null) {
      return false;
    }
    registration.dispose();
    return true;
  }

  Future<bool> dispatch(qlv2.InboundRpc rpc, QLConnection device) async {
    if (_disposed) {
      kPrint('Cannot dispatch QL v2 RPC after dispatcher dispose');
      return false;
    }

    final registrations = List<_QLV2RouteRegistration>.of(_registrations);
    final matches = <QLV2RpcRoute>[];

    for (final registration in registrations.reversed) {
      for (final route in registration.routes) {
        if (_routeMatches(route, rpc)) {
          matches.add(route);
        }
      }
    }

    if (matches.isEmpty) {
      _handleUnhandledRpc(rpc);
      return false;
    }

    final notificationRoutes =
        matches.where((route) => route.isNotification).toList();
    final singleConsumerRoutes =
        matches.where((route) => route.isSingleConsumer).toList();

    if (singleConsumerRoutes.isNotEmpty) {
      if (singleConsumerRoutes.length > 1) {
        _logDuplicateSingleConsumerRoutes(rpc, singleConsumerRoutes);
      }
      await _dispatchRoute(singleConsumerRoutes.first, rpc, device);
      return true;
    }

    for (final route in notificationRoutes) {
      await _dispatchRoute(route, rpc, device);
    }
    return true;
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;

    for (final registration in List<_QLV2RouteRegistration>.of(
      _registrations,
    )) {
      registration.dispose();
    }
    _registrations.clear();
    _legacyHandlers.clear();
  }

  bool _routeMatches(
    QLV2RpcRoute route,
    qlv2.InboundRpc rpc,
  ) {
    try {
      return route.matches(rpc);
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      kPrint(
        'QL v2 route ${route.label} failed matching ${rpc.runtimeType}: $e',
      );
      return false;
    }
  }

  Future<void> _dispatchRoute(
    QLV2RpcRoute route,
    qlv2.InboundRpc rpc,
    QLConnection device,
  ) async {
    try {
      await route.dispatch(rpc, device);
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      kPrint(
        'QL v2 route ${route.label} failed handling ${rpc.runtimeType}: $e',
      );
    }
  }

  void _logDuplicateSingleConsumerRoutes(
    qlv2.InboundRpc rpc,
    List<QLV2RpcRoute> routes,
  ) {
    final labels = routes.map((route) => route.label).join(', ');
    kPrint(
      'QL v2 RPC ${rpc.runtimeType} matched multiple single-consumer '
      'routes; dispatching to newest route only: $labels',
    );
  }

  void _handleUnhandledRpc(qlv2.InboundRpc rpc) {
    final callback = _onUnhandledRpc;
    if (callback != null) {
      try {
        callback(rpc);
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
        kPrint(
          'QL v2 unhandled RPC callback failed for ${rpc.runtimeType}: $e',
        );
      }
      return;
    }

    if (_logUnhandledRpcs) {
      kPrint('Unhandled QL v2 RPC: ${rpc.runtimeType}');
    }
  }
}

extension _QLV2LegacyHandlerRouterBuilder on QLV2RpcRouterBuilder {
  QLV2RpcRouterBuilder legacyHandler(
    QLV2RpcHandler handler, {
    String? debugName,
  }) {
    addRoute(_QLV2LegacyHandlerRoute(handler, debugName: debugName));
    return this;
  }
}

class _QLV2LegacyHandlerRoute implements QLV2RpcRoute {
  _QLV2LegacyHandlerRoute(this._handler, {this.debugName});

  final QLV2RpcHandler _handler;

  @override
  final String? debugName;

  @override
  QLV2RpcKind get kind => QLV2RpcKind.request;

  @override
  Type get rpcType => qlv2.InboundRpc;

  @override
  bool get isNotification => false;

  @override
  bool get isSingleConsumer => true;

  @override
  String get label => debugName ?? _handler.runtimeType.toString();

  @override
  bool matches(qlv2.InboundRpc rpc) => _handler.canHandle(rpc);

  @override
  Future<void> dispatch(qlv2.InboundRpc rpc, QLConnection device) {
    return _handler.handleRpc(rpc, device);
  }

  @override
  void disposeHandler() => _handler.dispose();
}

class _QLV2RouteRegistration {
  _QLV2RouteRegistration(this.routes);

  final List<QLV2RpcRoute> routes;
  bool _disposed = false;

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;

    for (final route in routes) {
      try {
        route.disposeHandler();
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
        kPrint('QL v2 route ${route.label} dispose failed: $e');
      }
    }
  }
}
