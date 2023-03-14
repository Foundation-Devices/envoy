// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'dart:io' show Platform;
import 'package:envoy/ui/home/settings/setting_text.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/settings.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:envoy/ui/onboard/magic/magic_setup_generate.dart';
import 'package:envoy/ui/onboard/magic/wallet_security/wallet_security_modal.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/home/settings/backup/export_backup_modal.dart';

import 'export_seed_modal.dart';

class BackupPage extends StatefulWidget {
  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  late EnvoySeed seed;

  @override
  void initState() {
    seed = EnvoySeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var s = Settings();

    var lastEnvoyServerBackup = EnvoySeed().getLastBackupTime();
    var lastCloudBackup = EnvoySeed().getLocalSecretLastBackupTimestamp();

    return Container(
        color: Colors.black,
        child: Padding(
            padding: const EdgeInsets.only(top: 100, left: 40, right: 40),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingText(S().manual_toggle_off_autobackup),
                    SettingToggle(() => s.syncToCloud, (enabled) {
                      if (!enabled) {
                        setState(() {
                          s.syncToCloud = enabled;
                          s.store();
                        });
                      }

                      if (enabled) {
                        showEnvoyDialog(
                            context: context,
                            dialog: WalletSecurityModal(
                              confirmationStep: true,
                              onLastStep: () {
                                setState(() {
                                  s.syncToCloud = enabled;
                                  s.store();
                                });

                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return MagicSetupGenerate();
                                }));

                                setState(() {});
                              },
                            ));
                      }
                    }),
                  ],
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: !s.syncToCloud ? 0 : 16,
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: !s.syncToCloud ? 0 : 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SettingText(S()
                                .manual_toggle_on_seed_backedup_android_wallet_data),
                            SettingText(
                              S().manual_toggle_on_seed_backedup_iOS_backup_now,
                              color: EnvoyColors.teal,
                              onTap: () {
                                EnvoySeed().backupData();
                              },
                            ),
                          ],
                        ),
                        SettingText(
                          lastEnvoyServerBackup == null
                              ? S()
                                  .manual_toggle_on_seed_not_backedup_android_pending_backup
                              : "${timeago.format(lastEnvoyServerBackup)[0].toUpperCase()}${timeago.format(lastEnvoyServerBackup).substring(1).toLowerCase()} to Foundation server",
                          color: EnvoyColors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: !s.syncToCloud ? 0 : 16,
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: !s.syncToCloud ? 0 : 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SettingText(S()
                                .manual_toggle_on_seed_backedup_android_wallet_seed),
                            if (Platform.isAndroid)
                              SettingText(
                                  S().manual_toggle_on_seed_not_backedup_android_open_settings,
                                  color: EnvoyColors.teal, onTap: () {
                                EnvoySeed().showSettingsMenu();
                              })
                          ],
                        ),
                        FutureBuilder<DateTime?>(
                            future: lastCloudBackup,
                            builder: (context, snapshot) {
                              return SettingText(
                                  Platform.isIOS
                                      ? S()
                                          .manual_toggle_on_seed_backedup_iOS_stored_in_cloud
                                      : snapshot.hasData
                                          ? S()
                                              .manual_toggle_on_seed_backedup_android_stored
                                          : S()
                                              .manual_toggle_on_seed_not_backedup_android_seed_pending_backup,
                                  color: EnvoyColors.grey);
                            }),
                      ],
                    ),
                  ),
                ),
                Divider(),
                SettingText(
                  S().manual_toggle_off_download_backup_file,
                  onTap: () {
                    showEnvoyDialog(
                        context: context, dialog: ExportBackupModal());
                  },
                ),
                Divider(),
                SettingText(
                  S().manual_toggle_off_view_seed_words,
                  onTap: () {
                    showEnvoyDialog(
                        context: context, dialog: ExportSeedModal());
                  },
                ),
              ],
            )));
  }
}

class AboutButton extends StatelessWidget {
  final String label;
  final Function()? onTap;

  AboutButton(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 25.0,
          decoration: BoxDecoration(
              color: EnvoyColors.darkTeal,
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ))),
    );
  }
}

class AboutText extends StatelessWidget {
  final String label;
  final bool dark;

  const AboutText(
    this.label, {
    this.dark: false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
          color: dark ? Colors.white38 : Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        ));
  }
}
