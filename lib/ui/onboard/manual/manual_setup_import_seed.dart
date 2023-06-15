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
  int currentPage = 0;
  bool finishSeedEntries = false;
  GlobalKey<MnemonicEntryGridState> _mnemonicEntryGridKey =
      GlobalKey<MnemonicEntryGridState>();
  List<String> currentWords = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return handleBackPress(context);
      },
      child: OnboardPageBackground(
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
                        onPressed: () async {
                          if (await handleBackPress(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: Text(
                          S().manual_setup_import_seed_12_words_heading,
                          style: Theme.of(context).textTheme.titleLarge,
                        )),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: 8),
                      height: MediaQuery.of(context).size.height * 0.59,
                      child: MnemonicEntryGrid(
                          key: _mnemonicEntryGridKey,
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
                    // SFT-1749: disable passphrases for beta
                    // InkWell(
                    //   onTap: () {
                    //     setState(() {
                    //       hasPassphrase = !hasPassphrase;
                    //       if (hasPassphrase == true) {
                    //         showPassphraseWarningDialog(context);
                    //       } else {
                    //         passPhrase = "";
                    //       }
                    //     });
                    //   },
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Checkbox(
                    //         checkColor: EnvoyColors.white100,
                    //         activeColor: EnvoyColors.darkTeal,
                    //         value: hasPassphrase,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             hasPassphrase = value ?? false;
                    //           });
                    //           if (value == true) {
                    //             showPassphraseWarningDialog(context);
                    //           } else {
                    //             passPhrase = "";
                    //           }
                    //         },
                    //       ),
                    //       Text(
                    //         S().manual_setup_import_seed_12_words_checkbox,
                    //         style: Theme.of(context).textTheme.labelLarge,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: IgnorePointer(
                          ignoring: finishSeedEntries == false,
                          child: Opacity(
                            opacity: finishSeedEntries ? 1 : 0.5,
                            child: OnboardingButton(
                                label:
                                    S().manual_setup_import_seed_12_words_CTA,
                                onTap: () {
                                  EnvoySeed()
                                      .create(currentWords,
                                          passphrase: passPhrase.isEmpty
                                              ? null
                                              : passPhrase)
                                      .then((success) {
                                    if (success) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ManualSetupImportBackup()));
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
      ),
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

  Future<bool> handleBackPress(BuildContext context) async {
    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      FocusManager.instance.primaryFocus?.unfocus();
      return false;
    } else {
      if (_mnemonicEntryGridKey.currentState?.currentPage != 0) {
        _mnemonicEntryGridKey.currentState?.showPage(0);
        return false;
      } else {
        return true;
      }
    }
  }

  Widget _buildPassphraseWarning(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 300, minHeight: 420),
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
              minHeight: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    Icon(EnvoyIcons.exclamation_warning,
                        color: EnvoyColors.darkCopper, size: 60),
                    Padding(padding: EdgeInsets.all(4)),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(S()
                              .manual_setup_verify_seed_12_words_passphrase_warning_modal_heading),
                          LinkText(
                              text: S()
                                  .manual_setup_verify_seed_12_words_passphrase_warning_modal_heading_2,
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              linkStyle: TextStyle(
                                  decoration: TextDecoration.underline),
                              onTap: () {
                                launchUrl(Uri.parse(
                                    "https://foundationdevices.com/2021/10/passphrases-what-why-how"));
                              }),
                          Padding(padding: EdgeInsets.all(8)),
                          Text(
                            S().manual_setup_verify_seed_12_words_passphrase_warning_modal_subheading,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: EnvoyButton(
                  S().manual_setup_verify_seed_12_words_passphrase_warning_modal_CTA,
                  onTap: () async {
                    Navigator.of(context).pop();
                    showPassphraseDialog(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
