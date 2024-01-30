// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/create_coin_tag_dialog.dart';

class ChooseTagForStagingTx extends ConsumerStatefulWidget {
  final String accountId;
  final Function onTagUpdate;
  final Function onEditTransaction;
  final hasMultipleTagsInput;

  const ChooseTagForStagingTx(
      {super.key,
      required this.onTagUpdate,
      required this.accountId,
      required this.onEditTransaction,
      this.hasMultipleTagsInput = false});

  @override
  ConsumerState<ChooseTagForStagingTx> createState() =>
      _ChooseTagForChangeState();
}

List<String> tagSuggestions = [
  // TODO: FIGMA
  "Expenses",
  "Business",
  "Fuel",
  "Conferences",
  "Savings",
];

class _ChooseTagForChangeState extends ConsumerState<ChooseTagForStagingTx> {
  late bool showTagForm = widget.hasMultipleTagsInput;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        showTagForm = !widget.hasMultipleTagsInput;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          width: (MediaQuery.of(context).size.width * 0.7).clamp(300, 540),
          height: (MediaQuery.of(context).size.height * 0.55).clamp(270, 520),
          padding: EdgeInsets.all(EnvoySpacing.small),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Align(
                alignment: Alignment(1.0, -1.0),
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(padding: EdgeInsets.all(EnvoySpacing.medium1)),
                  Image.asset(
                    "assets/exclamation_icon.png",
                    height: 68,
                    width: 68,
                  ),
                  Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                  Text(
                    S().change_output_from_multiple_tags_modal_heading,
                    style: EnvoyTypography.body.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(EnvoySpacing.medium1)),
                  Expanded(
                      child: Container(
                    child: PageTransitionSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder:
                          (child, animation, secondaryAnimation) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          fillColor: Colors.transparent,
                          transitionType: SharedAxisTransitionType.vertical,
                          child: child,
                        );
                      },
                      child: !showTagForm
                          ? _tagSubtitle(context)
                          : _tagWidget(context),
                    ),
                  ))
                ],
              ),
            ],
          )),
    );
  }

  TextEditingController _tagController = TextEditingController();
  String value = '';

  _tagWidget(BuildContext context) {
    return Container(
      child: Consumer(
        builder: (context, ref, child) {
          final tags = ref.watch(coinsTagProvider(widget.accountId)).toList()
            ..sort((a, b) => b.coins.length.compareTo(a.coins.length))
            ..removeWhere((element) => element.untagged)
            ..take(6);

          List<String> suggestions =
              tags.isEmpty ? tagSuggestions : tags.map((e) => e.name).toList();

          suggestions = suggestions.toSet().toList();
          List<String> firstRowContent = List.generate(3, (index) => "");
          List<String> secondRowContent = List.generate(3, (index) => "");

          suggestions.forEach((element) {
            int index = suggestions.indexOf(element);
            if (index < 3) {
              firstRowContent[index] = element;
            } else {
              secondRowContent[index - 3] = element;
            }
          });
          firstRowContent =
              firstRowContent.where((element) => element.isNotEmpty).toList();
          secondRowContent =
              secondRowContent.where((element) => element.isNotEmpty).toList();

          List<Widget> firsRowWidget = firstRowContent.map(
            (e) {
              return tagItem(context, e, () {
                _tagController.text = e;
                setState(() {});
              });
            },
          ).toList();

          List<Widget> secondRowWidget = secondRowContent.map(
            (e) {
              return tagItem(context, e, () {
                _tagController.text = e;
                setState(() {});
              });
            },
          ).toList();

          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
                decoration: BoxDecoration(
                    color: Color(0xffD9D9D9),
                    borderRadius: BorderRadius.circular(8)),
                child: TextFormField(
                    maxLength: 30,
                    style: TextStyle(
                        fontSize: 14,
                        overflow: TextOverflow.fade,
                        fontWeight: FontWeight.w500),
                    onChanged: (value) {
                      setState(() {
                        value = value;
                      });
                    },
                    controller: _tagController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      // Disable the borders
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                    )),
              ),
              Padding(padding: EdgeInsets.all(8)),
              tags.length != 0
                  ? Text("Most Used")
                  : Text("Suggestions"), // TODO: FIGMA
              Container(
                margin: EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
                constraints: BoxConstraints(maxHeight: 64),
                child: Column(
                  children: [
                    Flexible(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [...firsRowWidget],
                    )),
                    Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                    Flexible(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [...secondRowWidget],
                    )),
                  ],
                ),
              ),
              EnvoyButton("Continue", // TODO: FIGMA
                  enabled: _tagController.text.isNotEmpty,
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _tagController.text.isNotEmpty
                            ? Colors.white
                            : EnvoyColors.textTertiary,
                      ),
                  type: _tagController.text.isNotEmpty
                      ? EnvoyButtonTypes.primaryModal
                      : EnvoyButtonTypes.tertiary, onTap: () async {
                final existingTag = ref
                    .read(coinsTagProvider(widget.accountId))
                    .firstWhereOrNull((element) =>
                        element.name.toLowerCase() ==
                        _tagController.text.toLowerCase());

                if (existingTag != null) {
                  ref.read(stagingTxChangeOutPutTagProvider.notifier).state =
                      existingTag;
                } else {
                  CoinTag tag = CoinTag(
                    id: CoinTag.generateNewId(),
                    name: _tagController.text,
                    account: widget.accountId,
                    untagged: false,
                  );
                  ref.read(stagingTxChangeOutPutTagProvider.notifier).state =
                      tag;
                }
                widget.onTagUpdate();
              }),
            ],
          );
        },
      ),
    );
  }

  _tagSubtitle(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
            child: Text(
              S().change_output_from_multiple_tags_modal_subehading,
              style: EnvoyTypography.info,
              textAlign: TextAlign.center,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EnvoyButton(S().coincontrol_tx_detail_cta2,
                  enabled: true,
                  type: EnvoyButtonTypes.tertiary, onTap: () async {
                widget.onEditTransaction();
              }),
              Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
              EnvoyButton(S().component_continue,
                  enabled: true,
                  borderRadius: BorderRadius.circular(6),
                  textStyle: EnvoyTypography.button.copyWith(
                      color: EnvoyColors.solidWhite,
                      fontWeight: FontWeight.w500),
                  type: EnvoyButtonTypes.primaryModal, onTap: () async {
                setState(() {
                  showTagForm = !showTagForm;
                });
              }),
              Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            ],
          )
        ],
      ),
    );
  }
}
