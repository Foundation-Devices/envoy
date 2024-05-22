// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class PpRestoreSeedSuccessPage extends StatelessWidget {
  const PpRestoreSeedSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("pp_restore_seed_success"),
      clipArt: Center(
        child: Image.asset(
          "assets/circle_ok.png",
          height: 140,
        ),
      ),
      text: [
        OnboardingText(
            header: S().envoy_pp_restore_seed_success_heading,
            text: S().envoy_pp_new_seed_success_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 2,
      buttons: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: EnvoySpacing.medium2,
          ),
          child: OnboardingButton(
              label: S().component_continue,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const SingleImportPpIntroPage(
                    isExistingDevice: false,
                  );
                }));
              }),
        ),
      ],
    );
  }
}
