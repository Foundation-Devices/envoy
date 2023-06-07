// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:envoy/business/account.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/animated_qr_image.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/accounts/send_card.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/shield.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/wallet.dart';

//ignore: must_be_immutable
class PsbtCard extends StatelessWidget with NavigationCard {
  final Psbt psbt;
  final Account account;

  PsbtCard(this.psbt, this.account, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = S().envoy_home_accounts.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
                margin: EdgeInsets.all(10),
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 250,
                    minWidth: 200,
                    maxHeight: 400,
                    maxWidth: 350,
                  ),
                  child: QrTab(
                    title: S().envoy_psbt_scan_qr,
                    subtitle: S().envoy_psbt_explainer,
                    account: account,
                    qr: AnimatedQrImage(
                      base64Decode(psbt.base64),
                      urType: "crypto-psbt",
                      binaryCborTag: true,
                    ),
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              S().send_qr_code_subheading,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 50.0, right: 50.0, bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: psbt.base64));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(S().envoy_psbt_copied_clipboard),
                      ));
                    },
                    icon: EnvoyIcon(
                      icon: "ic_copy.svg",
                      size: 21,
                      color: EnvoyColors.teal,
                    )),
                QrShield(
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            EnvoyIcons.qr_scan,
                            size: 30,
                            color: EnvoyColors.darkTeal,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return ScannerPage(
                                  [ScannerType.address, ScannerType.azteco],
                                  account: account,
                                  onAddressValidated: (address, amount) {
                                navigator!.push(SendCard(account,
                                    address: address,
                                    amountSats: amount,
                                    navigationCallback: navigator));
                                FocusScope.of(context).unfocus();
                              });
                            }));
                          },
                        ))),
                IconButton(
                    onPressed: () {
                      Share.share(psbt.base64);
                    },
                    icon: EnvoyIcon(
                      icon: "ic_envoy_share.svg",
                      size: 21,
                      color: EnvoyColors.teal,
                    )),
              ],
            ),
          ),
        ]);
  }
}
