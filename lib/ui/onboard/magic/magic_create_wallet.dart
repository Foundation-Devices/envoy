// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/wallet_setup_finish.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:envoy/business/envoy_seed.dart';

class MagicCreateWallet extends StatefulWidget {
  const MagicCreateWallet({Key? key}) : super(key: key);

  @override
  State<MagicCreateWallet> createState() => _MagicCreateWalletState();
}

class _MagicCreateWalletState extends State<MagicCreateWallet> {
  StateMachineController? stateMachineController;
  PageController _pageController = PageController();
  int step = 0;
  List<String> stepsHeadings = [
    "MISSING", //S().magic_setup_envoy_key_creation_1_5_heading,
    "MISSING", //S().magic_setup_encrypting_backup_1_5_heading,
    "MISSING", //S().magic_setup_sending_backup_to_envoy_server_1_5_heading,
  ];

  List<String> stepSubHeadings = [
    "MISSING", //S().magic_setup_envoy_key_creation_1_5_subheading,
    "MISSING", //S().magic_setup_encrypting_backup_1_5_subheading,
    "MISSING", //S().magic_setup_sending_backup_to_envoy_server_1_5_subheading,
  ];

  _onRiveInit(Artboard artboard) {
    stateMachineController =
        StateMachineController.fromArtboard(artboard, 'STM');
    artboard.addController(stateMachineController!);
  }

  @override
  void initState() {
    super.initState();
    _initiateWalletCreate();
  }

  void _initiateWalletCreate() async {
    // TODO: sync this to actual steps in creation
    bool success = await EnvoySeed().generate();
    if (success) {
      await showDialog(
          context: context, builder: (context) => MagicRecoveryInfo());
      // await Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (c) => MagicRecoveryInfo()));
    }

    await Future.delayed(Duration(seconds: 2));
    setState(() {
      step = 1;
    });

    _updateProgress();
    //delay
    await Future.delayed(Duration(seconds: 4));
    setState(() {
      step = 2;
    });

    _updateProgress();

    await Future.delayed(Duration(seconds: 2));

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return WalletSetupFinish();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
      child: Material(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.black),
                    onPressed: () {
                      // stateMachineController?.findInput<bool>('showKey')?.change(false);
                      // stateMachineController?.findInput<bool>('showLock')?.change(true);
                      // stateMachineController?.findInput<bool>('showShield')?.change(false);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
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
                      ...stepsHeadings.map((e) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                stepsHeadings[step],
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 44, horizontal: 22),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 400),
                                  child: Text(
                                    stepSubHeadings[step],
                                    key: ValueKey<String>(
                                      stepSubHeadings[step],
                                    ),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(fontSize: 14),
                                  ),
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
    );
  }

  //Update page view and state machine
  _updateProgress() {
    _pageController.animateToPage(step,
        duration: Duration(milliseconds: 600), curve: Curves.easeInOut);
    stateMachineController?.findInput<bool>('showLock')?.change(step != 2);
    stateMachineController?.findInput<bool>('showShield')?.change(step == 2);
  }
}

class MagicRecoveryInfo extends StatelessWidget {
  const MagicRecoveryInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isAndroid = Platform.isAndroid;

    return OnboardPageBackground(
      child: Material(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  "assets/exclamation_icon.png",
                  height: 180,
                  width: 180,
                ),
                isAndroid
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              S().android_backup_info_heading,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Padding(padding: EdgeInsets.all(12)),
                            Text(
                              S().android_backup_info_subheading,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : _iosBackupInfo(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OnboardingButton(
                    label: S().component_continue,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          color: Colors.transparent),
    );
  }

  _iosBackupInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "MISSING", //S().recovery_scenario_heading,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(padding: EdgeInsets.all(12)),
          Text(
            "MISSING", //S().recovery_scenario_subheading,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
          ),
          Padding(padding: EdgeInsets.all(12)),
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
              "MISSING", //S().recovery_scenario_step_1,
              textAlign: TextAlign.start,
              style:
                  Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
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
              "MISSING", //S().recovery_scenario_step_2,
              textAlign: TextAlign.start,
              style:
                  Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
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
              "MISSING", //S().recovery_scenario_step_3,
              textAlign: TextAlign.start,
              style:
                  Theme.of(context).textTheme.caption?.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
