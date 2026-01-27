// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'dart:async';
import 'dart:typed_data';

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:foundation_api/foundation_api.dart' as api;

/// Handler for Tx related messages over Quantum Link.
///
class TransactionHandler extends PassportMessageHandler {
  TransactionHandler(super.connection);

  final StreamController<api.QuantumLinkMessage_BroadcastTransaction>
      _txBroadcast =
      StreamController<api.QuantumLinkMessage_BroadcastTransaction>.broadcast();

  Stream<api.QuantumLinkMessage_BroadcastTransaction> get txBroadcast =>
      _txBroadcast.stream.asBroadcastStream();

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_BroadcastTransaction;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message case api.QuantumLinkMessage_BroadcastTransaction txMessage) {
      _txBroadcast.add(txMessage);
    }
  }

  Future<void> sendPsbt(String accountId, Uint8List psbt) async {
    await qlConnection.writeMessage(api.QuantumLinkMessage.signPsbt(
        api.SignPsbt(psbt: psbt, accountId: accountId)));
  }
}
