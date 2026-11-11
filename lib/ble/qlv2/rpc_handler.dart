// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:async/async.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

abstract class QLV2RpcHandler {
  bool canHandle(qlv2.InboundRpc rpc);

  Future<void> handleRpc(qlv2.InboundRpc rpc, QLConnection device);

  void dispose() {}
}

abstract interface class QLV2DisposableHandler {
  void dispose();
}

abstract interface class QLV2RequestHandler<T extends qlv2.InboundRpc> {
  Future<void> handleRequest(T rpc, QLConnection device);
}

abstract interface class QLV2NotificationHandler<T extends qlv2.InboundRpc> {
  Future<void> handleNotification(T rpc, QLConnection device);
}

abstract interface class QLV2DuplexHandler<InboundEvent, OutboundEvent> {
  Future<void> handleDuplex(
    QLV2DuplexSession<InboundEvent, OutboundEvent> duplex,
    QLConnection device,
  );
}

abstract interface class QLV2DuplexRpcHandler<
    T extends qlv2.InboundRpc,
    InboundEvent,
    OutboundEvent> implements QLV2DuplexHandler<InboundEvent, OutboundEvent> {
  QLV2DuplexSession<InboundEvent, OutboundEvent> createSession(T rpc);
}

class QLV2DuplexSession<InboundEvent, OutboundEvent> {
  QLV2DuplexSession({
    required Stream<InboundEvent> Function() listen,
    required Future<void> Function(OutboundEvent event) send,
    required Future<void> Function() finish,
  })  : _listen = listen,
        _send = send,
        _finish = finish;

  final Stream<InboundEvent> Function() _listen;
  final Future<void> Function(OutboundEvent event) _send;
  final Future<void> Function() _finish;

  StreamQueue<InboundEvent>? _events;
  bool _finished = false;

  StreamQueue<InboundEvent> get events {
    return _events ??= StreamQueue(_listen());
  }

  Future<void> send(OutboundEvent event) {
    if (_finished) {
      throw StateError('Cannot send on a finished QL v2 duplex session');
    }
    return _send(event);
  }

  Future<void> finish() async {
    if (_finished) {
      return;
    }
    await _finish();
    _finished = true;
  }

  Future<void> dispose() async {
    await _events?.cancel();
    if (_finished) {
      return;
    }
    try {
      await finish();
    } catch (_) {
      // The transport may already have closed or the remote may have finished.
    }
  }
}

abstract interface class QLV2DownloadHandler<T extends qlv2.InboundRpc> {
  Future<void> handleDownload(T rpc, QLConnection device);
}

abstract interface class QLV2UploadHandler<T extends qlv2.InboundRpc> {
  Future<void> handleUpload(T rpc, QLConnection device);
}

abstract interface class QLV2SubscriptionHandler<T extends qlv2.InboundRpc> {
  Future<void> handleSubscription(T rpc, QLConnection device);
}

abstract interface class QLV2SessionEventHandler<T> {
  Future<void> handleEvent(T event, QLConnection device);
}
