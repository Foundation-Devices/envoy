// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/coin_selection_overlay.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

class CreateCoinTag extends ConsumerStatefulWidget {
  final String accountId;
  final List<Output> coins;
  final Function(BuildContext context) onTagUpdate;

  const CreateCoinTag({
    super.key,
    required this.onTagUpdate,
    required this.accountId,
    required this.coins,
  });

  @override
  ConsumerState<CreateCoinTag> createState() => _CreateCoinTagState();
}

List<String> tagSuggestions = [
  S().tagSelection_example1,
  S().tagSelection_example2,
  S().tagSelection_example3,
  S().tagSelection_example4,
  S().tagSelection_example5,
];

class _CreateCoinTagState extends ConsumerState<CreateCoinTag> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(), // to fix overflow in tests
      child: Container(
        width: (MediaQuery.of(context).size.width * 0.7).clamp(300, 540),
        padding: const EdgeInsets.all(EnvoySpacing.medium2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Align(
              alignment: const Alignment(1.00, -1.02),
              child: IconButton(
                icon: const Icon(Icons.close),
                padding: const EdgeInsets.all(EnvoySpacing.small),
                onPressed: () {
                  if (ref.read(selectedAccountProvider) != null) {
                    coinSelectionOverlayKey.currentState?.show(
                      SpendOverlayContext.preselectCoins,
                    );
                  }
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: EnvoySpacing.small),
            Image.asset("assets/exclamation_icon.png", height: 68, width: 68),
            const SizedBox(height: EnvoySpacing.medium1),
            Text(
              S().change_output_from_multiple_tags_modal_heading,
              style: EnvoyTypography.heading.copyWith(
                color: EnvoyColors.textPrimary,
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            _tagWidget(context),
          ],
        ),
      ),
    );
  }

  final TextEditingController _tagController = TextEditingController();
  String value = '';

  Consumer _tagWidget(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final tags = ref.watch(tagsProvider(widget.accountId)).toList()
          ..sort((a, b) => b.utxo.length.compareTo(a.utxo.length))
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

        List<Widget> firsRowWidget = firstRowContent.map((e) {
          return tagItem(context, e, () {
            _tagController.text = e;
            setState(() {});
          });
        }).toList();

        List<Widget> secondRowWidget = secondRowContent.map((e) {
          return tagItem(context, e, () {
            _tagController.text = e;
            setState(() {});
          });
        }).toList();

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
              ),
              decoration: BoxDecoration(
                color: EnvoyColors.surface4,
                borderRadius: BorderRadius.circular(EnvoySpacing.small),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.small,
                ),
                //16
                child: TextFormField(
                  style: const TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.fade,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) {
                    setState(() {
                      _tagController.text = value;
                    });
                  },
                  controller: _tagController,
                  textAlign: TextAlign.center,
                  maxLength: 30,
                  buildCounter: (
                    BuildContext context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return currentLength > 20
                        ? Text(
                            "${_tagController.text.length}/30",
                            style: const TextStyle(
                              color: DefaultSelectionStyle.defaultColor,
                            ),
                          )
                        : const SizedBox();
                  },
                  decoration: InputDecoration(
                    hintText: "Enter new tag i.e. Exchange",
                    // TODO: Figma
                    hintStyle: EnvoyTypography.info.copyWith(
                      color: EnvoyColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium1,
                      vertical: EnvoySpacing.xs,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            tags.isNotEmpty
                ? Text(S().create_second_tag_modal_2_2_mostUsed)
                : Text(S().create_first_tag_modal_2_2_suggest),
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: EnvoySpacing.medium1,
                horizontal: EnvoySpacing.xs,
              ),
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
                    ),
                  ),
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
                    ),
                  ),
                ],
              ),
            ),
            EnvoyButton(
              label: S().component_continue,
              type: ButtonType.primary,
              state: _isLoading
                  ? ButtonState.loading
                  : _tagController.text.trim().isEmpty
                      ? ButtonState.disabled
                      : ButtonState.defaultState,
              onTap: () => tagSelected(context, ref),
            ),
          ],
        );
      },
    );
  }

  Future tagSelected(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    try {
      final selectedAccount = ref.read(selectedAccountProvider);
      if (selectedAccount == null) {
        return;
      }

      String tag = _tagController.text;

      if (tag.toLowerCase().trim().isEmpty) {
        return;
      }
      if (tag.toLowerCase().trim() ==
              S().account_details_untagged_card.toLowerCase().trim() ||
          tag.toLowerCase().trim() == "untagged") {
        tag = "";
      }
      setState(() {
        _isLoading = true;
      });
      await selectedAccount.handler?.setTags(utxos: widget.coins, tag: tag);
    } catch (e) {
      kPrint(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

Widget tagItem(BuildContext context, String item, Function() onTap) {
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
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
          alignment: Alignment.center,
          child: Text(
            item.length > 9 ? '${item.substring(0, 7)}...' : item,
            style: EnvoyTypography.info.copyWith(
              color: EnvoyColors.accentPrimary,
            ),
          ),
        ),
      ),
    ),
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
