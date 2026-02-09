// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:backup/backup.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/dialogs.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/scanner/decoders/seed_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:rive/rive.dart' as rive;

class MagicRecoverWallet extends ConsumerStatefulWidget {
  const MagicRecoverWallet({super.key});

  @override
  ConsumerState<MagicRecoverWallet> createState() => _MagicRecoverWalletState();
}

enum MagicRecoveryWalletState {
  recovering,
  success,
  backupNotFound,
  serverNotReachable,
  seedNotFound,
  unableToDecryptBackup,
  failure,
  validSeedNoBackup,
  readingBackup,
}

class _MagicRecoverWalletState extends ConsumerState<MagicRecoverWallet> {
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;

  MagicRecoveryWalletState _magicRecoverWalletState =
      MagicRecoveryWalletState.recovering;

  String? _seed;

  @override
  void initState() {
    super.initState();
    _initRive();

    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      if (!ref.read(triedAutomaticRecovery) &&
          !ref.read(successfulManualRecovery) &&
          !ref.read(successfulSetupWallet)) {
        _tryAutomaticRecovery();
      }
    });
  }

  void _initRive() async {
    _riveFile = await rive.File.asset(
      "assets/envoy_loader.riv",
      riveFactory: rive.Factory.rive,
    );
    _controller = rive.RiveWidgetController(
      _riveFile!,
      stateMachineSelector: rive.StateMachineSelector.byName('STM'),
    );

    // Set initial indeterminate state
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller?.stateMachine.boolean("indeterminate")?.value = true;

    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  void _tryAutomaticRecovery() async {
    ref.read(triedAutomaticRecovery.notifier).state = true;
    await Future.delayed(const Duration(seconds: 1));
    var success = false;
    try {
      success = await EnvoySeed().restoreData();
      if (mounted) {
        setState(() {
          if (success) {
            Settings().updateAccountsViewSettings();
            _magicRecoverWalletState = MagicRecoveryWalletState.success;
          } else {
            _magicRecoverWalletState = MagicRecoveryWalletState.backupNotFound;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        if (e is GetBackupException) {
          if (e == GetBackupException.backupNotFound) {
            setState(() {
              _magicRecoverWalletState =
                  MagicRecoveryWalletState.backupNotFound;
            });
            return;
          } else if (e == GetBackupException.seedNotFound) {
            setState(() {
              _magicRecoverWalletState = MagicRecoveryWalletState.seedNotFound;
            });
            return;
          } else if (e == GetBackupException.serverUnreachable) {
            setState(() {
              _magicRecoverWalletState =
                  MagicRecoveryWalletState.serverNotReachable;
            });
            return;
          }
        }
        setState(() {
          _magicRecoverWalletState =
              MagicRecoveryWalletState.unableToDecryptBackup;
        });
      }
    } finally {
      if (success) {
        EnvoyStorage().setBool(PREFS_ONBOARDED, true);
        _setHappyState();
      } else {
        _setUnhappyState();
      }
    }
  }

  void _setUnhappyState() {
    if (_controller?.stateMachine == null) return;
    final stateMachine = _controller!.stateMachine;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("indeterminate")?.value = false;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("happy")?.value = false;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("unhappy")?.value = true;
  }

  void _setHappyState() {
    if (_controller?.stateMachine == null) return;
    final stateMachine = _controller!.stateMachine;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("indeterminate")?.value = false;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("happy")?.value = true;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("unhappy")?.value = false;
  }

  Future<bool> _handleBackPress() async {
    if (_magicRecoverWalletState == MagicRecoveryWalletState.recovering ||
        _magicRecoverWalletState == MagicRecoveryWalletState.readingBackup) {
      return false;
    }
    //remove seed that recovered from qr
    if (EnvoySeed().walletDerived()) {
      try {
        EnvoySeed().delete();
      } catch (exception) {
        kPrint(exception);
      }
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    bool isThereBottomButtons = getBottomButtons() != null;
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        _handleBackPress();
      },
      child: Material(
        color: Colors.transparent,
        child: Builder(
          builder: (context) {
            return OnboardPageBackground(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isThereBottomButtons
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_magicRecoverWalletState !=
                                  MagicRecoveryWalletState.success &&
                              _magicRecoverWalletState !=
                                  MagicRecoveryWalletState.recovering &&
                              _magicRecoverWalletState !=
                                  MagicRecoveryWalletState.readingBackup)
                            CupertinoNavigationBarBackButton(
                              color: Colors.black,
                              onPressed: () {
                                _handleBackPress().then((proceed) {
                                  if (proceed && context.mounted) {
                                    context.pop();
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                      Container(
                        constraints: BoxConstraints.tight(
                          const Size.fromHeight(240),
                        ),
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
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isThereBottomButtons
                                      ? 0
                                      : EnvoySpacing.large3,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 800),
                                  child: getMainWidget(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  getBottomButtons() ?? const SizedBox(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future _onSeedDetected(String seed, BuildContext context) async {
    try {
      _setIndeterminateState();
      setState(() {
        _magicRecoverWalletState = MagicRecoveryWalletState.recovering;
      });
      String? passphrase;
      List<String> seedList = seed.split(" ");
      if (seedList.length == 13 || seedList.length == 25) {
        seedList.removeLast();
        String passphrase0 = await showEnvoyDialog(
          dialog: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 330,
            child: SeedPassphraseEntry(
              onPassphraseEntered: (value) {
                passphrase = value;
                context.pop();
              },
            ),
          ),
          context: context,
        );
        setState(() {
          passphrase = passphrase0;
        });
      }
      bool isValidSeed = await EnvoyBip39.validateSeed(seedWords: seed);
      _seed = seed;

      bool success = await EnvoySeed().restoreData(
        seed: seed,
        passphrase: passphrase,
      );

      //Enable magic backup by default for seed recovery
      Settings().setSyncToCloud(true);
      setState(() {
        if (success) {
          Settings().updateAccountsViewSettings();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WalletSetupSuccess()),
          ).then((_) {
            //Try automatic recovery if the user press back button
            if (mounted && !ref.read(triedAutomaticRecovery)) {
              _tryAutomaticRecovery();
            }
          });
        } else if (isValidSeed) {
          _setUnhappyState();
          setState(() {
            _magicRecoverWalletState =
                MagicRecoveryWalletState.validSeedNoBackup;
          });
        } else {
          _setUnhappyState();
          setState(() {
            _magicRecoverWalletState = MagicRecoveryWalletState.failure;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        if (e is GetBackupException) {
          if (e == GetBackupException.backupNotFound) {
            setState(() {
              _magicRecoverWalletState =
                  MagicRecoveryWalletState.backupNotFound;
            });
            return;
          } else if (e == GetBackupException.seedNotFound) {
            setState(() {
              _magicRecoverWalletState = MagicRecoveryWalletState.seedNotFound;
            });
            return;
          } else if (e == GetBackupException.serverUnreachable) {
            setState(() {
              _magicRecoverWalletState =
                  MagicRecoveryWalletState.serverNotReachable;
            });
            return;
          }
        }
        setState(() {
          _magicRecoverWalletState =
              MagicRecoveryWalletState.unableToDecryptBackup;
        });
      }
    }
  }

  Widget getMainWidget() {
    if (_magicRecoverWalletState == MagicRecoveryWalletState.recovering) {
      return _recoveryInProgress(context);
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.success) {
      return _successMessage(context);
    }
    if (_magicRecoverWalletState ==
        MagicRecoveryWalletState.validSeedNoBackup) {
      return _manualSeedRecovery(context);
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.backupNotFound ||
        _magicRecoverWalletState ==
            MagicRecoveryWalletState.unableToDecryptBackup) {
      return _backupNotFound(context);
    }
    if (_magicRecoverWalletState ==
        MagicRecoveryWalletState.serverNotReachable) {
      return _serverNotReachable(context);
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.seedNotFound ||
        _magicRecoverWalletState == MagicRecoveryWalletState.failure) {
      return _seedNotFound(context);
    }
    return const SizedBox();
  }

  Widget? getBottomButtons() {
    if (_magicRecoverWalletState == MagicRecoveryWalletState.recovering ||
        _magicRecoverWalletState == MagicRecoveryWalletState.readingBackup) {
      return null;
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.success) {
      return Consumer(
        builder: (context, ref, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OnboardingButton(
                  label: S().component_continue,
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 200));
                    if (context.mounted) {
                      context.go("/");
                    }
                  },
                ),
              ),
              SizedBox(
                height: context.isSmallScreen
                    ? EnvoySpacing.medium1
                    : EnvoySpacing.medium2,
              ),
            ],
          );
        },
      );
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.backupNotFound) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingButton(
              label: S().component_continue,
              type: EnvoyButtonTypes.tertiary,
              onTap: () async {
                _seed ??= await EnvoySeed().get();
                if (_seed == null) {
                  return;
                }
                if (mounted) {
                  showContinueWarningDialog(context, _seed);
                }
              },
            ),
            OnboardingButton(
              label: S().manual_setup_import_backup_CTA2,
              type: EnvoyButtonTypes.secondary,
              onTap: () async {
                _openExternalBackUpFile(
                  context,
                  onFailure: () {
                    showRestoreFailedDialog(context);
                  },
                  seed: _seed,
                );
              },
            ),
            OnboardingButton(
              label: S().component_retry,
              onTap: () async {
                setState(() {
                  _magicRecoverWalletState =
                      MagicRecoveryWalletState.recovering;
                });
                _setIndeterminateState();
                _tryAutomaticRecovery();
              },
            ),
            SizedBox(
              height: context.isSmallScreen
                  ? EnvoySpacing.medium1
                  : EnvoySpacing.medium3,
            ),
          ],
        ),
      );
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.seedNotFound ||
        _magicRecoverWalletState == MagicRecoveryWalletState.failure ||
        _magicRecoverWalletState ==
            MagicRecoveryWalletState.unableToDecryptBackup) {
      return Padding(
        padding: const EdgeInsets.only(
          left: EnvoySpacing.xs,
          right: EnvoySpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingButton(
              label: S().magic_setup_recovery_fail_Android_CTA2,
              type: EnvoyButtonTypes.secondary,
              onTap: () async {
                _setUnhappyState();
                setState(() {
                  _magicRecoverWalletState =
                      MagicRecoveryWalletState.seedNotFound;
                });
                showScannerDialog(
                  context: context,
                  onBackPressed: (context) {
                    Navigator.pop(context);
                  },
                  decoder: SeedQrDecoder(
                    onSeedValidated: (String seed) {
                      context.pop();
                      _onSeedDetected(seed, context);
                    },
                  ),
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                return OnboardingButton(
                  label: S().component_retry,
                  type: EnvoyButtonTypes.primary,
                  onTap: () async {
                    _setIndeterminateState();
                    setState(() {
                      _magicRecoverWalletState =
                          MagicRecoveryWalletState.recovering;
                    });
                    _tryAutomaticRecovery();
                  },
                );
              },
            ),
            SizedBox(
              height: context.isSmallScreen
                  ? EnvoySpacing.medium1
                  : EnvoySpacing.medium2,
            ),
          ],
        ),
      );
    }
    if (_magicRecoverWalletState ==
            MagicRecoveryWalletState.serverNotReachable ||
        _magicRecoverWalletState ==
            MagicRecoveryWalletState.validSeedNoBackup) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingButton(
              label: S().component_continue,
              type: EnvoyButtonTypes.tertiary,
              onTap: () async {
                _seed ??= await EnvoySeed().get();
                if (mounted) {
                  showContinueWarningDialog(context, _seed!);
                }
              },
            ),
            Consumer(
              builder: (contextButton, ref, child) {
                return OnboardingButton(
                  label: S().manual_setup_import_backup_CTA2,
                  type: EnvoyButtonTypes.secondary,
                  onTap: () async {
                    setState(() {
                      _magicRecoverWalletState =
                          MagicRecoveryWalletState.readingBackup;
                    });
                    _setIndeterminateState();
                    if (context.mounted) {
                      _openExternalBackUpFile(
                        context,
                        seed: _seed,
                        onFailure: () {
                          showRestoreFailedDialog(context);
                          setState(() {
                            _magicRecoverWalletState =
                                MagicRecoveryWalletState.validSeedNoBackup;
                          });
                          _setUnhappyState();
                        },
                      );
                    }
                  },
                );
              },
            ),
            OnboardingButton(
              label: S().component_retry,
              onTap: () async {
                setState(() {
                  _magicRecoverWalletState =
                      MagicRecoveryWalletState.recovering;
                });
                _setIndeterminateState();
                _tryAutomaticRecovery();
              },
            ),
            SizedBox(
              height: context.isSmallScreen
                  ? EnvoySpacing.medium1
                  : EnvoySpacing.medium3,
            ),
          ],
        ),
      );
    }
    return null;
  }

  Widget _recoveryInProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          DefaultTextStyle(
            style: EnvoyTypography.heading,
            child: Text(
              S().magic_setup_recovery_retry_header,
              textAlign: TextAlign.center,
              style: EnvoyTypography.heading,
            ),
          ),
        ],
      ),
    );
  }

  // Might have use for this in the future?
  //ignore: unused_element
  Widget _successMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            S().onboarding_magicUserMobileSuccess_header,
            style: EnvoyTypography.heading,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Text(
              S().wallet_setup_success_subheading,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _manualSeedRecovery(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S().magic_setup_recovery_fail_backup_heading,
            textAlign: TextAlign.center,
            style: EnvoyTypography.heading,
          ),
        ),
        const Padding(padding: EdgeInsets.all(28)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S().magic_setup_recovery_fail_backup_subheading,
            textAlign: TextAlign.center,
            style: EnvoyTypography.info.copyWith(
              color: EnvoyColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _backupNotFound(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S().magic_setup_recovery_fail_backup_heading,
            textAlign: TextAlign.center,
            style: EnvoyTypography.heading,
          ),
        ),
        const Padding(padding: EdgeInsets.all(28)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S().magic_setup_recovery_fail_backup_subheading,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _serverNotReachable(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S().magic_setup_recovery_fail_connectivity_heading,
            textAlign: TextAlign.center,
            style: EnvoyTypography.heading,
          ),
        ),
        const Padding(padding: EdgeInsets.all(28)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S().magic_setup_recovery_fail_connectivity_subheading,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _seedNotFound(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
          child: Text(
            S().magic_setup_recovery_fail_heading,
            textAlign: TextAlign.center,
            style: EnvoyTypography.heading,
          ),
        ),
        const SizedBox(height: EnvoySpacing.medium3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
          child: Text(
            Platform.isAndroid
                ? S().magic_setup_recovery_fail_Android_subheading
                : S().magic_setup_recovery_fail_ios_subheading,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _setIndeterminateState() {
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller?.stateMachine.boolean("indeterminate")?.value = true;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller?.stateMachine.boolean("happy")?.value = false;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller?.stateMachine.boolean("unhappy")?.value = false;
  }

  Future<void> _openExternalBackUpFile(
    BuildContext context, {
    String? seed,
    required VoidCallback onFailure,
  }) async {
    try {
      final navigator = Navigator.of(context);
      bool success = await openBackupFile(context, seed: seed);
      if (success && seed != null) {
        if (context.mounted) {
          context.pushNamed(ONBOARD_ENVOY_MAGIC_GENERATE_SETUP);
        }
      }
      if (success) {
        await navigator.push(
          MaterialPageRoute(
            builder: (context) {
              return const WalletSetupSuccess();
            },
          ),
        );
      } else {
        onFailure();
      }
    } catch (e) {
      onFailure();
    }
  }

  void showContinueWarningDialog(BuildContext context, String? seed) {
    showEnvoyDialog(
      context: context,
      dismissible: false,
      dialog: EnvoyPopUp(
        icon: EnvoyIcons.alert,
        typeOfMessage: PopUpState.warning,
        showCloseButton: true,
        title: S().component_warning,
        customWidget: Text(
          S().manual_setup_recovery_import_backup_modal_fail_connectivity_subheading,
          textAlign: TextAlign.center,
          style: EnvoyTypography.info,
        ),
        primaryButtonLabel: S().component_continue,
        onPrimaryButtonTap: (context) async {
          if (seed != null) {
            await EnvoySeed().deriveAndAddWallets(seed);
          } else {
            EnvoyReport().log(
              "MagicRecoverWallet",
              "Seed is null in continue warning dialog",
            );
          }

          await Future.delayed(const Duration(milliseconds: 120));
          if (context.mounted) {
            context.goNamed(WALLET_SUCCESS);
          }
        },
        tertiaryButtonLabel: S().component_back,
        tertiaryButtonTextColor: EnvoyColors.accentPrimary,
        onTertiaryButtonTap: (context) async {
          context.pop();
        },
      ),
    );
  }
}
