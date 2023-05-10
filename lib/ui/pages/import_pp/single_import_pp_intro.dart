// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/import_pp/single_import_pp_scan.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class SingleImportPpIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return (false);
      },
      child: OnboardingPage(
        key: Key("single_import_pp_intro"),
        clipArt: Image.asset("assets/import_pp_intro.png"),
        text: [
          OnboardingText(
              header: S().pair_existing_device_intro_heading,
              text: S().pair_existing_device_intro_subheading),
        ],
        navigationDots: 2,
        navigationDotsIndex: 0,
        buttons: [
          OnboardingButton(
              label: S().pair_existing_device_intro_CTA,
              fontWeight: FontWeight.w600,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return SingleImportPpScanPage();
                }));
              }),
        ],
      ),
    );
  }
}
