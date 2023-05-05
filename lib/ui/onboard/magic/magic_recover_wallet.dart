// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:backup/backup.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';

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
    } on ServerUnreachable {
      print("Server {}");
      setState(() {
        _magicRecoverWalletState = MagicRecoveryWalletState.serverNotReachable;
      });
    } catch (e) {
      setState(() {
        _magicRecoverWalletState = MagicRecoveryWalletState.backupNotFound;
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
        child: OnboardPageBackground(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 8),
                  height: 44,
                  child: _magicRecoverWalletState ==
                          MagicRecoveryWalletState.backupNotFound
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoNavigationBarBackButton(
                              color: Colors.black,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        )
                      : SizedBox(),
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: 180,
                      child: Transform.scale(
                        scale: 1.3,
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
        ),
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
              //TODO: localize
              label: "Import Envoy Backup",
              type: EnvoyButtonTypes.secondary,
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  dialogTitle: "Choose Envoy backup file",
                );
                if (result != null) {
                  if (result.files.single.path != null) {
                    _recoverManually(path: result.files.single.path);
                  }
                }
              },
            ),
            OnboardingButton(
              label: S().magic_setup_recovery_fail_ios_CTA1,
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
    if (_magicRecoverWalletState ==
        MagicRecoveryWalletState.serverNotReachable) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingButton(
              //TODO: localize  key: magic_setup_recovery_fail_connectivity_cta3
              label: "Continue",
              type: EnvoyButtonTypes.tertiary,
              onTap: () {
                showContinueWarningDialog(context);
              },
            ),
            OnboardingButton(
              label: S().magic_setup_recovery_fail_ios_CTA2,
              type: EnvoyButtonTypes.secondary,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ScannerPage(
                    ScannerType.seed,
                    callback: (seed) async {
                      _recoverManually(seed: seed);
                    },
                  );
                }));
              },
            ),
            OnboardingButton(
              label: S().magic_setup_recovery_fail_ios_CTA1,
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

  //Recover using seed or backup file
  _recoverManually({String? path, String? seed}) async {
    setState(() {
      _magicRecoverWalletState = MagicRecoveryWalletState.recovering;
    });

    _setIndeterminateState();

    String? seed = null;
    String? passphrase = null;
    List<String> seedList = [];
    bool success = false;
    try {
      if (seed != null) {
        seedList = seed.split(" ");
        if (seedList.length == 13 || seedList.length == 25) {
          seedList.removeLast();
          await showEnvoyDialog(
              dialog: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 330,
                  child: SeedPassphraseEntry(onPassphraseEntered: (value) {
                    passphrase = value;
                    Navigator.pop(context);
                  })),
              context: context);
        }
      }
      if (seedList.isNotEmpty) {
        await EnvoySeed().create(seedList, passphrase: passphrase);
      }
      await Future.delayed(Duration(seconds: 1));
      success = await EnvoySeed().restoreData(seed: seed);
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
    } on ServerUnreachable {
      setState(() {
        _magicRecoverWalletState = MagicRecoveryWalletState.backupNotFound;
      });
    } catch (e) {
      setState(() {
        _magicRecoverWalletState = MagicRecoveryWalletState.backupNotFound;
      });
    } finally {
      if (success) {
        _setHappyState();
      } else {
        _setUnhappyState();
      }
    }
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
    bool isAndroid = Platform.isAndroid;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            S().magic_setup_recovery_fail_ios_heading,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(padding: EdgeInsets.all(28)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            isAndroid
                ? S().magic_setup_recovery_fail_android_subheading
                : S().magic_setup_recovery_fail_ios_subheading,
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
                        //TODO: Localize key:manual_setup_recovery_import_backup_modal_fail_connectivity_heading
                        "WARNING",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(2)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      //TODO: localize key:manual_setup_recovery_import_backup_modal_fail_subheading
                      child: Text(
                        "If you continue without a backup file, your wallet settings, additional accounts, plus Tags and Labels will not be restored.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(2)),
                  ],
                ),
                OnboardingButton(
                    //TODO: localize key:manual_setup_recovery_import_backup_modal_fail_connectivity_cta2
                    label: "Go Back",
                    type: EnvoyButtonTypes.tertiary,
                    onTap: () async {
                      Navigator.pop(context);
                    }),
                Padding(padding: EdgeInsets.all(2)),
                Consumer(
                  builder: (context, ref, child) {
                    return OnboardingButton(
                        //TODO: localize key:manual_setup_recovery_import_backup_modal_fail_connectivity_cta1
                        label: "Continue",
                        onTap: () async {
                          ref.read(homePageTabProvider.notifier).state =
                              HomePageTabState.accounts;
                          ref.read(homePageBackgroundProvider.notifier).state =
                              HomePageBackgroundState.hidden;
                          await Future.delayed(Duration(milliseconds: 200));
                          Navigator.of(context)
                              .popUntil(ModalRoute.withName("/"));
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
