// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';

class EraseWalletsAndBackupsWarning extends StatefulWidget {
  const EraseWalletsAndBackupsWarning({Key? key}) : super(key: key);

  @override
  State<EraseWalletsAndBackupsWarning> createState() =>
      _EraseWalletsAndBackupsWarningState();
}

class _EraseWalletsAndBackupsWarningState
    extends State<EraseWalletsAndBackupsWarning> {
  PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(8)),
            Column(
              children: [
                Image.asset(
                  "assets/exclamation_triangle.png",
                  height: 80,
                  width: 80,
                ),
                Padding(padding: EdgeInsets.all(4)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                      S().backups_erase_wallets_and_backups_modal_1_2_ios_heading,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: SizedBox(
                      height: 200,
                      child: PageView(
                        controller: _pageController,
                        children: [
                          Text(
                            Platform.isAndroid
                                ? S()
                                    .backups_erase_wallets_and_backups_modal_1_2_android_subheading
                                : S()
                                    .backups_erase_wallets_and_backups_modal_1_2_ios_subheading,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            S().backups_erase_wallets_and_backups_modal_2_2_subheading,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )),
                DotsIndicator(
                  totalPages: 2,
                  pageController: _pageController,
                ),
                Padding(padding: EdgeInsets.all(5)),
              ],
            ),
            OnboardingButton(
                type: EnvoyButtonTypes.tertiary,
                label: S().backups_erase_wallets_and_backups_modal_1_2_ios_cta1,
                onTap: () {
                  Navigator.pop(context);
                }),
            OnboardingButton(
                label: S().backups_erase_wallets_and_backups_modal_1_2_ios_cta,
                onTap: () {
                  int currentPage = _pageController.page?.toInt() ?? 0;
                  if (currentPage == 1) {
                    if (AccountManager().hotWalletAccountsEmpty()) {
                      // Safe to delete
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return SeedIntroScreen(
                          mode: SeedIntroScreenType.verify,
                        );
                      }));
                    }
                    else {

                    }
                  } else {
                    _pageController.nextPage(
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeInOut);
                  }
                }),
            Padding(padding: EdgeInsets.all(12)),
          ],
        ),
      ),
    );
  }
}
