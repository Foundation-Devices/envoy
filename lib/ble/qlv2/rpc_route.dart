// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/rpc_handler.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

enum QLV2RpcKind {
  request,
  notification,
  duplex,
  download,
  upload,
  subscription,
}

abstract interface class QLV2RpcRoute {
  QLV2RpcKind get kind;

  Type get rpcType;

  String? get debugName;

  bool get isNotification;

  bool get isSingleConsumer;

  String get label;

  bool matches(qlv2.InboundRpc rpc);

  Future<void> dispatch(qlv2.InboundRpc rpc, QLConnection device);

  void disposeHandler();
}

class QLV2TypedRpcRoute<T extends qlv2.InboundRpc> implements QLV2RpcRoute {
  QLV2TypedRpcRoute({
    required this.kind,
    required Future<void> Function(T rpc, QLConnection device) handle,
    Object? handler,
    this.debugName,
  })  : _handle = handle,
        _handler = handler;

  @override
  final QLV2RpcKind kind;

  @override
  Type get rpcType => T;

  @override
  final String? debugName;
  final Future<void> Function(T rpc, QLConnection device) _handle;
  final Object? _handler;

  @override
  bool get isNotification => kind == QLV2RpcKind.notification;

  @override
  bool get isSingleConsumer => !isNotification;

  @override
  String get label => debugName ?? _handler?.runtimeType.toString() ?? '$T';

  @override
  bool matches(qlv2.InboundRpc rpc) => rpc is T;

  @override
  Future<void> dispatch(qlv2.InboundRpc rpc, QLConnection device) {
    return _handle(rpc as T, device);
  }

  @override
  void disposeHandler() {
    final handler = _handler;
    if (handler is QLV2DisposableHandler) {
      handler.dispose();
    }
  }
}
