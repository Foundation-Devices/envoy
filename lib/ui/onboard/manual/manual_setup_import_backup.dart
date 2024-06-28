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
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/manual/dialogs.dart';
import 'package:rive/rive.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class ManualSetupImportBackup extends StatefulWidget {
  const ManualSetupImportBackup({super.key});

  @override
  State<ManualSetupImportBackup> createState() =>
      _ManualSetupImportBackupState();
}

class _ManualSetupImportBackupState extends State<ManualSetupImportBackup> {
  StateMachineController? _stateMachineController;
  bool _isRecoveryInProgress = false;

  @override
  void dispose() {
    _stateMachineController?.dispose();
    super.dispose();
  }

  _onRiveInit(Artboard artBoard) {
    _stateMachineController =
        StateMachineController.fromArtboard(artBoard, 'STM');
    artBoard.addController(_stateMachineController!);
    _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
  }

  Widget _recoveryInProgress(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints.tight(const Size.fromHeight(240)),
            child: Transform.scale(
              scale: 1.2,
              child: RiveAnimation.asset(
                "assets/envoy_loader.riv",
                fit: BoxFit.contain,
                onInit: _onRiveInit,
              ),
            ),
          ),
          const SizedBox(
            height: EnvoySpacing.xl * 2,
          ),
          Text(
            S().magic_setup_recovery_retry_header,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecoveryInProgress) {
      return OnboardPageBackground(
        child: Material(
          color: Colors.transparent,
          child: _recoveryInProgress(context),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: OnboardPageBackground(
          child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: EnvoySpacing.small),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.large3),
              child: Image.asset(
                "assets/fw_intro.png",
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.small),
                      child: Text(
                        S().manual_setup_import_backup_CTA2,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: EnvoySpacing.medium3),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.large1),
                      child: Text(S().manual_setup_import_backup_subheading,
                          textAlign: TextAlign.center,
                          style: EnvoyTypography.info
                              .copyWith(color: EnvoyColors.textTertiary)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            Padding(
              padding: const EdgeInsets.only(
                  left: EnvoySpacing.medium1,
                  right: EnvoySpacing.medium1,
                  bottom: EnvoySpacing.medium2,
                  top: EnvoySpacing.small),
              child: Column(
                children: [
                  OnboardingButton(
                      type: EnvoyButtonTypes.secondary,
                      label: S().manual_setup_import_backup_CTA2,
                      onTap: () {
                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            _isRecoveryInProgress = true;
                          });
                        });
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          openBackupFile(context).then((value) {
                            setState(() {
                              _isRecoveryInProgress = false;
                            });
                          });
                        });
                      }),
                  OnboardingButton(
                      type: EnvoyButtonTypes.primary,
                      label: S().manual_setup_import_backup_CTA1,
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const ManualSetupCreateAndStoreBackup();
                        }));
                      }),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class RecoverFromSeedLoader extends StatefulWidget {
  const RecoverFromSeedLoader({super.key, required this.seed});

  final String seed;

  @override
  State<RecoverFromSeedLoader> createState() => _RecoverFromSeedLoaderState();
}

class _RecoverFromSeedLoaderState extends State<RecoverFromSeedLoader> {
  Map<String, String>? data;

  checkForCloudBackup(String seed) async {
    List<String> seedList = widget.seed.split(" ");
    try {
      data = await Backup.restore(
          seed, Settings().envoyServerAddress, Tor.instance);
      setState(() {
        if (data != null) {
          showEnvoyPopUp(
              context,
              title: S().manual_setup_magicBackupDetected_heading,
              S().manual_setup_magicBackupDetected_subheading,
              S().manual_setup_magicBackupDetected_restore,
              (BuildContext context) async {
                await tryMagicRecover(seedList, seed, data, context);
              },
              icon: EnvoyIcons.info,
              secondaryButtonLabel: S().manual_setup_magicBackupDetected_ignore,
              onSecondaryButtonTap: (BuildContext context) {
                recoverManually(seedList, context);
                Navigator.pop(context);
              },
              dismissible: false);
        } else {
          if (mounted) {
            recoverManually(seedList, context);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        recoverManually(seedList, context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkForCloudBackup(widget.seed);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  color: EnvoyColors.tealLight,
                  backgroundColor: EnvoyColors.textInactive,
                  strokeWidth: 8,
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
  final navigator = Navigator.of(context);
  await EnvoySeed().create(seedList);
  bool success = await EnvoySeed().processRecoveryData(seed, data);

  if (success) {
    Settings().syncToCloud = true;
    navigator.push(MaterialPageRoute(builder: (context) {
      return const WalletSetupSuccess();
    }));
  } else {
    navigator.push(MaterialPageRoute(builder: (context) {
      return const ManualSetup();
    }));
  }
}

Future<void> recoverManually(
    List<String> seedList, BuildContext context) async {
  bool success = await EnvoySeed().create(seedList);

  if (success && context.mounted) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ManualSetupImportBackup()));
  } else {
    if (context.mounted) {
      showInvalidSeedDialog(
        context: context,
      );
    }
  }
}
