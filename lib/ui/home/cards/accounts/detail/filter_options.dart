// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/filter_chip.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as new_color_scheme;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterOptions extends ConsumerStatefulWidget {
  const FilterOptions({super.key});

  @override
  ConsumerState<FilterOptions> createState() => _FilterOptionsState();
}

class _FilterOptionsState extends ConsumerState<FilterOptions> {
  bool showFilterOptions = false;

  @override
  Widget build(BuildContext context) {
    AccountToggleState toggleState = ref.watch(accountToggleStateProvider);

    //margin on right is diff 8 compare to left, filter icon uses icon button that has touch target padding
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SlidingToggle(
                onChange: (value) async {
                  if (value == "Tx") {
                    if (ref.read(coinSelectionStateProvider).isNotEmpty) {
                      ref.read(coinSelectionStateProvider.notifier).reset();
                      //wait for coin selection bottom-sheet to close
                      await Future.delayed(const Duration(milliseconds: 240));
                    }
                  }
                  ref.read(accountToggleStateProvider.notifier).state =
                      toggleState == AccountToggleState.tx
                          ? AccountToggleState.coins
                          : AccountToggleState.tx;
                },
                value: toggleState == AccountToggleState.tx
                    ? "Tx"
                    : "Coins", // TODO: FIGMA
              ),
              Flexible(
                  flex: 1,
                  child: Consumer(
                    builder: (context, ref, child) {
                      bool isCoinSelectionActive =
                          ref.watch(isCoinsSelectedProvider);
                      bool isInEditMode = ref.watch(spendEditModeProvider);
                      bool hide = isCoinSelectionActive || isInEditMode;
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: hide ? 0 : 1,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 200),
                          offset: hide ? const Offset(0, 1.2) : Offset.zero,
                          child: child,
                        ),
                      );
                    },
                    child: Consumer(
                      builder: (context, ref, child) {
                        bool txFiltersEnabled =
                            ref.watch(isTransactionFiltersEnabled);
                        bool coinFiltersEnabled =
                            ref.watch(coinTagSortStateProvider) !=
                                CoinTagSortTypes.sortByTagNameAsc;
                        bool enabled = toggleState == AccountToggleState.tx
                            ? txFiltersEnabled
                            : coinFiltersEnabled;
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isDismissible: true,
                                useRootNavigator: true,
                                barrierColor: Colors.black.withOpacity(0.2),
                                enableDrag: true,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                        Radius.circular(EnvoySpacing.medium1),
                                    topRight:
                                        Radius.circular(EnvoySpacing.medium1),
                                  ),
                                ),
                                showDragHandle: true,
                                builder: (context) {
                                  return toggleState == AccountToggleState.tx
                                      ? TxFilterWidget()
                                      : const CoinTagsFilterWidget();
                                });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            padding: const EdgeInsets.all(EnvoySpacing.small),
                            decoration: BoxDecoration(
                                color: enabled
                                    ? Theme.of(context).primaryColor
                                    : new_color_scheme.EnvoyColors.solidWhite,
                                borderRadius: BorderRadius.circular(
                                    EnvoySpacing.medium3)),
                            child: SvgPicture.asset(
                              "assets/icons/ic_filter.svg",
                              color: enabled
                                  ? new_color_scheme.EnvoyColors.solidWhite
                                  : new_color_scheme.EnvoyColors.textTertiary,
                              width: 18,
                              height: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}

class TxFilterWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<TxFilterWidget> createState() => _TxFilterWidgetState();
}

class _TxFilterWidgetState extends ConsumerState<TxFilterWidget> {
  TransactionSortTypes? _sortState;
  Set<TransactionFilters>? _filterState;

  @override
  Widget build(BuildContext context) {
    final txFilterState = ref.watch(txFilterStateProvider);
    final txSortState = ref.watch(txSortStateProvider);
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16);
    final filterButtonTextStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14);

    _sortState ??= txSortState;
    _filterState ??= txFilterState;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EnvoySpacing.medium1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S().component_filter,
                style: titleStyle,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterState = {}..addAll(TransactionFilters.values);
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  S().component_reset,
                  style: filterButtonTextStyle,
                ),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          Row(
            children: [
              EnvoyFilterChip(
                icon: Icons.call_made,
                text: S().activity_sent,
                selected:
                    _filterState?.contains(TransactionFilters.sent) ?? false,
                onTap: () {
                  final Set<TransactionFilters> newState = {}
                    ..addAll(_filterState!);
                  if (_filterState!.contains(TransactionFilters.sent)) {
                    newState.remove(TransactionFilters.sent);
                  } else {
                    newState.add(TransactionFilters.sent);
                  }
                  setState(() {
                    _filterState = newState;
                  });
                },
              ),
              const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              EnvoyFilterChip(
                icon: Icons.call_received,
                selected: _filterState?.contains(TransactionFilters.received) ??
                    false,
                text: S().activity_received,
                onTap: () {
                  final Set<TransactionFilters> newState = {}
                    ..addAll(_filterState!);
                  if (_filterState!.contains(TransactionFilters.received)) {
                    newState.remove(TransactionFilters.received);
                  } else {
                    newState.add(TransactionFilters.received);
                  }
                  setState(() {
                    _filterState = newState;
                  });
                },
              )
            ],
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S().account_details_filter_tags_sortBy, style: titleStyle),
              TextButton(
                onPressed: () {
                  ref.read(txSortStateProvider.notifier).state =
                      TransactionSortTypes.newestFirst;
                  setState(() {
                    _sortState = TransactionSortTypes.newestFirst;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  S().component_reset,
                  style: filterButtonTextStyle,
                ),
              )
            ],
          ),
          CheckBoxFilterItem(
            text: S().filter_sortBy_newest,
            checked: _sortState == TransactionSortTypes.newestFirst,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = TransactionSortTypes.newestFirst;
              });
            },
          ),
          CheckBoxFilterItem(
            text: S().filter_sortBy_oldest,
            checked: _sortState == TransactionSortTypes.oldestFirst,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = TransactionSortTypes.oldestFirst;
              });
            },
          ),
          CheckBoxFilterItem(
            text: S().filter_sortBy_highest,
            checked: _sortState == TransactionSortTypes.amountHighToLow,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = TransactionSortTypes.amountHighToLow;
              });
            },
          ),
          CheckBoxFilterItem(
            text: S().filter_sortBy_lowest,
            checked: _sortState == TransactionSortTypes.amountLowToHigh,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = TransactionSortTypes.amountLowToHigh;
              });
            },
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(
            S().component_Apply,
            type: EnvoyButtonTypes.primaryModal,
            onTap: () {
              Haptics.lightImpact();
              Navigator.of(context).pop();
              if (_sortState != null) {
                ref.read(txSortStateProvider.notifier).state = _sortState!;
              }
              if (_filterState != null) {
                ref.read(txFilterStateProvider.notifier).state = _filterState!;
              }
            },
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.medium2)),
        ],
      ),
    );
  }
}

class CoinTagsFilterWidget extends ConsumerStatefulWidget {
  const CoinTagsFilterWidget({super.key});

  @override
  ConsumerState<CoinTagsFilterWidget> createState() =>
      _CoinTagsFilterWidgetState();
}

class _CoinTagsFilterWidgetState extends ConsumerState<CoinTagsFilterWidget> {
  CoinTagSortTypes? _sortState;

  @override
  Widget build(BuildContext context) {
    final coinSort = ref.watch(coinTagSortStateProvider);

    _sortState ??= coinSort;
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16);
    final filterButtonTextStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EnvoySpacing.medium1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S().account_details_filter_tags_sortBy,
                style: titleStyle,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sortState = CoinTagSortTypes.sortByTagNameAsc;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  S().component_reset,
                  style: filterButtonTextStyle,
                ),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          CheckBoxFilterItem(
            text: S().filter_sortBy_aToZ,
            checked: _sortState == CoinTagSortTypes.sortByTagNameAsc,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = CoinTagSortTypes.sortByTagNameAsc;
              });
            },
          ),
          CheckBoxFilterItem(
            text: S().filter_sortBy_zToA,
            checked: _sortState == CoinTagSortTypes.sortByTagNameDesc,
            onTap: () {
              setState(() {
                _sortState = CoinTagSortTypes.sortByTagNameDesc;
              });
            },
          ),
          CheckBoxFilterItem(
            text: S().filter_sortBy_highest,
            checked: _sortState == CoinTagSortTypes.amountHighToLow,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = CoinTagSortTypes.amountHighToLow;
              });
            },
          ),
          CheckBoxFilterItem(
            text: S().filter_sortBy_lowest,
            checked: _sortState == CoinTagSortTypes.amountLowToHigh,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = CoinTagSortTypes.amountLowToHigh;
              });
            },
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(
            S().component_Apply,
            type: EnvoyButtonTypes.primaryModal,
            onTap: () {
              Haptics.lightImpact();
              Navigator.of(context).pop();
              if (_sortState != null) {
                ref.read(coinTagSortStateProvider.notifier).state = _sortState!;
              }
            },
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.medium2)),
        ],
      ),
    );
  }
}

class CheckBoxFilterItem extends StatelessWidget {
  final bool checked;

  final String text;
  final GestureTapCallback onTap;

  CheckBoxFilterItem(
      {required this.checked, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.medium1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Transform.translate(
              offset: const Offset(0, 1.6),
              child: checked
                  ? Icon(
                      CupertinoIcons.checkmark_alt_circle_fill,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    )
                  : const Icon(
                      CupertinoIcons.circle,
                      color: new_color_scheme.EnvoyColors.surface2,
                      size: 24,
                    ),
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            Text(
              text,
              style: EnvoyTypography.body
                  .copyWith(color: new_color_scheme.EnvoyColors.textPrimary),
            )
          ],
        ),
      ),
    );
  }
}

class SlidingToggle extends StatefulWidget {
  final String value;
  final Duration duration;
  final Function(String value) onChange;

  const SlidingToggle(
      {super.key,
      required this.value,
      required this.onChange,
      this.duration = const Duration(milliseconds: 250)});

  @override
  State<SlidingToggle> createState() => _SlidingToggleState();
}

class _SlidingToggleState extends State<SlidingToggle>
    with SingleTickerProviderStateMixin {
  String value = "Tx"; // TODO: FIGMA

  final Duration _duration = const Duration(milliseconds: 150);
  late AnimationController _animationController;
  late Animation<Alignment> _slidingSegmentAnimation;
  late Animation<Color?> _textColorAnimation;
  late Animation<Color?> _activityIconColorAnimation;
  late Animation<Color?> _tagsIconColorAnimation;
  final Color _iconDisabledColor = new_color_scheme.EnvoyColors.textTertiary;
  String _text = "Activity"; // TODO: FIGMA

  @override
  void initState() {
    super.initState();
    value = widget.value;
    _animationController =
        AnimationController(vsync: this, duration: _duration);
    _slidingSegmentAnimation =
        AlignmentTween(begin: Alignment.centerLeft, end: Alignment.centerRight)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeInOutCubic));

    _activityIconColorAnimation = TweenSequence([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white,
          end: Colors.white10,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white10,
          end: _iconDisabledColor,
        ),
      ),
    ]).animate(_animationController);

    _tagsIconColorAnimation = TweenSequence([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: _iconDisabledColor,
          end: Colors.white10,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white10,
          end: Colors.white,
        ),
      ),
    ]).animate(_animationController);

    _textColorAnimation = TweenSequence([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white,
          end: Colors.white10,
        ),
      ),
      TweenSequenceItem(
        weight: .5,
        tween: ColorTween(
          begin: Colors.white10,
          end: Colors.transparent,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white10,
          end: Colors.white,
        ),
      ),
    ]).animate(_animationController);

    _animationController.addListener(() {
      setState(() {
        if (_animationController.value < 0.5) {
          _text = "Activity"; // TODO: FIGMA
        } else if (_animationController.value > 0.5) {
          _text = "Tags"; // TODO: FIGMA
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (value == "Tx") {
        // TODO: FIGMA
        _animationController.reverse();
      } else {
        _animationController.animateTo(1.0,
            duration: const Duration(milliseconds: 0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600, color: _textColorAnimation.value);
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () async {
            value = value == "Tx" ? "Coins" : "Tx"; // TODO: FIGMA
            if (_animationController.isAnimating) {
              _animationController.stop();
            }
            if (value == "Tx") {
              // TODO: FIGMA
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.onChange(value);
          },
          child: Container(
            constraints: BoxConstraints.tight(const Size(120, 34)),
            child: Container(
              decoration: BoxDecoration(
                  color: new_color_scheme.EnvoyColors.solidWhite,
                  borderRadius: BorderRadius.circular(EnvoySpacing.medium3)),
              child: Stack(
                children: [
                  //Show selection background with 71% of width
                  AlignTransition(
                    alignment: _slidingSegmentAnimation,
                    child: FractionallySizedBox(
                      widthFactor: 0.75,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: new_color_scheme.EnvoyColors.accentPrimary,
                            borderRadius:
                                BorderRadius.circular(EnvoySpacing.medium3)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.history,
                          size: 18, color: _activityIconColorAnimation.value),
                    ),
                  ),
                  AlignTransition(
                    alignment: Tween(
                            begin: const Alignment(.85, 0.0),
                            end: const Alignment(-.2, 0.0))
                        .animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeInOutCubic)),
                    child: Builder(builder: (context) {
                      return SvgPicture.asset("assets/icons/ic_tag.svg",
                          width: 18,
                          height: 18,
                          color: _tagsIconColorAnimation.value);
                    }),
                  ),
                  AlignTransition(
                      alignment: Tween(
                              begin: const Alignment(-.12, 0.0),
                              end: const Alignment(.45, 0))
                          .animate(CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeInOutCubic)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          _text,
                          key: ValueKey(_text),
                          //prevent unnecessary overflows, container size is fixed
                          textScaler: const TextScaler.linear(1),
                          textAlign: TextAlign.start,
                          style: textTheme,
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
