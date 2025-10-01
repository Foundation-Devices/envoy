// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:backup/backup.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/dialogs.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_create_and_store_backup.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:tor/tor.dart';

class ManualSetupImportBackup extends StatefulWidget {
  const ManualSetupImportBackup({super.key});

  @override
  State<ManualSetupImportBackup> createState() =>
      _ManualSetupImportBackupState();
}

class _ManualSetupImportBackupState extends State<ManualSetupImportBackup> {
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;
  bool _isRecoveryInProgress = false;
  late final bool isTest;

  @override
  void initState() {
    super.initState();
    // IS_TEST flag from run_integration_tests.sh
    isTest = const bool.fromEnvironment('IS_TEST', defaultValue: true);
    _initRive();
  }

  void _initRive() async {
    _riveFile = await rive.File.asset("assets/envoy_loader.riv",
        riveFactory: rive.Factory.rive);
    _controller = rive.RiveWidgetController(
      _riveFile!,
      stateMachineSelector: rive.StateMachineSelector.byName('STM'),
    );

    // Set initial indeterminate state
    _controller?.stateMachine.boolean("indeterminate")?.value = true;

    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
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
              child: _isInitialized && _controller != null
                  ? rive.RiveWidget(
                      controller: _controller!,
                      fit: rive.Fit.contain,
                    )
                  : const SizedBox(),
            ),
          ),
          const SizedBox(
            height: EnvoySpacing.xl * 2,
          ),
          DefaultTextStyle(
            style: EnvoyTypography.heading,
            child: Text(S().magic_setup_recovery_retry_header,
                textAlign: TextAlign.center, style: EnvoyTypography.heading),
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
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() {
            _isRecoveryInProgress = false;
          });
        }
      },
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
              child: GestureDetector(
                onLongPress: () {
                  if (isTest) {
                    setState(() {
                      _isRecoveryInProgress = true;
                    });
                    openBeefQABackupFile(context).then((value) {
                      setState(() {
                        _isRecoveryInProgress = false;
                      });
                    });
                  }
                },
                child: Image.asset(
                  "assets/fw_download.png",
                  width: 150,
                  height: 150,
                ),
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
                      child: Text(S().manual_setup_import_backup_CTA2,
                          textAlign: TextAlign.center,
                          style: EnvoyTypography.heading),
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
                left: EnvoySpacing.xs,
                right: EnvoySpacing.xs,
                bottom: EnvoySpacing.medium2,
              ),
              child: Column(
                children: [
                  OnboardingButton(
                      type: EnvoyButtonTypes.secondary,
                      label: S().manual_setup_import_backup_CTA2,
                      onTap: () {
                        setState(() {
                          _isRecoveryInProgress = true;
                        });
                        openExternalBackUpFile(context);
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

  Future<void> openExternalBackUpFile(BuildContext context) async {
    try {
      final navigator = Navigator.of(context);
      bool success = await openBackupFile(context);
      if (success) {
        await navigator.push(MaterialPageRoute(builder: (context) {
          return const WalletSetupSuccess();
        }));
      } else {
        setState(() {
          _isRecoveryInProgress = false;
        });
        if (context.mounted) {
          await showRestoreFailedDialog(context);
        }
      }
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      setState(() {
        _isRecoveryInProgress = false;
      });
      if (context.mounted) {
        await showRestoreFailedDialog(context);
      }
    }
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

  Future<void> checkForCloudBackup(String seed) async {
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
              showCloseButton: false,
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
        const Padding(
          padding: EdgeInsets.only(top: EnvoySpacing.xl),
          child: SizedBox(
            height: 180,
            width: 180,
            child: CircularProgressIndicator(
              color: EnvoyColors.tealLight,
              backgroundColor: EnvoyColors.surface4,
              strokeWidth: 15,
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: EnvoySpacing.medium3),
          child: DefaultTextStyle(
            style: EnvoyTypography.heading,
            child: Text(S().manual_setup_importingSeedLoadingInfo,
                style: EnvoyTypography.heading),
          ),
        )
      ],
    ));
  }
}

Future<void> tryMagicRecover(List<String> seedList, String seed,
    Map<String, String>? data, BuildContext context) async {
  final navigator = Navigator.of(context);
  bool success = await EnvoySeed()
      .processRecoveryData(seed, data, null, isMagicBackup: true);

  if (success) {
    Settings().setSyncToCloud(true);
    EnvoySeed().copySeedToNonSecure();
    navigator.push(MaterialPageRoute(builder: (context) {
      return const WalletSetupSuccess();
    }));
  } else {
    if (context.mounted) {
      recoverManually(seedList, context);
      Navigator.pop(context);
    }
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
