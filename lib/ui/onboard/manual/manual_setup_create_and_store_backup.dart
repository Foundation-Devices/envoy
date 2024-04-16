// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/settings/backup/erase_warning.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/state/global_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualSetupCreateAndStoreBackup extends ConsumerStatefulWidget {
  const ManualSetupCreateAndStoreBackup({super.key});

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
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox.shrink(),
                  ),
                  Flexible(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Image.asset("assets/onboarding_lock_icon.png"),
                  )),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S().manual_setup_create_and_store_backup_heading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        Text(
                          S().manual_setup_create_and_store_backup_subheading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
        OnboardingButton(
            type: EnvoyButtonTypes.primary,
            label: S().manual_setup_create_and_store_backup_CTA,
            onTap: () async {
              await EnvoySeed().saveOfflineData();

              if (globalState == GlobalState.nuclearDelete && context.mounted) {
                showEnvoyDialog(
                    context: context, dialog: const EraseWalletsConfirmation());
              } else {
                if (context.mounted) {
                  showWarningModal(context);
                }
              }
            })
      ],
    ));
  }

  void showWarningModal(BuildContext context) {
    showEnvoyDialog(
        context: context,
        dismissible: false,
        dialog: const BackupWarningModal());
  }
}

class BackupWarningModal extends ConsumerWidget {
  const BackupWarningModal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.all(8)),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline,
                      color: EnvoyColors.darkTeal, size: 68),
                  const Padding(padding: EdgeInsets.all(4)),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text(
                      S().manual_setup_create_and_store_backup_modal_subheading,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(2)),
                ],
              ),
              OnboardingButton(
                  type: EnvoyButtonTypes.primaryModal,
                  label: S().manual_setup_create_and_store_backup_modal_CTA,
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    //make sure system filepicker shown before navigating to success screen
                    await Future.delayed(const Duration(milliseconds: 200));
                    navigator.push(MaterialPageRoute(builder: (context) {
                      return const WalletSetupSuccess();
                    }));
                    //}
                  }),
              const Padding(padding: EdgeInsets.all(12)),
            ],
          ),
        ),
      ),
    );
  }
}
