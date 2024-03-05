// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/pages/fw/fw_ios_success.dart';

//ignore: must_be_immutable
class FwIosInstructionsPage extends ConsumerWidget {
  bool onboarding;
  int deviceId;

  FwIosInstructionsPage({this.onboarding = true, this.deviceId = 1});

  @override
  Widget build(context, ref) {
    final fwInfo = ref.watch(firmwareStreamProvider(deviceId));

    return OnboardingPage(
      key: Key("fw_ios_instructions"),
      clipArt: Image.asset("assets/fw_ios_instructions.png"),
      rightFunction: (_) {
        onboarding
            ? OnboardingPage.popUntilHome(context)
            : OnboardingPage.popUntilGoRoute(context);
      },
      text: [
        Flexible(
          child: SingleChildScrollView(
            child: OnboardingText(
              header: S().envoy_fw_ios_instructions_heading,
              text: S().envoy_fw_ios_instructions_subheading,
            ),
          ),
        )
      ],
      navigationDots: 6,
      navigationDotsIndex: 2,
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () async {
              final firmwareFile = await UpdatesManager().getStoredFw(deviceId);
              final uploader = FwUploader(firmwareFile);
              final folderPath = await uploader.promptUserForFolderAccess();

              if (folderPath != null) {
                await uploader.upload();
                Devices()
                    .markDeviceUpdated(deviceId, fwInfo.value!.storedVersion);

                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return FwIosSuccessPage(
                    onboarding: onboarding,
                  );
                }));
              } else {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return FwMicrosdPage(onboarding: onboarding);
                }));
              }
            }),
      ],
    );
  }
}
