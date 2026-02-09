// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Flag to track if the dialog is currently being shown
/// startBluetoothDisconnectionListener, will be hooked to different onboarding pages
/// but we only want to show one dialog at a time.
/// this flag will be set to false when the dialog widget get disposed.
bool _isDialogShowing = false;

/// Starts listening for Bluetooth disconnection events and shows a dialog if disconnected
void startBluetoothDisconnectionListener(BuildContext context, WidgetRef ref) {
  final qlConnection = ref.read(onboardingDeviceProvider);
  if (qlConnection == null) {
    return;
  }
  ref.listen(deviceConnectionStatusStreamProvider(qlConnection.deviceId), (
    previous,
    next,
  ) {
    final lastState = ref.read(primeUpdateStateProvider);
    final isRebooting = lastState == PrimeFwUpdateStep.rebooting ||
        lastState == PrimeFwUpdateStep.installing;
    if (next.hasValue) {
      final event = next.value!;
      if (event.type == BluetoothConnectionEventType.deviceDisconnected &&
          !isRebooting) {
        if (context.mounted && !_isDialogShowing) {
          showEnvoyDialog(
            context: context,
            useRootNavigator: true,
            dismissible: false,
            dialog: const ConnectionLostDialog(),
          );
          _isDialogShowing = true;
        }
      } else if (event.type == BluetoothConnectionEventType.deviceConnected) {
        //maybe handle dialog dismissal??
      }
    }
  });
}

class ConnectionLostDialog extends StatelessWidget {
  const ConnectionLostDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
      ),
      child: ExpandablePageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [const ConnectionLostModal()],
      ),
    );
  }
}

class ConnectionLostModal extends ConsumerStatefulWidget {
  const ConnectionLostModal({super.key});

  @override
  ConsumerState<ConnectionLostModal> createState() =>
      _ConnectionLostModalState();
}

class _ConnectionLostModalState extends ConsumerState<ConnectionLostModal> {
  bool _isReconnecting = false;

  //TODO: implement device speicific reconnect
  Future<void> _attemptReconnect() async {
    setState(() {
      _isReconnecting = true;
    });

    final qlConnection = ref.read(onboardingDeviceProvider);
    if (qlConnection == null) {
      return;
    }
    try {
      if (qlConnection.lastDeviceStatus.peripheralId == null) {
        throw Exception("No Previous connection...");
      }
      String deviceId = qlConnection.lastDeviceStatus.peripheralId ?? "";
      //  if (Devices().getPrimeDevices.isEmpty) {
      //    //TODO: localize
      //    // throw Exception("No Prime devices available to reconnect");
      //   deviceId =    Devices().getPrimeDevices.firs.
      //  }
      //  kPrint(
      //      "Attempting to reconnect to device... ${BluetoothChannel().lastDeviceStatus.}");
      await BluetoothManager().reconnect(deviceId);
      await Future.delayed(const Duration(seconds: 2));
      if (qlConnection.lastDeviceStatus.connected && mounted) {
        Navigator.pop(context);
        EnvoyToast(
          backgroundColor: Colors.lightBlue,
          replaceExisting: true,
          duration: const Duration(seconds: 3),
          message: S().onboarding_connectionIntro_connectedToPrime,
          icon: const EnvoyIcon(
            EnvoyIcons.check,
            color: EnvoyColors.solidWhite,
          ),
        ).show(context);
      }
    } catch (e, d) {
      EnvoyReport().log(
        "ConnectionLostDialog",
        "Reconnection attempt failed: $e",
        stackTrace: d,
      );
      if (mounted) {
        EnvoyToast(
          backgroundColor: Colors.lightBlue,
          replaceExisting: true,
          duration: const Duration(seconds: 3),
          message:
              S().firmware_updateModalConnectionLostToast_unableToReconnect,
          icon: const EnvoyIcon(
            EnvoyIcons.alert,
            color: EnvoyColors.accentSecondary,
          ),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReconnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingDevice = ref.watch(onboardingDeviceProvider);
    final device =
        onboardingDevice?.getDevice() ?? Devices().getPrimeDevices.first;
    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.medium2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EnvoyIcon(
            EnvoyIcons.alert,
            size: EnvoyIconSize.big,
            color: EnvoyColors.copperLight500,
          ),
          const SizedBox(height: EnvoySpacing.medium3),
          Text(
            S().firmware_updateModalConnectionLost_header,
            textAlign: TextAlign.center,
            style: EnvoyTypography.heading.copyWith(
              color: EnvoyColors.textPrimary,
            ),
          ),
          const SizedBox(height: EnvoySpacing.medium1),
          Text(
            S().onboarding_connectionIntroWarning_content,
            textAlign: TextAlign.center,
            style: EnvoyTypography.info.copyWith(
              color: EnvoyColors.textSecondary,
            ),
          ),
          const SizedBox(height: EnvoySpacing.medium3),
          Column(
            children: [
              if (Devices().getPrimeDevices.isEmpty ||
                  !device.onboardingComplete)
                EnvoyButton(
                  S().firmware_updateModalConnectionLost_exit,
                  borderRadius: BorderRadius.circular(EnvoySpacing.small),
                  type: EnvoyButtonTypes.secondary,
                  onTap: () {
                    resetOnboardingPrimeProviders(
                      ProviderScope.containerOf(context),
                    );
                    Navigator.of(context).pop();
                    context.go("/");
                  },
                ),
              const SizedBox(height: EnvoySpacing.medium1),
              EnvoyButton(
                _isReconnecting
                    ? S().firmware_updateModalConnectionLost_reconnecting
                    : S().firmware_updateModalConnectionLost_tryToReconnect,
                borderRadius: BorderRadius.circular(EnvoySpacing.small),
                type: EnvoyButtonTypes.primaryModal,
                leading: _isReconnecting
                    ? const CupertinoActivityIndicator(
                        color: EnvoyColors.textPrimaryInverse,
                        radius: 12,
                      )
                    : null,
                onTap: _isReconnecting ? null : _attemptReconnect,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDialogShowing = false;
    super.dispose();
  }
}
