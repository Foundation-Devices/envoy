// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/filter_chip.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:envoy/ui/home/cards/learn/filter_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LearnFilterWidget extends ConsumerStatefulWidget {
  const LearnFilterWidget({super.key});

  @override
  LearnFilterWidgetState createState() => LearnFilterWidgetState();
}

class LearnFilterWidgetState extends ConsumerState<LearnFilterWidget> {
  LearnSortTypes? _sortState;
  Set<LearnFilters>? _filterState;

  @override
  Widget build(BuildContext context) {
    final learnFilterState = ref.watch(learnFilterStateProvider);
    final learnSortState = ref.watch(learnSortStateProvider);
    final filterButtonTextStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14);

    _sortState ??= learnSortState;
    _filterState ??= learnFilterState;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EnvoySpacing.medium1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S().component_filter,
                style: EnvoyTypography.subheading
                    .copyWith(color: EnvoyColors.textPrimary),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterState = {}..addAll(LearnFilters.values);
                    _sortState = LearnSortTypes.newestFirst;
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
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                EnvoyFilterChip(
                  text: S().learning_center_filter_all,
                  selected: _filterState?.contains(LearnFilters.all) ?? false,
                  onTap: () {
                    final Set<LearnFilters> newState = {}
                      ..addAll(_filterState!);
                    if (_filterState!.contains(LearnFilters.all)) {
                      newState.remove(LearnFilters.all);
                      newState.remove(LearnFilters.videos);
                      newState.remove(LearnFilters.blogs);
                      newState.remove(LearnFilters.faqs);
                    } else {
                      newState.add(LearnFilters.all);
                      newState.add(LearnFilters.videos);
                      newState.add(LearnFilters.blogs);
                      newState.add(LearnFilters.faqs);
                    }
                    setState(() {
                      _filterState = newState;
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                EnvoyFilterChip(
                  selected:
                      ((_filterState?.contains(LearnFilters.videos) ?? false) &&
                          !(_filterState?.contains(LearnFilters.all) ?? true)),
                  text: S().learning_center_title_video,
                  onTap: () {
                    final Set<LearnFilters> newState = {}
                      ..addAll(_filterState!);
                    if (_filterState!.contains(LearnFilters.all)) {
                      newState.removeAll(_filterState!);
                    }
                    if (newState.contains(LearnFilters.videos)) {
                      newState.remove(LearnFilters.videos);
                    } else {
                      newState.add(LearnFilters.videos);
                    }
                    setState(() {
                      _filterState = newState;
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                EnvoyFilterChip(
                  selected:
                      ((_filterState?.contains(LearnFilters.faqs) ?? false) &&
                          !(_filterState?.contains(LearnFilters.all) ?? true)),
                  text: S().learning_center_title_faq,
                  onTap: () {
                    final Set<LearnFilters> newState = {}
                      ..addAll(_filterState!);
                    if (_filterState!.contains(LearnFilters.all)) {
                      newState.removeAll(_filterState!);
                    }
                    if (newState.contains(LearnFilters.faqs)) {
                      newState.remove(LearnFilters.faqs);
                    } else {
                      newState.add(LearnFilters.faqs);
                    }
                    setState(() {
                      _filterState = newState;
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                EnvoyFilterChip(
                  selected:
                      ((_filterState?.contains(LearnFilters.blogs) ?? false) &&
                          !(_filterState?.contains(LearnFilters.all) ?? true)),
                  text: S().learning_center_title_blog,
                  onTap: () {
                    final Set<LearnFilters> newState = {}
                      ..addAll(_filterState!);
                    if (_filterState!.contains(LearnFilters.all)) {
                      newState.removeAll(_filterState!);
                    }
                    if (newState.contains(LearnFilters.blogs)) {
                      newState.remove(LearnFilters.blogs);
                    } else {
                      newState.add(LearnFilters.blogs);
                    }
                    setState(() {
                      _filterState = newState;
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Text(S().account_details_filter_tags_sortBy,
              style: EnvoyTypography.subheading
                  .copyWith(color: EnvoyColors.textPrimary)),
          CheckBoxFilterItem(
            text: S().filter_sortBy_newest,
            checked: _sortState == LearnSortTypes.newestFirst,
            onTap: () {
              Haptics.selectionClick();
              setState(() {
                _sortState = LearnSortTypes.newestFirst;
              });
            },
          ),
          CheckBoxFilterItem(
            text: S().filter_sortBy_oldest,
            checked: _sortState == LearnSortTypes.oldestFirst,
            onTap: () {
              setState(() {
                _sortState = LearnSortTypes.oldestFirst;
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
                ref.read(learnSortStateProvider.notifier).state = _sortState!;
              }
              if (_filterState != null) {
                ref.read(learnFilterStateProvider.notifier).state =
                    _filterState!;
              }
            },
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.medium2)),
        ],
      ),
    );
  }
}
