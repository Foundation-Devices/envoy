// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/learn/filter_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/components/filter_chip.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';

class LearnFilterWidget extends ConsumerStatefulWidget {
  @override
  _LearnFilterWidgetState createState() => _LearnFilterWidgetState();
}

class _LearnFilterWidgetState extends ConsumerState<LearnFilterWidget> {
  LearnSortTypes? _sortState;
  Set<LearnFilters>? _filterState;

  @override
  Widget build(BuildContext context) {
    final learnFilterState = ref.watch(learnFilterStateProvider);
    final learnSortState = ref.watch(learnSortStateProvider);
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
      _sortState = learnSortState;
    }
    if (_filterState == null) {
      _filterState = learnFilterState;
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
                    _filterState = Set()..addAll(LearnFilters.values);
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
                text: "All",
                selected: _filterState?.contains(LearnFilters.All) ?? false,
                onTap: () {
                  final Set<LearnFilters> newState = Set()
                    ..addAll(_filterState!);
                  if (_filterState!.contains(LearnFilters.All)) {
                    newState.remove(LearnFilters.All);
                    newState.remove(LearnFilters.Videos);
                    newState.remove(LearnFilters.Blogs);
                    newState.remove(LearnFilters.FAQs);
                  } else {
                    newState.add(LearnFilters.All);
                    newState.add(LearnFilters.Videos);
                    newState.add(LearnFilters.Blogs);
                    newState.add(LearnFilters.FAQs);
                  }
                  setState(() {
                    _filterState = newState;
                  });
                },
              ),
              Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              EnvoyFilterChip(
                selected: _filterState?.contains(LearnFilters.Videos) ?? false,
                text: "Videos",
                onTap: () {
                  final Set<LearnFilters> newState = Set()
                    ..addAll(_filterState!);
                  if (_filterState!.contains(LearnFilters.All)) {
                    newState.remove(LearnFilters.All);
                  }
                  if (_filterState!.contains(LearnFilters.Videos)) {
                    newState.remove(LearnFilters.Videos);
                  } else {
                    newState.add(LearnFilters.Videos);
                    if (_filterState!.contains(LearnFilters.Blogs) &&
                        _filterState!.contains(LearnFilters.FAQs)) {
                      newState.add(LearnFilters.All);
                    }
                  }
                  setState(() {
                    _filterState = newState;
                  });
                },
              ),
              Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              EnvoyFilterChip(
                selected: _filterState?.contains(LearnFilters.FAQs) ?? false,
                text: "FAQs",
                onTap: () {
                  final Set<LearnFilters> newState = Set()
                    ..addAll(_filterState!);
                  if (_filterState!.contains(LearnFilters.All)) {
                    newState.remove(LearnFilters.All);
                  }
                  if (_filterState!.contains(LearnFilters.FAQs)) {
                    newState.remove(LearnFilters.FAQs);
                  } else {
                    newState.add(LearnFilters.FAQs);
                    if (_filterState!.contains(LearnFilters.Blogs) &&
                        _filterState!.contains(LearnFilters.Videos)) {
                      newState.add(LearnFilters.All);
                    }
                  }
                  setState(() {
                    _filterState = newState;
                  });
                },
              ),
              Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              EnvoyFilterChip(
                selected: _filterState?.contains(LearnFilters.Blogs) ?? false,
                text: "Blog posts",
                onTap: () {
                  final Set<LearnFilters> newState = Set()
                    ..addAll(_filterState!);
                  if (_filterState!.contains(LearnFilters.All)) {
                    newState.remove(LearnFilters.All);
                  }
                  if (_filterState!.contains(LearnFilters.Blogs)) {
                    newState.remove(LearnFilters.Blogs);
                  } else {
                    newState.add(LearnFilters.Blogs);
                    if (_filterState!.contains(LearnFilters.Videos) &&
                        _filterState!.contains(LearnFilters.FAQs)) {
                      newState.add(LearnFilters.All);
                    }
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
                  ref.read(learnSortStateProvider.notifier).state =
                      LearnSortTypes.newestFirst;
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
            checked: _sortState == LearnSortTypes.newestFirst,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = LearnSortTypes.newestFirst;
              });
            },
          ),
          CheckBoxFilterItem(
            text: "Oldest First",
            checked: _sortState == LearnSortTypes.oldestFirst,
            onTap: () {
              setState(() {
                _sortState = LearnSortTypes.oldestFirst;
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
                ref.read(learnSortStateProvider.notifier).state = _sortState!;
              }
              if (_filterState != null) {
                ref.read(learnFilterStateProvider.notifier).state =
                    _filterState!;
              }
            },
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.medium2)),
        ],
      ),
    );
  }
}
