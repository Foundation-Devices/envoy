// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/components/pop_up.dart';

class SeedPassphraseEntry extends StatefulWidget {
  final Function(String passphrase) onPassphraseEntered;
  final bool recovering;

  const SeedPassphraseEntry(
      {super.key, required this.onPassphraseEntered, this.recovering = false});

  @override
  State<SeedPassphraseEntry> createState() => _SeedPassphraseEntryState();
}

class _SeedPassphraseEntryState extends State<SeedPassphraseEntry> {
  final TextEditingController _textEditingController = TextEditingController();
  final PageController _pageController = PageController();
  bool verify = false;
  String passPhrase = "";
  bool hasError = false;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildInput(
            S().manual_setup_verify_enterYourPassphrase,
            widget.recovering
                ? S().manual_setup_recovery_passphrase_modal_subheading
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
      padding: const EdgeInsets.all(28).add(const EdgeInsets.only(top: -6)),
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
            alignment: Alignment.centerRight.add(const Alignment(.1, 0)),
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 0),
            child: Text(heading,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w500, fontSize: 22)),
          ),
          const Padding(padding: EdgeInsets.all(8)),
          Text(subheading, textAlign: TextAlign.center),
          const Padding(padding: EdgeInsets.all(8)),
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
                  decoration: const InputDecoration(
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
              ? Text("Passphrase did not match", // TODO: FIGMA
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.red))
              : const SizedBox.shrink(),
          const Padding(padding: EdgeInsets.all(12)),
          EnvoyButton(
            S().component_continue,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onTap: () {
              if (!verify && _textEditingController.text.isNotEmpty) {
                verify = true;
                passPhrase = _textEditingController.text;
                _textEditingController.text = "";
                _pageController.animateToPage(1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease);
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
    dialog: EnvoyPopUp(
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
      showCloseButton: true,
      content: S().manual_setup_import_seed_12_words_fail_modal_subheading,
      primaryButtonLabel: S().component_back,
      onPrimaryButtonTap: (context) async {
        Navigator.pop(context);
      },
    ),
  );
}
