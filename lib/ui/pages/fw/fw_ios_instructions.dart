// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FwIosInstructionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    var fw = FwUploader(UpdatesManager().getStoredFw());
    return OnboardingPage(
      key: Key("fw_ios_instructions"),
      clipArt: Image.asset("assets/fw_ios_instructions.png"),
      text: [
        OnboardingText(
          header: loc.envoy_fw_ios_instructions_heading,
          text: loc.envoy_fw_ios_instructions_subheading,
        )
      ],
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: loc.envoy_fw_ios_instructions_cta,
            onTap: () {
              fw.promptUserForFolderAccess();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage();
              }));
            }),
      ],
    );
  }
}
