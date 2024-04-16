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

class WalletSetupSuccess extends ConsumerStatefulWidget {
  const WalletSetupSuccess({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletSetupSuccess> createState() => _WalletSetupSuccessState();
}

class _WalletSetupSuccessState extends ConsumerState<WalletSetupSuccess> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 100)).then((_) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: EnvoySpacing.xl),
                      child: Transform.scale(
                        scale: 1.2,
                        child: Container(
                          constraints:
                              BoxConstraints.tight(Size.fromHeight(250)),
                          // margin: EdgeInsets.only(top: 24),
                          child: RiveAnimation.asset(
                            "assets/envoy_loader.riv",
                            fit: BoxFit.contain,
                            animations: ["happy"],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.medium3,
                          horizontal: EnvoySpacing.medium1),
                      child: Column(
                        children: [
                          Text(
                            S().wallet_setup_success_heading,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: EnvoySpacing.medium3),
                            child: Text(
                              S().wallet_setup_success_subheading,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
              child: Consumer(
                builder: (context, ref, child) {
                  return OnboardingButton(
                      label: S().component_continue,
                      onTap: () async {
                        OnboardingPage.popUntilHome(context);
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
