// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'onboarding_page.dart';

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
    EnvoyStorage().setBool(PREFS_ONBOARDED, true);

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
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: EnvoySpacing.xl),
                  Image.asset(
                    "assets/images/check_info.png",
                    height: 184,
                  ),
                  const SizedBox(height: EnvoySpacing.medium3),
                  Text(
                    widget.isPrimeWallet
                        ? S().finish_connectedSuccess_header
                        : S().onboarding_magicUserMobileSuccess_header,
                    style: EnvoyTypography.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: EnvoySpacing.medium3),
                  Text(S().wallet_setup_success_subheading,
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.body
                          .copyWith(color: EnvoyColors.textTertiary)),
                ],
              ),
              if (!widget.isPrimeWallet)
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: EnvoySpacing.medium2,
                      left: EnvoySpacing.xs,
                      right: EnvoySpacing.xs),
                  child: OnboardingButton(
                    label: S().component_continue,
                    type: EnvoyButtonTypes.primary,
                    onTap: () {
                      Settings().updateAccountsViewSettings();
                      if (mounted) {
                        context.go("/");
                      }
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
