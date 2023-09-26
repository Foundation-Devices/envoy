// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/components/filter_chip.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as newColorScheme;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterOptions extends ConsumerStatefulWidget {
  const FilterOptions({Key? key}) : super(key: key);

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
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: SlidingToggle(
                  onChange: (value) {
                    ref.read(accountToggleStateProvider.notifier).state =
                        toggleState == AccountToggleState.Tx
                            ? AccountToggleState.Coins
                            : AccountToggleState.Tx;
                  },
                  value: toggleState == AccountToggleState.Tx ? "Tx" : "Coins",
                ),
              ),
              Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          isDismissible: true,
                          useRootNavigator: true,
                          barrierColor: Colors.black.withOpacity(0.2),
                          enableDrag: true,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(EnvoySpacing.medium1),
                              topRight: Radius.circular(EnvoySpacing.medium1),
                            ),
                          ),
                          showDragHandle: true,
                          builder: (context) {
                            return toggleState == AccountToggleState.Tx
                                ? TxFilterWidget()
                                : CoinTagsFilterWidget();
                          });
                    },
                    child: Consumer(
                      builder: (context, ref, child) {
                        bool txFiltersEnabled =
                            ref.watch(isTransactionFiltersEnabled);
                        bool coinFiltersEnabled =
                            ref.watch(coinTagSortStateProvider) !=
                                CoinTagSortTypes.sortByTagNameAsc;
                        bool enabled = toggleState == AccountToggleState.Tx
                            ? txFiltersEnabled
                            : coinFiltersEnabled;

                        return Container(
                          width: 32,
                          height: 32,
                          padding: EdgeInsets.all(EnvoySpacing.small),
                          decoration: BoxDecoration(
                              color: enabled
                                  ? Theme.of(context).primaryColor
                                  : newColorScheme.EnvoyColors.solidWhite,
                              borderRadius:
                                  BorderRadius.circular(EnvoySpacing.medium3)),
                          child: SvgPicture.asset(
                            "assets/icons/ic_filter.svg",
                            color: enabled
                                ? newColorScheme.EnvoyColors.solidWhite
                                : newColorScheme.EnvoyColors.textTertiary,
                            width: 18,
                            height: 18,
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

///
/// TODO: localise the strings
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

    if (_sortState == null) {
      _sortState = txSortState;
    }
    if (_filterState == null) {
      _filterState = txFilterState;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: EnvoySpacing.medium1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filter",
                style: titleStyle,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterState = Set()..addAll(TransactionFilters.values);
                  });
                },
                child: Text(
                  "Reset filter",
                  style: filterButtonTextStyle,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  splashFactory: NoSplash.splashFactory,
                ),
              )
            ],
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          Row(
            children: [
              EnvoyFilterChip(
                icon: Icons.call_made,
                text: "Sent",
                selected:
                    _filterState?.contains(TransactionFilters.Sent) ?? false,
                onTap: () {
                  final Set<TransactionFilters> newState = Set()
                    ..addAll(_filterState!);
                  if (_filterState!.contains(TransactionFilters.Sent)) {
                    newState.remove(TransactionFilters.Sent);
                  } else {
                    newState.add(TransactionFilters.Sent);
                  }
                  setState(() {
                    _filterState = newState;
                  });
                },
              ),
              Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              EnvoyFilterChip(
                icon: Icons.call_received,
                selected: _filterState?.contains(TransactionFilters.Received) ??
                    false,
                text: "Received",
                onTap: () {
                  final Set<TransactionFilters> newState = Set()
                    ..addAll(_filterState!);
                  if (_filterState!.contains(TransactionFilters.Received)) {
                    newState.remove(TransactionFilters.Received);
                  } else {
                    newState.add(TransactionFilters.Received);
                  }
                  setState(() {
                    _filterState = newState;
                  });
                },
              )
            ],
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sort by", style: titleStyle),
              TextButton(
                onPressed: () {
                  ref.read(txSortStateProvider.notifier).state =
                      TransactionSortTypes.newestFirst;
                },
                child: Text(
                  "Reset sorting",
                  style: filterButtonTextStyle,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  splashFactory: NoSplash.splashFactory,
                ),
              )
            ],
          ),
          CheckBoxFilterItem(
            text: "Newest First",
            checked: _sortState == TransactionSortTypes.newestFirst,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = TransactionSortTypes.newestFirst;
              });
            },
          ),
          CheckBoxFilterItem(
            text: "Oldest First",
            checked: _sortState == TransactionSortTypes.oldestFirst,
            onTap: () {
              setState(() {
                _sortState = TransactionSortTypes.oldestFirst;
              });
            },
          ),
          CheckBoxFilterItem(
            text: "Highest Value",
            checked: _sortState == TransactionSortTypes.amountHighToLow,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = TransactionSortTypes.amountHighToLow;
              });
            },
          ),
          CheckBoxFilterItem(
            text: "Lowest Value",
            checked: _sortState == TransactionSortTypes.amountLowToHigh,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = TransactionSortTypes.amountLowToHigh;
              });
            },
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(
            "Apply filters",
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
          Padding(padding: EdgeInsets.all(EnvoySpacing.medium2)),
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

    if (_sortState == null) {
      _sortState = coinSort;
    }
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
      padding: EdgeInsets.symmetric(
        horizontal: EnvoySpacing.medium1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sort by",
                style: titleStyle,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sortState = CoinTagSortTypes.sortByTagNameAsc;
                  });
                  ref.read(coinTagSortStateProvider.notifier).state =
                      _sortState!;
                },
                child: Text(
                  "Reset filter",
                  style: filterButtonTextStyle,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  splashFactory: NoSplash.splashFactory,
                ),
              )
            ],
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          CheckBoxFilterItem(
            text: "A to Z",
            checked: _sortState == CoinTagSortTypes.sortByTagNameAsc,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = CoinTagSortTypes.sortByTagNameAsc;
              });
            },
          ),
          CheckBoxFilterItem(
            text: "Z to A",
            checked: _sortState == CoinTagSortTypes.sortByTagNameDesc,
            onTap: () {
              setState(() {
                _sortState = CoinTagSortTypes.sortByTagNameDesc;
              });
            },
          ),
          CheckBoxFilterItem(
            text: "Highest Value",
            checked: _sortState == CoinTagSortTypes.amountHighToLow,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = CoinTagSortTypes.amountHighToLow;
              });
            },
          ),
          CheckBoxFilterItem(
            text: "Lowest Value",
            checked: _sortState == CoinTagSortTypes.amountLowToHigh,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = CoinTagSortTypes.amountLowToHigh;
              });
            },
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(
            "Apply filters",
            type: EnvoyButtonTypes.primaryModal,
            onTap: () {
              Haptics.lightImpact();
              Navigator.of(context).pop();
              if (_sortState != null) {
                ref.read(coinTagSortStateProvider.notifier).state = _sortState!;
              }
            },
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.medium2)),
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
        padding: EdgeInsets.symmetric(
          vertical: EnvoySpacing.medium1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Transform.translate(
              offset: Offset(0, 1.6),
              child: checked
                  ? Icon(
                      CupertinoIcons.checkmark_alt_circle_fill,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    )
                  : Icon(
                      CupertinoIcons.circle,
                      color: newColorScheme.EnvoyColors.surface2,
                      size: 24,
                    ),
            ),
            Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            Text(
              text,
              style: EnvoyTypography.body
                  .copyWith(color: newColorScheme.EnvoyColors.textPrimary),
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
      {Key? key,
      required this.value,
      required this.onChange,
      this.duration = const Duration(milliseconds: 250)})
      : super(key: key);

  @override
  State<SlidingToggle> createState() => _SlidingToggleState();
}

class _SlidingToggleState extends State<SlidingToggle>
    with SingleTickerProviderStateMixin {
  String value = "Tx";

  final Duration _duration = Duration(milliseconds: 150);
  late AnimationController _animationController;
  late Animation<Alignment> _slidingSegmentAnimation;
  late Animation<Color?> _textColorAnimation;
  late Animation<Color?> _activityIconColorAnimation;
  late Animation<Color?> _tagsIconColorAnimation;
  final Color _iconDisabledColor = newColorScheme.EnvoyColors.textTertiary;
  String _text = "Activity";

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
          _text = "Activity";
        } else if (_animationController.value > 0.5) {
          _text = "Tags";
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (value == "Tx")
        _animationController.reverse();
      else
        _animationController.animateTo(1.0,
            duration: Duration(milliseconds: 0));
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
            value = value == "Tx" ? "Coins" : "Tx";
            if (_animationController.isAnimating) {
              _animationController.stop();
            }
            if (value == "Tx")
              _animationController.reverse();
            else
              _animationController.forward();
            widget.onChange(value);
          },
          child: Container(
            constraints: BoxConstraints.tight(Size(120, 34)),
            child: Container(
              decoration: BoxDecoration(
                  color: newColorScheme.EnvoyColors.solidWhite,
                  borderRadius: BorderRadius.circular(EnvoySpacing.medium3)),
              child: Stack(
                children: [
                  //Show selection background with 71% of width
                  AlignTransition(
                    alignment: _slidingSegmentAnimation,
                    child: FractionallySizedBox(
                      widthFactor: 0.75,
                      child: Container(
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: newColorScheme.EnvoyColors.accentPrimary,
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
                            begin: Alignment(.85, 0.0),
                            end: Alignment(-.2, 0.0))
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
                              begin: Alignment(-.12, 0.0),
                              end: Alignment(.45, 0))
                          .animate(CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeInOutCubic)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          child: Text(
                            _text,
                            key: ValueKey(_text),
                            //prevent unnecessary overflows, container size is fixed
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.start,
                            style: textTheme,
                          ),
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
