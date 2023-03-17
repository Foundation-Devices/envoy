// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class FadeEdgeEffectShader extends StatefulWidget {
  final Widget child;
  final ScrollController controller;

  const FadeEdgeEffectShader(
      {Key? key, required this.child, required this.controller})
      : super(key: key);

  @override
  State<FadeEdgeEffectShader> createState() => _FadeEdgeEffectShaderState();
}

class _FadeEdgeEffectShaderState extends State<FadeEdgeEffectShader>
    with SingleTickerProviderStateMixin {
  bool _hasShade = false;

  late AnimationController _controller;
  late Animation<double> _fadeTween;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 50));
    _fadeTween = Tween<double>(begin: 0.01, end: 0.12).animate(_controller);
    _controller.addListener(() {
      setState(() {});
    });
    Future.delayed(Duration(milliseconds: 100), () {
      widget.controller.addListener(() {
        _hasShade = widget.controller.offset > 0;
        if (_hasShade) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
      _hasShade = widget.controller.offset > 0;
      if (_hasShade) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<double> stops = [0.0, _fadeTween.value, .78, .986];
    return ShaderMask(
        shaderCallback: (Rect rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.transparent,
              Colors.transparent,
              Colors.white
            ],
            stops: stops,
          ).createShader(rect);
        },
        blendMode: BlendMode.dstOut,
        child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowIndicator();
              return false;
            },
            child: widget.child));
  }
}
