// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_restore_seed_backup.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class PpRestoreSeedPage extends StatelessWidget {
  const PpRestoreSeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("pp_restore_seed"),
      clipArt: Image.asset("assets/pp_restore_seed.png"),
      text: [
        OnboardingText(
            header: S().envoy_pp_restore_seed_heading,
            text: S().envoy_pp_restore_seed_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 0,
      buttons: [
        Padding(
          padding: const EdgeInsets.only(
            left: EnvoySpacing.xs,
            right: EnvoySpacing.xs,
            bottom: EnvoySpacing.medium2,
          ),
          child: OnboardingButton(
              label: S().component_continue,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const PpRestoreSeedBackupPage();
                }));
              }),
        ),
      ],
    );
  }
}
