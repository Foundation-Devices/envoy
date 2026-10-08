// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2BroadcastTransactionHandler
    implements QLV2RequestHandler<qlv2.InboundRpc_BroadcastTransaction> {
  @override
  Future<void> handleRequest(
    qlv2.InboundRpc_BroadcastTransaction rpc,
    QLConnection device,
  ) async {
    final request = rpc.field0.payload;
    final account = NgAccountManager().getAccountById(request.accountId);
    if (account == null) {
      await _respondError(rpc, 'unknown_account');
      return;
    }

    final connectedDevice = device.getDevice();
    if (connectedDevice == null ||
        account.deviceSerial != connectedDevice.serial) {
      await _respondError(rpc, 'account_device_mismatch');
      return;
    }

    final settings = Settings();
    final server = settings.electrumAddress(account.network);
    final torPort = settings.getTorPort(account.network, server);

    try {
      final txid = await EnvoyAccountHandler.broadcast(
        psbt: request.psbt,
        electrumServer: server,
        torPort: torPort,
        validateDomain: settings.validateDomain(
          server,
          viaTor: torPort != null,
        ),
      );
      await rpc.field0.respond(
        response: qlv2.BroadcastTransactionResponse.broadcast(txid: txid),
      );
    } on BroadcastError_NetworkError {
      await _respondError(rpc, 'network_error');
    } on BroadcastError_ConsensusError {
      await _respondError(rpc, 'transaction_rejected');
    } on BroadcastError_Message {
      await _respondError(rpc, 'invalid_transaction');
    } catch (_) {
      await _respondError(rpc, 'broadcast_failed');
    }
  }

  Future<void> _respondError(
    qlv2.InboundRpc_BroadcastTransaction rpc,
    String code,
  ) {
    return rpc.field0.respond(
      response: qlv2.BroadcastTransactionResponse.error(error: code),
    );
  }
}
