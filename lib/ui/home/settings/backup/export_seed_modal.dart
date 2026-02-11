// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/home/settings/backup/export_seed_modal_qr_code.dart';
import 'package:envoy/ui/components/pop_up.dart';

class ExportSeedModal extends StatefulWidget {
  const ExportSeedModal({super.key});

  @override
  State<ExportSeedModal> createState() => _ExportSeedModalState();
}

class _ExportSeedModalState extends State<ExportSeedModal> {
  @override
  Widget build(BuildContext context) {
    return EnvoyPopUp(
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
      title: S().component_warning.toUpperCase(),
      showCloseButton: true,
      content: S().export_seed_modal_subheading,
      primaryButtonLabel: S().component_continue,
      onPrimaryButtonTap: (context) {
        Navigator.of(context).pop();
        showEnvoyDialog(
          context: context,
          dialog: const ExportSeedModalQrCode(),
        );
      },
    );
  }
}
