// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:animations/animations.dart';
import 'package:bluart/bluart.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/onboard_prime.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';

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
      await Future.delayed(const Duration(milliseconds: 200));
      await bleStepNotifier.updateStep(
          S().onboarding_connectionIntro_connectedToPrime,
          EnvoyStepState.FINISHED);

      await Future.delayed(const Duration(milliseconds: 1000));

      await ref.read(deviceSecurityProvider.notifier).updateStep(
          S().onboarding_connectionIntro_checkingDeviceSecurity,
          EnvoyStepState.LOADING);

      await BluetoothManager().sendChallengeMessage();
    } catch (e) {
      kPrint(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firmWareCheck = ref.watch(firmWareUpdateProvider);
    final deviceCheck = ref.watch(deviceSecurityProvider);

    return PopScope(
      canPop: canPop,
      child: EnvoyPatternScaffold(
          gradientHeight: 1.8,
          header: Transform.translate(
            offset: const Offset(0, 70),
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(end: 1.0, begin: 0.0),
              curve: Curves.decelerate,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Image.asset(
                "assets/images/prime_envoy_devices.png",
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width * 0.8,
                height: 320,
              ),
            ),
          ),
          shield: PageTransitionSwitcher(
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                    fillColor: Colors.transparent,
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.vertical,
                    child: child);
              },
              child: Padding(
                padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
                child: mainWidget(deviceCheck, firmWareCheck, context),
              ))),
    );
  }

  Widget mainWidget(
      StepModel deviceCheck, StepModel firmWareCheck, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.xs, horizontal: EnvoySpacing.medium1),
      child: Column(
        children: [
          Text(
            S().onboarding_connectionIntro_header,
            textAlign: TextAlign.center,
            style: EnvoyTypography.heading,
          ),
          Expanded(child: Consumer(builder: (context, ref, child) {
            final bleStep = ref.watch(bleConnectionProvider);
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
                  if (deviceCheck.state != EnvoyStepState.ERROR)
                    EnvoyStepItem(
                        step: firmWareCheck, highlight: updateAvailable),
                ],
              ),
            );
          })),
          if (deviceCheck.state == EnvoyStepState.ERROR)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S().onboarding_connectionIntroError_content,
                  style: EnvoyTypography.body
                      .copyWith(color: EnvoyColors.textTertiary),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: EnvoySpacing.medium1),
                  child: EnvoyButton(
                    onTap: () {
                      context.go("/");
                    },
                    label: S().onboarding_connectionIntroError_exitSetup,
                    type: ButtonType.secondary,
                  ),
                ),
                EnvoyButton(
                  onTap: () {
                    launchUrl(Uri.parse(
                        "https://community.foundation.xyz/c/passport-prime/12"));
                  },
                  label: S().common_button_contactSupport,
                  type: ButtonType.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
