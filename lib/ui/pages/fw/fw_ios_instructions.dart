// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/devices.dart';
import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

//ignore: must_be_immutable
class FwIosInstructionsPage extends ConsumerWidget {
  final FwPagePayload fwPagePayload;

  const FwIosInstructionsPage({super.key, required this.fwPagePayload});

  @override
  Widget build(context, ref) {
    int deviceId = fwPagePayload.deviceId;
    final fwInfo = ref.watch(firmwareStreamProvider(deviceId));

    return CustomOnboardingPage(
      key: const Key("fw_ios_instructions"),
      topPadding: EnvoySpacing.large1,
      mainWidget: Column(
        children: [
          Image.asset("assets/fw_ios_instructions.png"),
          FadedDivider()
        ],
      ),
      title: S().envoy_fw_ios_instructions_heading,
      subheading: S().envoy_fw_ios_instructions_subheading,
      buttons: [
        EnvoyButton(S().component_continue,
            borderRadius:
                BorderRadius.all(Radius.circular(EnvoySpacing.medium1)),
            onTap: () async {
          final goRouter = GoRouter.of(context);
          final firmwareFile =
              await UpdatesManager().getStoredFirmware(deviceId);
          final uploader = FwUploader(firmwareFile);
          final folderPath = await uploader.promptUserForFolderAccess();

          if (folderPath != null) {
            await uploader.upload();
            Devices().markDeviceUpdated(deviceId, fwInfo.value!.storedVersion);
            goRouter.pushNamed(PASSPORT_UPDATE_IOS_SUCCESS,
                extra: fwPagePayload);
          } else {
            goRouter.pushNamed(PASSPORT_UPDATE_SD_CARD, extra: fwPagePayload);
          }
        }),
      ],
    );
  }
}

class FadedDivider extends StatelessWidget {
  const FadedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black,
            Colors.black,
            Colors.black.withValues(alpha: 0.0),
          ],
          stops: [
            0.0,
            0.1822,
            0.8179,
            0.9757,
          ],
        ),
      ),
    );
  }
}
