// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'dart:async';
import 'dart:typed_data';

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:qlv2/qlv2.dart' as qlv2;

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
    final v2 = qlConnection.v2Handler;
    if (v2 != null) {
      final response = await v2.requestSignPsbt(
        accountId: accountId,
        psbt: psbt,
      );
      switch (response) {
        case qlv2.SignPsbtResponse_Signed(:final psbt):
          _txBroadcast.add(
            api.QuantumLinkMessage_BroadcastTransaction(
              api.BroadcastTransaction(accountId: accountId, psbt: psbt),
            ),
          );
        case qlv2.SignPsbtResponse_Rejected():
          throw StateError('Passport rejected the signing request');
        case qlv2.SignPsbtResponse_Error(:final error):
          throw StateError('Passport signing failed: $error');
      }
      return;
    }
    await qlConnection.writeMessage(
      api.QuantumLinkMessage.signPsbt(
        api.SignPsbt(psbt: psbt, accountId: accountId),
      ),
    );
  }

  @override
  void dispose() {
    _txBroadcast.close();
    super.dispose();
  }
}
