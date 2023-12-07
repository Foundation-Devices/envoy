// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:backup/backup.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_create_and_store_backup.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/manual/dialogs.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';

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
                          openBackupFile(context);
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
}

class RecoverViaQR extends StatefulWidget {
  RecoverViaQR({Key? key, required this.seed}) : super(key: key);

  final String seed;

  @override
  State<RecoverViaQR> createState() => _RecoverViaQR();
}

class _RecoverViaQR extends State<RecoverViaQR> {
  Map<String, String>? data;

  checkForMagicRecover(String seed) async {
    List<String> seedList = widget.seed.split(" ");
    try {
      data = await Backup.restore(
          seed, Settings().envoyServerAddress, Tor.instance);
      setState(() {
        if (data != null)
          showEnvoyPopUp(
              context,
              title: "Magic Backup Detected",
              //TODO: Figma
              "A Magic Backup was found on the server.\nRestore your backup?",
              //TODO: Figma
              "Restore",
              //TODO: Figma
              () async {
                await tryMagicRecover(seedList, seed, data, context);
              },
              icon: EnvoyIcons.info,
              secondaryButtonLabel: "Ignore",
              //TODO: Figma
              onSecondaryButtonTap: () {
                manualRecover(seedList, context);
                Navigator.pop(context);
              },
              dismissible: false);
        else
          manualRecover(seedList, context);
      });
    } catch (e) {
      manualRecover(seedList, context);
    }
  }

  @override
  void initState() {
    super.initState();
    checkForMagicRecover(widget.seed);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  color: EnvoyColors.teal,
                  backgroundColor: EnvoyColors.greyLoadingSpinner,
                  strokeWidth: 4.71,
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}

Future<void> tryMagicRecover(List<String> seedList, String seed,
    Map<String, String>? data, BuildContext context) async {
  await EnvoySeed().create(seedList);
  bool success = await EnvoySeed().processRecoveryData(seed, data);

  if (success) {
    Settings().syncToCloud = true;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return WalletSetupSuccess();
    }));
  } else
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ManualSetup();
    }));
}

Future<void> manualRecover(List<String> seedList, BuildContext context) async {
  bool success = await EnvoySeed().create(seedList);

  if (success) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ManualSetupImportBackup()));
  } else
    showInvalidSeedDialog(
      context: context,
    );
}
