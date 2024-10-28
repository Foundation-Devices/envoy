// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';

class ScrollGradientMask extends StatefulWidget {
  final Widget child;
  final double start;
  final double topGradientValue;
  final double bottomGradientValue;
  final double end;

  const ScrollGradientMask({
    required this.child,
    this.start = 0.0,
    this.topGradientValue = 0.05,
    this.bottomGradientValue = 0.95,
    this.end = 1.0,
    super.key,
  });

  @override
  ScrollGradientMaskState createState() => ScrollGradientMaskState();
}

class ScrollGradientMaskState extends State<ScrollGradientMask> {
  final ValueNotifier<double> topGradientEndNotifier =
      ValueNotifier<double>(0.0);
  final ValueNotifier<double> bottomGradientStartNotifier =
      ValueNotifier<double>(1.0);
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        _updateGradients();
      });

    topGradientEndNotifier.value = widget.start;
    bottomGradientStartNotifier.value = widget.bottomGradientValue;
  }

  void _updateGradients() {
    if (_scrollController.offset == 0) {
      topGradientEndNotifier.value = widget.start;
      bottomGradientStartNotifier.value = widget.bottomGradientValue;
    } else if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      topGradientEndNotifier.value = widget.topGradientValue;
      bottomGradientStartNotifier.value = widget.end;
    } else {
      topGradientEndNotifier.value = widget.topGradientValue;
      bottomGradientStartNotifier.value = widget.bottomGradientValue;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    topGradientEndNotifier.dispose();
    bottomGradientStartNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: bottomGradientStartNotifier,
      builder: (context, bottomGradientStart, child) {
        return ValueListenableBuilder<double>(
          valueListenable: topGradientEndNotifier,
          builder: (context, topGradientEnd, child) {
            return ShaderMask(
              shaderCallback: (Rect rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [
                    EnvoyColors.solidWhite,
                    Colors.transparent,
                    Colors.transparent,
                    EnvoyColors.solidWhite,
                  ],
                  stops: [
                    0.0,
                    topGradientEnd,
                    bottomGradientStart,
                    1.0,
                  ],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification.metrics.pixels == 0) {
                    topGradientEndNotifier.value = widget.start;
                    bottomGradientStartNotifier.value =
                        widget.bottomGradientValue;
                  } else if (scrollNotification.metrics.pixels >=
                      scrollNotification.metrics.maxScrollExtent) {
                    topGradientEndNotifier.value = widget.topGradientValue;
                    bottomGradientStartNotifier.value = widget.end;
                  } else {
                    topGradientEndNotifier.value = widget.topGradientValue;
                    bottomGradientStartNotifier.value =
                        widget.bottomGradientValue;
                  }
                  return true;
                },
                child: widget.child,
              ),
            );
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
