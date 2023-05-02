// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:envoy/ui/pages/legal/passport_tou.dart';
import 'package:envoy/ui/shield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardPassportWelcomeScreen extends StatelessWidget {
  const OnboardPassportWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
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
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: "I don’t have a Passport.",
                          ),
                          TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: EnvoyColors.teal),
                              text: "  Buy One",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {}),
                        ],
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: EnvoyColors.grey)),
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
            onPressed: () => Navigator.pop(context),
          ),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: EnvoyButton(
                "Skip",
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
          offset: Offset(0, 54),
          child: Image.asset(
            "assets/passport_envoy.png",
            scale: 1,
            width: (MediaQuery.of(context).size.width * 0.7).clamp(250, 400),
          ),
        ),
        bottomNavigationBar: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              padding: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0x0),
                Color(0xff686868),
                Color(0xffFFFFFF),
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Shield(
                child: Padding(
                    padding: const EdgeInsets.only(
                        right: 15, left: 15, top: 15, bottom: 50),
                    child: SizedBox.expand(
                        child: Container(
                      height:
                          max(MediaQuery.of(context).size.height * 0.38, 300),
                      margin:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 18),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    S().passport_welcome_screen_heading,
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Padding(padding: EdgeInsets.all(6)),
                                  Text(
                                    S().passport_welcome_screen_subheading,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
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
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: S()
                                              .envoy_welcome_cta03
                                              .replaceAll("{{Buy One}}", ""),
                                        ),
                                        TextSpan(
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: EnvoyColors.teal),
                                            text: "  Buy One",
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                launchUrl(Uri.parse(
                                                    "https://foundationdevices.com/passport"));
                                              }),
                                      ],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: EnvoyColors.grey)),
                                ),
                                Padding(padding: EdgeInsets.all(8)),
                                EnvoyButton(
                                  S().passport_welcome_screen_cta2,
                                  type: EnvoyButtonTypes.primary,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return SingleImportPpIntroPage();
                                    }));
                                  },
                                ),
                                Padding(padding: EdgeInsets.all(8)),
                                EnvoyButton(
                                  S().passport_welcome_screen_cta1,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
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
          ),
        ),
      ),
    );
  }
}
