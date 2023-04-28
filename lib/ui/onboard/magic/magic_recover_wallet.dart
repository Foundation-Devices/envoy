// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  failure,
}

class _MagicRecoverWalletState extends State<MagicRecoverWallet> {
  StateMachineController? _stateMachineController;

  MagicRecoveryWalletState _magicRecoverWalletState =
      MagicRecoveryWalletState.recovering;

  @override
  void initState() {
    super.initState();
    _initWalletRecovery();
  }

  void _initWalletRecovery() async {
    await Future.delayed(Duration(seconds: 1));

    final success = await EnvoySeed().restoreData();

    setState(() {
      if (success) {
        _magicRecoverWalletState = MagicRecoveryWalletState.success;
      } else {
        _magicRecoverWalletState = MagicRecoveryWalletState.failure;
      }
    });

    if (success) {
      _setHappyState();
    } else {
      _setUnhappyState();
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
      child: OnboardPageBackground(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading:
                _magicRecoverWalletState == MagicRecoveryWalletState.failure
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          CupertinoIcons.back,
                          color: Colors.black,
                        ))
                    : SizedBox(),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 240,
                  margin: EdgeInsets.only(bottom: 24),
                  child: RiveAnimation.asset(
                    "assets/envoy_loader.riv",
                    fit: BoxFit.contain,
                    onInit: _onRiveInit,
                  ),
                ),
                AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    child: Builder(
                      builder: (context) {
                        if (_magicRecoverWalletState ==
                            MagicRecoveryWalletState.recovering) {
                          return _recoveryInProgress(context);
                        }
                        if (_magicRecoverWalletState ==
                            MagicRecoveryWalletState.success) {
                          return _recoverySteps(context);
                        }
                        if (_magicRecoverWalletState ==
                            MagicRecoveryWalletState.failure) {
                          return _unsuccessfulRecovery(context);
                        }
                        return SizedBox();
                      },
                    )),
              ],
            ),
          ),
          bottomNavigationBar: getBottomButtons(),
        ),
      ),
    );
  }

  Widget? getBottomButtons() {
    if (_magicRecoverWalletState == MagicRecoveryWalletState.recovering) {
      return null;
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.success) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: OnboardingButton(
            label: S().magic_setup_generate_wallet_modal_ios_CTA,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WalletSetupSuccess();
              }));
            },
          ));
    }
    if (_magicRecoverWalletState == MagicRecoveryWalletState.failure) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingButton(
              label: S().magic_setup_recovery_fail_ios_CTA2,
              type: EnvoyButtonTypes.secondary,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ScannerPage(
                    ScannerType.seed,
                    callback: (seed) async {
                      setState(() {
                        _magicRecoverWalletState =
                            MagicRecoveryWalletState.recovering;
                      });
                      String? passphrase = null;
                      List<String> seedList = seed.split(" ");
                      if (seedList.length == 13 || seedList.length == 25) {
                        seedList.removeLast();
                        await showEnvoyDialog(
                                dialog: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    height: 330,
                                    child: SeedPassphraseEntry(
                                        onPassphraseEntered: (value) {
                                      passphrase = value;
                                      Navigator.pop(context);
                                    })),
                                context: context)
                            .then((value) {
                          setState(() {
                            passphrase = value;
                          });
                        });
                      }

                      EnvoySeed().create(seedList, passphrase: passphrase);
                      EnvoySeed().restoreData(seed: seed).then((success) {
                        setState(() {
                          if (success) {
                            _magicRecoverWalletState =
                                MagicRecoveryWalletState.success;
                          } else {
                            _magicRecoverWalletState =
                                MagicRecoveryWalletState.failure;
                          }
                        });
                      });
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
                _initWalletRecovery();
              },
            ),
          ],
        ),
      );
    }
    return null;
  }

  Widget _recoveryInProgress(BuildContext context) {
    return Text(
      S().magic_setup_recovery_heading,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  // Might have use for this in the future?
  //ignore: unused_element
  Widget _recoverySteps(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(children: [
        Text(
          S().magic_setup_recovery_heading,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Padding(padding: EdgeInsets.all(12)),
        Container(
          width: 300,
          child: Text(
            S().magic_setup_recovery_success_android_subheading,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
          ),
        ),
        Padding(padding: EdgeInsets.all(14)),
        ListTile(
          minLeadingWidth: 20,
          dense: true,
          leading: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: EnvoyColors.teal,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "1",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white),
            ),
          ),
          title: Text(
            Platform.isIOS
                ? S().magic_setup_recovery_success_iOS_instruction1
                : S().magic_setup_recovery_success_android_instructions1,
            textAlign: TextAlign.start,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
        ListTile(
          minLeadingWidth: 20,
          dense: true,
          leading: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: EnvoyColors.teal,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "2",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white),
            ),
          ),
          title: Text(
            Platform.isIOS
                ? S().magic_setup_recovery_success_iOS_instruction2
                : S().magic_setup_recovery_success_android_instructions2,
            textAlign: TextAlign.start,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
        ListTile(
          minLeadingWidth: 20,
          dense: true,
          leading: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: EnvoyColors.teal,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("3",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white)),
          ),
          title: Text(
            Platform.isIOS
                ? S().magic_setup_recovery_success_iOS_instruction3
                : S().magic_setup_recovery_success_android_instructions3,
            textAlign: TextAlign.start,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
      ]),
    );
  }

  Widget _unsuccessfulRecovery(BuildContext context) {
    bool isAndroid = Platform.isAndroid;
    return Column(
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

  void _setIndeterminateState() {
    _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
    _stateMachineController?.findInput<bool>("happy")?.change(false);
    _stateMachineController?.findInput<bool>("unhappy")?.change(false);
  }
}
