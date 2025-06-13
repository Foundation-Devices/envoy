// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/settings.dart';

class WalletSetupSuccess extends ConsumerStatefulWidget {
  final bool isPrimeWallet;

  const WalletSetupSuccess({super.key, this.isPrimeWallet = false});

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
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        context.go("/");
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
                          widget.isPrimeWallet
                              ? S().finish_connectedSuccess_header
                              : S().wallet_setup_success_heading,
                          style: EnvoyTypography.heading,
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
              if (!widget.isPrimeWallet)
                Padding(
                  padding: const EdgeInsets.only(
                    left: EnvoySpacing.xs,
                    right: EnvoySpacing.xs,
                    bottom: EnvoySpacing.medium2,
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return OnboardingButton(
                          label: S().component_continue,
                          onTap: () async {
                            Settings().updateAccountsViewSettings();
                            LocalStorage().prefs.setBool(PREFS_ONBOARDED, true);
                            if (context.mounted) {
                              context.go("/");
                            }
                          });
                    },
                  ),
                ),
              if (widget.isPrimeWallet) SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
