// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;

class BlePassphraseHandler extends PassportMessageHandler {
  final StreamController<api.ApplyPassphrase> _passphraseEventController;

  BlePassphraseHandler(
    super.writer,
    this._passphraseEventController,
  );

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_ApplyPassphrase;
  }

  @override
  Future<void> handleMessage(
      api.QuantumLinkMessage message, String bleId) async {
    if (message case api.QuantumLinkMessage_ApplyPassphrase applyPassphrase) {
      kPrint(
          "Got ApplyPassphrase message: fingerprint=${applyPassphrase.field0.fingerprint}");
      _handleApplyPassphrase(applyPassphrase.field0);
    }
  }

  void _handleApplyPassphrase(api.ApplyPassphrase applyPassphrase) async {
    final fingerprint = applyPassphrase.fingerprint;

    if (fingerprint != null) {
      kPrint("Prime has applied passphrase with XFP: $fingerprint");
    } else {
      kPrint("Prime has cleared passphrase");
    }

    // Emit event through stream for UI to react
    _passphraseEventController.add(applyPassphrase);
  }
}
