// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:backup/backup.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/dialogs.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';

class MagicRecoverWallet extends ConsumerStatefulWidget {
  const MagicRecoverWallet({Key? key}) : super(key: key);

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
}

class _MagicRecoverWalletState extends ConsumerState<MagicRecoverWallet> {
  StateMachineController? _stateMachineController;

  MagicRecoveryWalletState _magicRecoverWalletState =
      MagicRecoveryWalletState.recovering;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 100)).then((_) {
      if (!ref.read(triedAutomaticRecovery) &&
          !ref.read(successfulManualRecovery) &&
          !ref.read(successfulSetupWallet)) {
        _tryAutomaticRecovery();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _stateMachineController?.dispose();
    super.dispose();
  }

  void _tryAutomaticRecovery() async {
    ref.read(triedAutomaticRecovery.notifier).state = true;
    await Future.delayed(Duration(seconds: 1));
    var success = false;
    try {
      success = await EnvoySeed().restoreData();
      if (mounted)
        setState(() {
          if (success) {
            _magicRecoverWalletState = MagicRecoveryWalletState.success;
          } else {
            _magicRecoverWalletState = MagicRecoveryWalletState.backupNotFound;
          }
        });
    } on BackupNotFound {
      if (mounted)
        setState(() {
          _magicRecoverWalletState = MagicRecoveryWalletState.backupNotFound;
        });
    } on SeedNotFound {
      if (mounted)
        setState(() {
          _magicRecoverWalletState = MagicRecoveryWalletState.seedNotFound;
        });
    } on ServerUnreachable {
      if (mounted)
        setState(() {
          _magicRecoverWalletState =
              MagicRecoveryWalletState.serverNotReachable;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _magicRecoverWalletState =
              MagicRecoveryWalletState.unableToDecryptBackup;
        });
    } finally {
      if (success) {
        _setHappyState();
      } else {
        _setUnhappyState();
      }
    }
  }

  void _setUnhappyState() {
    _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
    _stateMachineController?.findInput<bool>("happy")?.change(false);
    _stateMachineController?.findInput<bool>("unhappy")?.change(true);
  }

  void _setHappyState() {
    _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
    _stateMachineController?.findInput<bool>("happy")?.change(true);
    _stateMachineController?.findInput<bool>("unhappy")?.change(false);
  }

  _onRiveInit(Artboard artBoard) {
    _stateMachineController =
        StateMachineController.fromArtboard(artBoard, 'STM');
    artBoard.addController(_stateMachineController!);
    _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
  }

  Future<bool> _handleBackPress() async {
    if (_magicRecoverWalletState == MagicRecoveryWalletState.recovering) {
      return false;
    }
    //remove seed that recovered from qr
    if (EnvoySeed().walletDerived()) {
      try {
        EnvoySeed().delete();
      } catch (exception) {}
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        _handleBackPress();
      },
      child: Material(
        color: Colors.transparent,
        child: Builder(builder: (context) {
          return OnboardPageBackground(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoNavigationBarBackButton(
                          color: Colors.black,
                          onPressed: () {
                            _handleBackPress().then((value) {
                              if (value) {
                                Navigator.pop(context);
                              }
                            });
                          },
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            return Material(
                              color: Colors.transparent,
                              child: IconButton(
                                  onPressed: () async {
                                    ref
                                        .read(homePageTabProvider.notifier)
                                        .state = HomePageTabState.accounts;
                                    ref
                                        .read(
                                            homePageBackgroundProvider.notifier)
                                        .state = HomePageBackgroundState.hidden;
                                    await Future.delayed(
                                        Duration(milliseconds: 200));
                                    OnboardingPage.popUntilHome(context);
                                  },
                                  icon: Icon(Icons.close)),
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      constraints: BoxConstraints.tight(Size.fromHeight(240)),
                      child: Transform.scale(
                        scale: 1.2,
                        child: RiveAnimation.asset(
                          "assets/envoy_loader.riv",
                          fit: BoxFit.contain,
                          onInit: _onRiveInit,
                        ),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Padding(
                        //     padding: const EdgeInsets.symmetric(
                        //         vertical: EnvoySpacing.medium1)),
                        AnimatedSwitcher(
                            duration: Duration(milliseconds: 800),
                            child: getMainWidget()),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: EnvoySpacing.medium3)),
                        getBottomButtons() ?? SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget getMainWidget() {
    if (_magicRecoverWalletState == MagicRecoveryWalletState.recovering) {
      return _recoveryInProgress(context);
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.success) {
      return _successMessage(context);
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.backupNotFound) {
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
    return SizedBox();
  }

  Widget? getBottomButtons() {
    if (_magicRecoverWalletState == MagicRecoveryWalletState.recovering) {
      return null;
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.success) {
      return Consumer(
        builder: (context, ref, child) {
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OnboardingButton(
                label: S().component_continue,
                onTap: () async {
                  await Future.delayed(Duration(milliseconds: 200));
                  OnboardingPage.popUntilHome(context);
                },
              ));
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
              onTap: () {
                showContinueWarningDialog(context);
              },
            ),
            OnboardingButton(
              label: S().manual_setup_import_backup_CTA2,
              type: EnvoyButtonTypes.secondary,
              onTap: () {
                openBackupFile(context);
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
          ],
        ),
      );
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.seedNotFound ||
        _magicRecoverWalletState == MagicRecoveryWalletState.failure) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingButton(
              label: S().magic_setup_recovery_fail_Android_CTA2,
              type: EnvoyButtonTypes.tertiary,
              onTap: () async {
                _setUnhappyState();
                setState(() {
                  _magicRecoverWalletState =
                      MagicRecoveryWalletState.seedNotFound;
                });
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_c) {
                  return ScannerPage(
                    [ScannerType.seed],
                    onSeedValidated: (seed) async {
                      try {
                        _setIndeterminateState();
                        setState(() {
                          _magicRecoverWalletState =
                              MagicRecoveryWalletState.recovering;
                        });
                        String? passphrase = null;
                        List<String> seedList = seed.split(" ");
                        if (seedList.length == 13 || seedList.length == 25) {
                          seedList.removeLast();
                          String _passphrase = await showEnvoyDialog(
                              dialog: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  height: 330,
                                  child: SeedPassphraseEntry(
                                      onPassphraseEntered: (value) {
                                    passphrase = value;
                                    Navigator.maybePop(context);
                                  })),
                              context: context);
                          setState(() {
                            passphrase = _passphrase;
                          });
                        }
                        await EnvoySeed()
                            .create(seedList, passphrase: passphrase);
                        bool success =
                            await EnvoySeed().restoreData(seed: seed);
                        //Enable magic backup by default for seed recovery
                        Settings().syncToCloud = true;
                        setState(() {
                          if (success) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        WalletSetupSuccess())).then((_) {
                              //Try automatic recovery if the user press back button
                              if (mounted) {
                                _tryAutomaticRecovery();
                              }
                            });
                          } else {
                            _setUnhappyState();
                            setState(() {
                              _magicRecoverWalletState =
                                  MagicRecoveryWalletState.failure;
                            });
                          }
                        });
                      } on BackupNotFound {
                        _setUnhappyState();
                        setState(() {
                          _magicRecoverWalletState =
                              MagicRecoveryWalletState.backupNotFound;
                        });
                      } on SeedNotFound {
                        _setUnhappyState();
                        setState(() {
                          _magicRecoverWalletState =
                              MagicRecoveryWalletState.seedNotFound;
                        });
                      } on ServerUnreachable {
                        _setUnhappyState();
                        setState(() {
                          _magicRecoverWalletState =
                              MagicRecoveryWalletState.serverNotReachable;
                        });
                      } catch (e) {
                        _setUnhappyState();
                        setState(() {
                          _magicRecoverWalletState =
                              MagicRecoveryWalletState.unableToDecryptBackup;
                        });
                      }
                    },
                  );
                }));
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
          ],
        ),
      );
    }
    if (_magicRecoverWalletState ==
        MagicRecoveryWalletState.serverNotReachable) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingButton(
              label: S().component_continue,
              type: EnvoyButtonTypes.tertiary,
              onTap: () {
                showContinueWarningDialog(context);
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                return OnboardingButton(
                  label: S().manual_setup_import_backup_CTA2,
                  type: EnvoyButtonTypes.secondary,
                  onTap: () {
                    openBackupFile(context);
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
          ],
        ),
      );
    }
    return null;
  }

  Widget _recoveryInProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Recovering your Envoy wallet", //TODO: FIGMA
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  // Might have use for this in the future?
  //ignore: unused_element
  Widget _successMessage(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                S().wallet_setup_success_heading,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Text(
                  S().wallet_setup_success_subheading,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
      ),
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(padding: EdgeInsets.all(28)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S().magic_setup_recovery_fail_backup_subheading,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(padding: EdgeInsets.all(28)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S().magic_setup_recovery_fail_connectivity_subheading,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(padding: EdgeInsets.all(EnvoySpacing.medium2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
          child: Text(
            Platform.isAndroid
                ? S().magic_setup_recovery_fail_Android_subheading
                : S().magic_setup_recovery_fail_ios_subheading,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _setIndeterminateState() {
    _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
    _stateMachineController?.findInput<bool>("happy")?.change(false);
    _stateMachineController?.findInput<bool>("unhappy")?.change(false);
  }

  void showContinueWarningDialog(BuildContext context) {
    showEnvoyDialog(
        context: context,
        dismissible: false,
        dialog: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/exclamation_triangle.png",
                      height: 80,
                      width: 80,
                    ),
                    Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 0),
                      child: Text(
                        S().component_warning,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.info,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Text(
                        S().manual_setup_recovery_import_backup_modal_fail_connectivity_subheading,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.info,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(2)),
                  ],
                ),
                OnboardingButton(
                    label: S().component_back,
                    type: EnvoyButtonTypes.tertiary,
                    onTap: () async {
                      Navigator.maybePop(context);
                    }),
                Padding(padding: EdgeInsets.all(2)),
                Consumer(
                  builder: (context, ref, child) {
                    return OnboardingButton(
                        type: EnvoyButtonTypes.primaryModal,
                        label: S().component_continue,
                        onTap: () {
                          EnvoySeed().get().then((seed) async {
                            EnvoySeed().deriveAndAddWallets(seed!);
                            OnboardingPage.popUntilHome(context);
                          });
                        });
                  },
                ),
                Padding(padding: EdgeInsets.all(12)),
              ],
            ),
          ),
        ));
  }
}
