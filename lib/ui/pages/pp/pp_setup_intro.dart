// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/pages/pp/pp_new_seed.dart';
import 'package:envoy/ui/pages/pp/pp_restore_backup.dart';
import 'package:envoy/ui/pages/pp/pp_restore_seed.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class PpSetupIntroPage extends StatelessWidget {
  const PpSetupIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kToolbarHeight,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium1),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(EnvoySpacing.medium1),
              child: GestureDetector(
                  onTap: () {
                    OnboardingPage.popUntilHome(context);
                  },
                  child: const Icon(Icons.close_rounded)),
            )
          ],
        ),
        //using floating action button + offset for clamping the passport image to bottom nav
        //this is better than using a stack
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 100),
          child: Image.asset(
            "assets/pp_setup_intro.png",
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width / 1.3,
            height: MediaQuery.of(context).size.height / 1.3,
          ),
        ),
        bottomNavigationBar: envoyScaffoldShieldScrollView(
          context,
          Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: EnvoySpacing.medium1,
                  vertical: EnvoySpacing.large2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    //TODO: wrap this guy in a column
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.medium2),
                            child: Column(
                              children: [
                                const Padding(
                                    padding:
                                        EdgeInsets.all(EnvoySpacing.small)),
                                Text(
                                  S().envoy_pp_setup_intro_heading,
                                  textAlign: TextAlign.center,
                                  style: EnvoyTypography.heading,
                                ),
                                const Padding(
                                    padding:
                                        EdgeInsets.all(EnvoySpacing.small)),
                                Text(
                                  S().envoy_pp_setup_intro_subheading,
                                  style: EnvoyTypography.info.copyWith(
                                      color: EnvoyColors.textTertiary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.small,
                        vertical: EnvoySpacing.small),
                    child: Column(
                      children: [
                        EnvoyButton(
                            type: EnvoyButtonTypes.tertiary,
                            S().envoy_pp_setup_intro_cta3, onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const PpRestoreBackupPage();
                          }));
                        }),
                        const Padding(
                          padding: EdgeInsets.only(top: EnvoySpacing.small),
                        ),
                        EnvoyButton(
                            type: EnvoyButtonTypes.secondary,
                            S().envoy_pp_setup_intro_cta2, onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const PpRestoreSeedPage();
                          }));
                        }),
                        const Padding(
                          padding: EdgeInsets.only(top: EnvoySpacing.small),
                        ),
                        EnvoyButton(S().envoy_pp_setup_intro_cta1, onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const PpNewSeedPage();
                          }));
                        }),
                      ],
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
