// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/magic/magic_recover_wallet.dart';
import 'package:envoy/ui/onboard/magic/magic_setup_tutorial.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/envoy_scaffold.dart';

class OnboardEnvoyWelcomeScreen extends StatefulWidget {
  const OnboardEnvoyWelcomeScreen({Key? key}) : super(key: key);

  @override
  State<OnboardEnvoyWelcomeScreen> createState() =>
      _OnboardEnvoyWelcomeScreenState();
}

class _OnboardEnvoyWelcomeScreenState extends State<OnboardEnvoyWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      shield: Container(
        height: max(MediaQuery.of(context).size.height * 0.38, 300),
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        padding: EdgeInsets.only(top: 44),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: EnvoyButton(
                S().envoy_welcome_right_action,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
                type: EnvoyButtonTypes.tertiary,
                onTap: () {
                  Navigator.of(context).popUntil(ModalRoute.withName("/"));
                },
              ),
            )
          ],
        ),
        //using floating action button + offset for clamping the passport image to bottom nav
        //this is better than using a stack
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Transform.translate(
          offset: Offset(-8, 54),
          child: Image.asset(
            "assets/envoy_on_device.png",
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width / 2.4,
            height: MediaQuery.of(context).size.height / 2.4,
          ),
        ),
        bottomNavigationBar: EnvoyScaffoldShieldScrollView(
          context,
          Padding(
              padding: const EdgeInsets.only(right: 15, left: 15, top: 16),
              child: SizedBox.expand(
                  child: Container(
                height: max(MediaQuery.of(context).size.height * 0.38, 800),
                margin: EdgeInsets.symmetric(vertical: 4 * 10, horizontal: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              S().envoy_welcome_screen_heading,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Padding(padding: EdgeInsets.all(6)),
                            LinkText(
                              text: S().envoy_welcome_screen_subheading,
                              textStyle: Theme.of(context).textTheme.bodySmall,
                              linkStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 15, left: 28, right: 28),
                      child: Column(
                        children: [
                          Padding(padding: EdgeInsets.all(4)),
                          EnvoyButton(
                            S().envoy_welcome_screen_cta2,
                            type: EnvoyButtonTypes.secondary,
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ManualSetup();
                              }));
                            },
                          ),
                          Padding(padding: EdgeInsets.all(6)),
                          EnvoyButton(
                            S().envoy_welcome_screen_cta1,
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return MagicSetupTutorial();
                              }));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))),
        ),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        if (await EnvoySeed().get() != null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MagicRecoverWallet()));
        }
      } catch (e) {
        //no-op
      }
    });
    super.initState();
  }
}
