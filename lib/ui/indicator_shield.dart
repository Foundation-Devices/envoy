import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tor/tor.dart';

class IndicatorShield extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IndicatorShieldState();
  }
}

class IndicatorShieldState extends State<IndicatorShield>
    with SingleTickerProviderStateMixin {
  late StreamSubscription _torStream;
  Widget _currentShield = SizedBox.shrink();
  late AnimationController _circuitEstablishingAnimationController;
  late Animation<double> _circuitEstablishingAnimation;

  @override
  initState() {
    super.initState();
    _circuitEstablishingAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _circuitEstablishingAnimation = _circuitEstablishingAnimationController
        .drive(Tween(begin: 1.0, end: 0.5));
    _circuitEstablishingAnimationController.addListener(() {
      setState(() {});
    });

    _circuitEstablishingAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _circuitEstablishingAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _circuitEstablishingAnimationController.forward();
      }
    });

    _torStream = Tor().events.stream.listen((event) {
      // Update UI on Tor changes
      setState(() {
        _currentShield = _determineShield();
      });

      _checkIfNeedAnimate();
    });

    _currentShield = _determineShield();
    _checkIfNeedAnimate();
  }

  void _checkIfNeedAnimate() {
    if (Tor().enabled && !Tor().circuitEstablished) {
      _circuitEstablishingAnimationController.forward();
    } else {
      _circuitEstablishingAnimationController.stop();
    }
  }

  Widget _determineShield() {
    if (!Tor().enabled) {
      // No shield
      return SizedBox.shrink(key: UniqueKey());
    } else {
      if (Tor().circuitEstablished) {
        // Same image as below until we decide on all the colours/states
        return Image.asset(
          "assets/indicator_shield_teal.png",
          key: UniqueKey(),
        );
      } else {
        return Image.asset(
          "assets/indicator_shield_teal.png",
          key: UniqueKey(),
        );
      }
    }
  }

  @override
  void dispose() {
    _torStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: Tor().circuitEstablished
            ? 1.0
            : _circuitEstablishingAnimation.value,
        child: AnimatedSwitcher(
            duration: Duration(seconds: 1), child: _currentShield));
  }
}
