// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/animated_qr_image.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/shield_path.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as envoy_colors;
import 'package:envoy/ui/widgets/scanner/decoders/crypto_tx_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

//ignore: must_be_immutable
class PsbtCard extends ConsumerWidget {
  final DraftTransaction transaction;

  PsbtCard(this.transaction) : super(key: UniqueKey());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final account = ref.read(selectedAccountProvider);
    if (account == null) {
      return const SizedBox();
    }
    return Stack(
      children: [
        ClipPath(
          clipper: ShieldClipper(),
          child: SizedBox.expand(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    envoy_colors.EnvoyColors.surface2,
                    envoy_colors.EnvoyColors.surface1
                  ])),
            ),
          ),
        ),
        EnvoyScaffold(
          topBarLeading: Padding(
            padding: const EdgeInsets.all(12),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
              onPressed: () {
                GoRouter.of(context).pop();
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
                          transaction.psbt,
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
                  padding: const EdgeInsets.only(
                      left: 50.0, right: 50.0, bottom: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: base64Encode(transaction.psbt)));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  "PSBT copied to clipboard!"), //TODO: FIGMA
                            ));
                          },
                          icon: const EnvoyIcon(
                            EnvoyIcons.copy,
                            color: EnvoyColors.darkTeal,
                          )),
                      QrShield(
                          child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Consumer(
                                builder: (_, ref, child) {
                                  return IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const EnvoyIcon(
                                      EnvoyIcons.scan,
                                      size: EnvoyIconSize.medium,
                                      color: EnvoyColors.darkTeal,
                                    ),
                                    onPressed: () {
                                      final navigator = Navigator.of(context,
                                          rootNavigator: true);
                                      final gorouter = GoRouter.of(context);
                                      final decoder = CryptoTxDecoder(onScan:
                                          (CryptoPsbt cryptoPsbt) async {
                                        navigator.pop(context);
                                        await Future.delayed(
                                            const Duration(milliseconds: 100));
                                        gorouter.pop(cryptoPsbt);
                                      });
                                      showScannerDialog(
                                          context: context,
                                          onBackPressed: (context) {
                                            Navigator.pop(context);
                                          },
                                          decoder: decoder);
                                      return;
                                    },
                                  );
                                },
                              ))),
                      IconButton(
                          onPressed: () {
                            SharePlus.instance.share(ShareParams(
                              text: base64Encode(transaction.psbt),
                            ));
                          },
                          icon: const EnvoyIcon(
                            EnvoyIcons.externalLink,
                            color: EnvoyColors.darkTeal,
                          )),
                    ],
                  ),
                ),
              ]),
        ),
      ],
    );
  }
}
