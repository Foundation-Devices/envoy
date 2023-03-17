// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_import_backup.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/manual/widgets/wordlist.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:url_launcher/url_launcher.dart';

class ManualSetupImportSeed extends StatefulWidget {
  final SeedLength seedLength;

  const ManualSetupImportSeed({Key? key, required this.seedLength})
      : super(key: key);

  @override
  State<ManualSetupImportSeed> createState() => _ManualSetupImportSeedState();
}

class _ManualSetupImportSeedState extends State<ManualSetupImportSeed> {
  bool hasPassphrase = false;
  String passPhrase = "";
  bool finishSeedEntries = false;

  List<String> currentWords = [];

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
      child: Material(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        S().manual_setup_import_seed_12_words_heading,
                        style: Theme.of(context).textTheme.headline6,
                      )),
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.only(top: 8),
                    height: MediaQuery.of(context).size.height * 0.59,
                    child: MnemonicEntryGrid(
                        seedLength: widget.seedLength,
                        onSeedWordAdded: (List<String> words) {
                          currentWords = words;
                          bool isValid = currentWords
                              .map((e) => seed_en.contains(e))
                              .reduce((value, element) => value && element);
                          setState(() {
                            finishSeedEntries = isValid;
                          });
                        }),
                  ))
                ],
              )),
              Column(
                children: [
                  Padding(padding: EdgeInsets.all(2)),
                  InkWell(
                    onTap: () {
                      setState(() {
                        hasPassphrase = !hasPassphrase;
                        if (hasPassphrase == true) {
                          showPassphraseWarningDialog(context);
                        } else {
                          passPhrase = "";
                        }
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          checkColor: EnvoyColors.white100,
                          activeColor: EnvoyColors.darkTeal,
                          value: hasPassphrase,
                          onChanged: (value) {
                            setState(() {
                              hasPassphrase = value ?? false;
                            });
                            if (value == true) {
                              showPassphraseWarningDialog(context);
                            } else {
                              passPhrase = "";
                            }
                          },
                        ),
                        Text(
                          S().manual_setup_import_seed_12_words_checkbox,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: IgnorePointer(
                        ignoring: finishSeedEntries == false,
                        child: Opacity(
                          opacity: finishSeedEntries ? 1 : 0.5,
                          child: OnboardingButton(
                              label: S().manual_setup_import_seed_12_words_CTA,
                              onTap: () {
                                EnvoySeed()
                                    .create(currentWords,
                                        passphrase: passPhrase)
                                    .then((success) {
                                  if (success) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return ManualSetupImportBackup();
                                    }));
                                  } else {
                                    showInvalidSeedDialog(
                                      context: context,
                                    );
                                  }
                                });
                              }),
                        ),
                      ))
                ],
              )
            ],
          ),
          color: Colors.transparent),
    );
  }

  void showPassphraseWarningDialog(BuildContext context) {
    showEnvoyDialog(dialog: _buildPassphraseWarning(context), context: context)
        .then((value) {
      setState(() {
        hasPassphrase = passPhrase.isNotEmpty;
      });
    });
  }

  void showPassphraseDialog(BuildContext context) {
    showEnvoyDialog(
            dialog: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 330,
                child: SeedPassphraseEntry(onPassphraseEntered: (value) {
                  setState(() {
                    passPhrase = value;
                  });
                  //TODO: BIP39 passphrase
                  Navigator.pop(context);
                })),
            context: context)
        .then((value) {
      setState(() {
        hasPassphrase = passPhrase.isNotEmpty;
      });
    });
  }

  Widget _buildPassphraseWarning(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85, minHeight: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    hasPassphrase = false;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(EnvoyIcons.exclamation_warning,
                    color: EnvoyColors.darkCopper, size: 60),
                Padding(padding: EdgeInsets.all(4)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: Builder(
                    builder: (context) {
                      List<String> warning = S()
                          .manual_setup_verify_seed_12_words_passphrase_warning_modal_subheading
                          .split("\n");
                      List<TextSpan> spans =
                          warning.map((e) => TextSpan(text: "${e}\n")).toList();
                      if (spans.length > 2) {
                        spans[1] = TextSpan(
                            text: spans[1].text,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500));
                      }
                      return GestureDetector(
                        onTap: () async {
                          try {
                            await launchUrl(Uri.parse(
                                "https://foundationdevices.com/2021/10/passphrases-what-why-how"));
                          } catch (e) {
                            //no-op
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                              children: spans,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            child: EnvoyButton(
              S().manual_setup_verify_seed_12_words_passphrase_warning_modal_CTA,
              onTap: () async {
                Navigator.of(context).pop();
                showPassphraseDialog(context);
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 8))
        ],
      ),
    );
  }
}
