// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/accounts/tx_review.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:envoy/ui/animated_qr_image.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/business/account.dart';

//ignore: must_be_immutable
class PsbtCard extends StatelessWidget with NavigationCard {
  final Psbt psbt;
  final Account account;

  PsbtCard(this.psbt, this.account, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = S().send_qr_code_heading.toUpperCase();
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
            child: Padding(
                padding: const EdgeInsets.all(15.0),
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
                    icon: Icon(
                      Icons.copy,
                      size: 20,
                      color: EnvoyColors.darkTeal,
                    )),
                IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return ScannerPage.tx((psbt) {
                          account.wallet.decodePsbt(psbt).then((decoded) {
                            navigator!.push(TxReview(
                              decoded,
                              account,
                              navigationCallback: navigator,
                              onFinishNavigationClick: () {
                                navigator?.pop(depth: 4);
                              },
                            ));
                          });
                        });
                      }));
                    },
                    icon: Icon(
                      EnvoyIcons.qr_scan,
                      size: 20,
                      color: EnvoyColors.darkTeal,
                    )),
                IconButton(
                    onPressed: () {
                      Share.share(psbt.base64);
                    },
                    icon: Icon(
                      Icons.share,
                      size: 20,
                      color: EnvoyColors.darkTeal,
                    )),
              ],
            ),
          ),
        ]);
  }
}
