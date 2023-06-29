// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
import 'dart:io';
import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

//ignore: must_be_immutable
class FwIosInstructionsPage extends StatelessWidget {
  bool onboarding;
  int deviceId;

  FwIosInstructionsPage({this.onboarding = true, this.deviceId = 1});

  @override
  Widget build(BuildContext context) {
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
              UpdatesManager().getStoredFw(deviceId).then((File file) {
                FwUploader(file).promptUserForFolderAccess();
              });

              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage(onboarding: onboarding);
              }));
            }),
      ],
    );
  }
}
