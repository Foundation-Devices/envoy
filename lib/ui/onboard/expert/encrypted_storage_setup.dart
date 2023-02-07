// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';

class StorageSetupPage extends StatefulWidget {
  const StorageSetupPage({Key? key}) : super(key: key);

  @override
  State<StorageSetupPage> createState() => _StorageSetupPageState();
}

class _StorageSetupPageState extends State<StorageSetupPage> {
  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox.shrink(),
                ),
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset("assets/onboarding_lock_icon.png"),
                )),
                Flexible(
                    child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.all(8)),
                      Text(
                        "Store Your Encrypted Backup",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(padding: EdgeInsets.all(12)),
                      Text(
                        "Envoy has generated your encrypted backup. This backup contains useful wallet data such as labels, account info and Envoy settings.\n\nYou can choose to secure it on a cloud, another device, or an external storage option like a microSD card.",
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
                    child: OnboardingButton(
                        light: false,
                        label: "Choose destination",
                        onTap: () {
                          showVerificationFailedDialog(context);
                        }))
              ],
            ),
          ),
        ),
      ],
    ));
  }

  void showVerificationFailedDialog(BuildContext context) {
    showEnvoyDialog(
      context: context,
      dismissible: false,
      builder: Builder(builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.38,
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(padding: EdgeInsets.all(8)),
                Expanded(
                    child: Column(
                  children: [
                    Icon(Icons.info_outline,
                        color: EnvoyColors.darkTeal, size: 68),
                    Padding(padding: EdgeInsets.all(4)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Text(
                        "Your backup is encrypted by your seed words. If you lose access to your seed words, you will be unable to recover your backup file contents.\n\nPlease ensure you have a robust seed word backup solution.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(2)),
                  ],
                )),
                OnboardingButton(
                    label: "I understand",
                    onTap: () async {
                      //TODO - implement backup options
                      Navigator.of(context).pop();
                    }),
                Padding(padding: EdgeInsets.all(12)),
              ],
            ),
          ),
        );
      }),
    );
  }
}
