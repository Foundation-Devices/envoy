// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:backup/backup.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/dialogs.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_import_backup.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class MagicRecoverWallet extends StatefulWidget {
  const MagicRecoverWallet({Key? key}) : super(key: key);

  @override
  State<MagicRecoverWallet> createState() => _MagicRecoverWalletState();
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

class _MagicRecoverWalletState extends State<MagicRecoverWallet> {
  StateMachineController? _stateMachineController;

  MagicRecoveryWalletState _magicRecoverWalletState =
      MagicRecoveryWalletState.recovering;

  @override
  void initState() {
    super.initState();
    _tryAutomaticRecovery();
  }

  void _tryAutomaticRecovery() async {
    await Future.delayed(Duration(seconds: 1));
    var success = false;
    try {
      success = await EnvoySeed().restoreData();
      setState(() {
        if (success) {
          _magicRecoverWalletState = MagicRecoveryWalletState.success;
        } else {
          _magicRecoverWalletState = MagicRecoveryWalletState.backupNotFound;
        }
      });
    } on BackupNotFound {
      setState(() {
        _magicRecoverWalletState = MagicRecoveryWalletState.backupNotFound;
      });
    } on SeedNotFound {
      setState(() {
        _magicRecoverWalletState = MagicRecoveryWalletState.seedNotFound;
      });
    } on ServerUnreachable {
      setState(() {
        _magicRecoverWalletState = MagicRecoveryWalletState.serverNotReachable;
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_magicRecoverWalletState == MagicRecoveryWalletState.recovering) {
          return false;
        }
        return true;
      },
      child: Material(
        color: Colors.transparent,
        child: Builder(builder: (context) {
          return OnboardPageBackground(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoNavigationBarBackButton(
                          color: Colors.black,
                          onPressed: () {
                            Navigator.pop(context);
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
                                    Navigator.of(context)
                                        .popUntil(ModalRoute.withName("/"));
                                  },
                                  icon: Icon(Icons.close)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        height: 180,
                        child: Transform.scale(
                          scale: 1.6,
                          child: RiveAnimation.asset(
                            "assets/envoy_loader.riv",
                            fit: BoxFit.contain,
                            onInit: _onRiveInit,
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 800),
                            child: getMainWidget()),
                      ),
                    ],
                  )),
                  getBottomButtons() ?? SizedBox(),
                ],
              ),
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
                label: S().magic_setup_generate_wallet_modal_ios_CTA,
                onTap: () async {
                  ref.read(homePageTabProvider.notifier).state =
                      HomePageTabState.accounts;
                  ref.read(homePageBackgroundProvider.notifier).state =
                      HomePageBackgroundState.hidden;
                  await Future.delayed(Duration(milliseconds: 200));
                  Navigator.of(context).popUntil(ModalRoute.withName("/"));
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
              label: S().magic_setup_recovery_fail_backup_cta3,
              type: EnvoyButtonTypes.tertiary,
              onTap: () {
                showContinueWarningDialog(context);
              },
            ),
            OnboardingButton(
              label: S().magic_setup_recovery_fail_backup_cta2,
              type: EnvoyButtonTypes.secondary,
              onTap: () {
                openBackupFile(context);
              },
            ),
            OnboardingButton(
              label: S().magic_setup_recovery_fail_backup_cta1,
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
                    onSeedParsed: (seed) async {
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
                                    Navigator.pop(context);
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
                        setState(() {
                          if (success) {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManualSetupImportBackup()))
                                .then((value) {
                              //Try automatic recovery if the user press back button
                              if (mounted) {
                                _tryAutomaticRecovery();
                              }
                            });
                          } else {
                            _setUnhappyState();
                            _magicRecoverWalletState =
                                MagicRecoveryWalletState.failure;
                          }
                        });
                      } catch (e) {
                        setState(() {
                          _setUnhappyState();
                          _magicRecoverWalletState =
                              MagicRecoveryWalletState.failure;
                        });
                        print(e);
                      }
                    },
                  );
                }));
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                return OnboardingButton(
                  label: S().magic_setup_recovery_fail_backup_cta1,
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
              label: S().magic_setup_recovery_fail_connectivity_cta3,
              type: EnvoyButtonTypes.tertiary,
              onTap: () {
                showContinueWarningDialog(context);
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                return OnboardingButton(
                  label: S().magic_setup_recovery_fail_connectivity_cta2,
                  type: EnvoyButtonTypes.secondary,
                  onTap: () {
                    openBackupFile(context);
                  },
                );
              },
            ),
            OnboardingButton(
              label: S().magic_setup_recovery_fail_connectivity_cta1,
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
              S().magic_setup_recovery_heading,
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
      mainAxisSize: MainAxisSize.max,
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
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            Platform.isAndroid
                ? S().magic_setup_recovery_fail_Android_heading
                : S().magic_setup_recovery_fail_ios_heading,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(padding: EdgeInsets.all(28)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
          width: MediaQuery.of(context).size.width * 0.8,
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
                    Padding(padding: EdgeInsets.all(4)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Text(
                        S().manual_setup_recovery_import_backup_modal_fail_connectivity_heading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(2)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Text(
                        S().manual_setup_recovery_import_backup_modal_fail_connectivity_subheading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(2)),
                  ],
                ),
                OnboardingButton(
                    label: S()
                        .manual_setup_recovery_import_backup_modal_fail_connectivity_cta2,
                    type: EnvoyButtonTypes.tertiary,
                    onTap: () async {
                      Navigator.pop(context);
                    }),
                Padding(padding: EdgeInsets.all(2)),
                Consumer(
                  builder: (context, ref, child) {
                    return OnboardingButton(
                        label: S()
                            .manual_setup_recovery_import_backup_modal_fail_connectivity_cta1,
                        onTap: () {
                          EnvoySeed().get().then((seed) async {
                            EnvoySeed().deriveAndAddWallets(seed!);
                            ref.read(homePageTabProvider.notifier).state =
                                HomePageTabState.accounts;
                            ref
                                .read(homePageBackgroundProvider.notifier)
                                .state = HomePageBackgroundState.hidden;
                            await Future.delayed(Duration(milliseconds: 200));
                            Navigator.of(context)
                                .popUntil(ModalRoute.withName("/"));
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
