// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io' show Platform;
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/backup_section_title.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/home/settings/backup/erase_warning.dart';
import 'package:envoy/ui/home/settings/backup/export_backup_modal.dart';
import 'package:envoy/ui/home/settings/backup/export_seed_modal.dart';
import 'package:envoy/ui/home/settings/setting_text.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/state/global_state.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as new_colors;
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/ui/onboard/magic/wallet_security/wallet_security_modal.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage>
    with WidgetsBindingObserver {
  late EnvoySeed seed;
  bool _isBackupInProgress = false;
  Timer? _timer;
  bool _advancedVisible = false;

  @override
  void initState() {
    seed = EnvoySeed();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
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
      if (mounted) {
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

    final bottomOffset = MediaQuery.of(context).padding.bottom;
    final Locale activeLocale = Localizations.localeOf(context);

    return EnvoyScaffold(
        hasScrollBody: false,
        child: Padding(
            padding: const EdgeInsets.only(
                top: 14,
                left: EnvoySpacing.medium2,
                right: EnvoySpacing.medium2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: !s.syncToCloud ? 0 : 16,
                          child: const Padding(padding: EdgeInsets.all(8)),
                        ),

                        BackupSectionTitle(
                          title: S().backups_toggle_envoy_magic_backups,
                          icon: EnvoyIcons.phone,
                          switchValue: s.syncToCloud,
                          onSwitch: (value) {
                            if (value) {
                              showEnablingBackupDialog(context);
                            }
                            // todo: add flow
                            s.setSyncToCloud(value);
                            setState(() {});
                          },
                        ),

                        // if (!s.syncToCloud)
                        //   SettingText(
                        //     S().manual_toggle_off_disabled_for_manual_seed_configuration,
                        //     color: EnvoyColors.textTertiary,
                        //   ),
                        if (s.syncToCloud)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: EnvoySpacing.medium1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 100),
                                                child: SettingText(
                                                  S().backups_toggle_envoy_mobile_wallet_key,
                                                ),
                                              ),
                                            ),
                                            if (Platform.isAndroid)
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 190),
                                                child: SettingText(
                                                  S().manual_toggle_on_seed_not_backedup_android_open_settings,
                                                  color:
                                                      EnvoyColors.accentPrimary,
                                                  onTap: () {
                                                    EnvoySeed()
                                                        .showSettingsMenu();
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
                                                color: EnvoyColors.textTertiary,
                                                maxLines: 2,
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                  SettingText(S().backups_settingsAndMetadata),
                                  SettingText(
                                    _isBackupInProgress
                                        ? S()
                                            .manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress
                                        : lastEnvoyServerBackup == null
                                            ? S()
                                                .manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup
                                            : "${timeago.format(lastEnvoyServerBackup, locale: activeLocale.languageCode).capitalize()} ${S().manual_toggle_on_seed_backedup_iOS_toFoundationServers}",
                                    color: EnvoyColors.textTertiary,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: !s.syncToCloud ? 0 : 16,
                          child: const Padding(padding: EdgeInsets.all(8)),
                        ),

                        const Divider(),

                        ExpansionTile(
                          tilePadding: const EdgeInsets.all(0),
                          onExpansionChanged: (value) {
                            setState(() {
                              _advancedVisible = value;
                            });
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(S().backups_advancedBackups,
                                  style: EnvoyTypography.body
                                      .copyWith(color: Colors.white)),
                              AnimatedRotation(
                                duration: const Duration(milliseconds: 200),
                                turns: _advancedVisible ? 0.0 : 0.5,
                                child: const Icon(
                                  Icons.keyboard_arrow_up_sharp,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          trailing: const SizedBox(),
                          controlAffinity: ListTileControlAffinity.platform,
                          childrenPadding: const EdgeInsets.only(left: 8),
                          children: <Widget>[
                            ListTile(
                              dense: true,
                              onTap: () {},
                              contentPadding: const EdgeInsets.all(0),
                              title: SettingText(
                                  S().backups_viewMobileWalletSeed, onTap: () {
                                showEnvoyDialog(
                                    context: context,
                                    dialog: const ExportSeedModal());
                              }),
                            ),
                            ListTile(
                              dense: true,
                              onTap: () {},
                              contentPadding: const EdgeInsets.all(0),
                              title: SettingText(
                                  S().backups_downloadSettingsMetadataBackupFile,
                                  onTap: () {
                                showEnvoyDialog(
                                    context: context,
                                    dialog: const ExportBackupModal());
                              }),
                            ),
                            ListTile(
                              dense: true,
                              onTap: () {},
                              contentPadding: const EdgeInsets.all(0),
                              title: SettingText(
                                  S().backups_downloadBIP329BackupFile,
                                  onTap: () {
                                AccountManager().exportBIP329();
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: bottomOffset + 30.0),
                  child: Column(
                    children: [
                      if (s.syncToCloud)
                        EnvoyButton(
                          _isBackupInProgress
                              ? S().manual_toggle_on_seed_backingup
                              : S()
                                  .manual_toggle_on_seed_backedup_iOS_backup_now,
                          enabled: !_isBackupInProgress,
                          type: EnvoyButtonTypes.primary,
                          onTap: () {
                            // todo: text
                            showBackupDialog(context);
                          },
                        ),
                      EnvoyButton(
                        S().backups_erase_wallets_and_backups,
                        textStyle: const TextStyle(
                          color: EnvoyColors.danger,
                          fontWeight: FontWeight.w900,
                        ),
                        type: EnvoyButtonTypes.tertiary,
                        onTap: () {
                          globalState.state = GlobalState.nuclearDelete;
                          showEraseWalletsAndBackupsWarning(context);
                        },
                      ),
                    ],
                  ),
                )
              ],
            )));
  }

  void showEraseWalletsAndBackupsWarning(BuildContext context) {
    showEnvoyDialog(
        context: context,
        dismissible: false,
        dialog: const EraseWalletsAndBackupsWarning());
  }

  void showBackupDialog(BuildContext context) {
    showEnvoyDialog(
        context: context,
        dismissible: false,
        dialog: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.small,
                      vertical: EnvoySpacing.small,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                Image.asset(
                  "assets/exclamation_icon.png",
                  height: 64,
                  width: 64,
                ),
                const Padding(padding: EdgeInsets.all(8)),
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.all(EnvoySpacing.small),
                  child: Text(
                      S().manual_toggle_on_seed_backup_now_modal_heading,
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.heading),
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium3,
                          vertical: EnvoySpacing.small,
                        ),
                        child: Text(
                          S().manual_toggle_on_seed_backup_now_modal_subheading,
                          style: EnvoyTypography.info.copyWith(
                              color: new_colors.EnvoyColors.textTertiary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: OnboardingButton(
                      type: EnvoyButtonTypes.primaryModal,
                      label: S().component_continue,
                      onTap: () {
                        Navigator.pop(context);
                        createBackup();
                      }),
                ),
              ],
            ),
          ),
        ));
  }

  showEnablingBackupDialog(BuildContext context) {
    showEnvoyPopUp(
        context,
        S().backups_manualToMagicrModal_subheader,
        S().component_continue,
        (_) {
          Navigator.of(context).pop();
        },
        title: S().backups_manualToMagicrModal_header,
        secondaryButtonLabel: S().component_back,
        onSecondaryButtonTap: (_) {
          Navigator.of(context).pop();
          showEnvoyDialog(
              context: context,
              dialog: WalletSecurityModal(
                onLastStep: () {
                  Navigator.pop(context);
                },
              ));
        },
        showCloseButton: false,
        icon: EnvoyIcons.info,
        learnMoreText: S().component_learnMore,
        onLearnMore: () {
          showEnvoyDialog(
              context: context,
              dialog: WalletSecurityModal(
                onLastStep: () {
                  Navigator.pop(context);
                },
              ));
        });
  }
}
