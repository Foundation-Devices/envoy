// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/widgets/scanner/decoders/pair_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';

class SingleImportPpScanPage extends OnboardingPage {
  const SingleImportPpScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: OnboardingPage(
        key: const Key("single_import_pp_scan"),
        clipArt: Image.asset("assets/pair_new_device_scan.png"),
        rightFunction: null,
        text: [
          OnboardingText(
            header: S().pair_new_device_scan_heading,
            text: S().pair_new_device_scan_subheading,
          ),
        ],
        buttons: [
          OnboardingButton(
              label: S().component_continue,
              onTap: () {
                showScannerDialog(
                    infoType: QrIntentInfoType.core,
                    context: context,
                    onBackPressed: (context) {
                      Navigator.pop(context);
                    },
                    decoder: PairPayloadDecoder(
                      onScan: (binary) async {
                        Navigator.pop(context);
                        final scaffold = ScaffoldMessenger.of(context);
                        final goRouter = GoRouter.of(context);
                        (DeviceAccountResult, EnvoyAccount?) paringResult;
                        try {
                          paringResult = await NgAccountManager()
                              .addPassportAccount(binary);
                          EnvoyAccount? account;
                          switch (paringResult.$1) {
                            case DeviceAccountResult.ADDED:
                              account = paringResult.$2;
                              break;
                            case DeviceAccountResult
                                  .UPDATED_WITH_NEW_DESCRIPTOR:
                              account = paringResult.$2;
                              break;
                            case DeviceAccountResult.ERROR:
                              break;
                          }
                          if (account == null) {
                            goRouter.go("/");
                          } else {
                            //TODO: let the user know if the account
                            //was updated or added ?
                            goRouter.goNamed(ONBOARD_PASSPORT_SCV_SUCCESS,
                                extra: account);
                          }
                        } on AccountAlreadyPaired catch (_) {
                          scaffold.showSnackBar(const SnackBar(
                            content: Text(
                                "Account already connected"), // TODO: FIGMA
                          ));
                          await Future.delayed(const Duration(seconds: 1));
                          goRouter.go("/");
                          return;
                        }
                      },
                    ));
              }),
        ],
      ),
    );
  }
}
