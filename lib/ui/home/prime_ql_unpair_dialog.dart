// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as api;

// -----------------
// QL Unpair dialog
// -----------------

final _unPairDialogShownForDeviceIds = <String>{};

final _unpairingRequestStreamProvider =
    StreamProvider.family<api.UnpairingRequest?, Device>((ref, device) {
  final primeDevices = ref.watch(devicesProvider).getPrimeDevices;
  final matches = primeDevices.where((d) => d.serial == device.serial);
  if (matches.isEmpty) {
    return Stream.value(null);
  } else {
    final qlConnection = matches.first.qlConnection();
    return qlConnection.qlHandler.bleAccountHandler.unpairRequestStream;
  }
});

/// Listens for unpairing requests from paired Prime devices and shows a dialog.
void listenForPrimeUnpair(BuildContext context, WidgetRef ref) {
  final primeDevices = ref.watch(devicesProvider).getPrimeDevices;

  for (final device in primeDevices) {
    ref.listen(_unpairingRequestStreamProvider(device), (prev, next) {
      if (next.hasValue && next.value != null) {
        showUnpairingDialog(context, device);
      }
    });
  }
}

void showUnpairingDialog(BuildContext context, Device device) {
  if (_unPairDialogShownForDeviceIds.contains(device.serial)) return;
  _unPairDialogShownForDeviceIds.add(device.serial);
  showEnvoyDialog(
    context: context,
    useRootNavigator: true,
    dismissible: false,
    dialog: PrimeQLUnpairDialog(
      device: device,
      onDismiss: () async {
        final deviceId =
            Platform.isAndroid ? device.bleId : device.peripheralId;
        _bleActiveSince.remove(deviceId);
        await device.qlConnection().disconnect();
        await Future.delayed(const Duration(milliseconds: 200));
        await Devices().clearDeviceQLKeys(device);
        if (Platform.isIOS) {
          final id = device.peripheralId;
          await BluetoothChannel().removeAccessory(id);
        }
      },
    ),
  );
}

class PrimeQLUnpairDialog extends StatelessWidget {
  final Device device;
  final AsyncCallback? onDismiss;

  const PrimeQLUnpairDialog({super.key, required this.device, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(EnvoySpacing.medium2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EnvoyIcon(
              EnvoyIcons.alert,
              size: EnvoyIconSize.mediumLarge,
              color: EnvoyColors.copperLight500,
            ),
            const SizedBox(height: EnvoySpacing.medium3),
            Text(
              S().manage_deviceDetailsUnpairedModalWarning_header,
              textAlign: TextAlign.center,
              style: EnvoyTypography.topBarTitle.copyWith(
                color: EnvoyColors.textPrimary,
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            Text(
              S().manage_deviceDetailsUnpairedModalWarning_content,
              textAlign: TextAlign.center,
              style: EnvoyTypography.info.copyWith(
                color: EnvoyColors.textSecondary,
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium3),
            EnvoyButton(
              S().component_confirm,
              borderRadius: BorderRadius.circular(EnvoySpacing.small),
              type: EnvoyButtonTypes.primary,
              onTap: () {
                onDismiss?.call().then((_) {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------
// Heartbeat lost dialog
// ----------------------

Timer? _heartbeatTimeoutCheckTimer;
String? _heartbeatDialogDeviceId;
final Map<String, DateTime> _bleActiveSince = {};
final _shownLostQLForDeviceIds = <String>{};

const Duration _heartbeatTimeoutDuration = Duration(seconds: 15);
const Duration _heartbeatTimeoutCheckInterval = Duration(seconds: 1);

/// Hooks heartbeat monitoring into the home page build cycle.
/// For each paired Prime device: if BLE is connected but no heartbeat is
/// received for [_heartbeatTimeoutDuration], a dialog is shown.
void startPrimeHeartbeatMonitoring(BuildContext context, WidgetRef ref) {
  final primeDevices = ref.watch(devicesProvider).getPrimeDevices;

  for (final device in primeDevices) {
    final deviceId = Platform.isAndroid ? device.bleId : device.peripheralId;

    ref.listen(primeQLActivityProvider(device), (prev, isActive) {
      if (isActive) {
        // Heartbeat resumed — clear timeout, dismiss dialog if it was for this device
        _bleActiveSince.remove(deviceId);
        if (_heartbeatDialogDeviceId == deviceId) {
          _dismissHeartbeatDialog(context);
        }
      } else {
        // Heartbeat lost — only start countdown while BLE transport is still up
        final isConnected = ref.read(isPrimeConnectedProvider(device));
        if (isConnected) {
          _bleActiveSince.putIfAbsent(deviceId, () => DateTime.now());
          _startHeartbeatCheckTimer(context);
        }
      }
    });

    ref.listen(deviceConnectionStatusStreamProvider(device), (prev, next) {
      if (!next.hasValue) return;
      final event = next.value!;
      if (event.type == BluetoothConnectionEventType.deviceDisconnected) {
        // BLE dropped — not a heartbeat-timeout situation, clear state
        _bleActiveSince.remove(deviceId);
        if (_heartbeatDialogDeviceId == deviceId) {
          _dismissHeartbeatDialog(context);
        }
      } else if (event.type == BluetoothConnectionEventType.deviceConnected) {
        // Fresh BLE connection — reset heartbeat tracking from connection time
        _bleActiveSince[deviceId] = DateTime.now();
        _startHeartbeatCheckTimer(context);
      }
    });
  }
}

void _startHeartbeatCheckTimer(BuildContext context) {
  if (_heartbeatTimeoutCheckTimer?.isActive == true) return;
  _heartbeatTimeoutCheckTimer = Timer.periodic(
    _heartbeatTimeoutCheckInterval,
    (_) => _checkHeartbeatTimeouts(context),
  );
}

void _checkHeartbeatTimeouts(BuildContext context) {
  if (!context.mounted) {
    _heartbeatTimeoutCheckTimer?.cancel();
    _heartbeatTimeoutCheckTimer = null;
    return;
  }
  if (_bleActiveSince.isEmpty) {
    _heartbeatTimeoutCheckTimer?.cancel();
    _heartbeatTimeoutCheckTimer = null;
    return;
  }
  if (_shownLostQLForDeviceIds.isNotEmpty) return;

  final now = DateTime.now();
  for (final entry in _bleActiveSince.entries) {
    if (now.difference(entry.value) >= _heartbeatTimeoutDuration) {
      final deviceId = entry.key;
      final matches = Devices().getPrimeDevices.where(
            (d) => (Platform.isAndroid ? d.bleId : d.peripheralId) == deviceId,
          );
      _showHeartbeatLostDialog(
        context,
        deviceId,
        matches.isEmpty ? null : matches.first,
      );
      break; // one dialog at a time
    }
  }
}

void _showHeartbeatLostDialog(
  BuildContext context,
  String deviceId,
  Device? device,
) async {
  if (device == null || device.xid == null || device.senderXid == null) return;
  _shownLostQLForDeviceIds.add(deviceId);
  _heartbeatDialogDeviceId = deviceId;
  await showEnvoyDialog(
    context: context,
    useRootNavigator: true,
    dismissible: false,
    dialog: PrimeHeartbeatLostDialog(
      device: device,
      onDismiss: () async {
        _bleActiveSince.remove(deviceId);
        await device.qlConnection().disconnect();
        await Future.delayed(const Duration(milliseconds: 200));
        await Devices().clearDeviceQLKeys(device);
        if (Platform.isIOS) {
          final id = device.peripheralId;
          await BluetoothChannel().removeAccessory(id);
        }
      },
    ),
  );
  // Clear dialog tracking state before disconnect so the
  _heartbeatDialogDeviceId = null;
  _shownLostQLForDeviceIds.remove(deviceId);
}

void _dismissHeartbeatDialog(BuildContext context) {
  _shownLostQLForDeviceIds.remove(_heartbeatDialogDeviceId);
  _heartbeatDialogDeviceId = null;
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();
}

class PrimeHeartbeatLostDialog extends ConsumerStatefulWidget {
  final Device? device;
  final VoidCallback? onDismiss;

  const PrimeHeartbeatLostDialog({
    super.key,
    this.device,
    this.onDismiss,
  });

  @override
  ConsumerState<PrimeHeartbeatLostDialog> createState() =>
      _PrimeHeartbeatLostDialogState();
}

class _PrimeHeartbeatLostDialogState
    extends ConsumerState<PrimeHeartbeatLostDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(EnvoySpacing.medium2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EnvoyIcon(
              EnvoyIcons.alert,
              size: EnvoyIconSize.mediumLarge,
              color: EnvoyColors.copperLight500,
            ),
            const SizedBox(height: EnvoySpacing.medium2),
            Text(
              S().manage_deviceDetailsUnpairedModal_header,
              textAlign: TextAlign.center,
              style: EnvoyTypography.topBarTitle.copyWith(
                color: EnvoyColors.textPrimary,
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium2),
            Text(
              S().manage_deviceDetailsUnpairedModal_content,
              textAlign: TextAlign.center,
              style: EnvoyTypography.info.copyWith(
                color: EnvoyColors.textSecondary,
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium2),
            EnvoyButton(
              S().component_confirm,
              borderRadius: BorderRadius.circular(EnvoySpacing.small),
              type: EnvoyButtonTypes.primary,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.onDismiss?.call();
    super.dispose();
  }
}
