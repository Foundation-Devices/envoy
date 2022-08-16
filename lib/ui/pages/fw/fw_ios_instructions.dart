// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

//ignore: must_be_immutable
class FwIosInstructionsPage extends StatelessWidget {
  bool returnHome;
  FwIosInstructionsPage({this.returnHome: false});

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
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: S().envoy_fw_ios_instructions_cta,
            onTap: () {
              fw.promptUserForFolderAccess();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage(returnHome: returnHome);
              }));
            }),
      ],
    );
  }
}
