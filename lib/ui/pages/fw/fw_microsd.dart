// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_android_instructions.dart';
import 'package:envoy/ui/pages/fw/fw_ios_instructions.dart';
import 'package:envoy/ui/pages/fw/fw_passport.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

//ignore: must_be_immutable
class FwMicrosdPage extends StatelessWidget {
  bool returnHome;
  FwMicrosdPage({this.returnHome: false});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    var fw = FwUploader(UpdatesManager().getStoredFw());
    return OnboardingPage(
      key: Key("fw_microsd"),
      clipArt: Image.asset("assets/fw_microsd.png"),
      text: [
        OnboardingText(
          header: loc.envoy_fw_microsd_heading,
          text: loc.envoy_fw_microsd_subheading,
        )
      ],
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: loc.envoy_fw_microsd_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                try {
                  fw.upload();
                } catch (e) {
                  print("SD: error " + e.toString());
                  if (Platform.isIOS) // TODO: this needs to be smarter
                    return FwIosInstructionsPage(returnHome: returnHome);

                  if (Platform.isAndroid)
                    return FwAndroidInstructionsPage(returnHome: returnHome);
                }
                return FwPassportPage(
                  returnHome: returnHome,
                );
              }));
            }),
      ],
    );
  }
}
