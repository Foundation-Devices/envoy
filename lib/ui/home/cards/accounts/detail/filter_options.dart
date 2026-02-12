// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/filter_chip.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as new_color_scheme;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

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
                    bool isCoinSelectionActive = ref.watch(
                      isCoinsSelectedProvider,
                    );
                    bool isInEditMode = ref.watch(spendEditModeProvider) !=
                        SpendOverlayContext.hidden;
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
                      bool txFiltersEnabled = ref.watch(
                        isTransactionFiltersEnabled,
                      );
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
                            barrierColor: Colors.black.applyOpacity(0.2),
                            enableDrag: true,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(EnvoySpacing.medium1),
                                topRight: Radius.circular(EnvoySpacing.medium1),
                              ),
                            ),
                            showDragHandle: true,
                            builder: (context) {
                              if (toggleState == AccountToggleState.tx) {
                                return const TxFilterWidget();
                              } else {
                                return const CoinTagsFilterWidget();
                              }
                            },
                          );
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
                              EnvoySpacing.medium3,
                            ),
                          ),
                          child: SvgPicture.asset(
                            "assets/icons/ic_filter.svg",
                            colorFilter: ColorFilter.mode(
                              enabled
                                  ? new_color_scheme.EnvoyColors.solidWhite
                                  : new_color_scheme.EnvoyColors.textTertiary,
                              BlendMode.srcIn,
                            ),
                            width: 18,
                            height: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TxFilterWidget extends ConsumerStatefulWidget {
  const TxFilterWidget({super.key});

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
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        );
    final filterButtonTextStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            );

    _sortState ??= txSortState;
    _filterState ??= txFilterState;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S().component_filter, style: titleStyle),
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
                child: Text(S().component_reset, style: filterButtonTextStyle),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          Row(
            children: [
              EnvoyFilterChip(
                icon: EnvoyIcons.arrow_up_right,
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
                icon: EnvoyIcons.receive,
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
              ),
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
                child: Text(S().component_reset, style: filterButtonTextStyle),
              ),
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
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        );
    final filterButtonTextStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S().account_details_filter_tags_sortBy, style: titleStyle),
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
                child: Text(S().component_reset, style: filterButtonTextStyle),
              ),
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
  final String? subtitle;

  const CheckBoxFilterItem(
      {super.key,
      required this.checked,
      required this.text,
      required this.onTap,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: EnvoyTypography.body.copyWith(
                      color: new_color_scheme.EnvoyColors.textPrimary),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: EnvoyTypography.info.copyWith(
                        color: new_color_scheme.EnvoyColors.textTertiary),
                  ),
              ],
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
  final String? firstValue;
  final String? secondValue;
  final String? firstLabel;
  final String? secondLabel;
  final EnvoyIcons? firstIcon;
  final EnvoyIcons? secondIcon;
  final Color? backgroundColor;

  const SlidingToggle({
    super.key,
    required this.value,
    required this.onChange,
    this.duration = const Duration(milliseconds: 250),
    this.firstValue,
    this.secondValue,
    this.firstLabel,
    this.secondLabel,
    this.firstIcon,
    this.secondIcon,
    this.backgroundColor,
  });

  @override
  State<SlidingToggle> createState() => _SlidingToggleState();
}

class _SlidingToggleState extends State<SlidingToggle>
    with SingleTickerProviderStateMixin {
  final textTheme = EnvoyTypography.info;

  late String value;
  late String _firstValue;
  late String _secondValue;
  late String _firstOptionText;
  late String _secondOptionText;
  late EnvoyIcons _firstIcon;
  late EnvoyIcons _secondIcon;

  final Duration _duration = const Duration(milliseconds: 150);
  late AnimationController _animationController;
  late Animation<Alignment> _slidingSegmentAnimation;
  late Animation<Color?> _textColorAnimation;
  late Animation<Color?> _activityIconColorAnimation;
  late Animation<Color?> _tagsIconColorAnimation;
  final Color _iconDisabledColor = new_color_scheme.EnvoyColors.textTertiary;
  late String _currentOptionText;
  double _maxOptionWidth = 0.0;

  @override
  void initState() {
    super.initState();
    // Use custom values or fall back to defaults
    _firstValue = widget.firstValue ?? "Tx";
    _secondValue = widget.secondValue ?? "Coins";
    _firstOptionText = widget.firstLabel ?? S().coincontrol_switchActivity;
    _secondOptionText = widget.secondLabel ?? S().coincontrol_switchTags;
    _firstIcon = widget.firstIcon ?? EnvoyIcons.history;
    _secondIcon = widget.secondIcon ?? EnvoyIcons.tag;
    _currentOptionText = _firstOptionText;
    value = widget.value;

    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
    );

    _slidingSegmentAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _activityIconColorAnimation = TweenSequence([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(begin: Colors.white, end: Colors.white10),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(begin: Colors.white10, end: _iconDisabledColor),
      ),
    ]).animate(_animationController);

    _tagsIconColorAnimation = TweenSequence([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(begin: _iconDisabledColor, end: Colors.white10),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(begin: Colors.white10, end: Colors.white),
      ),
    ]).animate(_animationController);

    _textColorAnimation = TweenSequence([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(begin: Colors.white, end: Colors.white10),
      ),
      TweenSequenceItem(
        weight: .5,
        tween: ColorTween(begin: Colors.white10, end: Colors.transparent),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(begin: Colors.white10, end: Colors.white),
      ),
    ]).animate(_animationController);

    _animationController.addListener(() {
      if (!mounted) return;
      setState(() {
        if (_animationController.value < 0.5) {
          _currentOptionText = _firstOptionText;
        } else {
          _currentOptionText = _secondOptionText;
        }
      });
    });

    if (value == _firstValue) {
      if (mounted) _animationController.reverse();
    } else {
      if (mounted) {
        _animationController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 0),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maxOptionWidth = getMaxOptionWidth(context);
  }

  double getMaxOptionWidth(BuildContext context) {
    final textPainter1 = TextPainter(
      text: TextSpan(text: _firstOptionText, style: textTheme),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(
        context,
      ).clamp(minScaleFactor: 1, maxScaleFactor: 1),
    )..layout();

    final textPainter2 = TextPainter(
      text: TextSpan(text: _secondOptionText, style: textTheme),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(
        context,
      ).clamp(minScaleFactor: 1, maxScaleFactor: 1),
    )..layout();

    double textWidth1 = textPainter1.width * 2 + 42; // + for compensation
    double textWidth2 = textPainter2.width * 2 + 42;

    double maxWidth = max(textWidth1, textWidth2);
    if (maxWidth > 180) {
      maxWidth = 180;
    }
    return maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () async {
            value = value == _firstValue ? _secondValue : _firstValue;
            if (_animationController.isAnimating) {
              _animationController.stop();
            }
            if (value == _firstValue) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.onChange(value);
          },
          child: SizedBox(
            height: 34,
            width: _maxOptionWidth,
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    new_color_scheme.EnvoyColors.solidWhite,
                borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
              ),
              child: Stack(
                children: [
                  // Show selection background with 78% of width
                  AlignTransition(
                    alignment: _slidingSegmentAnimation,
                    child: FractionallySizedBox(
                      widthFactor: 0.78,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.small,
                        ),
                        margin: const EdgeInsets.all(EnvoySpacing.xs),
                        decoration: BoxDecoration(
                          color: new_color_scheme.EnvoyColors.accentPrimary,
                          borderRadius: BorderRadius.circular(
                            EnvoySpacing.medium1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  EnvoyIcon(
                                    value == _firstValue
                                        ? _firstIcon
                                        : _secondIcon,
                                    size: EnvoyIconSize.small,
                                    color: value == _firstValue
                                        ? _activityIconColorAnimation.value
                                        : _tagsIconColorAnimation.value,
                                  ),
                                  const SizedBox(width: EnvoySpacing.small),
                                  Flexible(
                                    child: Text(
                                      _currentOptionText,
                                      key: ValueKey(_currentOptionText),
                                      overflow: TextOverflow.ellipsis,
                                      textScaler: MediaQuery.textScalerOf(
                                        context,
                                      ).clamp(
                                        minScaleFactor: 1,
                                        maxScaleFactor: 1,
                                      ),
                                      maxLines: 1,
                                      style: textTheme.copyWith(
                                        color: _textColorAnimation.value,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: EnvoySpacing.small),
                      child: value == _secondValue
                          ? EnvoyIcon(
                              _firstIcon,
                              size: EnvoyIconSize.small,
                              color: _activityIconColorAnimation.value,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  AlignTransition(
                    alignment: Tween(
                      begin: const Alignment(.85, 0.0),
                      end: const Alignment(-.2, 0.0),
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOutCubic,
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        return value == _firstValue
                            ? EnvoyIcon(
                                _secondIcon,
                                size: EnvoyIconSize.small,
                                color: _tagsIconColorAnimation.value,
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant SlidingToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      value = widget.value;
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
      if (value == _firstValue) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }
}
