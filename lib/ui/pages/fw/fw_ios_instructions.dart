// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

//ignore: must_be_immutable
class FwIosInstructionsPage extends StatelessWidget {
  bool onboarding;

  FwIosInstructionsPage({this.onboarding = true});

  @override
  Widget build(BuildContext context) {
    var fw = FwUploader(UpdatesManager().getStoredFw());
    return OnboardingPage(
      key: Key("fw_ios_instructions"),
      clipArt: Image.asset("assets/fw_ios_instructions.png"),
      text: [
        OnboardingText(
          header: S().envoy_fw_ios_instructions_heading,
          text: S().envoy_fw_ios_instructions_subheading,
        )
      ],
      navigationDots: 6,
      navigationDotsIndex: 2,
      buttons: [
        OnboardingButton(
            label: S().envoy_fw_ios_instructions_cta,
            onTap: () {
              fw.promptUserForFolderAccess();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage(onboarding: onboarding);
              }));
            }),
      ],
    );
  }
}
