import 'package:envoy/ble/handlers/account_handler.dart';
import 'package:envoy/ble/handlers/device_handler.dart';
import 'package:envoy/ble/handlers/fw_update_handler.dart';
import 'package:envoy/ble/handlers/heartbeat_handler.dart';
import 'package:envoy/ble/handlers/magic_backup_handler.dart';
import 'package:envoy/ble/handlers/onboard_handler.dart';
import 'package:envoy/ble/handlers/scv_handler.dart';
import 'package:envoy/ble/handlers/shards_handler.dart';
import 'package:envoy/ble/handlers/timezone_handler.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:foundation_api/foundation_api.dart' as api;

import 'handlers/transactions_handler.dart';

/// Holds QL protocol message handlers for a specific QLConnection.
/// Each QLConnection has its own QLHandlers instance so handlers can
/// access their associated connection at any time.
class QLHandlers {
  /// The QLConnection this handler set belongs to
  final QLConnection connection;

  /// The underlying message router from quantum_link_router
  final PassportMessageRouter _messageRouter = PassportMessageRouter();

  /// Handlers - exposed for UI access
  late final BleMagicBackupHandler _bleMagicBackupHandler;
  late final BleAccountHandler _bleAccountHandler;
  late final ShardsHandler _bleShardsHandler;
  late final ScvHandler _scvAccountHandler;
  late final BleOnboardHandler _bleOnboardHandler;
  late final FwUpdateHandler _fwUpdateHandler;
  late final HeartbeatHandler _heartbeatHandler;
  late final DeviceHandler _deviceHandler;
  late final TimeZoneHandler _timeZoneHandler;
  late final TransactionHandler _txHandler;

  /// Getters for handlers
  BleMagicBackupHandler get magicBackupHandler => _bleMagicBackupHandler;
  BleAccountHandler get bleAccountHandler => _bleAccountHandler;
  TransactionHandler get txHandler => _txHandler;
  ShardsHandler get shardsHandler => _bleShardsHandler;
  ScvHandler get scvAccountHandler => _scvAccountHandler;
  BleOnboardHandler get bleOnboardHandler => _bleOnboardHandler;
  FwUpdateHandler get fwUpdateHandler => _fwUpdateHandler;
  HeartbeatHandler get heartbeatHandler => _heartbeatHandler;
  DeviceHandler get deviceHandler => _deviceHandler;
  TimeZoneHandler get timeZoneHandler => _timeZoneHandler;

  QLHandlers(this.connection) {
    _initHandlers();
    _registerHandlers();
  }

  void _initHandlers() {
    _bleMagicBackupHandler = BleMagicBackupHandler(connection);
    _bleAccountHandler = BleAccountHandler(connection);
    _txHandler = TransactionHandler(connection);
    _bleShardsHandler = ShardsHandler(connection);
    _scvAccountHandler = ScvHandler(connection);
    _bleOnboardHandler = BleOnboardHandler(connection);
    _fwUpdateHandler = FwUpdateHandler(connection);
    _heartbeatHandler = HeartbeatHandler(connection);
    _deviceHandler = DeviceHandler(connection);
    _timeZoneHandler = TimeZoneHandler(connection);
  }

  void _registerHandlers() {
    _messageRouter.registerHandler(_bleMagicBackupHandler);
    _messageRouter.registerHandler(_bleShardsHandler);
    _messageRouter.registerHandler(_bleAccountHandler);
    _messageRouter.registerHandler(_bleOnboardHandler);
    _messageRouter.registerHandler(_fwUpdateHandler);
    _messageRouter.registerHandler(_scvAccountHandler);
    _messageRouter.registerHandler(_heartbeatHandler);
    _messageRouter.registerHandler(_deviceHandler);
    _messageRouter.registerHandler(_timeZoneHandler);
    _messageRouter.registerHandler(_txHandler);
  }

  /// Dispatch a message to the appropriate handler
  Future<void> dispatch(api.PassportMessage message) async {
    await _messageRouter.dispatch(message);
  }

  /// Get the underlying router if needed
  PassportMessageRouter get messageRouter => _messageRouter;
}
