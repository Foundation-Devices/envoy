// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/home/settings/bluetooth_diag.dart';
import 'package:envoy/ui/onboard/prime/connection_lost_dialog.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardPrimeWelcome extends StatefulWidget {
  const OnboardPrimeWelcome({super.key});

  @override
  State<OnboardPrimeWelcome> createState() => _OnboardPrimeWelcomeState();
}

class _OnboardPrimeWelcomeState extends State<OnboardPrimeWelcome> {
  final s = Settings();
  int colorWay = 1;
  bool onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = GoRouter.of(context).state.uri.queryParameters;
      setState(() {
        final param = params["c"] ?? "1";
        onboardingComplete = int.tryParse(params["o"] ?? "0") == 1;
        colorWay = int.tryParse(param) ?? 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // bool enabledMagicBackup = s.syncToCloud;
    //TODO: update copy based on s.syncToCloud
    return Consumer(builder: (context, ref, child) {
      startBluetoothDisconnectionListener(context, ref);
      return PopScope(
        canPop: LocalStorage().prefs.getBool(PREFS_ONBOARDED) != true,
        onPopInvokedWithResult: (didPop, result) {
          if (LocalStorage().prefs.getBool(PREFS_ONBOARDED) == true) {
            GoRouter.of(context).go(ROUTE_ACCOUNTS_HOME);
          } else {}
        },
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
                colorWay == 1
                    ? "assets/images/prime_midnight_bronze.png"
                    : "assets/images/prime_artic_copper.png",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      S().onboarding_primeIntro_header,
                                      textAlign: TextAlign.center,
                                      style: EnvoyTypography.body.copyWith(
                                        fontSize: 20,
                                        color: EnvoyColors.gray1000,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: EnvoySpacing.small),
                                    Text(
                                      S().onboarding_primeIntro_content,
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
                    EnvoyButton(S().component_continue, onTap: () {
                      final params =
                          GoRouter.of(context).state.uri.queryParameters;
                      context.goNamed(
                        ONBOARD_PRIME_BLUETOOTH,
                        queryParameters: params,
                      );
                    }),
                    const SizedBox(height: EnvoySpacing.small),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
