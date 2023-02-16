// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/expert/generate_seed.dart';
import 'package:envoy/ui/onboard/expert/import_mnemonic_setup.dart';
import 'package:envoy/ui/onboard/expert/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter/material.dart';

class ExpertSetupPage extends StatefulWidget {
  const ExpertSetupPage({Key? key}) : super(key: key);

  @override
  State<ExpertSetupPage> createState() => _ExpertSetupPageState();
}

class _ExpertSetupPageState extends State<ExpertSetupPage> {
  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: TextButton(
              child: Text("Skip",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black)),
              onPressed: () {
                OnboardingPage.goHome(context);
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S().envoy_welcome_card1_heading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(padding: EdgeInsets.all(24)),
                      Text(
                        S().envoy_welcome_card1_subheading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox.shrink(),
                ),
                Flexible(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      child: TextButton(
                          child: Text(S().manual_setup_flow_tutorial_CTA_2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(color: EnvoyColors.teal)),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return SelectMode(
                                generate: false,
                              );
                            }));
                          }),
                    ),
                    OnboardingButton(
                        light: false,
                        label: S().manual_setup_flow_tutorial_CTA_1,
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return SelectMode(generate: true);
                          }));
                        }),
                  ],
                ))
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class SelectMode extends StatelessWidget {
  final bool generate;

  const SelectMode({Key? key, required this.generate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Padding(padding: EdgeInsets.all(14)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Image.asset("assets/fi_shield_off.png"),
                  )),
                  Flexible(
                      child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S().magic_setup_import_seed_heading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Padding(padding: EdgeInsets.all(24)),
                        Text(
                          S().magic_setup_import_seed_subheading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox.shrink(),
                  ),
                  generate
                      ? OnboardingButton(
                          light: false,
                          label: S().manual_setup_generate_seed_CTA,
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return Builder(builder: (context) {
                                return GenerateSeedScreen();
                              });
                            }));
                          })
                      : Flexible(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OnboardingButton(
                                light: true,
                                label: S().magic_setup_import_seed_CTA_1,
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return Builder(builder: (context) {
                                      return ImportMnemonicSeed(
                                        seedLength: SeedLength.MNEMONIC_12,
                                      );
                                    });
                                  }));
                                }),
                            OnboardingButton(
                                light: true,
                                label: S().magic_setup_import_seed_CTA_2,
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return Builder(builder: (context) {
                                      return ImportMnemonicSeed(
                                        seedLength: SeedLength.MNEMONIC_24,
                                      );
                                    });
                                  }));
                                }),
                          ],
                        ))
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
