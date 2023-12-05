// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_method_channel.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/envoy_seed.dart';

import 'export_seed_modal_words.dart';

class ExportSeedModalQrCode extends StatefulWidget {
  const ExportSeedModalQrCode({Key? key}) : super(key: key);

  @override
  State<ExportSeedModalQrCode> createState() => _ExportSeedModalQrCodeState();
}

class _ExportSeedModalQrCodeState extends State<ExportSeedModalQrCode> {
  @override
  void initState() {
    super.initState();
    enableSecureScreen();
  }

  @override
  void dispose() {
    disableSecureScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPassphrase = EnvoySeed().getWallet()!.hasPassphrase;

    var textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );

    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 68),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<String?>(
                    future: EnvoySeed().get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        String seed = snapshot.data!;

                        // Add a note to query the user for passphrase on other device
                        if (hasPassphrase) {
                          seed = seed + (" passphrase"); // TODO: FIGMA
                        }

                        return EnvoyQR(data: seed);
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    S().export_seed_modal_QR_code_subheading,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
                if (hasPassphrase)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      S().export_seed_modal_QR_code_subheading_passphrase,
                      textAlign: TextAlign.center,
                      style: textStyle?.copyWith(color: EnvoyColors.grey),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            child: Column(
              children: [
                EnvoyButton(
                  S().export_seed_modal_QR_code_CTA2,
                  type: EnvoyButtonTypes.secondary,
                  onTap: () {
                    EnvoySeed().get().then((value) async {
                      enableSecureScreen();
                      List<String> seed = value!.split(" ");

                      await showEnvoyDialog(
                          context: context,
                          dialog: ExportSeedModalWords(
                            seed: seed,
                            hasPassphrase: hasPassphrase,
                          ));
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: EnvoyButton(
                    S().export_seed_modal_QR_code_CTA1,
                    type: EnvoyButtonTypes.primaryModal,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
