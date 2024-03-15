// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:envoy/business/account.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/animated_qr_image.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/shield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/wallet.dart';

//ignore: must_be_immutable
class PsbtCard extends StatelessWidget {
  final Psbt psbt;
  final Account account;
  final Function(Psbt)? onSignedPsbtScanned;

  PsbtCard(this.psbt, this.account, {this.onSignedPsbtScanned})
      : super(key: UniqueKey()) {}

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return EnvoyScaffold(
      topBarLeading: Padding(
        padding: const EdgeInsets.all(12),
        child: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
      removeAppBarPadding: true,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: QrTab(
                    title: S().send_qr_code_card_heading,
                    subtitle: S().send_qr_code_card_subheading,
                    account: account,
                    qr: AnimatedQrImage(
                      base64Decode(psbt.base64),
                      urType: "crypto-psbt",
                      binaryCborTag: true,
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
                          content:
                              Text("PSBT copied to clipboard!"), //TODO: FIGMA
                        ));
                      },
                      icon: EnvoyIcon(
                        icon: "ic_copy.svg",
                        size: 21,
                        color: EnvoyColors.darkTeal,
                      )),
                  QrShield(
                      child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Consumer(
                            builder: (_, ref, child) {
                              return IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  EnvoyIcons.qr_scan,
                                  size: 30,
                                  color: EnvoyColors.darkTeal,
                                ),
                                onPressed: () {
                                  final navigator = Navigator.of(context);
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                          MaterialPageRoute(builder: (context) {
                                    return ScannerPage.tx((psbt) async {
                                      Psbt psbtParsed =
                                          await account.wallet.decodePsbt(psbt);
                                      if (onSignedPsbtScanned != null) {
                                        onSignedPsbtScanned?.call(psbtParsed);
                                      } else {
                                        navigator.pop(psbtParsed);
                                      }
                                    });
                                  }));
                                },
                              );
                            },
                          ))),
                  IconButton(
                      onPressed: () {
                        Share.share(psbt.base64);
                      },
                      icon: EnvoyIcon(
                        icon: "ic_envoy_share.svg",
                        size: 21,
                        color: EnvoyColors.darkTeal,
                      )),
                ],
              ),
            ),
          ]),
    );
  }
}
