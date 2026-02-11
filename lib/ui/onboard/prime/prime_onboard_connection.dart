// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:envoy/ble/handlers/scv_handler.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

//TODO: this needs to go, once multiple primes are supported
const String primeSerialPref = "prime_serial";

class PrimeOnboardParing extends ConsumerStatefulWidget {
  const PrimeOnboardParing({super.key});

  @override
  ConsumerState<PrimeOnboardParing> createState() => _PrimeOnboardParingState();
}

class _PrimeOnboardParingState extends ConsumerState<PrimeOnboardParing> {
  bool canPop = true;

  //TODO: use provider to get firmware update status
  bool updateAvailable = false;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> showExitWarning(BuildContext context) {
    final Completer<bool> completer = Completer<bool>();
    showEnvoyDialog(
      context: context,
      dismissible: true,
      dialog: EnvoyPopUp(
        icon: EnvoyIcons.alert,
        typeOfMessage: PopUpState.warning,
        showCloseButton: false,
        title: S().onboarding_connectionModalAbort_header,
        content: S().onboarding_connectionModalAbort_content,
        primaryButtonLabel: S().component_cancel,
        secondaryButtonLabel: S().component_exit,
        onPrimaryButtonTap: (context) async {
          completer.complete(false);
          Navigator.pop(context);
        },
        onSecondaryButtonTap: (context) async {
          completer.complete(true);
          Navigator.pop(context);
        },
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final firmWareCheck = ref.watch(firmWareUpdateProvider);
    final deviceCheck = ref.watch(deviceSecurityProvider);

    ref.listen(onboardingStateStreamProvider, (prev, next) {
      next.whenData((state) {
        if (state == OnboardingState.firmwareUpdateScreen) {
          context.goNamed(ONBOARD_PRIME_FIRMWARE_UPDATE);
        } else if (state == OnboardingState.securingDevice) {
          context.goNamed(ONBOARD_PRIME_CONTINUING_SETUP);
        } else if (state == OnboardingState.walletConected) {
          context.goNamed(ONBOARD_PRIME_CONNECTED_SUCCESS);
        } else if (state == OnboardingState.completed) {
          context.go(ROUTE_ACCOUNTS_HOME);
        }
      });
    });

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (canPop, _) async {
        final exit = await showExitWarning(context);
        if (exit && context.mounted) {
          context.go(ROUTE_ACCOUNTS_HOME);
        }
      },
      child: EnvoyPatternScaffold(
        gradientHeight: 1.8,
        shieldHeightFactor: 0.58,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const EnvoyIcon(
              EnvoyIcons.chevron_left,
              color: EnvoyColors.solidWhite,
            ),
            onPressed: () async {
              if (context.canPop()) {
                final exit = await showExitWarning(context);
                if (exit && context.mounted) {
                  context.go(ROUTE_ACCOUNTS_HOME);
                }
              }
            },
          ),
          automaticallyImplyLeading: false,
        ),
        header: Transform.translate(
          offset: const Offset(0, 70),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(end: 1.0, begin: 0.0),
            curve: Curves.decelerate,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Hero(
              tag: "hero_prime_devices",
              child: Image.asset(
                "assets/images/prime_envoy_devices.png",
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width * 0.8,
                height: 320,
              ),
            ),
          ),
        ),
        shield: PageTransitionSwitcher(
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return SharedAxisTransition(
              fillColor: Colors.transparent,
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.vertical,
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
            child: mainWidget(deviceCheck, firmWareCheck, context),
          ),
        ),
      ),
    );
  }

  Widget mainWidget(
    SecurityStepModel deviceCheck,
    StepModel firmWareCheck,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: EnvoySpacing.medium1,
        horizontal: EnvoySpacing.medium1,
      ),
      child: Column(
        children: [
          Text(
            S().onboarding_connectionIntro_header,
            textAlign: TextAlign.center,
            style: EnvoyTypography.heading,
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final bleStep = ref.watch(bleConnectionProvider);
                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.medium1,
                    horizontal: EnvoySpacing.large1,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: EnvoySpacing.medium1,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EnvoyStepItem(step: bleStep),
                          SizedBox(height: EnvoySpacing.medium1),
                          EnvoyStepItem(step: deviceCheck),
                          SizedBox(height: EnvoySpacing.medium1),
                          if (deviceCheck.state != EnvoyStepState.ERROR)
                            EnvoyStepItem(
                              step: firmWareCheck,
                              highlight: updateAvailable,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (deviceCheck.state == EnvoyStepState.ERROR)
            _buildErrorContent(deviceCheck, context),
        ],
      ),
    );
  }

  Widget _buildErrorContent(
    SecurityStepModel deviceCheck,
    BuildContext context,
  ) {
    final isNetworkError = deviceCheck.errorType == ScvErrorType.networkError;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isNetworkError
              ? S().onboarding_connectionIntroErrorInternet_content
              : S().onboarding_connectionIntroError_content,
          style: EnvoyTypography.body.copyWith(
            color: EnvoyColors.copperLight500,
          ),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
          child: EnvoyButton(
            onTap: () {
              context.go("/");
            },
            S().onboarding_connectionIntroError_exitSetup,
            type: EnvoyButtonTypes.secondary,
          ),
        ),
        EnvoyButton(
          onTap: () {
            if (isNetworkError) {
              // Retry the security check
              ref
                  .read(onboardingDeviceProvider)
                  ?.qlHandler
                  .scvAccountHandler
                  .sendSecurityChallenge();
            } else {
              // Contact support for verification failure
              launchUrl(
                Uri.parse(
                  "https://community.foundation.xyz/c/passport-prime/12",
                ),
              );
            }
          },
          isNetworkError
              ? S().common_button_retry
              : S().common_button_contactSupport,
          type: EnvoyButtonTypes.primary,
        ),
      ],
    );
  }
}
