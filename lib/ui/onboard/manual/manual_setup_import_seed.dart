// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/manual/widgets/wordlist.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class ManualSetupImportSeed extends ConsumerStatefulWidget {
  final SeedLength seedLength;

  const ManualSetupImportSeed({super.key, required this.seedLength});

  @override
  ConsumerState<ManualSetupImportSeed> createState() =>
      _ManualSetupImportSeedState();
}

class _ManualSetupImportSeedState extends ConsumerState<ManualSetupImportSeed> {
  bool hasPassphrase = false;
  String passPhrase = "";
  int currentPage = 0;
  bool finishSeedEntries = false;
  final GlobalKey<MnemonicEntryGridState> _mnemonicEntryGridKey =
      GlobalKey<MnemonicEntryGridState>();
  List<String> currentWords = [];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) async {
        handleBackPress(context);
      },
      child: OnboardPageBackground(
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 3),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoNavigationBarBackButton(
                        color: Colors.black,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        S().manual_setup_import_seed_12_words_heading,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [],
                    body: MnemonicEntryGrid(
                        key: _mnemonicEntryGridKey,
                        seedLength: widget.seedLength,
                        onSeedWordAdded: (List<String> words) {
                          currentWords = words;
                          bool isValid = currentWords
                              .map((e) => seedEn.contains(e))
                              .reduce((value, element) => value && element);
                          setState(() {
                            finishSeedEntries = isValid;
                          });
                        }),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium2,
                      vertical: EnvoySpacing.medium1),
                  child: IgnorePointer(
                    ignoring: finishSeedEntries == false,
                    child: Opacity(
                      opacity: finishSeedEntries ? 1 : 0.5,
                      child: OnboardingButton(
                          label: S().component_done,
                          onTap: () {
                            String result = currentWords.join(' ');
                            checkSeed(context, result);
                          }),
                    ),
                  )),
              SizedBox(
                  height: context.isSmallScreen
                      ? EnvoySpacing.medium1
                      : EnvoySpacing.medium3),
              // SFT-1749: disable passphrases for beta
              // Column(
              //   children: [
              //     Padding(padding: EdgeInsets.all(2)),
              //     InkWell(
              //       onTap: () {
              //         setState(() {
              //           hasPassphrase = !hasPassphrase;
              //           if (hasPassphrase == true) {
              //             showPassphraseWarningDialog(context);
              //           } else {
              //             passPhrase = "";
              //           }
              //         });
              //       },
              //       child: Row(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Checkbox(
              //             checkColor: EnvoyColors.white100,
              //             activeColor: EnvoyColors.darkTeal,
              //             value: hasPassphrase,
              //             onChanged: (value) {
              //               setState(() {
              //                 hasPassphrase = value ?? false;
              //               });
              //               if (value == true) {
              //                 showPassphraseWarningDialog(context);
              //               } else {
              //                 passPhrase = "";
              //               }
              //             },
              //           ),
              //           Text(
              //             S().manual_setup_import_seed_12_words_checkbox,
              //             style: Theme.of(context).textTheme.labelLarge,
              //           ),
              //         ],
              //       ),
              //     ),
              //     Padding(
              //         padding: EdgeInsets.symmetric(horizontal: 24),
              //         child: IgnorePointer(
              //           ignoring: finishSeedEntries == false,
              //           child: Opacity(
              //             opacity: finishSeedEntries ? 1 : 0.5,
              //             child: OnboardingButton(
              //                 label: S().component_done,
              //                 onTap: () {
              //                   String result = currentWords.join(' ');
              //                   checkSeed(context, result);
              //                 }),
              //           ),
              //         )),
              //   ],
              // )
            ],
          ),
        ),
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
            dialog: SizedBox(
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
      constraints: const BoxConstraints(minWidth: 300, minHeight: 420),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              hasPassphrase = false;
                            });
                          },
                        ),
                      ),
                    ),
                    const Icon(EnvoyIcons.exclamationWarning,
                        color: EnvoyColors.darkCopper, size: 60),
                    const Padding(padding: EdgeInsets.all(4)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            S().component_warning,
                            style: EnvoyTypography.info,
                          ),
                          LinkText(
                              text: S()
                                  .manual_setup_verify_seed_12_words_passphrase_warning_modal_heading_2,
                              textStyle: EnvoyTypography.info,
                              linkStyle: const TextStyle(
                                  decoration: TextDecoration.underline),
                              onTap: () {
                                launchUrl(Uri.parse(
                                    "https://foundation.xyz/2021/10/passphrases-what-why-how"));
                              }),
                          const Padding(padding: EdgeInsets.all(8)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: EnvoyButton(
                  S().component_continue,
                  type: EnvoyButtonTypes.primaryModal,
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
