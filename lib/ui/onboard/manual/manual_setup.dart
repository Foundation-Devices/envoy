// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/generate_seed.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_import_seed.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/manual/widgets/wordlist.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManualSetup extends StatefulWidget {
  const ManualSetup({Key? key}) : super(key: key);

  @override
  State<ManualSetup> createState() => _ManualSetupState();
}

class _ManualSetupState extends State<ManualSetup> {
  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CupertinoNavigationBarBackButton(
              color: Colors.black,
              onPressed: () => Navigator.pop(context),
            ),
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
          ],
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
                        S().manual_setup_tutorial_heading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Padding(padding: EdgeInsets.all(24)),
                      Text(
                        S().manual_setup_tutorial_subheading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
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
                    OnboardingButton(
                        label: S().manual_setup_tutorial_CTA2,
                        type: EnvoyButtonTypes.secondary,
                        fontWeight: FontWeight.w600,
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return SeedIntroScreen(
                              mode: SeedIntroScreenType.import,
                            );
                          }));
                        }),
                    !EnvoySeed().walletDerived()
                        ? OnboardingButton(
                            label: S().manual_setup_tutorial_CTA1,
                            fontWeight: FontWeight.w600,
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return SeedIntroScreen(
                                    mode: SeedIntroScreenType.generate);
                              }));
                            })
                        : SizedBox.shrink(),
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

enum SeedIntroScreenType {
  generate,
  import,
  verify,
}

class SeedIntroScreen extends StatelessWidget {
  final SeedIntroScreenType mode;

  const SeedIntroScreen({Key? key, required this.mode}) : super(key: key);

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
                      child: Container(
                    child: mode == SeedIntroScreenType.generate ||
                            mode == SeedIntroScreenType.verify
                        ? Image.asset(
                            "assets/shield_inspect.png",
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/fw_intro.png",
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                    padding: EdgeInsets.only(bottom: 12),
                  )),
                  Flexible(
                      child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mode == SeedIntroScreenType.generate ||
                                  mode == SeedIntroScreenType.verify
                              ? S().manual_setup_generate_seed_heading
                              : S().manual_setup_import_seed_heading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Padding(padding: EdgeInsets.all(24)),
                        Text(
                          mode == SeedIntroScreenType.generate ||
                                  mode == SeedIntroScreenType.verify
                              ? S().manual_setup_generate_seed_subheading
                              : S().manual_setup_import_seed_subheading,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox.shrink(),
                  ),
                  mode == SeedIntroScreenType.generate ||
                          mode == SeedIntroScreenType.verify
                      ? OnboardingButton(
                          label: mode == SeedIntroScreenType.generate
                              ? S().manual_setup_generate_seed_CTA
                              : S()
                                  .backups_erase_wallets_and_backups_show_seed_CTA,
                          fontWeight: FontWeight.w600,
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return Builder(builder: (context) {
                                return SeedScreen(
                                    generate:
                                        mode == SeedIntroScreenType.generate);
                              });
                            }));
                          })
                      : Flexible(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OnboardingButton(
                                type: EnvoyButtonTypes.secondary,
                                label: S().manual_setup_import_seed_CTA3,
                                fontWeight: FontWeight.w600,
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return Builder(builder: (context) {
                                      return ManualSetupImportSeed(
                                        seedLength: SeedLength.MNEMONIC_12,
                                      );
                                    });
                                  }));
                                }),
                            OnboardingButton(
                                type: EnvoyButtonTypes.secondary,
                                label: S().manual_setup_import_seed_CTA2,
                                fontWeight: FontWeight.w600,
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return Builder(builder: (context) {
                                      return ManualSetupImportSeed(
                                        seedLength: SeedLength.MNEMONIC_24,
                                      );
                                    });
                                  }));
                                }),
                            OnboardingButton(
                                type: EnvoyButtonTypes.primary,
                                label: S().manual_setup_import_seed_CTA1,
                                fontWeight: FontWeight.w600,
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return ScannerPage([ScannerType.seed],
                                        callback: (result) {
                                      List<String> seedWords =
                                          result.split(" ");
                                      String passPhrase = "";
                                      bool isValid = seedWords
                                          .map((e) => seed_en.contains(e))
                                          .reduce((value, element) =>
                                              value && element);
                                      if (!isValid) {
                                        showInvalidSeedDialog(
                                          context: context,
                                        );
                                        return;
                                      }
                                      print("isValid ${isValid} ${seedWords}");
                                      //TODO: Passphrase
                                      EnvoySeed()
                                          .create(seedWords,
                                              passphrase: passPhrase.isEmpty
                                                  ? null
                                                  : passPhrase)
                                          .then((success) {
                                        if (success) {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return WalletSetupSuccess();
                                          }));
                                        } else {
                                          showInvalidSeedDialog(
                                            context: context,
                                          );
                                        }
                                      });
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
