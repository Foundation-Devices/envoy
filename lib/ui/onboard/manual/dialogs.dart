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

void showRestoreFailedDialog(BuildContext context) {
  showEnvoyDialog(
    context: context,
    dismissible: false,
    builder: Builder(builder: (context) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(8)),
                Column(
                  children: [
                    Image.asset(
                      "assets/exclamation_triangle.png",
                      height: 80,
                      width: 80,
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Text(
                          S().manual_setup_import_backup_fails_modal_heading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Text(
                        S().manual_setup_import_backup_fails_modal_subheading,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(2)),
                  ],
                ),
                OnboardingButton(
                    type: EnvoyButtonTypes.primaryModal,
                    label: S().component_continue,
                    onTap: () {
                      Navigator.pop(context);
                    }),
                Padding(padding: EdgeInsets.all(12)),
              ],
            ),
          ),
        ),
      );
    }),
  );
}

Future<void> openBackupFile(BuildContext context) async {
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
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return WalletSetupSuccess();
      }));
    } else {
      showRestoreFailedDialog(context);
    }
  } else {
    showRestoreFailedDialog(context);
  }
}
