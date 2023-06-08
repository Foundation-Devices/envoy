// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io' show Platform;

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/settings/backup/erase_warning.dart';
import 'package:envoy/ui/home/settings/backup/export_backup_modal.dart';
import 'package:envoy/ui/home/settings/backup/export_seed_modal.dart';
import 'package:envoy/ui/home/settings/setting_text.dart';
import 'package:envoy/ui/state/global_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class BackupPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage>
    with WidgetsBindingObserver {
  late EnvoySeed seed;
  bool _isBackupInProgress = false;

  @override
  void initState() {
    seed = EnvoySeed();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future createBackup(BuildContext context) async {
    try {
      setState(() {
        _isBackupInProgress = true;
      });
      await EnvoySeed().backupData();
      setState(() {
        _isBackupInProgress = false;
      });
    } catch (e) {
      setState(() {
        _isBackupInProgress = false;
      });
      EnvoyToast(
        backgroundColor: Colors.lightBlue,
        replaceExisting: true,
        duration: Duration(seconds: 3),
        message: "Unable to backup. Please try again later.",
        icon: Icon(
          Icons.error_outline_rounded,
          color: EnvoyColors.darkCopper,
        ),
      ).show(context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // SFT-1737: refresh everything when app comes back into focus
    if (state == AppLifecycleState.resumed) {
      // re-render only if the widget is mounted
      if (mounted) {
        setState(() {});
      }
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
                    SettingText(S().manual_toggle_off_automatic_backups),
                    // SettingToggle(
                    //   () => s.syncToCloud,
                    //   (enabled) {
                    //     if (!enabled) {
                    //       setState(() {
                    //         s.syncToCloud = enabled;
                    //         s.store();
                    //
                    //         // Remove file from reach of OS backup mechanism
                    //         // Note this doesn't mean seed that's already backed up will be immediately removed
                    //         EnvoySeed().removeSeedFromNonSecure();
                    //       });
                    //     }
                    //
                    //     if (enabled) {
                    //       showEnvoyDialog(
                    //           context: context,
                    //           dialog: WalletSecurityModal(
                    //             confirmationStep: true,
                    //             onLastStep: () => {},
                    //             onConfirmBackup: () async {
                    //               setState(() {
                    //                 s.syncToCloud = enabled;
                    //                 s.store();
                    //               });
                    //               // Once we copy to non-secure OS backup mechanisms can start working on it
                    //               EnvoySeed().copySeedToNonSecure();
                    //               Navigator.pop(context);
                    //               await Navigator.of(context).push(
                    //                   MaterialPageRoute(builder: (context) {
                    //                 return MagicSetupGenerate();
                    //               }));
                    //               setState(() {});
                    //             },
                    //             onDenyBackup: () {
                    //               //TODO: disable auto-backup
                    //               setState(() {
                    //                 s.syncToCloud = false;
                    //                 s.store();
                    //               });
                    //               Navigator.pop(context);
                    //             },
                    //           ));
                    //     }
                    //   },
                    //   enabled: false,
                    // ),
                  ],
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: !s.syncToCloud ? 0 : 16,
                  child: Padding(padding: EdgeInsets.all(8)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: !s.syncToCloud ? 0 : 60,
                    child: SingleChildScrollView(
                      child: Container(
                        height: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SettingText(S()
                                    .manual_toggle_on_seed_backedup_android_wallet_data),
                                Builder(
                                  builder: (context) {
                                    if (_isBackupInProgress) {
                                      return SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: EnvoyColors.teal,
                                          backgroundColor: Color(0xffD9D9D9),
                                        ),
                                      );
                                    } else {
                                      return SettingText(
                                        S().manual_toggle_on_seed_backedup_iOS_backup_now,
                                        color: EnvoyColors.teal,
                                        onTap: () {
                                          createBackup(context);
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            SettingText(
                              _isBackupInProgress
                                  ? "Backup in Progress"
                                  : lastEnvoyServerBackup == null
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
                  child: Padding(padding: EdgeInsets.all(8)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: !s.syncToCloud ? 0 : 60,
                    child: SingleChildScrollView(
                      child: Container(
                        height: 60,
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
                  S().manual_toggle_off_download_wallet_data,
                  onTap: () {
                    showEnvoyDialog(
                        context: context, dialog: ExportBackupModal());
                  },
                ),
                Divider(),
                SettingText(
                  S().manual_toggle_off_view_wallet_seed,
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
