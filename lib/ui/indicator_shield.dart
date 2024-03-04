// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/settings.dart';

class IndicatorShield extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IndicatorShieldState();
  }
}

class IndicatorShieldState extends State<IndicatorShield>
    with SingleTickerProviderStateMixin {
  late StreamSubscription _connectivityStream;
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
      if (mounted) {
        setState(() {});
      }
    });

    _circuitEstablishingAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _circuitEstablishingAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _circuitEstablishingAnimationController.forward();
      }
    });

    _connectivityStream = ConnectivityManager().events.stream.listen((_) {
      // Update UI on connectivity changes
      if (mounted) {
        setState(() {
          _updateShield();
        });
      }
    });
  }

  void _checkIfNeedAnimate() {
    if (ConnectivityManager().torEnabled &&
        !ConnectivityManager().torCircuitEstablished) {
      _circuitEstablishingAnimationController.forward();
    } else {
      _circuitEstablishingAnimationController.stop();
    }
  }

  void _updateShield() {
    _currentShield = _determineShield();
    _checkIfNeedAnimate();
  }

  Widget _determineShield() {
    if (!ConnectivityManager().torEnabled ||
        ConnectivityManager().torTemporarilyDisabled) {
      // No shield
      return SizedBox.shrink(key: UniqueKey());
    } else {
      if (!ConnectivityManager().electrumConnected) {
        return Image.asset(
          "assets/indicator_shield_red.png",
          key: UniqueKey(),
        );
      }

      return Image.asset(
        "assets/indicator_shield_teal.png",
        key: UniqueKey(),
      );
    }
  }

  @override
  void dispose() {
    _circuitEstablishingAnimationController.dispose();
    _connectivityStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      ref.watch(settingsProvider);
      _updateShield();
      return Opacity(
          opacity: ConnectivityManager().torCircuitEstablished
              ? 1.0
              : _circuitEstablishingAnimation.value,
          child: AnimatedSwitcher(
              duration: Duration(seconds: 1), child: _currentShield));
    });
  }
}
