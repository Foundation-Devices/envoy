// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/home/settings/bluetooth_diag.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:go_router/go_router.dart';

class OnboardPrimeWelcome extends StatefulWidget {
  const OnboardPrimeWelcome({super.key});

  @override
  State<OnboardPrimeWelcome> createState() => _OnboardPrimeWelcomeState();
}

const String PRIME_SERIAL = "prime_serial";

class _OnboardPrimeWelcomeState extends State<OnboardPrimeWelcome> {
  final s = Settings();
  bool scanningFinished = false;

  @override
  void initState() {
    super.initState();
    LocalStorage().prefs.setBool(PREFS_ONBOARDED, true);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {},
    );
  }

  @override
  Widget build(BuildContext context) {
    // bool enabledMagicBackup = s.syncToCloud;
    //TODO: update copy based on s.syncToCloud
    return wrapWithQRScannerPage(
      child: EnvoyPatternScaffold(
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
                  if (scanningFinished)
                    EnvoyButton("Connect", onTap: () {
                      context.goNamed(ONBOARD_PRIME_BLUETOOTH);
                    }),
                  const SizedBox(height: EnvoySpacing.small),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget wrapWithQRScannerPage({required Widget child}) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 340),
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      child: scanningFinished
          ? child
          : ScannerPage(
              const [ScannerType.pairPrime],
              onPrimePair: (api.U8Array6 primeSerial) async {
                kPrint(
                    "Prime Serial  ${primeSerial.inner.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase()} \n UInt8Array ${primeSerial.inner}");
                LocalStorage().prefs.setString(
                    PRIME_SERIAL,
                    primeSerial.inner
                        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                        .join(':')
                        .toUpperCase());
                if (mounted) {
                  setState(() {
                    scanningFinished = true;
                  });
                }
              },
            ),
    );
  }
}
