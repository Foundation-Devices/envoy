// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ble/qlv2/rpc_handler.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2AccountUpdateStepState {
  const QLV2AccountUpdateStepState({required this.message, required this.step});

  final String message;
  final EnvoyStepState step;
}

class QLV2AccountUpdateEvents {
  QLV2AccountUpdateEvents();
  final _status = StreamController<QLV2AccountUpdateStepState>.broadcast();

  Stream<QLV2AccountUpdateStepState> get status => _status.stream;

  void emit(String message, EnvoyStepState step) {
    if (_status.isClosed) return;
    _status.add(QLV2AccountUpdateStepState(message: message, step: step));
  }

  void dispose() {
    unawaited(_status.close());
  }
}

class QLV2AccountUpdateHandler
    implements QLV2SessionEventHandler<qlv2.AccountUpdatedEvent> {
  QLV2AccountUpdateHandler(this._events);

  final QLV2AccountUpdateEvents _events;

  @override
  Future<void> handleEvent(
    qlv2.AccountUpdatedEvent event,
    QLConnection device,
  ) async {
    final message = S().finalize_catchAll_connectingAccount;
    _events.emit(message, EnvoyStepState.LOADING);
    try {
      await device.qlHandler.bleAccountHandler.handleAccountUpdate(
        api.AccountUpdate(accountId: event.accountId, update: event.update),
      );
      _events.emit(message, EnvoyStepState.FINISHED);
    } catch (error, stackTrace) {
      await EnvoyReport().log(
        'qlv2_account_update_handler',
        'Failed to handle account update (${error.runtimeType})',
        stackTrace: stackTrace,
      );
      _events.emit(message, EnvoyStepState.ERROR);
    }
  }
}
