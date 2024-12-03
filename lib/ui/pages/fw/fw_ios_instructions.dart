// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/devices.dart';
import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

//ignore: must_be_immutable
class FwIosInstructionsPage extends ConsumerWidget {
  final FwPagePayload fwPagePayload;

  const FwIosInstructionsPage({super.key, required this.fwPagePayload});

  @override
  Widget build(context, ref) {
    int deviceId = fwPagePayload.deviceId;
    final fwInfo = ref.watch(firmwareStreamProvider(deviceId));

    return OnboardingPage(
      key: const Key("fw_ios_instructions"),
      clipArt: Image.asset("assets/fw_ios_instructions.png"),
      text: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: OnboardingText(
                  header: S().envoy_fw_ios_instructions_heading,
                  text: S().envoy_fw_ios_instructions_subheading,
                ),
              ),
            ),
          ],
        )
      ],
      navigationDots: 6,
      navigationDotsIndex: 2,
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () async {
              final goRouter = GoRouter.of(context);
              final firmwareFile = await UpdatesManager().getStoredFw(deviceId);
              final uploader = FwUploader(firmwareFile);
              final folderPath = await uploader.promptUserForFolderAccess();

              if (folderPath != null) {
                await uploader.upload();
                Devices()
                    .markDeviceUpdated(deviceId, fwInfo.value!.storedVersion);
                goRouter.goNamed(PASSPORT_UPDATE_IOS_SUCCESS,
                    extra: fwPagePayload);
              } else {
                goRouter.goNamed(PASSPORT_UPDATE_SD_CARD, extra: fwPagePayload);
              }
            }),
      ],
    );
  }
}
