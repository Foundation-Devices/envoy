// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/magic/magic_recover_wallet.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:go_router/go_router.dart';

class OnboardEnvoyWelcomeScreen extends ConsumerStatefulWidget {
  const OnboardEnvoyWelcomeScreen({super.key});

  @override
  ConsumerState<OnboardEnvoyWelcomeScreen> createState() =>
      _OnboardEnvoyWelcomeScreenState();
}

//global variable to prevent welcome screen initState being called when navigating
bool _checkedMagicBackUpInWelcomeScreen = false;

class _OnboardEnvoyWelcomeScreenState
    extends ConsumerState<OnboardEnvoyWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
            child: EnvoyButton(
              S().component_skip,
              textStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
              type: EnvoyButtonTypes.tertiary,
              onTap: () {
                context.go("/");
              },
            ),
          )
        ],
      ),
      header: Transform.translate(
        offset: const Offset(-8, 68),
        child: Image.asset(
          "assets/envoy_on_device.png",
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width * 0.55,
          height: MediaQuery.of(context).size.height * 0.55,
        ),
      ),
      shield: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.minHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      Text(S().envoy_welcome_screen_heading,
                                          textAlign: TextAlign.center,
                                          style: EnvoyTypography.heading),
                                      const SizedBox(
                                          height: EnvoySpacing.small),
                                      LinkText(
                                        text:
                                            S().envoy_welcome_screen_subheading,
                                        textStyle:
                                            EnvoyTypography.body.copyWith(
                                          color: EnvoyColors.inactiveDark,
                                        ),
                                        linkStyle:
                                            EnvoyTypography.body.copyWith(
                                          color: EnvoyColors.inactiveDark,
                                          fontWeight: FontWeight.w700,
                                        ),
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
                      bottom: EnvoySpacing.xs),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: EnvoySpacing.medium1),
                          EnvoyButton(
                            S().envoy_welcome_screen_cta2,
                            type: EnvoyButtonTypes.secondary,
                            onTap: () {
                              context.pushNamed(ONBOARD_ENVOY_MANUAL_SETUP);
                            },
                          ),
                          const SizedBox(height: EnvoySpacing.medium1),
                          EnvoyButton(
                            S().envoy_welcome_screen_cta1,
                            onTap: () {
                              context.pushNamed(ONBOARD_ENVOY_MAGIC_SETUP);
                            },
                          ),
                          const SizedBox(height: EnvoySpacing.small),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 100)).then((value) async {
        //while pop back to home, welcome screen will init again, so we need to check if we already tried automatic recovery
        if (mounted) {
          if (!ref.read(triedAutomaticRecovery) &&
              !ref.read(successfulSetupWallet) &&
              !_checkedMagicBackUpInWelcomeScreen) {
            try {
              _checkedMagicBackUpInWelcomeScreen = true;
              //make sure automatic recovery only once
              if (await EnvoySeed().get() != null && mounted) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MagicRecoverWallet()));
              }
            } catch (e) {
              //no-op
            }
          }
        }
      });
    }
    super.initState();
  }
}
