// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/util/haptics.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCoinTag extends StatefulWidget {
  final String accountId;
  final CoinTag tag;

  const CreateCoinTag({super.key, required this.accountId, required this.tag});

  @override
  State<CreateCoinTag> createState() => _CreateCoinTagState();
}

List<String> tagSuggestions = [
  "Expenses",
  "Business",
  "Fuel",
  "Conferences",
  "Savings",
];

class _CreateCoinTagState extends State<CreateCoinTag> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          width: (MediaQuery.of(context).size.width * 0.8).clamp(254, 540),
          height: (MediaQuery.of(context).size.height * 0.56).clamp(450, 540),
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
                    "Create a tag",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  _tagWidget(context),
                ],
              ),
            ],
          )),
    );
  }

  TextEditingController _tagController = TextEditingController();
  String value = '';

  _tagWidget(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final tags = ref
            .watch(coinsTagProvider(widget.accountId))
            .where((element) => !element.untagged)
            .toList()
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
            tags.length != 0 ? Text("Most Used") : Text("Suggestions"),
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
                        if (tags.isNotEmpty && _tagController.text.isNotEmpty) {
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
            EnvoyButton("Continue",
                enabled: _tagController.text.isNotEmpty,
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _tagController.text.isNotEmpty
                          ? Colors.white
                          : EnvoyColors.grey,
                    ),
                type: _tagController.text.isNotEmpty
                    ? EnvoyButtonTypes.primary
                    : EnvoyButtonTypes.tertiary, onTap: () async {
              final coins = widget.tag.coins;
              final selections = ref.read(coinSelectionStateProvider);
              final selectedCoins = coins
                  .where((element) => selections.contains(element.id))
                  .toList();

              final existingTag = ref
                  .read(coinsTagProvider(widget.accountId))
                  .firstWhereOrNull((element) =>
                      element.name.toLowerCase() ==
                      _tagController.text.toLowerCase());
              if (existingTag != null) {
                existingTag.addCoins(selectedCoins);
                await CoinRepository().updateCoinTag(existingTag);
              } else {
                CoinTag tag = CoinTag(
                  id: CoinTag.generateNewId(),
                  name: _tagController.text,
                  account: widget.accountId,
                  untagged: false,
                )..addCoins(selectedCoins);
                await CoinRepository().addCoinTag(tag);
              }
              final _ = ref.refresh(accountsProvider);
              //Wait for the refresh to propagate
              await Future.delayed(Duration(milliseconds: 180));
              //Reset the selection
              ref.read(coinSelectionStateProvider.notifier).reset();
              Haptics.lightImpact();
              Navigator.pop(context);
              Navigator.pop(context);
            }),
          ],
        );
      },
    );
  }
}
