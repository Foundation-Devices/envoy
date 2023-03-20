// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';

//ignore: must_be_immutable
class FwAndroidInstructionsPage extends StatelessWidget {
  bool onboarding;
  FwAndroidInstructionsPage({this.onboarding = true});

  @override
  Widget build(BuildContext context) {
    var fw = FwUploader(UpdatesManager().getStoredFw());
    return OnboardingPage(
      key: Key("fw_android_instructions"),
      text: [
        OnboardingText(
          header: "Allow phone to access the microSD card",
          text:
              "Grant phone access to copy files to the microSD card with the name PASSPORT-SD.",
        )
      ],
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: "Continue",
            onTap: () {
              fw.getDirectoryContentPermission();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage(onboarding: onboarding);
              }));
            }),
      ],
    );
  }
}
