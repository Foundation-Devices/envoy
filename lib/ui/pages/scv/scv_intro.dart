// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scv/scv_show_qr.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class ScvIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("scv_intro"),
      clipArt: Center(child: Image.asset("assets/shield_inspect.png")),
      text: [
        OnboardingText(
            header: S().envoy_scv_intro_heading,
            text: S().envoy_scv_intro_subheading)
      ],
      navigationDots: 3,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: S().envoy_scv_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScvShowQrPage();
              }));
            }),
      ],
    );
  }
}
