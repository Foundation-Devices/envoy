// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/prime/connection_lost_dialog.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/app_store_url.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum ConnectivityState { checking, connected, disconnected }

class OnboardPrimeWelcome extends StatefulWidget {
  const OnboardPrimeWelcome({super.key});

  @override
  State<OnboardPrimeWelcome> createState() => _OnboardPrimeWelcomeState();
}

class _OnboardPrimeWelcomeState extends State<OnboardPrimeWelcome> {
  final s = Settings();
  int colorWay = 1;
  bool onboardingComplete = false;
  ConnectivityState _connectivityState = ConnectivityState.checking;
  bool _networkError = false;
  Timer? _retryTimer;

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
      _checkConnectivity();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    try {
      setState(() {
        _connectivityState = ConnectivityState.checking;
      });
      final canReach = await ScvServer().canReachPrimeServer();
      if (!mounted) return;

      if (!canReach) {
        if (!mounted) return;
        setState(() {
          _networkError = true;
          _connectivityState = ConnectivityState.disconnected;
        });
        _scheduleRetry();
        return;
      }

      _retryTimer?.cancel();

      final isDeprecated = await Server()
          .checkForForceUpdate()
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
      if (!mounted) return;

      if (isDeprecated) {
        showForceUpdateDialog();
        return;
      }

      setState(() {
        _networkError = false;
        _connectivityState = ConnectivityState.connected;
      });
    } catch (e, stackTrace) {
      EnvoyReport().log("canReachPrimeServer",
          "Error checking connectivity to Prime server: $e",
          stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _networkError = true;
        _connectivityState = ConnectivityState.disconnected;
      });
      _scheduleRetry();
    }
  }

  void showForceUpdateDialog() {
    showEnvoyPopUp(
      context,
      S().accounts_forceUpdate_subheading,
      S().accounts_forceUpdate_cta,
      (context) {
        launchUrlString(getAppStoreUrl());
      },
      title: S().accounts_forceUpdate_heading,
      icon: EnvoyIcons.download,
      dismissible: false,
      showCloseButton: false,
    );
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _connectivityState != ConnectivityState.connected) {
        _checkConnectivity();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // bool enabledMagicBackup = s.syncToCloud;
    //TODO: update copy based on s.syncToCloud
    return Consumer(
      builder: (context, ref, child) {
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
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: EnvoySpacing.large1),
                                      child: Text(
                                        S().onboarding_primeIntro_header,
                                        textAlign: TextAlign.center,
                                        style: EnvoyTypography.body.copyWith(
                                          fontSize: 20,
                                          color: EnvoyColors.gray1000,
                                          decoration: TextDecoration.none,
                                        ),
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
                                    if (_networkError) ...[
                                      const SizedBox(
                                          height: EnvoySpacing.medium1),
                                      EnvoyIcon(
                                        EnvoyIcons.alert,
                                        size: EnvoyIconSize.small,
                                        color: EnvoyColors.warning,
                                      ),
                                      const SizedBox(height: EnvoySpacing.xs),
                                      Text(
                                        S().onboarding_primeIntroError_content,
                                        style: EnvoyTypography.info.copyWith(
                                          color: EnvoyColors.warning,
                                          decoration: TextDecoration.none,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
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
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity:
                                _connectivityState == ConnectivityState.checking
                                    ? 0.5
                                    : 1,
                            child: EnvoyButton(
                              S().component_continue,
                              enabled: _connectivityState ==
                                  ConnectivityState.connected,
                              onTap: () {
                                final params = GoRouter.of(
                                  context,
                                ).state.uri.queryParameters;
                                context.goNamed(
                                  ONBOARD_PRIME_BLUETOOTH,
                                  queryParameters: params,
                                );
                              },
                            ),
                          ),
                          if (_connectivityState == ConnectivityState.checking)
                            const CupertinoActivityIndicator(),
                        ],
                      ),
                      const SizedBox(height: EnvoySpacing.small),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
