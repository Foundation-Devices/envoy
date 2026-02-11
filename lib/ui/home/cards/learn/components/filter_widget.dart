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
  Set<DeviceFilters>? _deviceFilterState;

  @override
  Widget build(BuildContext context) {
    final learnFilterState = ref.watch(learnFilterStateProvider);
    final learnSortState = ref.watch(learnSortStateProvider);
    final deviceFilterState = ref.watch(deviceFilterStateProvider);
    final filterButtonTextStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            );

    _sortState ??= learnSortState;
    _filterState ??= learnFilterState;
    _deviceFilterState ??= deviceFilterState;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
      child: SafeArea(
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S().component_filter,
                  style: EnvoyTypography.subheading.copyWith(
                    color: EnvoyColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filterState = {}..addAll(LearnFilters.values);
                      _deviceFilterState = {}..addAll(DeviceFilters.values);
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
                ),
              ],
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            Wrap(
              runSpacing: EnvoySpacing.small,
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
            const SizedBox(height: EnvoySpacing.medium3),
            Text(
              S().component_device,
              style: EnvoyTypography.subheading.copyWith(
                color: EnvoyColors.textPrimary,
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            Wrap(
              runSpacing: EnvoySpacing.small,
              children: [
                EnvoyFilterChip(
                  text: S().component_filter_button_all,
                  selected:
                      _deviceFilterState?.contains(DeviceFilters.all) ?? false,
                  onTap: () {
                    final Set<DeviceFilters> newState = {}
                      ..addAll(_deviceFilterState!);
                    if (_deviceFilterState!.contains(DeviceFilters.all)) {
                      newState.remove(DeviceFilters.all);
                      newState.remove(DeviceFilters.envoy);
                      newState.remove(DeviceFilters.passport);
                      newState.remove(DeviceFilters.passportPrime);
                    } else {
                      newState.add(DeviceFilters.all);
                      newState.add(DeviceFilters.envoy);
                      newState.add(DeviceFilters.passport);
                      newState.add(DeviceFilters.passportPrime);
                    }
                    setState(() {
                      _deviceFilterState = newState;
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                EnvoyFilterChip(
                  selected:
                      ((_deviceFilterState?.contains(DeviceFilters.envoy) ??
                              false) &&
                          !(_deviceFilterState?.contains(DeviceFilters.all) ??
                              true)),
                  text: S().learning_center_device_envoy,
                  onTap: () {
                    final Set<DeviceFilters> newState = {}
                      ..addAll(_deviceFilterState!);
                    if (_deviceFilterState!.contains(DeviceFilters.all)) {
                      newState.removeAll(_deviceFilterState!);
                    }
                    if (newState.contains(DeviceFilters.envoy)) {
                      newState.remove(DeviceFilters.envoy);
                    } else {
                      newState.add(DeviceFilters.envoy);
                    }
                    setState(() {
                      _deviceFilterState = newState;
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                EnvoyFilterChip(
                  selected:
                      ((_deviceFilterState?.contains(DeviceFilters.passport) ??
                              false) &&
                          !(_deviceFilterState?.contains(DeviceFilters.all) ??
                              true)),
                  text: S().learning_center_device_passportCore,
                  onTap: () {
                    final Set<DeviceFilters> newState = {}
                      ..addAll(_deviceFilterState!);
                    if (_deviceFilterState!.contains(DeviceFilters.all)) {
                      newState.removeAll(_deviceFilterState!);
                    }
                    if (newState.contains(DeviceFilters.passport)) {
                      newState.remove(DeviceFilters.passport);
                    } else {
                      newState.add(DeviceFilters.passport);
                    }
                    setState(() {
                      _deviceFilterState = newState;
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                EnvoyFilterChip(
                  selected: ((_deviceFilterState?.contains(
                            DeviceFilters.passportPrime,
                          ) ??
                          false) &&
                      !(_deviceFilterState?.contains(DeviceFilters.all) ??
                          true)),
                  text: S().learning_center_device_passportPrime,
                  onTap: () {
                    final Set<DeviceFilters> newState = {}
                      ..addAll(_deviceFilterState!);
                    if (_deviceFilterState!.contains(DeviceFilters.all)) {
                      newState.removeAll(_deviceFilterState!);
                    }
                    if (newState.contains(DeviceFilters.passportPrime)) {
                      newState.remove(DeviceFilters.passportPrime);
                    } else {
                      newState.add(DeviceFilters.passportPrime);
                    }
                    setState(() {
                      _deviceFilterState = newState;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: EnvoySpacing.medium3),
            Text(
              S().account_details_filter_tags_sortBy,
              style: EnvoyTypography.subheading.copyWith(
                color: EnvoyColors.textPrimary,
              ),
            ),
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
            const SizedBox(height: EnvoySpacing.medium1),
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
                if (_deviceFilterState != null) {
                  ref.read(deviceFilterStateProvider.notifier).state =
                      _deviceFilterState!;
                }
              },
            ),
            const SizedBox(height: EnvoySpacing.medium1),
          ],
        ),
      ),
    );
  }
}
