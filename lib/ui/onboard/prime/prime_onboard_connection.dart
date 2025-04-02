// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:bluart/bluart.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/prime/onboard_prime.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart';

class PrimeOnboardParing extends ConsumerStatefulWidget {
  const PrimeOnboardParing({super.key});

  @override
  ConsumerState<PrimeOnboardParing> createState() => _PrimeOnboardParingState();
}

class _PrimeOnboardParingState extends ConsumerState<PrimeOnboardParing> {
  bool canPop = false;

  //TODO: use provider to get firmware update status
  bool updateAvailable = false;
  BleDevice? device;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        // await Permission.bluetooth.request();
        // await Permission.bluetoothConnect.request();
        _connectBLE();
      } catch (e) {
        if (mounted && context.mounted) {
          //TODO: fix this dialog
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Permission Error"),
                content: const Text(
                    "Please enable Bluetooth and Location permissions to continue."),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"))
                ],
              );
            },
          );
        }
        kPrint("Error getting permissions: $e");
      }
    });
  }

  _connectBLE() async {
    try {
      if (mounted) {
        setState(() {
          canPop = false;
        });
      }
      final bleStepNotifier = ref.read(bleConnectionProvider.notifier);
      final deviceSecurityStepNotifier =
          ref.read(deviceSecurityProvider.notifier);
      final firmWareUpdateStepNotifier =
          ref.read(firmWareUpdateProvider.notifier);

      String id = LocalStorage().prefs.getString(primeSerialPref) ?? "";
      device = BleDevice(id: id, name: "Passport Prime", connected: false);
      kPrint("Connecting to Prime with ID: $id");
      await bleStepNotifier.updateStep(
          "Connecting to Prime", EnvoyStepState.LOADING);
      //  await BluetoothManager().connect(id: id);
      ref.read(primeBleIdProvider.notifier).state = id;
      setState(() {
        device = BleDevice(id: id, name: "Passport Prime", connected: true);
      });
      await Future.delayed(const Duration(seconds: 1));
      await bleStepNotifier.updateStep(
          S().onboarding_connectionIntro_connectedToPrime,
          EnvoyStepState.FINISHED);

      await deviceSecurityStepNotifier.updateStep(
          S().onboarding_connectionIntro_checkingDeviceSecurity,
          EnvoyStepState.LOADING);
      await Future.delayed(const Duration(seconds: 10));
      await deviceSecurityStepNotifier.updateStep(
          S().onboarding_connectionChecking_SecurityPassed,
          EnvoyStepState.FINISHED);

      await BluetoothManager()
          .sendOnboardingState(OnboardingState.securityChecked);

      await firmWareUpdateStepNotifier.updateStep(
          S().onboarding_connectionChecking_forUpdates, EnvoyStepState.LOADING);
      await Future.delayed(const Duration(seconds: 10));
      await firmWareUpdateStepNotifier.updateStep(
          S().onboarding_connectionUpdatesAvailable_updatesAvailable,
          EnvoyStepState.FINISHED);
      await BluetoothManager()
          .sendOnboardingState(OnboardingState.updateAvailable);
      if (mounted) {
        setState(() {
          canPop = true;
          updateAvailable = true;
        });
      }
    } catch (e) {
      kPrint(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firmWareCheck = ref.watch(firmWareUpdateProvider);

    return PopScope(
      canPop: canPop,
      child: OnboardPageBackground(
          child: EnvoyScaffold(
        removeAppBarPadding: true,
        topBarActions: const [],
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.small, vertical: EnvoySpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 24,
            children: [
              Image.asset(
                "assets/images/prime_envoy_devices.png",
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width * 0.8,
                height: 320,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.xs,
                    horizontal: EnvoySpacing.medium1),
                child: Column(
                  children: [
                    Text(
                      S().onboarding_connectionIntro_header,
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.heading,
                    ),
                    Expanded(child: Consumer(builder: (context, ref, child) {
                      final bleStep = ref.watch(bleConnectionProvider);
                      final deviceCheck = ref.watch(deviceSecurityProvider);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.medium1,
                          horizontal: EnvoySpacing.medium2,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: EnvoySpacing.medium1,
                          children: [
                            EnvoyStepItem(step: bleStep),
                            EnvoyStepItem(step: deviceCheck),
                            EnvoyStepItem(
                                step: firmWareCheck,
                                highlight: updateAvailable),
                          ],
                        ),
                      );
                    })),
                  ],
                ),
              )),
            ],
          ),
        ),
      )),
    );
  }
}
