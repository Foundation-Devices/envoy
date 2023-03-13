// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';

class SeedPassphraseEntry extends StatefulWidget {
  final Function(String passphrase) onPassphraseEntered;
  final bool recovering;

  SeedPassphraseEntry(
      {Key? key, required this.onPassphraseEntered, this.recovering: false})
      : super(key: key);

  @override
  State<SeedPassphraseEntry> createState() => _SeedPassphraseEntryState();
}

class _SeedPassphraseEntryState extends State<SeedPassphraseEntry> {
  TextEditingController _textEditingController = TextEditingController();
  PageController _pageController = PageController();
  bool verify = false;
  String passPhrase = "";
  bool hasError = false;
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildInput(
            S()
                .manual_setup_verify_seed_12_words_enter_passphrase_modal_heading,
            widget.recovering
                ? S().export_seed_modal_passphrase_2_3_subheading
                : S()
                    .manual_setup_verify_seed_12_words_enter_passphrase_modal_subheading,
            context),
        _buildInput(
            S().manual_setup_verify_seed_12_words_verify_passphrase_modal_heading,
            S().manual_setup_verify_seed_12_words_verify_passphrase_modal_subheading,
            context),
      ],
    );
  }

  Widget _buildInput(String heading, String subheading, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28).add(EdgeInsets.only(top: -6)),
      constraints: BoxConstraints(
        minHeight: 360,
        maxWidth: MediaQuery.of(context).size.width * 0.80,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Align(
            alignment: Alignment.centerRight.add(Alignment(.1, 0)),
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 0),
            child: Text(heading,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w500, fontSize: 22)),
          ),
          Padding(padding: EdgeInsets.all(8)),
          Text(subheading, textAlign: TextAlign.center),
          Padding(padding: EdgeInsets.all(8)),
          Container(
            decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                  focusNode: _focusNode,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _textEditingController,
                  validator: (value) {
                    return null;
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    // Disable the borders
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  )),
            ),
          ),
          hasError
              ? Text("Passphrase did not match",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.red))
              : SizedBox.shrink(),
          Padding(padding: EdgeInsets.all(12)),
          EnvoyButton(
            S().recovery_scenario_ios_CTA,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            onTap: () {
              if (!verify && _textEditingController.text.isNotEmpty) {
                verify = true;
                passPhrase = _textEditingController.text;
                _textEditingController.text = "";
                _pageController.animateToPage(1,
                    duration: Duration(milliseconds: 300), curve: Curves.ease);
              } else {
                setState(() {
                  hasError = passPhrase != _textEditingController.text;
                  if (!hasError) {
                    widget.onPassphraseEntered(passPhrase);
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

void showInvalidSeedDialog({required BuildContext context}) {
  showEnvoyDialog(
    context: context,
    dismissible: true,
    builder: Builder(builder: (context) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close)),
                      alignment: Alignment.topRight),
                ),
                Icon(EnvoyIcons.exclamation_warning,
                    color: EnvoyColors.darkCopper, size: 58),
                Padding(padding: EdgeInsets.all(8)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 38),
                  child: Text(
                    S().manual_setup_import_seed_12_words_fail_modal_subheading,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: OnboardingButton(
                  label: S().manual_setup_import_seed_12_words_fail_modal_CTA,
                  onTap: () async {
                    Navigator.pop(context);
                  }),
            ),
          ],
        ),
      );
    }),
  );
}
