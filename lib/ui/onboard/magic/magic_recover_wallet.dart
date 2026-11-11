// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:backup/backup.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/restore_account_metadata.dart';
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
  accountRestoreFailed,
  validSeedNoBackup,
  readingBackup,
}

class _MagicRecoverWalletState extends ConsumerState<MagicRecoverWallet> {
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;

  MagicRecoveryWalletState _state = MagicRecoveryWalletState.recovering;

  MagicRecoveryWalletState get _magicRecoverWalletState => _state;

  // While partial-restore accounts are retained, every failure lands in the
  // one state that can continue with them, never a Scan/Retry-only screen.
  set _magicRecoverWalletState(MagicRecoveryWalletState next) {
    _state = _preserveRecoveredAccounts && _isFailureState(next)
        ? MagicRecoveryWalletState.accountRestoreFailed
        : next;
  }

  static bool _isFailureState(MagicRecoveryWalletState state) => !{
        MagicRecoveryWalletState.recovering,
        MagicRecoveryWalletState.readingBackup,
        MagicRecoveryWalletState.success,
        MagicRecoveryWalletState.accountRestoreFailed,
      }.contains(state);

  String? _seed;

  // Kept alongside the seed so a retry after a partial recovery can rerun
  // the same restore; it only lived in a local before.
  String? _passphrase;
  bool _preserveRecoveredAccounts = false;

  // Every seed scanned on this screen: any of them may have been stored
  // locally by a restore that then failed with no account created.
  final Set<String> _scannedSeeds = {};

  // What storage held before the first scanned restore, so cleanup removes
  // only a copy this screen stored, never a pre-existing one.
  String? _seedBeforeScan;

  @override
  void initState() {
    super.initState();
    _initRive();
    // Hot accounts present on entry survived an earlier partial restore (no
    // entry point derives one first); back must never delete them.
    _preserveRecoveredAccounts = EnvoySeed().walletDerived();

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
        _setUnhappyState();
        if (e is AccountRestoreException) {
          // Only a partial recovery has accounts worth preserving; with
          // nothing restored, the plain failure state is the honest one.
          if (e.anyRestored) {
            _preserveRecoveredAccounts = true;
            setState(() {
              _magicRecoverWalletState =
                  MagicRecoveryWalletState.accountRestoreFailed;
            });
          } else {
            setState(() {
              _magicRecoverWalletState = MagicRecoveryWalletState.failure;
            });
          }
          return;
        }
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
    final inFlight =
        _magicRecoverWalletState == MagicRecoveryWalletState.recovering ||
            _magicRecoverWalletState == MagicRecoveryWalletState.readingBackup;
    // Retained partial-restore accounts must not leak into a different
    // recovery started from the welcome flow, and a retry in flight must
    // settle before its buttons unlock: two restores must never overlap.
    if (_preserveRecoveredAccounts) {
      return false;
    }
    // An attempt can take minutes over Tor, so back must still leave; the
    // attempt finishes in the background, as it always has.
    if (inFlight) {
      return true;
    }
    //remove seed that recovered from qr
    if (EnvoySeed().walletDerived()) {
      await EnvoyReport().log(
        "Magic Backup",
        "recovery screen requested wallet seed deletion",
      );
      try {
        EnvoySeed().delete();
      } catch (exception) {
        kPrint(exception);
      }
      return true;
    }
    // A restore can store the scanned seed and then fail before creating
    // any account. Undo that local write (never the remote backup): put back
    // the seed storage held before the first scan, or clear it if none.
    final stored = _scannedSeeds.isEmpty ? null : await EnvoySeed().get();
    // Whichever scan last wrote storage, not just the latest scan.
    if (stored != null &&
        stored != _seedBeforeScan &&
        _scannedSeeds.contains(stored)) {
      final previous = _seedBeforeScan;
      if (previous != null) {
        await EnvoyReport().log(
          "Magic Backup",
          "recovery screen restored the seed an unused scan replaced",
        );
        await EnvoySeed().store(previous);
      } else {
        await EnvoyReport().log(
          "Magic Backup",
          "recovery screen cleared an unused scanned seed",
        );
        await EnvoySeed().removeSeed();
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    bool isThereBottomButtons = getBottomButtons() != null;
    return PopScope(
      // The pop only proceeds when _handleBackPress allows it; without
      // canPop false its verdicts were never enforced.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final router = GoRouter.of(context);
        if (await _handleBackPress()) {
          router.pop();
        }
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
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
    _setIndeterminateState();
    setState(() {
      _magicRecoverWalletState = MagicRecoveryWalletState.recovering;
    });
    String? passphrase;
    try {
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
    } catch (e) {
      _setUnhappyState();
      if (mounted) {
        setState(() {
          _magicRecoverWalletState = MagicRecoveryWalletState.failure;
        });
      }
      return;
    }
    await _recoverFromSeed(seed, passphrase);
  }

  Future _recoverFromSeed(String seed, String? passphrase) async {
    try {
      bool isValidSeed = await EnvoyBip39.validateSeed(seedWords: seed);
      if (_scannedSeeds.isEmpty) {
        _seedBeforeScan = await EnvoySeed().get();
      }
      _seed = seed;
      _passphrase = passphrase;
      _scannedSeeds.add(seed);

      bool success = await EnvoySeed().restoreData(
        seed: seed,
        passphrase: passphrase,
      );

      //Enable magic backup by default for seed recovery
      Settings().setSyncToCloud(true);
      if (success) {
        Settings().updateAccountsViewSettings();
        if (mounted) {
          context.pushNamed(WALLET_SUCCESS).then((_) {
            //Try automatic recovery if the user press back button
            if (mounted && !ref.read(triedAutomaticRecovery)) {
              _tryAutomaticRecovery();
            }
          });
        }
      } else if (isValidSeed) {
        _setUnhappyState();
        setState(() {
          _magicRecoverWalletState = MagicRecoveryWalletState.validSeedNoBackup;
        });
      } else {
        _setUnhappyState();
        setState(() {
          _magicRecoverWalletState = MagicRecoveryWalletState.failure;
        });
      }
    } catch (e) {
      _setUnhappyState();
      if (mounted) {
        if (e is AccountRestoreException) {
          if (e.anyRestored) {
            _preserveRecoveredAccounts = true;
            setState(() {
              _magicRecoverWalletState =
                  MagicRecoveryWalletState.accountRestoreFailed;
            });
          } else {
            setState(() {
              _magicRecoverWalletState = MagicRecoveryWalletState.failure;
            });
          }
          return;
        }
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
            MagicRecoveryWalletState.accountRestoreFailed ||
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
    if (_magicRecoverWalletState ==
        MagicRecoveryWalletState.accountRestoreFailed) {
      return Padding(
        padding: const EdgeInsets.all(20),
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
                  showContinueWarningDialog(context, _seed,
                      passphrase: _passphrase);
                }
              },
            ),
            OnboardingButton(
              label: S().manual_setup_import_backup_CTA2,
              type: EnvoyButtonTypes.secondary,
              onTap: () {
                // A partial offline restore is retried by re-importing. The
                // spinner state keeps the other actions out of reach until
                // the import settles, so operations cannot overlap.
                setState(() {
                  _magicRecoverWalletState =
                      MagicRecoveryWalletState.readingBackup;
                });
                _setIndeterminateState();
                _openExternalBackUpFile(
                  context,
                  seed: _seed,
                  passphrase: _passphrase,
                  onFailure: () {
                    showRestoreFailedDialog(context);
                    _setUnhappyState();
                    setState(() {
                      _magicRecoverWalletState =
                          MagicRecoveryWalletState.accountRestoreFailed;
                    });
                  },
                );
              },
            ),
            OnboardingButton(
              label: S().component_retry,
              onTap: () {
                setState(() {
                  _magicRecoverWalletState =
                      MagicRecoveryWalletState.recovering;
                });
                _setIndeterminateState();
                // Rerun the recovery that actually failed: a scanned seed
                // keeps its passphrase, which automatic recovery lacks.
                if (_seed != null) {
                  _recoverFromSeed(_seed!, _passphrase);
                } else {
                  _tryAutomaticRecovery();
                }
              },
            ),
          ],
        ),
      );
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
                  showContinueWarningDialog(context, _seed,
                      passphrase: _passphrase);
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
                  passphrase: _passphrase,
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
                      // Close the modal bottom sheet (root navigator),
                      // not the GoRouter route.
                      Navigator.of(context, rootNavigator: true).pop();
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
                    // A scanned seed must retry with its passphrase;
                    // automatic recovery would derive without one.
                    if (_seed != null) {
                      _recoverFromSeed(_seed!, _passphrase);
                    } else {
                      _tryAutomaticRecovery();
                    }
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
                  showContinueWarningDialog(context, _seed!,
                      passphrase: _passphrase);
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
                        passphrase: _passphrase,
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
    final accountRestoreFailed = _magicRecoverWalletState ==
        MagicRecoveryWalletState.accountRestoreFailed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            accountRestoreFailed
                ? S().magic_setup_recovery_fail_heading
                : S().magic_setup_recovery_fail_backup_heading,
            textAlign: TextAlign.center,
            style: EnvoyTypography.heading,
          ),
        ),
        const Padding(padding: EdgeInsets.all(28)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            accountRestoreFailed
                ? S().menu_toast_unexpectedError
                : S().magic_setup_recovery_fail_backup_subheading,
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
    String? passphrase,
    required VoidCallback onFailure,
  }) async {
    try {
      final navigator = Navigator.of(context);
      bool success = await openBackupFile(
        context,
        seed: seed,
        passphrase: passphrase,
      );
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
    } on AccountRestoreException catch (e) {
      if (mounted) {
        _setUnhappyState();
        _preserveRecoveredAccounts =
            _preserveRecoveredAccounts || e.anyRestored;
        // Leave readingBackup as its launcher's onFailure would, and
        // re-assign either way so retained accounts remap the state to the
        // partial-failure screen (Continue, re-import, Retry).
        setState(() {
          _magicRecoverWalletState =
              _magicRecoverWalletState == MagicRecoveryWalletState.readingBackup
                  ? MagicRecoveryWalletState.validSeedNoBackup
                  : _magicRecoverWalletState;
        });
      }
      if (context.mounted) {
        await showRestoreFailedDialog(
          context,
          accountRestoreFailed: true,
          onContinueWithRestored: e.anyRestored
              ? (dialogContext) {
                  Navigator.pop(dialogContext);
                  showContinueWarningDialog(
                    context,
                    seed ?? _seed,
                    passphrase: _passphrase,
                  );
                }
              : null,
        );
      }
    } catch (e) {
      onFailure();
    }
  }

  void showContinueWarningDialog(
    BuildContext context,
    String? seed, {
    String? passphrase,
  }) {
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
          // Restored devices need their sessions prepared, same as the
          // full-success paths.
          EnvoySeed().deferDeviceReconnect();
          if (seed != null) {
            await EnvoySeed().deriveAndAddWallets(seed, passphrase: passphrase);
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
