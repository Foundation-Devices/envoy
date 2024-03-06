// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/home/settings/backup/export_seed_modal_qr_code.dart';

class ExportSeedModal extends StatefulWidget {
  const ExportSeedModal({super.key});

  @override
  State<ExportSeedModal> createState() => _ExportSeedModalState();
}

class _ExportSeedModalState extends State<ExportSeedModal> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const EnvoyIcon(
                  EnvoyIcons.alert,
                  size: EnvoyIconSize.big,
                  color: EnvoyColors.copper,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
                  child: Text(
                    S().component_warning,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
                  child: Text(
                    S().export_seed_modal_subheading,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.info,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 28),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: EnvoyButton(
                    S().component_continue,
                    type: EnvoyButtonTypes.primaryModal,
                    onTap: () {
                      Navigator.of(context).pop();
                      showEnvoyDialog(
                          context: context,
                          dialog: const ExportSeedModalQrCode());
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
