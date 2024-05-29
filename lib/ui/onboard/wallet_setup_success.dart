// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class WalletSetupSuccess extends ConsumerStatefulWidget {
  const WalletSetupSuccess({super.key});

  @override
  ConsumerState<WalletSetupSuccess> createState() => _WalletSetupSuccessState();
}

class _WalletSetupSuccessState extends ConsumerState<WalletSetupSuccess> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      ref.read(successfulSetupWallet.notifier).state = true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) async {
        OnboardingPage.popUntilHome(context);
      },
      child: OnboardPageBackground(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Container(
                  constraints: BoxConstraints.tight(const Size.fromHeight(250)),
                  // margin: EdgeInsets.only(top: 24),
                  child: const RiveAnimation.asset(
                    "assets/envoy_loader.riv",
                    fit: BoxFit.contain,
                    animations: ["happy"],
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.medium1),
                    child: Column(
                      children: [
                        Text(
                          S().wallet_setup_success_heading,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: EnvoySpacing.large2),
                        Text(S().wallet_setup_success_subheading,
                            textAlign: TextAlign.center,
                            style: EnvoyTypography.info
                                .copyWith(color: EnvoyColors.textTertiary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: EnvoySpacing.medium1),
              Padding(
                padding: const EdgeInsets.only(
                    left: EnvoySpacing.medium1,
                    right: EnvoySpacing.medium1,
                    bottom: EnvoySpacing.medium2,
                    top: EnvoySpacing.small),
                child: Consumer(
                  builder: (context, ref, child) {
                    return OnboardingButton(
                        label: S().component_continue,
                        onTap: () async {
                          if (context.mounted) {
                            OnboardingPage.popUntilHome(context);
                          }
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
