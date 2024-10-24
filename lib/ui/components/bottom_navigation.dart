// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class EnvoyBottomNavigation extends ConsumerStatefulWidget {
  final Function(int)? onIndexChanged;
  final int initialIndex;

  const EnvoyBottomNavigation(
      {super.key, this.onIndexChanged, this.initialIndex = 2});

  @override
  EnvoyBottomNavigationState createState() => EnvoyBottomNavigationState();
}

class EnvoyBottomNavigationState extends ConsumerState<EnvoyBottomNavigation> {
  int _selectedIndex = 2;
  var activeColor = EnvoyColors.accentPrimary;
  var inActiveColor = EnvoyColors.textTertiary;
  var labelStyle = EnvoyTypography.label;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inActiveColor,
        icon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.devices,
            color: activeColor,
          ),
        ),
        inactiveIcon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.devices,
            color: inActiveColor,
          ),
        ),
        title: S().bottomNav_devices,
      ),
      PersistentBottomNavBarItem(
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inActiveColor,
        icon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.shield,
            color: activeColor,
          ),
        ),
        inactiveIcon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.shield,
            color: inActiveColor,
          ),
        ),
        title: S().bottomNav_privacy,
      ),
      PersistentBottomNavBarItem(
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inActiveColor,
        icon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.wallet,
            color: activeColor,
          ),
        ),
        inactiveIcon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.wallet,
            color: inActiveColor,
          ),
        ),
        title: S().bottomNav_accounts,
      ),
      PersistentBottomNavBarItem(
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inActiveColor,
        icon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.history,
            color: activeColor,
          ),
        ),
        inactiveIcon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.history,
            color: inActiveColor,
          ),
        ),
        title: S().bottomNav_activity,
      ),
      PersistentBottomNavBarItem(
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inActiveColor,
        icon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.learn,
            color: activeColor,
          ),
        ),
        inactiveIcon: Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
          child: EnvoyIcon(
            EnvoyIcons.learn,
            color: inActiveColor,
          ),
        ),
        title: S().bottomNav_learn,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding =
        MediaQuery.viewPaddingOf(context).bottom;

    // listen to route changes and update selected index
    ref.listen<List<String>>(routeMatchListProvider, (previous, next) {
      // Iterate through the next routes. If it contains homeTabRoutes,
      // update the selected bottom navigation index.
      // homeTabRoutes are defined in the same order as the bottom navigation bar.
      for (var nextRoute in next) {
        for (var homeRoute in homeTabRoutes) {
          if (nextRoute.startsWith(homeRoute) && homeRoute != "/") {
            if (homeTabRoutes.indexOf(homeRoute) != _selectedIndex) {
              setState(() {
                _selectedIndex = homeTabRoutes.indexOf(homeRoute);
              });
            }
          }
        }
      }
    });

    return Padding(
        padding: EdgeInsets.only(
            bottom:
                (Platform.isAndroid ? EnvoySpacing.xs : EnvoySpacing.small) +
                    additionalBottomPadding),
        child: EnvoyBottomNavBar(
          _navBarItems(),
          selectedIndex: _selectedIndex,
          labelStyle: labelStyle,
          onItemSelected: (int index) {
            setState(() {
              if (index == _selectedIndex) {
                // if selected index is "Accounts"
                if (index == 2 && GoRouter.of(context).canPop()) {
                  GoRouter.of(context).pop();
                } else {
                  return;
                }
              }

              _selectedIndex = index;
              if (widget.onIndexChanged != null) {
                widget.onIndexChanged!(_selectedIndex);
              }
            });
          },
        ));
  }
}

class EnvoyBottomNavBar extends StatelessWidget {
  const EnvoyBottomNavBar(
    this.items, {
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
    required this.labelStyle,
  });

  final int selectedIndex;
  final List<PersistentBottomNavBarItem> items;
  final ValueChanged<int> onItemSelected;
  final TextStyle labelStyle;

  Widget _buildItem(
          final PersistentBottomNavBarItem item, final bool isSelected) =>
      Container(
        alignment: Alignment.center,
        height: kBottomNavigationBarHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: IconTheme(
                data: IconThemeData(
                    size: isSelected ? 40 : 20,
                    color: isSelected
                        ? item.activeColorPrimary
                        : item.inactiveColorPrimary),
                child: isSelected ? item.icon : item.inactiveIcon ?? item.icon,
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: FittedBox(
                  child: Text(
                item.title ?? "",
                style: labelStyle.copyWith(
                    color: isSelected
                        ? item.activeColorPrimary
                        : item.inactiveColorPrimary),
              )),
            )
          ],
        ),
      );

  @override
  Widget build(final BuildContext context) => Container(
        color: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          // height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((final item) {
              final int index = items.indexOf(item);
              return Flexible(
                child: GestureDetector(
                  onTap: () {
                    onItemSelected(index);
                  },
                  child: Container(
                      color: Colors.transparent,
                      child: _buildItem(item, selectedIndex == index)),
                ),
              );
            }).toList(),
          ),
        ),
      );
}
