// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/home/settings/backup/erase_warning.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/state/global_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class ManualSetupCreateAndStoreBackup extends ConsumerStatefulWidget {
  const ManualSetupCreateAndStoreBackup({Key? key}) : super(key: key);

  @override
  ConsumerState<ManualSetupCreateAndStoreBackup> createState() =>
      _ManualSetupCreateAndStoreBackupState();
}

class _ManualSetupCreateAndStoreBackupState
    extends ConsumerState<ManualSetupCreateAndStoreBackup> {
  @override
  Widget build(BuildContext context) {
    final globalState = ref.watch(globalStateProvider);
    return OnboardPageBackground(
        child: Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            constraints: BoxConstraints.tight(Size.fromHeight(260)),
            child: Image.asset("assets/onboarding_lock_icon.png"),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: EnvoySpacing.large1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      S().manual_setup_create_and_store_backup_heading,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EnvoySpacing.medium1),
                    Text(S().manual_setup_create_and_store_backup_subheading,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.info
                            .copyWith(color: EnvoyColors.textTertiary)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(EnvoySpacing.xs),
            child: SizedBox.shrink(),
          ),
          OnboardingButton(
              type: EnvoyButtonTypes.primary,
              label: S().manual_setup_create_and_store_backup_CTA,
              onTap: () async {
                await EnvoySeed().saveOfflineData();

                if (globalState == GlobalState.nuclearDelete) {
                  showEnvoyDialog(
                      context: context, dialog: EraseWalletsConfirmation());
                } else
                  showWarningModal(context);
              })
        ],
      ),
    ));
  }

  void showWarningModal(BuildContext context) {
    showEnvoyDialog(
        context: context, dismissible: false, dialog: BackupWarningModal());
  }
}

class BackupWarningModal extends ConsumerWidget {
  const BackupWarningModal({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: EnvoySpacing.medium3),
          EnvoyIcon(
            EnvoyIcons.info,
            size: EnvoyIconSize.big,
            color: EnvoyColors.accentPrimary,
          ),
          const SizedBox(height: EnvoySpacing.medium2),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.medium3),
                child: Text(
                  S().manual_setup_create_and_store_backup_modal_subheading,
                  style: EnvoyTypography.info
                      .copyWith(color: EnvoyColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium3),
            child: OnboardingButton(
                type: EnvoyButtonTypes.primaryModal,
                label: S().manual_setup_create_and_store_backup_modal_CTA,
                onTap: () async {
                  Navigator.pop(context);
                  //make sure system filepicker shown before navigating to success screen
                  await Future.delayed(Duration(milliseconds: 200));
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return WalletSetupSuccess();
                  }));
                  //}
                }),
          ),
        ],
      ),
    );
  }
}
