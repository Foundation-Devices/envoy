// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/prime/prime_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardPrimeWelcome extends StatelessWidget {
  const OnboardPrimeWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      gradientHeight: 1.8,
      shield: Container(
        margin: const EdgeInsets.all(EnvoySpacing.medium1),
        padding: const EdgeInsets.only(top: EnvoySpacing.large1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
              child: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      S().passport_welcome_screen_heading,
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.heading,
                    ),
                    const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
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
                  const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                  LinkText(
                    text: S().passport_welcome_screen_cta3,
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: EnvoyColors.textTertiary),
                    linkStyle: EnvoyTypography.button
                        .copyWith(color: EnvoyColors.accentPrimary),
                    onTap: () {
                      launchUrl(Uri.parse("https://foundation.xyz/passport"));
                    },
                  ),
                  const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                  EnvoyButton(
                    S().passport_welcome_screen_cta2,
                    type: EnvoyButtonTypes.secondary,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardPrimeWelcome(),
                          ));
                    },
                  ),
                  const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                  EnvoyButton(
                    S().passport_welcome_screen_cta1,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardPrimeWelcome(),
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
                  context.go("/");
                },
              ),
            )
          ],
        ),
        //using floating action button + offset for clamping the passport image to bottom nav
        //this is better than using a stack
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 75),
          child: Image.asset(
            "assets/prime_welcome_white.png",
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
          ),
        ),
        bottomNavigationBar: envoyScaffoldShieldScrollView(
          context,
          Padding(
              padding: const EdgeInsets.only(
                right: EnvoySpacing.medium1,
                left: EnvoySpacing.medium1,
                top: EnvoySpacing.medium1,
              ),
              child: Column(
                children: [
                  const SizedBox(height: EnvoySpacing.medium1),
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 300,
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: EnvoySpacing.large1,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                                          "Welcome Prime",
                                          textAlign: TextAlign.center,
                                          style: EnvoyTypography.body.copyWith(
                                            fontSize: 20,
                                            color: EnvoyColors.gray1000,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        const SizedBox(
                                            height: EnvoySpacing.small),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: EnvoySpacing.medium1,
                        right: EnvoySpacing.medium1,
                        bottom: EnvoySpacing.large2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: EnvoySpacing.medium1),
                        Consumer(
                          builder: (context, ref, child) {
                            final payload = ref.watch(primePayload);
                            return Text("Payload : $payload");
                          },
                        ),
                        const SizedBox(height: EnvoySpacing.medium1),
                        EnvoyButton("Connect", onTap: () {}),
                        const SizedBox(height: EnvoySpacing.small),
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
