// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/settings/backup/erase_warning.dart';
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
import 'package:envoy/ui/home/settings/backup/export_seed_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:envoy/ui/state/global_state.dart';

class BackupPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage>
    with WidgetsBindingObserver {
  late EnvoySeed seed;

  @override
  void initState() {
    seed = EnvoySeed();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // SFT-1737: refresh everything when app comes back into focus
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalState = ref.watch(globalStateProvider.notifier);
    var s = Settings();

    var lastEnvoyServerBackup = EnvoySeed().getLastBackupTime();
    var lastCloudBackup = EnvoySeed().getNonSecureLastBackupTimestamp();

    final _bottomOffset = MediaQuery.of(context).padding.bottom;

    return Container(
        color: Colors.black,
        child: Padding(
            padding: const EdgeInsets.only(top: 14, left: 40, right: 40),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingText(S().manual_toggle_off_autobackup),
                    SettingToggle(
                      () => s.syncToCloud,
                      (enabled) {
                        if (!enabled) {
                          setState(() {
                            s.syncToCloud = enabled;
                            s.store();

                            // Remove file from reach of OS backup mechanism
                            // Note this doesn't mean seed that's already backed up will be immediately removed
                            EnvoySeed().removeSeedFromNonSecure();
                          });
                        }

                        if (enabled) {
                          showEnvoyDialog(
                              context: context,
                              dialog: WalletSecurityModal(
                                confirmationStep: true,
                                onLastStep: () => {},
                                onConfirmBackup: () async {
                                  setState(() {
                                    s.syncToCloud = enabled;
                                    s.store();
                                  });
                                  // Once we copy to non-secure OS backup mechanisms can start working on it
                                  EnvoySeed().copySeedToNonSecure();
                                  Navigator.pop(context);
                                  await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return MagicSetupGenerate();
                                  }));
                                  setState(() {});
                                },
                                onDenyBackup: () {
                                  //TODO: disable auto-backup
                                  setState(() {
                                    s.syncToCloud = false;
                                    s.store();
                                  });
                                  Navigator.pop(context);
                                },
                              ));
                        }
                      },
                      enabled: false,
                    ),
                  ],
                ),
                SettingText(
                  s.syncToCloud
                      ? S()
                          .manual_toggle_on_seed_backedup_iOS_auto_backup_coming_soon
                      : S()
                          .manual_toggle_off_disabled_for_manual_seed_configuration,
                  color: EnvoyColors.grey,
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
                    child: SingleChildScrollView(
                      child: Container(
                        height: 80,
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
                                    EnvoySeed().backupData().then((_) {
                                      setState(() {});
                                    });
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
                    child: SingleChildScrollView(
                      child: Container(
                        height: 80,
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
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: _bottomOffset + 30.0),
                      child: EnvoyButton(
                        S().backups_erase_wallets_and_backups,
                        textStyle: TextStyle(
                          color: EnvoyColors.danger,
                          fontWeight: FontWeight.w900,
                        ),
                        type: EnvoyButtonTypes.tertiary,
                        onTap: () {
                          globalState.state = GlobalState.nuclearDelete;
                          showEraseWalletsAndBackupsWarning(context);
                        },
                      ),
                    ),
                  ),
                )
              ],
            )));
  }

  void showEraseWalletsAndBackupsWarning(BuildContext context) {
    showEnvoyDialog(
        context: context,
        dismissible: false,
        dialog: EraseWalletsAndBackupsWarning());
  }
}
