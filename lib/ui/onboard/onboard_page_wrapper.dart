// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/shield.dart';
import 'package:flutter/material.dart';

class OnboardPageBackground extends StatelessWidget {
  final Widget child;

  const OnboardPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    double shieldTop = MediaQuery.of(context).padding.top + 6.0;
    double shieldBottom = MediaQuery.of(context).padding.bottom + 6.0;
    return Stack(
      children: [
        const AppBackground(),
        Padding(
          padding: EdgeInsets.only(
              right: 5.0, left: 5.0, top: shieldTop, bottom: shieldBottom),
          child: Hero(
            tag: "shield",
            transitionOnUserGestures: true,
            child: Shield(
              child: Padding(
                  padding: const EdgeInsets.only(
                      right: 15, left: 15, top: 15, bottom: 50),
                  child: SizedBox.expand(
                    child: child,
                  )),
            ),
          ),
        )
      ],
    );
  }
}
