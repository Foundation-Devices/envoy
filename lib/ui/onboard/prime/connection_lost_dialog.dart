// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:go_router/go_router.dart';

class ConnectionLostDialog extends StatelessWidget {
  const ConnectionLostDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
      ),
      child: ExpandablePageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const ConnectionLostModal(),
        ],
      ),
    );
  }
}

class ConnectionLostModal extends StatefulWidget {
  const ConnectionLostModal({super.key});

  @override
  State<ConnectionLostModal> createState() => _ConnectionLostModal();
}

class _ConnectionLostModal extends State<ConnectionLostModal> {
  // bool _isReconnecting = false;

  // Future<void> _attemptReconnect() async {
  //   setState(() {
  //     _isReconnecting = true;
  //   });
  //
  //   final bleId = BluetoothManager().bleId;
  //   BleDevice?
  //       device; // TODO: how to get the "connected" from Prime, also if it reconnects how is Prime going to continue to do what he was already doing?
  //
  //   try {
  //     await BluetoothManager().connect(id: bleId);
  //
  //     // If connection was successful, dismiss the dialog
  //     if (device!.connected && mounted) {
  //       Navigator.pop(context);
  //       // TODO: show a toast/snackbar if reconnected
  //     }
  //   } catch (e) {
  //     // If connection fails, reset the reconnecting state
  //     kPrint("Reconnect failed: $e");
  //     if (mounted) {
  //       setState(() {
  //         _isReconnecting = false;
  //       });
  //     }
  //
  //     // TODO: show a toast/snackbar or log error
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.medium2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EnvoyIcon(
            EnvoyIcons.alert,
            size: EnvoyIconSize.big,
            color: EnvoyColors.copperLight500,
          ),
          const SizedBox(height: EnvoySpacing.medium3),
          Text(
            S().firmware_updateModalConnectionLost_header,
            textAlign: TextAlign.center,
            style: EnvoyTypography.heading
                .copyWith(color: EnvoyColors.textPrimary),
          ),
          const SizedBox(height: EnvoySpacing.medium1),
          Text(
            S().onboarding_connectionIntroWarning_content,
            textAlign: TextAlign.center,
            style:
                EnvoyTypography.info.copyWith(color: EnvoyColors.textSecondary),
          ),
          const SizedBox(height: EnvoySpacing.medium3),
          Column(
            children: [
              EnvoyButton(
                S().firmware_updateModalConnectionLost_exit,
                borderRadius: BorderRadius.circular(EnvoySpacing.small),
                type: EnvoyButtonTypes.secondary,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go("/");
                },
              ),
              // TODO: reconnect button
              // const SizedBox(height: EnvoySpacing.medium1),
              // EnvoyButton(
              //   _isReconnecting
              //       ? S().firmware_updateModalConnectionLost_reconnecting
              //       : S().firmware_updateModalConnectionLost_tryToReconnect,
              //   borderRadius: BorderRadius.circular(EnvoySpacing.small),
              //   type: EnvoyButtonTypes.primaryModal,
              //   leading: _isReconnecting
              //       ? const CupertinoActivityIndicator(
              //           color: EnvoyColors.textPrimaryInverse,
              //           radius: 12,
              //         )
              //       : null,
              //   onTap: _isReconnecting ? null : _attemptReconnect,
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
