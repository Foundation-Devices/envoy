// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/fw/fw_passport.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/business/fw_uploader.dart';

//ignore: must_be_immutable
class FwProgressPage extends StatelessWidget {
  bool onboarding;
  FwUploader fw;

  FwProgressPage(this.fw, {this.onboarding: true});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("fw_progress"),
      //clipArt: Image.asset("assets/fw_passport.png"),
      text: [
        OnboardingText(
          header: "Wait here",
          text: onboarding
              ? "There will be a spinner on this screen"
              : "It will transform to a checkmark and whisk you away",
        )
      ],
      buttons: [
        OnboardingButton(
            label: "Continue",
            onTap: () {
              fw.flush();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwPassportPage(
                  onboarding: onboarding,
                );
              }));
            })
      ],
    );
  }
}
