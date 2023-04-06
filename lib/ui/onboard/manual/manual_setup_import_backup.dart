// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_create_and_store_backup.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:file_picker/file_picker.dart';

class ManualSetupImportBackup extends StatefulWidget {
  const ManualSetupImportBackup({Key? key}) : super(key: key);

  @override
  State<ManualSetupImportBackup> createState() =>
      _ManualSetupImportBackupState();
}

class _ManualSetupImportBackupState extends State<ManualSetupImportBackup> {
  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox.shrink(),
                ),
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset("assets/fw_intro.png"),
                )),
                Flexible(
                    child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.all(8)),
                      Text(
                        S().manual_setup_import_backup_heading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Padding(padding: EdgeInsets.all(12)),
                      Text(
                        S().manual_setup_import_backup_subheading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox.shrink(),
                ),
                Flexible(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    OnboardingButton(
                        type: EnvoyButtonTypes.secondary,
                        label: S().manual_setup_import_backup_CTA2,
                        onTap: () {
                          FilePicker.platform.pickFiles().then((result) {
                            if (result != null) {
                              EnvoySeed()
                                  .restoreData(
                                      filePath: result.files.single.path!)
                                  .then((success) {
                                if (success) {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return WalletSetupSuccess();
                                  }));
                                } else {
                                  showRestoreFailedDialog(context);
                                }
                              });
                            } else {
                              showRestoreFailedDialog(context);
                            }
                          });
                        }),
                    OnboardingButton(
                        type: EnvoyButtonTypes.primary,
                        label: S().manual_setup_import_backup_CTA1,
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ManualSetupCreateAndStoreBackup();
                          }));
                        }),
                  ],
                ))
              ],
            ),
          ),
        ),
      ],
    ));
  }

  void showRestoreFailedDialog(BuildContext context) {
    showEnvoyDialog(
      context: context,
      dismissible: false,
      builder: Builder(builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    label: "Continue",
                    onTap: () {
                      Navigator.pop(context);
                    }),
                Padding(padding: EdgeInsets.all(12)),
              ],
            ),
          ),
        );
      }),
    );
  }
}
