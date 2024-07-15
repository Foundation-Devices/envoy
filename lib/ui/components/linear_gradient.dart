// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';

class LinearGradients {
  static LinearGradient blogPostGradient(double topGradientEnd) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        EnvoyColors.solidWhite,
        Colors.transparent,
        Colors.transparent,
        EnvoyColors.solidWhite,
      ],
      stops: [0.0, topGradientEnd, 0.85, 0.96],
    );
  }
}

class ScrollGradientMask extends StatefulWidget {
  final Widget child;

  const ScrollGradientMask({required this.child, super.key});

  @override
  ScrollGradientMaskState createState() => ScrollGradientMaskState();
}

class ScrollGradientMaskState extends State<ScrollGradientMask> {
  final ValueNotifier<double> topGradientEndNotifier =
      ValueNotifier<double>(0.0);
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset == 0) {
          topGradientEndNotifier.value = 0.0;
        } else {
          topGradientEndNotifier.value = 0.05;
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    topGradientEndNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: topGradientEndNotifier,
      builder: (context, topGradientEnd, child) {
        return ShaderMask(
          shaderCallback: (Rect rect) {
            return LinearGradients.blogPostGradient(topGradientEnd)
                .createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.pixels == 0) {
                topGradientEndNotifier.value = 0.0;
              } else {
                topGradientEndNotifier.value = 0.05;
              }
              return true;
            },
            child: widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
