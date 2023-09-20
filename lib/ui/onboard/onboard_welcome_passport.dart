// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:envoy/ui/pages/legal/passport_tou.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';

class OnboardPassportWelcomeScreen extends StatelessWidget {
  const OnboardPassportWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      shield: Container(
        height: max(MediaQuery.of(context).size.height * 0.38, 300),
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        padding: EdgeInsets.only(top: 44),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      S().passport_welcome_screen_heading,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Padding(padding: EdgeInsets.all(6)),
                    Text(
                      S().passport_welcome_screen_subheading,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(padding: EdgeInsets.all(4)),
                  LinkText(
                    text: S().passport_welcome_screen_cta3,
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800, color: EnvoyColors.grey),
                    linkStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800, color: EnvoyColors.teal),
                    onTap: () {
                      launchUrl(
                          Uri.parse("https://foundationdevices.com/passport"));
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  EnvoyButton(
                    S().passport_welcome_screen_cta2,
                    type: EnvoyButtonTypes.secondary,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OnboardPassportWelcomeScreen(),
                          ));
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  EnvoyButton(
                    S().passport_welcome_screen_cta1,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OnboardPassportWelcomeScreen(),
                          ));
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kToolbarHeight,
          backgroundColor: Colors.transparent,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
              return;
              //TODO: fix this
              // if (GoRouter.of(context).canPop()) {
              //   GoRouter.of(context).pop();
              // } else {
              //   GoRouter.of(context).push(ROUTE_ACCOUNTS_HOME);
              // }
            },
          ),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: EnvoyButton(
                S().passport_welcome_screen_skip,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
                type: EnvoyButtonTypes.tertiary,
                onTap: () {
                  popBackToHome(context);
                },
              ),
            )
          ],
        ),
        //using floating action button + offset for clamping the passport image to bottom nav
        //this is better than using a stack
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Transform.translate(
          offset: Offset(0, 54),
          child: Image.asset(
            "assets/passport_envoy.png",
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width / 1.55,
            height: MediaQuery.of(context).size.height / 1.55,
          ),
        ),
        bottomNavigationBar: EnvoyScaffoldShieldScrollView(
          context,
          Padding(
              padding: const EdgeInsets.only(
                  right: 15, left: 15, top: 15, bottom: 50),
              child: SizedBox.expand(
                  child: Container(
                height: max(MediaQuery.of(context).size.height * 0.38, 300),
                margin: EdgeInsets.symmetric(horizontal: 18),
                padding: EdgeInsets.only(top: 44),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        width: 380,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              S().passport_welcome_screen_heading,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Padding(padding: EdgeInsets.all(6)),
                            Text(
                              S().passport_welcome_screen_subheading,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(padding: EdgeInsets.all(4)),
                          LinkText(
                            text: S().passport_welcome_screen_cta3,
                            textStyle: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: EnvoyColors.grey),
                            linkStyle: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: EnvoyColors.teal),
                            onTap: () {
                              launchUrl(Uri.parse(
                                  "https://foundationdevices.com/passport"));
                            },
                          ),
                          Padding(padding: EdgeInsets.all(8)),
                          EnvoyButton(
                            S().passport_welcome_screen_cta2,
                            type: EnvoyButtonTypes.secondary,
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return SingleImportPpIntroPage();
                              }));
                            },
                          ),
                          Padding(padding: EdgeInsets.all(8)),
                          EnvoyButton(
                            S().passport_welcome_screen_cta1,
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return TouPage();
                              }));
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ))),
        ),
      ),
    );
  }
}
