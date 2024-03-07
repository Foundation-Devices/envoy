// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/haptics.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCoinTag extends StatefulWidget {
  final String accountId;
  final Function onTagUpdate;

  const CreateCoinTag(
      {super.key, required this.onTagUpdate, required this.accountId});

  @override
  State<CreateCoinTag> createState() => _CreateCoinTagState();
}

List<String> tagSuggestions = [
  S().tagSelection_example1,
  S().tagSelection_example2,
  S().tagSelection_example3,
  S().tagSelection_example4,
  S().tagSelection_example5,
];

class _CreateCoinTagState extends State<CreateCoinTag> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width * 0.7).clamp(300, 540),
      height: 428,
      padding: const EdgeInsets.all(EnvoySpacing.small),
      child: EnvoyScaffold(
          resizeToAvoidBottomInset: false,
          removeAppBarPadding: true,
          extendBody: true,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Align(
                alignment: const Alignment(1.00, -1.02),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  padding: const EdgeInsets.all(12),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                  Image.asset(
                    "assets/exclamation_icon.png",
                    height: 68,
                    width: 68,
                  ),
                  const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                  Text(
                    S().change_output_from_multiple_tags_modal_heading,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                  _tagWidget(context),
                ],
              ),
            ],
          )),
    );
  }

  final TextEditingController _tagController = TextEditingController();
  String value = '';

  _tagWidget(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final tags = ref.watch(coinsTagProvider(widget.accountId)).toList()
          ..sort((a, b) => b.coins.length.compareTo(a.coins.length))
          ..removeWhere((element) => element.untagged)
          ..take(6);

        List<String> suggestions =
            tags.isEmpty ? tagSuggestions : tags.map((e) => e.name).toList();
        suggestions = suggestions.toSet().toList();
        List<String> firstRowContent = [];
        List<String> secondRowContent = [];

        /// allocate the first 3 suggestions to the first row and the rest to the second row
        suggestions.take(6).toList().asMap().forEach((index, element) {
          if (index < 3) {
            firstRowContent.add(element);
          } else {
            secondRowContent.add(element);
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
              margin:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
              decoration: BoxDecoration(
                  color: const Color(0xffD9D9D9),
                  borderRadius: BorderRadius.circular(EnvoySpacing.small)),
              child: Padding(
                  padding: const EdgeInsets.only(top: EnvoySpacing.small),
                  //16
                  child: TextFormField(
                    style: const TextStyle(
                      fontSize: 14,
                      overflow: TextOverflow.fade,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _tagController.text = value;
                      });
                    },
                    controller: _tagController,
                    textAlign: TextAlign.center,
                    maxLength: 30,
                    buildCounter: (BuildContext context,
                        {required int currentLength,
                        required bool isFocused,
                        required int? maxLength}) {
                      return currentLength > 20
                          ? Text("${_tagController.text.length}/30",
                              style: const TextStyle(
                                  color: DefaultSelectionStyle.defaultColor))
                          : const SizedBox();
                    },
                    decoration: InputDecoration(
                      hintText: "Enter new tag i.e. Exchange",
                      // TODO: Figma
                      hintStyle: EnvoyTypography.info
                          .copyWith(color: EnvoyColors.textTertiary),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1,
                          vertical: EnvoySpacing.xs),
                    ),
                  )),
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            tags.isNotEmpty
                ? Text(S().create_second_tag_modal_2_2_mostUsed)
                : Text(S().create_first_tag_modal_2_2_suggest),
            Container(
              margin: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.medium1, horizontal: EnvoySpacing.xs),
              constraints: const BoxConstraints(maxHeight: 64),
              child: Column(
                children: [
                  Flexible(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [...firsRowWidget],
                    ),
                  )),
                  const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                  Flexible(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [...secondRowWidget],
                    ),
                  )),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
              child: EnvoyButton(
                S().component_continue,
                enabled: _tagController.text.isNotEmpty,
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _tagController.text.isNotEmpty
                          ? EnvoyColors.textPrimaryInverse
                          : EnvoyColors.textTertiary,
                    ),
                type: _tagController.text.isNotEmpty
                    ? EnvoyButtonTypes.primaryModal
                    : EnvoyButtonTypes.tertiary,
                onTap: () => tagSelected(context, ref),
              ),
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          ],
        );
      },
    );
  }

  Future tagSelected(BuildContext context, WidgetRef ref) async {
    //get coins from the repository
    try {
      List<Coin> coins = [];
      ref
          .read(coinsTagProvider(widget.accountId))
          .map((e) => e.coins)
          .forEach((element) {
        coins.addAll(element);
      });
      final selections = ref.read(coinSelectionStateProvider);
      //pick all the coins that are selected in current tag
      final selectedCoins =
          coins.where((element) => selections.contains(element.id)).toList();

      //user selected from suggestions
      CoinTag? targetTag = ref
          .read(coinsTagProvider(widget.accountId))
          .firstWhereOrNull((element) =>
              element.name.toLowerCase() == _tagController.text.toLowerCase());

      final tags = ref.read(coinsTagProvider(widget.accountId));

      if (targetTag?.coinsId.containsAll(selections) == true) {
        widget.onTagUpdate();
        return;
      }

      //if the tag is not found, create a new tag
      if (targetTag == null) {
        targetTag = CoinTag(
          id: CoinTag.generateNewId(),
          name: _tagController.text,
          account: widget.accountId,
          untagged: false,
        );
        await CoinRepository().addCoinTag(targetTag);
      }

      targetTag.addCoins(selectedCoins);

      await CoinRepository().updateCoinTag(targetTag);

      Set<CoinTag> coinsRemovedTags = {};

      for (var tag in tags) {
        /// no need to remove coins to the tag that we just added
        if (tag.id != targetTag.id) {
          for (var element in selectedCoins) {
            if (tag.coinsId.contains(element.id)) {
              tag.removeCoin(element);
              coinsRemovedTags.add(tag);
            }
          }
        }
      }

      for (var coin in coinsRemovedTags) {
        if (!coin.untagged) {
          await Future.delayed(const Duration(milliseconds: 10));
          await CoinRepository().updateCoinTag(coin);
        }
      }

      final _ = ref.refresh(accountsProvider);
      //Wait for the refresh to propagate
      await Future.delayed(const Duration(milliseconds: 180));

      //Reset the selection
      Haptics.lightImpact();
    } catch (e) {
      kPrint(e);
    }

    widget.onTagUpdate();
  }
}

Widget tagItem(context, String item, Function() onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: EnvoyColors.accentPrimary, width: 1),
            ),
            height: 34,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
                alignment: Alignment.center,
                child: Text(
                  item.length > 9 ? '${item.substring(0, 7)}...' : item,
                  style: EnvoyTypography.info
                      .copyWith(color: EnvoyColors.accentPrimary),
                )))),
  );
}

// _emptyTag(BuildContext context, CoinTag tag) {
//   showEnvoyDialog(
//     context: context,
//     useRootNavigator: true,
//     borderRadius: 20,
//     dialog: Builder(
//       builder: (context) {
//         return DeleteTagDialog(
//             dialogSubheading: S().empty_tag_modal_subheading(tag.name),
//             primaryButtonText: S().empty_tag_modal_cta1,
//             secondaryButtonText: S().delete_tag_modal_cta2,
//             onPrimaryButtonTap: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             onSecondaryButtonTap: () async {
//               await CoinRepository().deleteTag(tag);
//               Navigator.pop(context);
//               Navigator.pop(context);
//             });
//       },
//     ),
//   );
// }
