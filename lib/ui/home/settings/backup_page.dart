// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'dart:io' show Platform;
import 'package:envoy/ui/home/settings/setting_text.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
//import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/settings.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../onboard/magic/magic_setup_generate.dart';
import '../../onboard/magic/wallet_security/wallet_security_modal.dart';
import '../../widgets/blur_dialog.dart';

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
                    SettingText("Auto Backup"),
                    SettingToggle(() => s.syncToCloud, (enabled) {
                      setState(() {
                        s.syncToCloud = enabled;
                      });

                      if (enabled) {
                        showEnvoyDialog(
                            context: context,
                            dialog: WalletSecurityModal(
                              onLastStep: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return MagicSetupGenerate();
                                }));
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
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: !s.syncToCloud ? 0 : 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SettingText("Backup state"),
                            SettingText(
                              lastEnvoyServerBackup == null
                                  ? "Never backed up"
                                  : timeago.format(lastEnvoyServerBackup),
                              color: EnvoyColors.grey,
                            ),
                          ],
                        ),
                      ),
                      SettingText(
                        "Backup Now",
                        color: EnvoyColors.teal,
                        onTap: () {
                          EnvoySeed().backupData();
                        },
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: !s.syncToCloud ? 0 : 16,
                  child: Divider(),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: !s.syncToCloud ? 0 : 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SettingText("Seed state"),
                            FutureBuilder<DateTime?>(
                                future: lastCloudBackup,
                                builder: (context, snapshot) {
                                  return SettingText(
                                      !snapshot.hasData
                                          ? "Never backed up"
                                          : timeago.format(snapshot.data!),
                                      color: EnvoyColors.grey);
                                }),
                          ],
                        ),
                      ),
                      SettingText("Back up to cloud", color: EnvoyColors.teal,
                          onTap: () {
                        EnvoySeed().showSettingsMenu();
                      }),
                    ],
                  ),
                ),
                Divider(),
                SettingText("Download Backup File"),
                Divider(),
                SettingText("View Seed Words"),
                Divider(),
                Divider(),
                Divider(),
                FutureBuilder<String?>(
                    future: seed.get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return AboutText(
                            snapshot.data == null ? "NULL" : snapshot.data!);
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                Divider(),
                AboutText(Platform.isAndroid ? "Last Backup" : "Last Restore"),
                FutureBuilder<DateTime?>(
                    future: lastCloudBackup,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return AboutText(snapshot.data == null
                            ? "NULL"
                            : snapshot.data!.toIso8601String());
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                if (Platform.isAndroid) Divider(),
                if (Platform.isAndroid)
                  AboutButton(
                    "Backup Settings",
                    onTap: () {
                      seed.showSettingsMenu();
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
