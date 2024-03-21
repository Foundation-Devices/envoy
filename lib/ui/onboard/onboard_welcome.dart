// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_privacy_setup.dart';
import 'package:envoy/ui/onboard/onboard_welcome_envoy.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/onboard/onboard_welcome_passport.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/envoy_seed.dart';

enum EscapeHatchTap { logo, text }

const List<EscapeHatchTap> secretCombination = [
  EscapeHatchTap.logo,
  EscapeHatchTap.logo,
  EscapeHatchTap.text,
  EscapeHatchTap.text,
  EscapeHatchTap.logo,
  EscapeHatchTap.logo,
];

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

final successfulSetupWallet = StateProvider((ref) => false);
final successfulManualRecovery = StateProvider((ref) => false);
final triedAutomaticRecovery = StateProvider((ref) => false);

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  List<EscapeHatchTap> escapeHatchTaps = [];

  registerEscapeTap(EscapeHatchTap tap) async {
    escapeHatchTaps.add(tap);

    if (listEquals(
        escapeHatchTaps,
        secretCombination
            .getRange(0, min(escapeHatchTaps.length, secretCombination.length))
            .toList())) {
      if (escapeHatchTaps.length == secretCombination.length) {
        escapeHatchTaps.clear();
        try {
          await EnvoySeed().removeSeedFromNonSecure();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Envoy Seed deleted!"), // TODO: FIGMA
          ));
        } on Exception catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Couldn't delete Envoy Seed!"), // TODO: FIGMA
          ));
        }
      }
    } else {
      escapeHatchTaps.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: EnvoyPatternScaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
        ),
        header: GestureDetector(
          onTap: () {
            registerEscapeTap(EscapeHatchTap.logo);
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Image.asset(
              "assets/envoy_logo_with_title.png",
            ),
          ),
        ),
        shield: Padding(
          padding: const EdgeInsets.all(EnvoySpacing.medium1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: EnvoySpacing.small,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: EnvoySpacing.small),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: EnvoySpacing.medium1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S().welcome_screen_heading,
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                  padding:
                                      EdgeInsets.all(EnvoySpacing.medium1)),
                              GestureDetector(
                                onTap: () {
                                  registerEscapeTap(EscapeHatchTap.text);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: EnvoySpacing.xs),
                                  child: Text(
                                    S().welcome_screen_subheading,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: EnvoySpacing.medium3),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.medium1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    EnvoyButton(
                      S().welcome_screen_cta2,
                      type: EnvoyButtonTypes.secondary,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            // Don't set up privacy if previously onboarded
                            if (LocalStorage().prefs.getBool(PREFS_ONBOARDED) ==
                                null) {
                              return OnboardPrivacySetup(
                                  setUpEnvoyWallet: false);
                            }
                            return LocalStorage()
                                    .prefs
                                    .getBool(PREFS_ONBOARDED)!
                                ? OnboardPassportWelcomeScreen()
                                : OnboardPrivacySetup(setUpEnvoyWallet: false);
                          },
                        ));
                      },
                    ),
                    Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                    EnvoyButton(
                      S().welcome_screen_ctA1,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            // Don't set up privacy if previously onboarded
                            if (LocalStorage().prefs.getBool(PREFS_ONBOARDED) ==
                                null) {
                              return OnboardPrivacySetup(
                                  setUpEnvoyWallet: true);
                            }
                            return LocalStorage()
                                    .prefs
                                    .getBool(PREFS_ONBOARDED)!
                                ? OnboardEnvoyWelcomeScreen()
                                : OnboardPrivacySetup(setUpEnvoyWallet: true);
                          },
                        ));
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
