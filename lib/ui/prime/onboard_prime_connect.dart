// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/prime/onboard_prime_connect_wallet.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum StepProgress {
  waiting,
  success,
  failed,
}

class OnboardPrime extends StatefulWidget {
  const OnboardPrime({super.key});

  @override
  State<OnboardPrime> createState() => _OnboardPrimeState();
}

class _OnboardPrimeState extends State<OnboardPrime> {
  bool connectToPrimeWallet = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: EnvoyPatternScaffold(
        heroTag: "shield",
        child: OnboardPageBackground(
          child: PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return SharedAxisTransition(
                  animation: primaryAnimation,
                  fillColor: Colors.transparent,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  child: Material(
                    color: Colors.transparent,
                    child: child,
                  ));
            },
            child: connectToPrimeWallet
                ? const ConnectPrimeAccount()
                : OnboardPrimeConnectionStatus(
                    onConnect: () {
                      setState(() {
                        connectToPrimeWallet = true;
                      });
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class OnboardPrimeConnectionStatus extends StatefulWidget {
  final Function onConnect;

  const OnboardPrimeConnectionStatus({super.key, required this.onConnect});

  @override
  State<OnboardPrimeConnectionStatus> createState() =>
      _OnboardPrimeConnectionStatusState();
}

class _OnboardPrimeConnectionStatusState
    extends State<OnboardPrimeConnectionStatus> {
  int step = 0;
  StepProgress connectionStep = StepProgress.waiting;
  StepProgress securityStep = StepProgress.waiting;
  StepProgress firmWareStep = StepProgress.waiting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      init();
    });
  }

  //TODO: Simulate connection process
  init() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      connectionStep = StepProgress.success;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      securityStep = StepProgress.waiting;
      step = 1;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      securityStep = StepProgress.success;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      firmWareStep = StepProgress.waiting;
      step = 2;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      firmWareStep = StepProgress.success;
    });
    await Future.delayed(const Duration(seconds: 1));
    widget.onConnect.call();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 40),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Image.asset(
                "assets/prime_device_connect.png",
                width: 240,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.all(EnvoySpacing.medium1)),
            SliverToBoxAdapter(
              child: Text(
                "Passport Prime Connected",
                style: EnvoyTypography.heading.copyWith(
                  fontSize: MediaQuery.sizeOf(context).width > 410 ? 24 : 28,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.all(EnvoySpacing.small)),
            SliverToBoxAdapter(
              child: _buildConnectionStepWidget(),
            ),
            SliverToBoxAdapter(
              child: _buildSecurityStepWidget(),
            ),
            SliverToBoxAdapter(
              child: _buildFirmWareStepWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStepWidget() {
    String message = "";

    switch (connectionStep) {
      case StepProgress.waiting:
        //TODO: Change to actual device name
        message = "Connecting to Passport Prime\nSN219831 with QuantumLink";
        break;
      case StepProgress.success:
        //TODO: Change to actual device name
        message = "Connected to Passport Prime\nSN219831 with QuantumLink";
        break;
      case StepProgress.failed:
        message = "Connecting to Passport Prime\nSN219831 failed";
        break;
    }

    return PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            fillColor: Colors.transparent,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          );
        },
        child: step >= 0
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: ProgressStepWidget(
                  message: message,
                  key: ValueKey(message),
                  progress: connectionStep == StepProgress.waiting,
                  success: connectionStep == StepProgress.success,
                  error:
                      connectionStep == StepProgress.failed ? "Failed" : null,
                ),
              )
            : const SizedBox.shrink());
  }

  Widget _buildSecurityStepWidget() {
    String message = "";

    switch (securityStep) {
      case StepProgress.waiting:
        message = "Checking Device Security";
        break;
      case StepProgress.success:
        message = "Checked Device Security ";
        break;
      case StepProgress.failed:
        message = "Failed to Check Device Security";
        break;
    }

    return PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            fillColor: Colors.transparent,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          );
        },
        child: step >= 1
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: ProgressStepWidget(
                  key: ValueKey(message),
                  message: message,
                  progress: securityStep == StepProgress.waiting,
                  success: securityStep == StepProgress.success,
                  error: securityStep == StepProgress.failed ? "Failed" : null,
                ),
              )
            : const SizedBox.shrink());
  }

  Widget _buildFirmWareStepWidget() {
    String message = "";

    switch (firmWareStep) {
      case StepProgress.waiting:
        message = "Checking Firmware Update";
        break;
      case StepProgress.success:
        message = "No Firmware Update available";
        break;
      case StepProgress.failed:
        message = "failed to check Firmware Update";
        break;
    }

    return PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            fillColor: Colors.transparent,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          );
        },
        child: step >= 2
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: ProgressStepWidget(
                  key: ValueKey(message),
                  message: message,
                  progress: firmWareStep == StepProgress.waiting,
                  success: firmWareStep == StepProgress.success,
                  error: firmWareStep == StepProgress.failed ? "Failed" : null,
                ),
              )
            : const SizedBox.shrink());
  }
}

class ProgressStepWidget extends StatelessWidget {
  final String message;
  final bool progress;
  final bool success;
  final String? error;

  const ProgressStepWidget(
      {super.key,
      required this.message,
      required this.progress,
      required this.success,
      this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(message),
      width: MediaQuery.sizeOf(context).width * 0.64,
      height: 40,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
      child: ListTile(
        dense: true,
        titleAlignment: ListTileTitleAlignment.center,
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 24,
        minVerticalPadding: 0,
        visualDensity: VisualDensity.compact,
        horizontalTitleGap: EnvoySpacing.small,
        leading: SizedBox.square(
          dimension: 24,
          child: success
              ? const Icon(Icons.check)
              : const CupertinoActivityIndicator(),
        ),
        title: Text(
          message,
          style: EnvoyTypography.body,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
