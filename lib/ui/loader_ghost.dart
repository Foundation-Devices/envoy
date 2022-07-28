// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class LoaderGhost extends StatefulWidget {
  final double width;
  final double height;

  const LoaderGhost({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<LoaderGhost> createState() => _LoaderGhostState();
}

class _LoaderGhostState extends State<LoaderGhost>
    with SingleTickerProviderStateMixin {
  late AnimationController _circuitEstablishingAnimationController;
  late Animation<double> _circuitEstablishingAnimation;
  late void Function() _animationTickListener;
  late void Function(AnimationStatus) _animationStatusListener;

  @override
  initState() {
    super.initState();
    _circuitEstablishingAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _circuitEstablishingAnimation = _circuitEstablishingAnimationController
        .drive(Tween(begin: 0.8, end: 0.5));

    _animationTickListener = () {
      setState(() {});
    };

    _circuitEstablishingAnimationController.addListener(_animationTickListener);

    _animationStatusListener = (status) {
      if (status == AnimationStatus.completed) {
        _circuitEstablishingAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _circuitEstablishingAnimationController.forward();
      }
    };

    _circuitEstablishingAnimationController
        .addStatusListener(_animationStatusListener);

    _circuitEstablishingAnimationController.forward();
  }

  @override
  dispose() {
    _circuitEstablishingAnimationController
        .removeListener(_animationTickListener);
    _circuitEstablishingAnimationController
        .removeStatusListener(_animationStatusListener);

    _circuitEstablishingAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: _circuitEstablishingAnimation.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(15))),
        ));
  }
}
