// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/magic/magic_recover_wallet.dart';
import 'package:envoy/ui/onboard/magic/magic_setup_tutorial.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class OnboardEnvoyWelcomeScreen extends ConsumerStatefulWidget {
  const OnboardEnvoyWelcomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardEnvoyWelcomeScreen> createState() =>
      _OnboardEnvoyWelcomeScreenState();
}

class _OnboardEnvoyWelcomeScreenState
    extends ConsumerState<OnboardEnvoyWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      shield: Container(
        height: max(MediaQuery.of(context).size.height * 0.38, 300),
        margin: EdgeInsets.symmetric(
            vertical: EnvoySpacing.medium1, horizontal: EnvoySpacing.medium1),
        padding: EdgeInsets.only(top: EnvoySpacing.large1),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
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
                  OnboardingPage.popUntilHome(context);
                },
              ),
            )
          ],
        ),
        //using floating action button + offset for clamping the passport image to bottom nav
        //this is better than using a stack
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Transform.translate(
          offset: Offset(-8, 70),
          child: Image.asset(
            "assets/envoy_on_device.png",
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width * 0.55,
            height: MediaQuery.of(context).size.height * 0.55,
          ),
        ),
        bottomNavigationBar: EnvoyScaffoldShieldScrollView(
          context,
          Padding(
              padding: const EdgeInsets.only(
                  right: EnvoySpacing.medium1,
                  left: EnvoySpacing.medium1,
                  top: EnvoySpacing.medium1),
              child: Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: EnvoySpacing.large2,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: EnvoySpacing.medium1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: EnvoySpacing.medium1),
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  S().envoy_welcome_screen_heading,
                                  textAlign: TextAlign.center,
                                  style: EnvoyTypography.body.copyWith(
                                    fontSize: 20,
                                    color: EnvoyColors.gray1000,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.all(EnvoySpacing.xs)),
                                LinkText(
                                  text: S().envoy_welcome_screen_subheading,
                                  textStyle: EnvoyTypography.body.copyWith(
                                    color: EnvoyColors.inactiveDark,
                                  ),
                                  linkStyle: EnvoyTypography.body.copyWith(
                                    color: EnvoyColors.inactiveDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(EnvoySpacing.medium2),
                          child: Column(
                            children: [
                              Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                              EnvoyButton(
                                S().envoy_welcome_screen_cta2,
                                type: EnvoyButtonTypes.secondary,
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return ManualSetup();
                                  }));
                                },
                              ),
                              Padding(
                                  padding: EdgeInsets.all(EnvoySpacing.small)),
                              EnvoyButton(
                                S().envoy_welcome_screen_cta1,
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return MagicSetupTutorial();
                                  }));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }

  @override
  void initState() {
    if (mounted) {
      Future.delayed(Duration(milliseconds: 100)).then((value) async {
        ///while pop back to home, welcome screen will init again, so we need to check if we already tried automatic recovery
        if (!ref.read(triedAutomaticRecovery) &&
            !ref.read(successfulSetupWallet)) {
          try {
            if (await EnvoySeed().get() != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MagicRecoverWallet()));
            }
          } catch (e) {
            //no-op
          }
        }
      });
    }
    super.initState();
  }
}
