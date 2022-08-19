// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/pages/import_pp/import_pp_scan.dart';

class ImportPpIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("import_pp_intro"),
      text: [
        OnboardingText(
            header: S().envoy_import_pp_intro_heading,
            text: S().envoy_import_pp_intro_subheading),
      ],
      navigationDots: 2,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: S().envoy_import_pp_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ImportPpScanPage();
              }));
            }),
      ],
    );
  }
}
