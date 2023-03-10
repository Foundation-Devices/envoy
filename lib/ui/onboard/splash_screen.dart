// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/expert/manual_setup.dart';
import 'package:envoy/ui/onboard/magic/magic_setup_tutorial.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/local_storage.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only onboard once
    LocalStorage().prefs.setBool("onboarded", true);
    return OnboardingPage(
      key: Key("splash_screen"),
      leftFunction: null,
      right: Text("Skip"),
      clipArt: Image.asset("assets/envoy.png"),
      text: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: OnboardingText(
              header: S().splash_screen_heading,
              text: S().splash_screen_subheading),
        )
      ],
      buttons: [
        OnboardingButton(
            label: S().splash_screen_CTA3,
            type: EnvoyButtonTypes.tertiary,
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EnvoyColors.teal, fontWeight: FontWeight.w600),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleImportPpIntroPage();
              }));
            }),
        OnboardingButton(
            type: EnvoyButtonTypes.secondary,
            label: S().splash_screen_CTA2,
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EnvoyColors.teal, fontWeight: FontWeight.w600),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ManualSetup();
              }));
            }),
        OnboardingButton(
            label: S().splash_screen_CTA1,
            textStyle: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MagicSetupTutorial();
              }));
            }),
      ],
    );
  }
}
