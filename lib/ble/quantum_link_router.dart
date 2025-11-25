// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'dart:async';

import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;

/// Handler for incoming `api.QuantumLinkMessage`.
/// Implement `canHandle` and `handle`.
abstract class PassportMessageHandler {
  final EnvoyMessageWriter writer;

  PassportMessageHandler(this.writer);

  Future<void> handleMessage(api.QuantumLinkMessage message, String bleId);

  /// Return true if this handler should receive [message].
  bool canHandle(api.QuantumLinkMessage message);
}

/// Writer used by handlers to send messages to the device.
/// Implementations will be on BluethManager, can be used for testing handlers
mixin EnvoyMessageWriter {
  Future<Stream<double>> writeMessageWithProgress(
      api.QuantumLinkMessage message);

  Future<bool> writeMessage(api.QuantumLinkMessage message);
}

/// Routes messages to registered handlers.
/// Calls handlers in insertion order
/// and does not await their `handle` futures (fire-and-forget).
class PassportMessageRouter {
  final List<PassportMessageHandler> _handlers = [];

  void registerHandler(PassportMessageHandler handler) {
    _handlers.add(handler);
  }

  Future<void> dispatch(api.QuantumLinkMessage message, String bleId) async {
    for (final handler in _handlers) {
      if (handler.canHandle(message)) {
        kPrint(
            "Handler ${handler.runtimeType} CAN handle message ${message.runtimeType}");
      }
      if (handler.canHandle(message)) {
        try {
          //allows multiple handlers to handle same types
          unawaited(handler.handleMessage(message, bleId));
        } catch (e) {
          kPrint("Error handling message ${message.runtimeType}: $e");
        }
      }
    }
  }
}
