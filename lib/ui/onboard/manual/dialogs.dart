// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

void showRestoreFailedDialog(BuildContext context) {
  showEnvoyDialog(
    context: context,
    dismissible: false,
    builder: Builder(builder: (context) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                Column(
                  children: [
                    Image.asset(
                      "assets/exclamation_triangle.png",
                      height: 80,
                      width: 80,
                    ),
                    const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.small,
                          horizontal: EnvoySpacing.medium1),
                      child: Text(
                          S().manual_setup_import_backup_fails_modal_heading,
                          textAlign: TextAlign.center,
                          style: EnvoyTypography.heading),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.small,
                          horizontal: EnvoySpacing.medium1),
                      child: Text(
                        S().manual_setup_import_backup_fails_modal_subheading,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                OnboardingButton(
                    type: EnvoyButtonTypes.primaryModal,
                    label: S().component_continue,
                    onTap: () {
                      Navigator.pop(context);
                    }),
                const SizedBox(
                  height: EnvoySpacing.medium1,
                ),
              ],
            ),
          ),
        ),
      );
    }),
  );
}

Future<void> openBackupFile(BuildContext buildContext) async {
  final navigator = Navigator.of(buildContext);
  final context = buildContext;
  var result = await FilePicker.platform.pickFiles();

  if (result != null) {
    var success = false;

    try {
      success =
          await EnvoySeed().restoreData(filePath: result.files.single.path!);
    } catch (e) {
      success = false;
    }
    if (success) {
      navigator.push(MaterialPageRoute(builder: (context) {
        return const WalletSetupSuccess();
      }));
    } else {
      if (context.mounted) {
        showRestoreFailedDialog(context);
      }
    }
  } else {
    if (context.mounted) {
      showRestoreFailedDialog(context);
    }
  }
}
