// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'dart:async';

import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:foundation_api/foundation_api.dart' as api;

/// Handler for incoming `api.QuantumLinkMessage`.
/// Implement `canHandle` and `handle`.
abstract class PassportMessageHandler {
  final QLConnection qlConnection;
  PassportMessageHandler(this.qlConnection);

  Future<void> handleMessage(
      api.QuantumLinkMessage message);

  /// Return true if this handler should receive [message].
  bool canHandle(api.QuantumLinkMessage message);

  ///
  void onDeviceStatus(api.DeviceStatus status) {}
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
  final List<PassportMessageHandler> _qlHandlers = [];

  void registerHandler(PassportMessageHandler handler) {
    _qlHandlers.add(handler);
  }

  Future<void> dispatch(api.PassportMessage message) async {
    final qMessage = message.message;
    for (final handler in _qlHandlers) {
      if (handler.canHandle(qMessage)) {
        kPrint(
            "Handler ${handler.runtimeType} CAN handle message ${(qMessage.runtimeType)}");
        try {
          //allows multiple handlers to handle same types
          unawaited(handler.handleMessage(qMessage));
        } catch (e, stack) {
          debugPrintStack(stackTrace: stack);
          kPrint("Error handling message ${message.runtimeType}: $e");
        }
        try {
          //handlers who wants to know device status
          handler.onDeviceStatus(message.status);
        } catch (e) {
          // kPrint("Error handling message ${message.runtimeType}: $e");
        }
      }
    }
  }
}
