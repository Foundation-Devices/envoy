// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/text_field.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/scanner/decoders/generic_qr_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockExplorerEntry extends ConsumerStatefulWidget {
  final String Function() getter;
  final Function(String) setter;

  const BlockExplorerEntry(this.getter, this.setter, {super.key});

  @override
  ConsumerState<BlockExplorerEntry> createState() => _BlockExplorerEntryState();
}

class _BlockExplorerEntryState extends ConsumerState<BlockExplorerEntry> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.getter();
  }

  void onChange(String address) {
    widget.setter(address);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
          ),
          child: EnvoyTextField(
            controller: _controller,
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              onChange(_controller.text);
            },
            defaultText: S().privacy_explorer_explorerAddress,
            informationalText: S().privacy_explorer_configure,
            additionalButtons: true,
            onChanged: (address) {
              onChange(address);
            },
            isError: false,
            onQrScan: () {
              showScannerDialog(
                context: context,
                onBackPressed: (context) {
                  Navigator.pop(context);
                },
                decoder: GenericQrDecoder(
                  onScan: (result) {
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    _controller.text = result;
                    onChange(result);
                    return result;
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
