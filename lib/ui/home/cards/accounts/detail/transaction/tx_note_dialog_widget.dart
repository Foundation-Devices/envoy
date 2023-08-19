import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/state/transactions_note_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TxNoteDialog extends ConsumerStatefulWidget {
  final String txId;

  const TxNoteDialog({super.key, required this.txId});

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
      _textEditingController.text = ref.read(txNoteProvider(widget.txId)) ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 334,
      padding: EdgeInsets.all(EnvoySpacing.medium1),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Text(S().add_note_modal_heading,
              style: Theme.of(context).textTheme.titleLarge),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Text(
            S().add_note_modal_subheading,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Container(
            margin: EdgeInsets.only(top: EnvoySpacing.medium1),
            child: Container(
              decoration: BoxDecoration(
                  color: EnvoyColors.surface2,
                  borderRadius: BorderRadius.circular(15)),
              padding: EdgeInsets.all(4),
              child: TextFormField(
                maxLines: 2,
                maxLength: 34,
                controller: _textEditingController,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(EnvoySpacing.medium1),
                  hintText: S().add_note_modal_ie_text_field,
                  labelStyle: EnvoyTypography.body1Medium
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
          EnvoyButton(
            S().add_note_modal_cta,
            onTap: () {
              EnvoyStorage()
                  .addTxNote(_textEditingController.text, widget.txId);
              Navigator.pop(context);
            },
            type: EnvoyButtonTypes.primaryModal,
          )
        ],
      ),
    );
  }
}
