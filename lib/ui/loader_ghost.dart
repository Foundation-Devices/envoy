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
      this.diagonal = false})
      : super(key: key);

  @override
  State<LoaderGhost> createState() => _LoaderGhostState();
}

class _LoaderGhostState extends State<LoaderGhost>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late void Function() _animationTickListener;
  late void Function(AnimationStatus) _animationStatusListener;

  @override
  initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _animation = _animationController.drive(Tween(begin: 0.3, end: 0.1));

    _animationTickListener = () {
      setState(() {});
    };

    _animationController.addListener(_animationTickListener);

    _animationStatusListener = (status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    };

    _animationController.addStatusListener(_animationStatusListener);

    _animationController.forward();
  }

  @override
  dispose() {
    _animationController.removeListener(_animationTickListener);
    _animationController.removeStatusListener(_animationStatusListener);

    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: _animation.value,
        child: widget.diagonal
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
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                ),
              )
            : Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              ));
  }
}
