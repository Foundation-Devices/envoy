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
import 'package:envoy/ui/theme/envoy_spacing.dart';

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
    S().magic_setup_generate_envoy_key_heading,
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
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
                                vertical: EnvoySpacing.xs,
                                horizontal: EnvoySpacing.small),
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
                                  padding: const EdgeInsets.only(
                                    top: EnvoySpacing.medium1,
                                    left: EnvoySpacing.medium1,
                                    right: EnvoySpacing.medium1,
                                  ),
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
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_androidBackupInfoPage != 0) {
          setState(() {
            _androidBackupInfoPage = 0;
          });
        }
        if (widget.onContinue != null) {
          widget.onContinue!.call();
        }
        if (widget.skipSuccessScreen) {
          Navigator.pop(context);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return WalletSetupSuccess();
          }));
        }
      },
      child: OnboardPageBackground(
        child: Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: EnvoySpacing.large3),
                  child: Container(
                    constraints: BoxConstraints.tight(Size.fromHeight(150)),
                    child: Image.asset(
                      "assets/exclamation_icon.png",
                      height: 150,
                      width: 150,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                      child: isAndroid
                          ? _androidBackUPInfo(context)
                          : _recoverStepsInfo(context)),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: EnvoySpacing.medium2,
                      left: EnvoySpacing.small,
                      right: EnvoySpacing.small),
                  child: OnboardingButton(
                    label: S().component_continue,
                    onTap: () {
                      if (isAndroid && _androidBackupInfoPage == 0) {
                        setState(() {
                          _androidBackupInfoPage = 1;
                        });
                        return;
                      }
                      if (widget.onContinue != null) {
                        widget.onContinue!.call();
                        return;
                      }
                      if (widget.skipSuccessScreen) {
                        //clear on-boarding routes and go to home
                        OnboardingPage.popUntilHome(context);
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return WalletSetupSuccess();
                        }));
                      }
                    },
                  ),
                )
              ],
            ),
            color: Colors.transparent),
      ),
    );
  }

  _recoverStepsInfo(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S().recovery_scenario_heading,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.medium2)),
                Text(
                  S().recovery_scenario_subheading,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 13),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.medium3)),
                ListTile(
                  minLeadingWidth: 20,
                  dense: true,
                  leading: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: EnvoySpacing.xs,
                        horizontal: EnvoySpacing.small),
                    decoration: BoxDecoration(
                      color: EnvoyColors.accentPrimary,
                      borderRadius: BorderRadius.circular(EnvoySpacing.xs),
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
                    padding: EdgeInsets.symmetric(
                        vertical: EnvoySpacing.xs,
                        horizontal: EnvoySpacing.small),
                    decoration: BoxDecoration(
                      color: EnvoyColors.accentPrimary,
                      borderRadius: BorderRadius.circular(EnvoySpacing.xs),
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
                    S().recovery_scenario_instruction2,
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
                    padding: EdgeInsets.symmetric(
                        vertical: EnvoySpacing.xs,
                        horizontal: EnvoySpacing.small),
                    decoration: BoxDecoration(
                      color: EnvoyColors.accentPrimary,
                      borderRadius: BorderRadius.circular(EnvoySpacing.xs),
                    ),
                    child: Text("3",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white)),
                  ),
                  title: Text(
                    S().recovery_scenario_ios_instruction3,
                    textAlign: TextAlign.start,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _androidBackUPInfo(BuildContext context) {
    return Container(
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
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S().android_backup_info_heading,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: EnvoySpacing.medium3)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1),
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
              ],
            )
          : _recoverStepsInfo(context),
    ));
  }
}
