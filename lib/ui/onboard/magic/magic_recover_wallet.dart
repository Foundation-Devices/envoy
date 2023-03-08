// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

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
    await Future.delayed(Duration(seconds: 3));

    final success = await EnvoySeed().restoreData();

    setState(() {
      if (success) {
        _magicRecoverWalletState = MagicRecoveryWalletState.success;
      } else {
        _magicRecoverWalletState = MagicRecoveryWalletState.failure;
      }
    });

    _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
    _stateMachineController?.findInput<bool>("happy")?.change(false);
    _stateMachineController?.findInput<bool>("unhappy")?.change(true);
  }

  _onRiveInit(Artboard artBoard) {
    _stateMachineController =
        StateMachineController.fromArtboard(artBoard, 'STM');
    artBoard.addController(_stateMachineController!);
    _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
      child: Material(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 240,
                  height: 240,
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
                          return _recoveryInstructions(context);
                        }
                        if (_magicRecoverWalletState ==
                            MagicRecoveryWalletState.success) {
                          return _recoveryInstructions(context);
                        }
                        if (_magicRecoverWalletState ==
                            MagicRecoveryWalletState.failure) {
                          return _unsuccessfulRecovery(context);
                        }
                        return SizedBox();
                      },
                    )),
                _magicRecoverWalletState == MagicRecoveryWalletState.success
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: OnboardingButton(
                          label: "Continue",
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return WalletSetupSuccess();
                            }));
                          },
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
          color: Colors.transparent),
    );
  }

  Widget _recoveryInstructions(BuildContext context) {
    return Column(
      children: [
        Text(
          S().magic_setup_recovery_heading,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        Padding(padding: EdgeInsets.all(12)),
        Text(
          S().magic_setup_recovery_subheading,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  // Might have use for this in the future?
  //ignore: unused_element
  Widget _recoverySteps(BuildContext context) {
    return Column(children: [
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
          "MISSING", //S().magic_recovery_flow_step_1,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
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
          "MISSING", //S().magic_recovery_flow_step_2,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
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
          "MISSING", //S().magic_recovery_flow_step_3,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
        ),
      ),
    ]);
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
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Padding(padding: EdgeInsets.all(12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            isAndroid
                ? S().magic_setup_recovery_fail_android_subheading
                : S().magic_setup_recovery_fail_ios_subheading,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
          ),
        ),
        Padding(padding: EdgeInsets.all(24)),
        OnboardingButton(
          label: S().magic_setup_recovery_fail_ios_CTA2,
          light: true,
          onTap: () {
            setState(() {
              _magicRecoverWalletState = MagicRecoveryWalletState.recovering;
            });

            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ScannerPage(
                ScannerType.seed,
                callback: (seed) {
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
              _magicRecoverWalletState = MagicRecoveryWalletState.recovering;
            });
            _stateMachineController
                ?.findInput<bool>("indeterminate")
                ?.change(true);
            _stateMachineController?.findInput<bool>("happy")?.change(false);
            _stateMachineController?.findInput<bool>("unhappy")?.change(false);

            await Future.delayed(Duration(seconds: 3));

            setState(() {
              _magicRecoverWalletState = MagicRecoveryWalletState.success;
            });
            _stateMachineController
                ?.findInput<bool>("indeterminate")
                ?.change(false);
            _stateMachineController?.findInput<bool>("happy")?.change(true);
            _stateMachineController?.findInput<bool>("unhappy")?.change(false);
          },
        ),
      ],
    );
  }
}
