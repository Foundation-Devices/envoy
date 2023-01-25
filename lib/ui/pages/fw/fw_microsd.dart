// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_android_instructions.dart';
import 'package:envoy/ui/pages/fw/fw_ios_instructions.dart';
import 'package:envoy/ui/pages/fw/fw_passport.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'dart:io';
import 'package:envoy/business/devices.dart';

//ignore: must_be_immutable
class FwMicrosdPage extends StatelessWidget {
  bool onboarding;

  FwMicrosdPage({this.onboarding: true});

  @override
  Widget build(BuildContext context) {
    var fw = FwUploader(UpdatesManager().getStoredFw());
    return OnboardingPage(
      key: Key("fw_microsd"),
      clipArt: Image.asset("assets/fw_microsd.png"),
      text: [
        OnboardingText(
          header: S().envoy_fw_microsd_heading,
          text: S().envoy_fw_microsd_subheading,
        )
      ],
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: S().envoy_fw_microsd_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                try {
                  fw.upload();

                  // Here we assume user has updated all his devices
                  Devices()
                      .markAllUpdated(UpdatesManager().getStoredFwVersion()!);
                } catch (e) {
                  print("SD: error " + e.toString());
                  if (Platform.isIOS) // TODO: this needs to be smarter
                    return FwIosInstructionsPage(onboarding: onboarding);

                  if (Platform.isAndroid)
                    return FwAndroidInstructionsPage(onboarding: onboarding);
                }
                return FwPassportPage(
                  onboarding: onboarding,
                );
              }));
            }),
      ],
    );
  }
}
