// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// A scaffold that provides a consistent look and feel for the app.
/// EnvoyScaffold is a wrapper around [Scaffold] that provides a scrollable body for content,
/// along with options to pass in a custom [AppBar] and a bottom widget that sticks to the bottom.
///
class EnvoyScaffold extends StatelessWidget {
  /// [child] - the content of the scaffold; if the child doesn't fit in the viewport, it will be scrolled using CustomScrollView.
  /// [topBarLeading] and [topBarActions] - the content of the app bar.
  /// [topBarTitle] - the title of the app bar.
  /// [topBarColor] - the color of the app bar.
  /// [bottom] - the content that sticks to the bottom of the scaffold.
  /// [hasScrollBody] - set this to true if the child is scrollable to enable proper scrolling.
  /// [backgroundColor] - the background color of the scaffold.
  /// [removeAppBarPadding] - if there are multiple scaffolds, the app bar might add unnecessary padding to the top (normal behavior of scaffold).
  /// [appBar] - if provided, this will be used instead of the default app bar.

  final Widget? child;
  final Color backgroundColor;
  final bool removeAppBarPadding;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Widget? bottom;
  final List<Widget> topBarActions;
  final Widget? topBarLeading;
  final Widget? topBarTitle;
  final Color topBarColor;
  final AppBar? appBar;
  final bool hasScrollBody;

  const EnvoyScaffold(
      {super.key,
      required this.child,
      this.extendBody = false,
      this.extendBodyBehindAppBar = false,
      this.topBarActions = const [],
      this.hasScrollBody = false,
      this.backgroundColor = Colors.transparent,
      this.topBarColor = Colors.transparent,
      this.topBarLeading,
      this.topBarTitle,
      this.bottom,
      this.removeAppBarPadding = false,
      this.appBar,
      this.resizeToAvoidBottomInset = true});

  @override
  Widget build(BuildContext context) {
    bool hasAppBarContentProvided =
        topBarLeading != null || topBarActions.isNotEmpty;

    /// MediaQuery.removePadding is used to remove the default padding that scaffold adds to the top.
    /// This is necessary when there are multiple scaffolds on the same page.
    return MediaQuery.removePadding(
      removeTop: removeAppBarPadding,
      context: context,
      child: Scaffold(
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        extendBody: extendBody,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        backgroundColor: backgroundColor,
        //use custom appbar if provided, otherwise use default
        appBar: appBar ??
            (hasAppBarContentProvided
                ? AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    title: topBarTitle,
                    centerTitle: false,
                    leading: topBarLeading,
                    actions: topBarActions,
                  )
                : null),
        //scrollable body
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: hasScrollBody,
              fillOverscroll: true,
              child: child,
            )
          ],
        ),
        bottomNavigationBar: bottom,
      ),
    );
  }
}

///
/// ```dart
/// class ScaffoldSample extends StatelessWidget {
//   const ScaffoldSample({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return EnvoyScaffold(
//       hasScrollBody: false,
//       backgroundColor: Colors.white,
//       topBarTitle: Text("Envoy", style: Theme.of(context).textTheme.bodySmall),
//       topBarLeading: CupertinoNavigationBarBackButton(
//         color: EnvoyColors.blackish,
//         onPressed: () {},
//       ),
//       topActions: [
//         TextButton(
//           onPressed: () {},
//           child: Text("Action"),
//         ),
//       ],
//       child: Container(
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text("top"),
//             Text("center"),
//             Text("bottom"),
//           ],
//         ),
//       ),
//       bottom: Container(
//         margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             EnvoyButton("Secondary action", type: EnvoyButtonTypes.secondary),
//             EnvoyButton("Primary action", type: EnvoyButtonTypes.primary),
//           ],
//         ),
//       ),
//     );
//   }
// }
///
