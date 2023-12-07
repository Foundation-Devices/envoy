// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:animations/animations.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/envoy_method_channel.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class MagicSetupGenerate extends StatefulWidget {
  const MagicSetupGenerate({Key? key}) : super(key: key);

  @override
  State<MagicSetupGenerate> createState() => _MagicSetupGenerateState();
}

class _MagicSetupGenerateState extends State<MagicSetupGenerate> {
  final walletGenerated = EnvoySeed().walletDerived();

  StateMachineController? stateMachineController;
  PageController _pageController = PageController();
  late int step;

  List<String> stepsHeadings = [
    Platform.isAndroid
        ? S().magic_setup_generate_envoy_key_android_heading
        : S().magic_setup_generate_envoy_key_ios_heading,
    S().magic_setup_generate_backup_heading,
    S().magic_setup_send_backup_to_envoy_server_heading,
  ];

  List<String> stepSubHeadings = [
    Platform.isAndroid
        ? S().magic_setup_generate_envoy_key_android_subheading
        : S().magic_setup_generate_envoy_key_ios_subheading,
    S().magic_setup_generate_backup_subheading,
    S().magic_setup_send_backup_to_envoy_server_subheading,
  ];

  bool isRiveInitialized = false;

  _onRiveInit(Artboard artboard) {
    stateMachineController =
        StateMachineController.fromArtboard(artboard, 'STM');
    artboard.addController(stateMachineController!);
    if (walletGenerated) {
      stateMachineController?.findInput<bool>('ShowKey')?.change(false);
      stateMachineController?.findInput<bool>('showLock')?.change(true);
      stateMachineController?.findInput<bool>('showShield')?.change(false);
    }
    if (!isRiveInitialized) {
      _initiateWalletCreate();
      isRiveInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    step = walletGenerated ? 1 : 0;
  }

  void _initiateWalletCreate() async {
    if (!walletGenerated) {
      Settings().syncToCloud = true;
      Settings().store();

      await EnvoySeed().generate();
    }

    if (!walletGenerated) {
      await Future.delayed(Duration(seconds: 2));
      if (mounted)
        setState(() {
          step = 1;
        });
      _updateProgress();
      //delay
    }
    _updateProgress();
    await Future.delayed(Duration(seconds: 4));
    setState(() {
      step = 2;
    });
    _updateProgress();

    await Future.delayed(Duration(seconds: 2));

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            MagicRecoveryInfo(skipSuccessScreen: walletGenerated),
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: OnboardPageBackground(
        child: Material(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    alignment: Alignment.topCenter,
                    height: 280,
                    width: 280,
                    child: RiveAnimation.asset(
                      'assets/envoy_magic_setup.riv',
                      stateMachines: ["STM"],
                      onInit: _onRiveInit,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 280,
                    child: PageView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      children: [
                        ...stepsHeadings.map((heading) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  heading,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24, horizontal: 22),
                                  child: Text(
                                    stepSubHeadings[
                                        stepsHeadings.indexOf(heading)],
                                    key: ValueKey<String>(
                                      stepSubHeadings[
                                          stepsHeadings.indexOf(heading)],
                                    ),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList()
                      ],
                    ),
                  ),
                )
              ],
            ),
            color: Colors.transparent),
      ),
    );
  }

  //Update page view and state machine
  _updateProgress() async {
    if (walletGenerated) {
      stateMachineController?.findInput<bool>('ShowKey')?.change(step == 0);
      stateMachineController?.findInput<bool>('showLock')?.change(step == 1);
      stateMachineController?.findInput<bool>('showShield')?.change(step == 2);
    } else {
      stateMachineController?.findInput<bool>('showLock')?.change(step != 2);
      stateMachineController?.findInput<bool>('showShield')?.change(step == 2);
    }
    _pageController.animateToPage(step,
        duration: Duration(milliseconds: 580), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    stateMachineController?.dispose();
    super.dispose();
  }
}

class MagicRecoveryInfo extends ConsumerStatefulWidget {
  final bool skipSuccessScreen;
  final GestureTapCallback? onContinue;

  MagicRecoveryInfo(
      {Key? key, this.skipSuccessScreen = false, this.onContinue = null})
      : super(key: key);

  @override
  ConsumerState<MagicRecoveryInfo> createState() => _MagicRecoveryInfoState();
}

class _MagicRecoveryInfoState extends ConsumerState<MagicRecoveryInfo> {
  int _androidBackupInfoPage = 0;

  @override
  Widget build(BuildContext context) {
    bool isAndroid = Platform.isAndroid;
    bool _iphoneSE = MediaQuery.of(context).size.height < 700;
    return WillPopScope(
      onWillPop: () async {
        if (_androidBackupInfoPage != 0) {
          setState(() {
            _androidBackupInfoPage = 0;
          });
          return false;
        }
        if (widget.onContinue != null) {
          widget.onContinue!.call();
          return false;
        }
        if (widget.skipSuccessScreen) {
          Navigator.pop(context);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return WalletSetupSuccess();
          }));
        }
        return false;
      },
      child: OnboardPageBackground(
        child: Material(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Image.asset(
                    "assets/exclamation_icon.png",
                    height: 180,
                    width: 180,
                  ),
                  height: _iphoneSE ? 220 : 250,
                ),
                Expanded(
                    child: isAndroid
                        ? _androidBackUPInfo(context)
                        : _recoverStepsInfo(context))
              ],
            ),
            color: Colors.transparent),
      ),
    );
  }

  _recoverStepsInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Platform.isAndroid
                    ? S().recovery_scenario_android_heading
                    : S().recovery_scenario_ios_heading,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Padding(padding: EdgeInsets.all(16)),
              Text(
                Platform.isAndroid
                    ? S().recovery_scenario_android_subheading
                    : S().recovery_scenario_ios_subheading,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 13),
              ),
              Padding(padding: EdgeInsets.all(16)),
              ListTile(
                minLeadingWidth: 20,
                dense: true,
                leading: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: EnvoyColors.accentPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "1",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
                title: Text(
                  Platform.isAndroid
                      ? S().recovery_scenario_Android_instruction1
                      : S().recovery_scenario_ios_instruction1,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 14),
                ),
              ),
              ListTile(
                minLeadingWidth: 20,
                dense: true,
                leading: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: EnvoyColors.accentPrimary,
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
                  Platform.isAndroid
                      ? S().recovery_scenario_Android_instruction2
                      : S().recovery_scenario_ios_instruction2,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 14),
                ),
              ),
              ListTile(
                minLeadingWidth: 20,
                dense: true,
                leading: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: EnvoyColors.accentPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text("3",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white)),
                ),
                title: Text(
                  Platform.isAndroid
                      ? S().recovery_scenario_Android_instruction1
                      : S().recovery_scenario_ios_instruction3,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          Spacer(),
          OnboardingButton(
            label: S().component_continue,
            onTap: () {
              if (widget.onContinue != null) {
                widget.onContinue!.call();
                return;
              }
              if (widget.skipSuccessScreen) {
                //clear on-boarding routes and go to home
                OnboardingPage.popUntilHome(context);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return WalletSetupSuccess();
                }));
              }
            },
          ),
        ],
      ),
    );
  }

  _androidBackUPInfo(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: PageTransitionSwitcher(
          reverse: _androidBackupInfoPage == 1,
          duration: Duration(milliseconds: 600),
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return SharedAxisTransition(
              animation: animation,
              fillColor: Colors.transparent,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.vertical,
              child: child,
            );
          },
          child: _androidBackupInfoPage == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S().android_backup_info_heading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Padding(padding: EdgeInsets.all(12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: LinkText(
                            text: S().android_backup_info_subheading,
                            onTap: () {
                              openAndroidSettings();
                            },
                            linkStyle: EnvoyTypography.button
                                .copyWith(color: EnvoyColors.accentPrimary),
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: OnboardingButton(
                        label: S().component_continue,
                        onTap: () {
                          setState(() {
                            _androidBackupInfoPage = 1;
                          });
                        },
                      ),
                    ),
                  ],
                )
              : _recoverStepsInfo(context),
        ));
  }
}
