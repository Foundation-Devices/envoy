// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/rpc_handler.dart';
import 'package:envoy/ble/qlv2/rpc_route.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2RpcRouter {
  QLV2RpcRouter._(List<QLV2RpcRoute> routes)
      : routes = List.unmodifiable(routes);

  final List<QLV2RpcRoute> routes;

  static QLV2RpcRouterBuilder builder() => QLV2RpcRouterBuilder();
}

class QLV2RpcRouterBuilder {
  final List<QLV2RpcRoute> _routes = [];

  void addRoute(QLV2RpcRoute route) {
    _addRoute(route);
  }

  QLV2RpcRouterBuilder request<T extends qlv2.InboundRpc>(
    QLV2RequestHandler<T> handler, {
    String? debugName,
  }) {
    _addRoute(
      QLV2TypedRpcRoute<T>(
        kind: QLV2RpcKind.request,
        handle: handler.handleRequest,
        handler: handler,
        debugName: debugName,
      ),
    );
    return this;
  }

  QLV2RpcRouterBuilder notification<T extends qlv2.InboundRpc>(
    QLV2NotificationHandler<T> handler, {
    String? debugName,
  }) {
    _addRoute(
      QLV2TypedRpcRoute<T>(
        kind: QLV2RpcKind.notification,
        handle: handler.handleNotification,
        handler: handler,
        debugName: debugName,
      ),
    );
    return this;
  }

  QLV2RpcRouterBuilder
      duplex<T extends qlv2.InboundRpc, InboundEvent, OutboundEvent>(
    QLV2DuplexHandler<InboundEvent, OutboundEvent> handler, {
    required QLV2DuplexSession<InboundEvent, OutboundEvent> Function(T rpc)
        createSession,
    String? debugName,
  }) {
    _addRoute(
      QLV2TypedRpcRoute<T>(
        kind: QLV2RpcKind.duplex,
        handle: (rpc, device) async {
          final session = createSession(rpc);
          try {
            await handler.handleDuplex(session, device);
          } finally {
            await session.dispose();
          }
        },
        handler: handler,
        debugName: debugName,
      ),
    );
    return this;
  }

  QLV2RpcRouterBuilder
      duplexRpc<T extends qlv2.InboundRpc, InboundEvent, OutboundEvent>(
    QLV2DuplexRpcHandler<T, InboundEvent, OutboundEvent> handler, {
    String? debugName,
  }) {
    return duplex<T, InboundEvent, OutboundEvent>(
      handler,
      createSession: handler.createSession,
      debugName: debugName,
    );
  }

  QLV2RpcRouterBuilder download<T extends qlv2.InboundRpc>(
    QLV2DownloadHandler<T> handler, {
    String? debugName,
  }) {
    _addRoute(
      QLV2TypedRpcRoute<T>(
        kind: QLV2RpcKind.download,
        handle: handler.handleDownload,
        handler: handler,
        debugName: debugName,
      ),
    );
    return this;
  }

  QLV2RpcRouterBuilder upload<T extends qlv2.InboundRpc>(
    QLV2UploadHandler<T> handler, {
    String? debugName,
  }) {
    _addRoute(
      QLV2TypedRpcRoute<T>(
        kind: QLV2RpcKind.upload,
        handle: handler.handleUpload,
        handler: handler,
        debugName: debugName,
      ),
    );
    return this;
  }

  QLV2RpcRouterBuilder subscription<T extends qlv2.InboundRpc>(
    QLV2SubscriptionHandler<T> handler, {
    String? debugName,
  }) {
    _addRoute(
      QLV2TypedRpcRoute<T>(
        kind: QLV2RpcKind.subscription,
        handle: handler.handleSubscription,
        handler: handler,
        debugName: debugName,
      ),
    );
    return this;
  }

  void _addRoute(QLV2RpcRoute route) {
    if (route.isSingleConsumer) {
      for (final existingRoute in _routes) {
        if (existingRoute.isSingleConsumer &&
            existingRoute.rpcType == route.rpcType) {
          throw StateError(
            'Duplicate QLv2 ${route.kind.name} handler for '
            '${route.rpcType}: existing=${existingRoute.label}, '
            'new=${route.label}',
          );
        }
      }
    }

    _routes.add(route);
  }

  QLV2RpcRouter build() => QLV2RpcRouter._(_routes);
}
