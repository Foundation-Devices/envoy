// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:animations/animations.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/prime/onboarding_icon_loader.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrimeSeedSetup extends ConsumerStatefulWidget {
  const PrimeSeedSetup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PrimeSeedSetupState();
}

class _PrimeSeedSetupState extends ConsumerState<PrimeSeedSetup> {
  int _currentPage = 0;

  IconLoaderState _state = IconLoaderState.indeterminate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  init() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _currentPage = 1;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      _state = IconLoaderState.success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: OnboardPageBackground(
          child: EnvoyScaffold(
              removeAppBarPadding: true,
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.small,
                      vertical: EnvoySpacing.small),
                  child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 1200),
                    transitionBuilder:
                        (child, primaryAnimation, secondaryAnimation) {
                      return SharedAxisTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        fillColor: Colors.transparent,
                        transitionType: SharedAxisTransitionType.vertical,
                        child: child,
                      );
                    },
                    child: _currentPage == 0
                        ? const SeedSetupIntro()
                        : _progressPage(),
                  ))),
        ));
  }

  Widget _progressPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 24,
      children: [
        IconLoader(
          state: _state,
          child: _state == IconLoaderState.success
              ? const SizedBox()
              : SizedBox.square(
                  dimension: 180, child: Image.asset("assets/key.png")),
        ),
        Text(
            _state == IconLoaderState.success
                ? "Wallet created successfully"
                : "Creating Wallet…",
            style: EnvoyTypography.heading),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: EnvoySpacing.small,
            vertical: EnvoySpacing.small,
          ),
          child: AnimatedOpacity(
            opacity: _state == IconLoaderState.success ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 320),
            child: Text(
              "Backup this wallet in the next step.",
              style: EnvoyTypography.body
                  .copyWith(color: EnvoyColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class SeedSetupIntro extends StatelessWidget {
  const SeedSetupIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 24,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: EnvoySpacing.medium1,
          ),
          child: Image.asset(
            "assets/sheild_info_prime.png",
            width: 180,
            height: 180,
          ),
        ),
        Text("Wallet Creation", style: EnvoyTypography.heading),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: EnvoySpacing.small,
            vertical: EnvoySpacing.small,
          ),
          child: Text(
            "Create a new wallet, restore from a backup or a seed directly.\n\nRestoring is possible with different options.\n\n{teaser options here?}",
            style:
                EnvoyTypography.body.copyWith(color: EnvoyColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
