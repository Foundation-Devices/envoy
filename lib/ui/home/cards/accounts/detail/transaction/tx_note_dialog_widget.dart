// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
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
  TextEditingController _textEditingController = TextEditingController();

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
    return Container(
      width: 280,
      height: 360,
      padding: EdgeInsets.all(EnvoySpacing.medium1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          Text(widget.noteTitle, style: Theme.of(context).textTheme.titleLarge),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.noteSubTitle,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: EnvoySpacing.medium1),
            child: Container(
              decoration: BoxDecoration(
                  color: EnvoyColors.gray200,
                  borderRadius: BorderRadius.circular(15)),
              padding: EdgeInsets.all(4),
              child: TextFormField(
                maxLines: 2,
                maxLength: 34,
                controller: _textEditingController,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(EnvoySpacing.medium1),
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
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(S().add_note_modal_cta2, onTap: () {
            widget.onAdd(_textEditingController.text);
          }, type: EnvoyButtonTypes.tertiary),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(
            S().add_note_modal_cta,
            onTap: () {
              widget.onAdd(_textEditingController.text);
            },
            type: EnvoyButtonTypes.primaryModal,
          )
        ],
      ),
    );
  }
}
