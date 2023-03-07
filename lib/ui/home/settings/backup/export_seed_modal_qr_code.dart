// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'export_seed_modal_words.dart';

class ExportSeedModalQrCode extends StatefulWidget {
  const ExportSeedModalQrCode({Key? key}) : super(key: key);

  @override
  State<ExportSeedModalQrCode> createState() => _ExportSeedModalQrCodeState();
}

class _ExportSeedModalQrCodeState extends State<ExportSeedModalQrCode> {
  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyText2?.copyWith(
          fontWeight: FontWeight.w500,
        );

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
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
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<String?>(
                    future: EnvoySeed().get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return QrImage(
                            data: snapshot.data == null
                                ? "NULL"
                                : snapshot.data!);
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    S().export_seed_modal_QR_code_subheading,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 28),
            child: Column(
              children: [
                EnvoyButton(
                  S().export_seed_modal_QR_code_CTA2,
                  light: true,
                  onTap: () {
                    EnvoySeed().get().then((value) => showEnvoyDialog(
                        context: context,
                        dialog: ExportSeedModalWords(
                          seed: value!.split(" "),
                        )));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: EnvoyButton(
                    S().export_seed_modal_QR_code_CTA1,
                    light: false,
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
