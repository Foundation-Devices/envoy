// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
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
  ProviderSubscription<PrimeOnboardingStep?>? _onboardingStepSubscription;

  @override
  void initState() {
    super.initState();
    _onboardingStepSubscription = ref.listenManual<PrimeOnboardingStep?>(
      primeOnboardingStepProvider,
      (_, next) => _routeFromOnboardingStep(next),
      fireImmediately: true,
    );
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      ref.read(successfulSetupWallet.notifier).state = true;
    });
    EnvoyStorage().setBool(PREFS_ONBOARDED, true);
  }

  @override
  void dispose() {
    _onboardingStepSubscription?.close();
    super.dispose();
  }

  void _routeFromOnboardingStep(PrimeOnboardingStep? state) {
    if (state == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (state) {
        case PrimeOnboardingStep.firmwareUpdateScreen:
          context.goNamed(ONBOARD_PRIME_FIRMWARE_UPDATE);
          break;
        case PrimeOnboardingStep.securingDevice:
          context.goNamed(ONBOARD_PRIME_CONTINUING_SETUP);
          break;
        case PrimeOnboardingStep.completed:
          context.go(ROUTE_ACCOUNTS_HOME);
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: OnboardPageBackground(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: EnvoySpacing.xl),
                      Image.asset("assets/images/check_info.png", height: 184),
                      const SizedBox(height: EnvoySpacing.medium3),
                      Text(
                        widget.isPrimeWallet
                            ? S().finish_connectedSuccess_header
                            : S().onboarding_magicUserMobileSuccess_header,
                        style: EnvoyTypography.heading,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: EnvoySpacing.medium3),
                      Text(
                        S().wallet_setup_success_subheading,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.body.copyWith(
                          color: EnvoyColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!widget.isPrimeWallet)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: EnvoySpacing.medium2,
                    left: EnvoySpacing.xs,
                    right: EnvoySpacing.xs,
                  ),
                  child: OnboardingButton(
                    label: S().component_continue,
                    type: EnvoyButtonTypes.primary,
                    onTap: () {
                      Settings().updateAccountsViewSettings();
                      if (mounted) {
                        GoRouter.of(context).go(ROUTE_ACCOUNTS_HOME);
                      }
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
