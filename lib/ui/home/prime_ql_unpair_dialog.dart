// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
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
  // Rebuild this stream when the underlying QLConnection instance changes
  // (e.g. after the user re-pairs via "Pair Passport Again"). Without this,
  // the listener stays bound to the stale BleAccountHandler from before the
  // re-pair and never sees the next UnpairingRequest.
  ref.watch(qlConnectionStreamProvider);
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
        _unPairDialogShownForDeviceIds.remove(device.serial);
        await device.qlConnection().disconnect();
        await Future.delayed(const Duration(milliseconds: 200));
        await Devices().clearDeviceQLKeys(device);
        if (Platform.isIOS) {
          await BluetoothChannel().removeAccessory(device.peripheralId);
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
              EnvoyIcons.info,
              size: EnvoyIconSize.mediumLarge,
              color: EnvoyColors.accentPrimary,
            ),
            const SizedBox(height: EnvoySpacing.medium3),
            Text(
              S().manage_deviceDetailsUnpairedModal_header,
              textAlign: TextAlign.center,
              style: EnvoyTypography.topBarTitle.copyWith(
                color: EnvoyColors.textPrimary,
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            Text(
              S().manage_deviceDetailsUnpairedModal_content.replaceAll(
                    '{0}',
                    device.name,
                  ),
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
