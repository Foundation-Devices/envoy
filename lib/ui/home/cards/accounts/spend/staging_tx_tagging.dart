// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChooseTagForStagingTx extends ConsumerStatefulWidget {
  final String accountId;
  final Function onTagUpdate;

  const ChooseTagForStagingTx(
      {super.key, required this.onTagUpdate, required this.accountId});

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
  bool showTagForm = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          width: (MediaQuery.of(context).size.width * 0.8).clamp(254, 540),
          height: (MediaQuery.of(context).size.height * 0.56).clamp(400, 450),
          padding: EdgeInsets.all(24),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Align(
                alignment: Alignment(1.15, -1.1),
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(padding: EdgeInsets.all(8)),
                  Image.asset(
                    "assets/exclamation_icon.png",
                    height: 68,
                    width: 68,
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  Text(
                    S().change_output_from_multiple_tags_modal_heading,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  Expanded(
                      child: Container(
                    height: 400,
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
            ..take(5);

          List<String> suggestions =
              tags.isEmpty ? tagSuggestions : tags.map((e) => e.name).toList();
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffD9D9D9),
                    borderRadius: BorderRadius.circular(8)),
                child: TextFormField(
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
                constraints: BoxConstraints(maxHeight: 100),
                margin: EdgeInsets.symmetric(vertical: 12),
                child: Scrollbar(
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Wrap(
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runAlignment: WrapAlignment.start,
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 12,
                      children: [
                        ...suggestions.where((element) {
                          //Show only the tags that match the search, search will only be active
                          // if there are existing tags, search wont be active for suggestions
                          if (tags.isNotEmpty &&
                              _tagController.text.isNotEmpty) {
                            return element
                                .toLowerCase()
                                .startsWith(_tagController.text.toLowerCase());
                          }
                          return true;
                        }).map((e) => InkWell(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      child: Text("${e}")),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: EnvoyColors.teal, width: 1),
                                  ),
                                  height: 28),
                              onTap: () {
                                _tagController.text = e;
                                setState(() {});
                              },
                            ))
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(8)),
              EnvoyButton("Continue", // TODO: FIGMA
                  enabled: _tagController.text.isNotEmpty,
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _tagController.text.isNotEmpty
                            ? Colors.white
                            : EnvoyColors.grey,
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
                  await CoinRepository().addCoinTag(tag);
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
          Spacer(),
          Text(
            S().change_output_from_multiple_tags_modal_subehading,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          Column(
            children: [
              EnvoyButton("Edit Transaction", // TODO: FIGMA
                  enabled: true,
                  type: EnvoyButtonTypes.tertiary, onTap: () async {
                Navigator.of(context).pop();
              }),
              Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
              EnvoyButton(S().change_output_from_multiple_tags_modal_cta1,
                  enabled: true,
                  type: EnvoyButtonTypes.primaryModal, onTap: () async {
                setState(() {
                  showTagForm = !showTagForm;
                });
              }),
            ],
          )
        ],
      ),
    );
  }
}
