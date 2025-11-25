// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';

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
        children: [
          const ConnectionLostModal(),
        ],
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

  Future<void> _attemptReconnect() async {
    setState(() {
      _isReconnecting = true;
    });

    // Allow UI to update BEFORE heavy work
    await Future.delayed(Duration.zero);

    final bleId = BluetoothManager().bleId;
    final device = Devices().getDeviceByBleId(bleId);

    const int attempts = 5; // total retries
    const Duration delayPerAttempt = Duration(milliseconds: 500);
    bool success = false;

    for (int i = 0; i < attempts; i++) {
      try {
        await BluetoothManager().reconnect(device!);

        // Wait a bit to allow provider to update
        await Future.delayed(const Duration(milliseconds: 200));

        final bool isConnected =
            ref.read(isPrimeConnectedProvider(device.bleId));

        if (isConnected) {
          success = true;
          break;
        }
      } catch (e) {
        kPrint("Reconnect attempt ${i + 1} failed: $e");
      }

      // Wait before next attempt
      await Future.delayed(delayPerAttempt);
    }

    // After all attempts:
    if (success && mounted) {
      Navigator.pop(context);
    } else {
      _unableToReconnectPrimeToast();
    }

    if (mounted) {
      setState(() {
        _isReconnecting = false;
      });
    }
  }

  void _unableToReconnectPrimeToast() {
    if (context.mounted) {
      EnvoyToast(
        backgroundColor: Colors.lightBlue,
        replaceExisting: true,
        duration: const Duration(seconds: 3),
        message: S().firmware_updateModalConnectionLostToast_unableToReconnect,
        icon: const EnvoyIcon(
          EnvoyIcons.alert,
          color: EnvoyColors.accentSecondary,
        ),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnboardingComplete =
        LocalStorage().prefs.getBool(PREFS_ONBOARDED) ?? false;

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
            style: EnvoyTypography.heading
                .copyWith(color: EnvoyColors.textPrimary),
          ),
          const SizedBox(height: EnvoySpacing.medium1),
          Text(
            S().onboarding_connectionIntroWarning_content,
            textAlign: TextAlign.center,
            style:
                EnvoyTypography.info.copyWith(color: EnvoyColors.textSecondary),
          ),
          const SizedBox(height: EnvoySpacing.medium3),
          Column(
            children: [
              isOnboardingComplete
                  ? EnvoyButton(
                      S().firmware_updateModalConnectionLost_exit,
                      borderRadius: BorderRadius.circular(EnvoySpacing.small),
                      type: EnvoyButtonTypes.secondary,
                      onTap: () {
                        resetOnboardingPrimeProviders(ref);
                        Navigator.of(context).pop();
                        context.go("/");
                      },
                    )
                  : SizedBox.shrink(),
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
}
