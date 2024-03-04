// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
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
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/state/global_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:envoy/ui/theme/envoy_spacing.dart';

class BackupPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage>
    with WidgetsBindingObserver {
  late EnvoySeed seed;
  bool _isBackupInProgress = false;
  Timer? _timer;

  @override
  void initState() {
    seed = EnvoySeed();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(Duration(minutes: 1), (Timer timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future createBackup() async {
    try {
      setState(() {
        _isBackupInProgress = true;
      });
      await EnvoySeed().backupData();
      if (this.mounted) {
        setState(() {
          _isBackupInProgress = false;
        });
      }
    } catch (e) {
      setState(() {
        _isBackupInProgress = false;
      });
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
    final Locale activeLocale = Localizations.localeOf(context);

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
                SettingText(S().magic_setup_tutorial_heading),
                if (!s.syncToCloud)
                  SettingText(
                    S().manual_toggle_off_disabled_for_manual_seed_configuration,
                    color: EnvoyColors.grey,
                  ),
                if (s.syncToCloud)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: 150),
                                    child: SettingText(
                                      S().manual_toggle_on_seed_backedup_android_wallet_data,
                                    ),
                                  ),
                                ),
                                Builder(
                                  builder: (_) {
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
                                      return Container(
                                        constraints:
                                            BoxConstraints(maxWidth: 150),
                                        child: SettingText(
                                          S().manual_toggle_on_seed_backedup_iOS_backup_now,
                                          color: EnvoyColors.teal,
                                          onTap: () {
                                            showBackupDialog(context);
                                          },
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            SettingText(
                              _isBackupInProgress
                                  ? S()
                                      .manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress
                                  : lastEnvoyServerBackup == null
                                      ? S()
                                          .manual_toggle_on_seed_not_backedup_pending_android_data_pending_backup
                                      : "${timeago.format(lastEnvoyServerBackup, locale: activeLocale.languageCode).capitalize()} ${S().manual_toggle_on_seed_backedup_iOS_toFoundationServers}",
                              color: EnvoyColors.grey,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: !s.syncToCloud ? 0 : 16,
                  child: Padding(padding: EdgeInsets.all(8)),
                ),
                if (s.syncToCloud)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: 100),
                                    child: SettingText(
                                      S().manual_toggle_on_seed_backedup_android_wallet_seed,
                                    ),
                                  ),
                                ),
                                if (Platform.isAndroid)
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 190),
                                    child: SettingText(
                                      S().manual_toggle_on_seed_not_backedup_android_open_settings,
                                      color: EnvoyColors.teal,
                                      onTap: () {
                                        EnvoySeed().showSettingsMenu();
                                      },
                                    ),
                                  ),
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
                                                .manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup,
                                    color: EnvoyColors.grey,
                                    maxLines: 2,
                                  );
                                }),
                          ],
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
                  maxLines: 2,
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

  void showBackupDialog(BuildContext context) {
    showEnvoyDialog(
        context: context,
        dismissible: false,
        dialog: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
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
                Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/exclamation_icon.png",
                      height: 64,
                      width: 64,
                    ),
                    Padding(padding: EdgeInsets.all(8)),
                    SingleChildScrollView(
                      child: Flexible(
                        child: Column(
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: 200),
                              padding: const EdgeInsets.all(EnvoySpacing.small),
                              child: Text(
                                  S().manual_toggle_on_seed_backup_now_modal_heading,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge),
                            ),
                            Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                            Padding(
                              padding: const EdgeInsets.all(EnvoySpacing.small),
                              child: Text(
                                S().manual_toggle_on_seed_backup_now_modal_subheading,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                OnboardingButton(
                    type: EnvoyButtonTypes.primaryModal,
                    label: S().component_continue,
                    onTap: () {
                      Navigator.pop(context);
                      createBackup();
                    }),
                Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
              ],
            ),
          ),
        ));
  }
}
