// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_method_channel.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/envoy_seed.dart';

import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'export_seed_modal_words.dart';

class ExportSeedModalQrCode extends StatefulWidget {
  const ExportSeedModalQrCode({super.key});

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

    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.medium1,
                    horizontal: EnvoySpacing.small),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium3),
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

                          return EnvoyQR(
                            data: seed,
                            dimension: 200,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                    child: Text(
                      S().export_seed_modal_QR_code_subheading,
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.info
                          .copyWith(color: EnvoyColors.textPrimary),
                    ),
                  ),
                  if (hasPassphrase)
                    Padding(
                      padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                      child: Text(
                        S().export_seed_modal_QR_code_subheading_passphrase,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.info
                            .copyWith(color: EnvoyColors.textTertiary),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: EnvoySpacing.medium2,
                  vertical: EnvoySpacing.medium1),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.medium1),
                    child: EnvoyButton(
                      S().component_done,
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
      ),
    );
  }
}
