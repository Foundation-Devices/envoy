// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:envoy/ui/pages/legal/passport_tou.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class OnboardPassportWelcomeScreen extends StatelessWidget {
  const OnboardPassportWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      shield: Container(
        height: max(MediaQuery.of(context).size.height * 0.38, 300),
        margin: EdgeInsets.all(EnvoySpacing.medium1),
        padding: EdgeInsets.only(top: EnvoySpacing.large1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
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
                    Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                  LinkText(
                    text: S().passport_welcome_screen_cta3,
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: EnvoyColors.textTertiary),
                    linkStyle: EnvoyTypography.button
                        .copyWith(color: EnvoyColors.accentPrimary),
                    onTap: () {
                      launchUrl(
                          Uri.parse("https://foundationdevices.com/passport"));
                    },
                  ),
                  Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
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
                  Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
              child: EnvoyButton(
                S().component_skip,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
                type: EnvoyButtonTypes.tertiary,
                onTap: () {
                  OnboardingPage.popUntilHome(context);
                },
              ),
            )
          ],
        ),
        //using floating action button + offset for clamping the passport image to bottom nav
        //this is better than using a stack
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Transform.translate(
          offset: Offset(0, 75),
          child: Image.asset(
            "assets/passport_envoy.png",
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
          ),
        ),
        bottomNavigationBar: EnvoyScaffoldShieldScrollView(
          context,
          Padding(
              padding: const EdgeInsets.only(
                right: EnvoySpacing.medium1,
                left: EnvoySpacing.medium1,
                top: EnvoySpacing.medium1,
              ),
              child: Column(
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: EnvoySpacing.large1,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: EnvoySpacing.small),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: EnvoySpacing.medium1),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        S().passport_welcome_screen_heading,
                                        textAlign: TextAlign.center,
                                        style: EnvoyTypography.body.copyWith(
                                          fontSize: 20,
                                          color: EnvoyColors.gray1000,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.all(
                                              EnvoySpacing.small)),
                                      Text(
                                        S().passport_welcome_screen_subheading,
                                        style: EnvoyTypography.info.copyWith(
                                          color: EnvoyColors.inactiveDark,
                                          decoration: TextDecoration.none,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: EnvoySpacing.medium1,
                        right: EnvoySpacing.medium1,
                        top: EnvoySpacing.medium1,
                        bottom: EnvoySpacing.large2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                        LinkText(
                          text: S().passport_welcome_screen_cta3,
                          textStyle: EnvoyTypography.button.copyWith(
                            color: EnvoyColors.inactiveDark,
                          ),
                          linkStyle: EnvoyTypography.button
                              .copyWith(color: EnvoyColors.accentPrimary),
                          onTap: () {
                            launchUrl(Uri.parse(
                                "https://foundationdevices.com/passport"));
                          },
                        ),
                        Padding(padding: EdgeInsets.all(EnvoySpacing.medium1)),
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
                        Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
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
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
