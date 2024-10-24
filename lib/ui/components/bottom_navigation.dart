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

  @override
  Widget build(BuildContext context) {
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
          bottom: Platform.isAndroid ? EnvoySpacing.xs : EnvoySpacing.small),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: activeColor,
        unselectedItemColor: inActiveColor,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: labelStyle,
        unselectedLabelStyle: labelStyle,
        unselectedIconTheme: const IconThemeData(size: 20),
        selectedIconTheme: const IconThemeData(size: 40),
        backgroundColor: Colors.transparent,
        enableFeedback: true,
        elevation: 0.0,
        onTap: (int index) {
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.devices,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.devices,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_devices,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.shield,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.shield,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_privacy,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.wallet,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.wallet,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_accounts,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.history,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.history,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_activity,
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.learn,
                color: inActiveColor,
              ),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
              child: EnvoyIcon(
                EnvoyIcons.learn,
                color: activeColor,
              ),
            ),
            label: S().bottomNav_learn,
          ),
        ],
      ),
    );
  }
}
