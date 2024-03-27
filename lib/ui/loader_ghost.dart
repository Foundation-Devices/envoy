// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'dart:math';

class LoaderGhost extends StatefulWidget {
  final double width;
  final double height;
  final bool diagonal;
  const LoaderGhost(
      {Key? key,
      required this.width,
      required this.height,
      this.diagonal = false,
      this.animate = false})
      : super(key: key);

  final bool animate;

  @override
  State<LoaderGhost> createState() => _LoaderGhostState();
}

class _LoaderGhostState extends State<LoaderGhost>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _animation = Tween(begin: .3, end: .8).animate(
        new CurvedAnimation(parent: _animationController, curve: Curves.ease));
    _animationController.addListener(() {
      if (mounted) setState(() {});
    });
    _animationController.repeat(reverse: true, period: Duration(seconds: 1));
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.diagonal
          ? SizedBox(
              width: widget.width,
              height: widget.height,
              child: Center(
                child: Transform.rotate(
                  angle: -pi / 4,
                  child: Container(
                    width: widget.width - 5,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
              ),
            )
          : Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            );
    }
    return widget.diagonal
        ? SizedBox(
            width: widget.width,
            height: widget.height,
            child: Center(
              child: Transform.rotate(
                angle: -pi / 4,
                child: Container(
                  width: widget.width - 5,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
              ),
            ),
          )
        : Container(
            width: widget.width,
            height: widget.height,
            // child: Text('${_animation.value}'),
            decoration: BoxDecoration(
                color: Colors.grey.shade400.withOpacity(_animation.value),
                borderRadius: BorderRadius.all(Radius.circular(20))),
          );
  }
}
