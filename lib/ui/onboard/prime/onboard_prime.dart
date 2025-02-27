// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/home/settings/bluetooth_diag.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardPrimeWelcome extends StatefulWidget {
  const OnboardPrimeWelcome({super.key});

  @override
  State<OnboardPrimeWelcome> createState() => _OnboardPrimeWelcomeState();
}

const String primeSerialPref = "prime_serial";

enum BleConnectState { idle, invalidId, connecting, connected }

class _OnboardPrimeWelcomeState extends State<OnboardPrimeWelcome> {
  final s = Settings();
  BleConnectState bleConnectState = BleConnectState.idle;

  @override
  void initState() {
    super.initState();
    LocalStorage().prefs.setBool(PREFS_ONBOARDED, true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final bleId = GoRouter.of(context).state.uri.queryParameters["p"];
      final regex = RegExp(r'^([0-9A-Fa-f]{2}:){5}([0-9A-Fa-f]{2})$');
      if (!regex.hasMatch(bleId ?? "")) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Invalid Prime Serial"),
                  content: const Text("Invalid Prime Serial"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ));
        setState(() {
          bleConnectState = BleConnectState.invalidId;
        });
      }
    });
  }

  _connectToPrime() async {
    setState(() {
      bleConnectState = BleConnectState.connecting;
    });
    try {
      final bleId = GoRouter.of(context).state.uri.queryParameters["p"];
      final regex = RegExp(r'^([0-9A-Fa-f]{2}:){5}([0-9A-Fa-f]{2})$');
      if (regex.hasMatch(bleId ?? "")) {
        BluetoothManager().getPermissions();
        kPrint("Connecting to Prime with ID: $bleId");
        // connect(id: bleId);
        // connect(id: "63:89:95:2E:A2:23");
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            bleConnectState = BleConnectState.connected;
          });
        }

        if (context.mounted && mounted) {
          context.goNamed(ONBOARD_PRIME_BLUETOOTH);
        }
      } else {
        throw Exception("Invalid Prime Serial");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          bleConnectState = BleConnectState.invalidId;
        });
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Unable to connect "),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ));
        kPrint(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // bool enabledMagicBackup = s.syncToCloud;
    //TODO: update copy based on s.syncToCloud
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: kToolbarHeight,
        backgroundColor: Colors.transparent,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
            return;
            //TODO: fix this
            // if (GoRouter.of(context).canPop()) {
            //   GoRouter.of(context).pop();
            // } else {
            //   GoRouter.of(context).push(ROUTE_ACCOUNTS_HOME);
            // }
          },
        ),
        automaticallyImplyLeading: false,
      ),
      header: GestureDetector(
        onLongPress: () {
          BluetoothManager().getPermissions();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BluetoothDiagnosticsPage(),
              ));
        },
        child: Transform.translate(
          offset: const Offset(0, 85),
          child: Image.asset(
            //TODO: change prime product image based on scanned QR
            "assets/images/prime_artic_copper.png",
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
          ),
        ),
      ),
      shield: Column(
        children: [
          const SizedBox(height: EnvoySpacing.medium1),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 300,
              ),
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.large1,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.medium1),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Setup a new Passport Prime",
                                  textAlign: TextAlign.center,
                                  style: EnvoyTypography.body.copyWith(
                                    fontSize: 20,
                                    color: EnvoyColors.gray1000,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: EnvoySpacing.small),
                                Text(
                                  "Passport Prime protects your Bitcoin keys by securing them offline while offering apps as your one go to security device. \n"
                                  "With this type of \"cold\" wallet, transactions must be authorized with your Passport.\n\n"
                                  "The Backup Strategy involves automatically saving one part in the cloud. That guarantees the easiest recovery path.",
                                  style: EnvoyTypography.info.copyWith(
                                    color: EnvoyColors.inactiveDark,
                                    decoration: TextDecoration.none,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: EnvoySpacing.medium1,
              right: EnvoySpacing.medium1,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: EnvoySpacing.medium1),
                // Consumer(
                //   builder: (context, ref, child) {
                //     final payload = GoRouter.of(context)
                //         .state
                //         ?.uri
                //         .queryParameters["p"];
                //     return Text("Debug Payload : $payload");
                //   },
                // ),
                const SizedBox(height: EnvoySpacing.medium1),
                Opacity(
                  opacity: (bleConnectState == BleConnectState.invalidId ||
                          bleConnectState == BleConnectState.connecting)
                      ? 0.5
                      : 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: bleConnectState == BleConnectState.connecting
                            ? 0.5
                            : 1,
                        child: EnvoyButton("Connect", onTap: () {
                          _connectToPrime();
                        }),
                      ),
                      if (bleConnectState == BleConnectState.connecting)
                        const CupertinoActivityIndicator(),
                    ],
                  ),
                ),
                const SizedBox(height: EnvoySpacing.small),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
