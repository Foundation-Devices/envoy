// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/state/transactions_note_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TxNoteDialog extends ConsumerStatefulWidget {
  final String txId;
  final Function(String) onAdd;
  final String noteTitle;
  final String? value;
  final String noteSubTitle;
  final String noteHintText;

  const TxNoteDialog(
      {super.key,
      required this.noteTitle,
      this.value,
      required this.onAdd,
      required this.noteSubTitle,
      required this.noteHintText,
      required this.txId});

  @override
  ConsumerState<TxNoteDialog> createState() => _TxNoteDialogState();
}

class _TxNoteDialogState extends ConsumerState<TxNoteDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// if value is passed as param, use that
      if (widget.value != null) {
        _textEditingController.text = widget.value!;
      } else {
        _textEditingController.text =
            ref.read(txNoteProvider(widget.txId)) ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return EnvoyDialog(
      title: widget.noteTitle,
      dismissible: false,
      content:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          widget.noteSubTitle,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
          //maxLines: 2,
        ),
        Container(
          margin: const EdgeInsets.only(top: EnvoySpacing.medium1),
          decoration: BoxDecoration(
              color: EnvoyColors.gray200,
              borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.all(EnvoySpacing.xs),
          child: TextFormField(
            maxLines: null,
            minLines: null,
            maxLength: 255,
            controller: _textEditingController,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.done,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(EnvoySpacing.medium1),
              hintText: widget.noteHintText,
              labelStyle: EnvoyTypography.body
                  .copyWith(color: EnvoyColors.textTertiary),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
      ]),
      actions: [
        EnvoyButton(S().component_cancel, onTap: () {
          Navigator.of(context).pop();
        }, type: EnvoyButtonTypes.tertiary),
        EnvoyButton(
          S().component_save,
          onTap: () {
            widget.onAdd(_textEditingController.text);
          },
          type: EnvoyButtonTypes.primaryModal,
        )
      ],
    );
  }
}
