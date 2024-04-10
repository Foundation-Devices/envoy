// ignore_for_file: missing_provider_scope
// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ui/lock/authenticate_page.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';

//default envoy session timeout
const envoySessionTimeout = Duration(seconds: 60);

// SessionManager is a singleton that listens to the app lifecycle and
// manages the session timeout. It will show the AuthenticatePage if the app is resumed after the timeout..
class SessionManager with WidgetsBindingObserver {
  static final SessionManager _singleton = SessionManager._internal();
  Timer? _timer;
  NavigatorState? _router;
  //flag to determine if the session is timed out
  bool _timeout = false;

  //during the auth process, app lifecycle will change. inorder to avoid multiple auth pages,
  //we need to track the auth process
  bool _authenticateInProcess = false;

  factory SessionManager() {
    return _singleton;
  }

  SessionManager._internal();

  //bind to app lifecycle and navigator
  bind(NavigatorState router) {
    _router = router;
    WidgetsBinding.instance.addObserver(this);
  }

  //removes app lifecycle observer and navigator
  remove() {
    _router = null;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive && !_authenticateInProcess) {
      _timer?.cancel();
      _timer = Timer(
        envoySessionTimeout,
        () {
          kPrint("⏳Session timeout!");
          _timeout = true;
        },
      );
    }
    //if the app is resumed and the session is timed out, show the AuthenticatePage
    if (state == AppLifecycleState.resumed) {
      if (_authenticateInProcess) {
        return;
      }
      if (_timeout && _router?.mounted == true && !_authenticateInProcess) {
        _authenticateInProcess = true;
        _router
            ?.push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.black12,
                pageBuilder: (context, a, b) => const AuthenticatePage(
                  sessionAuthenticate: true,
                ),
              ),
            )
            //wait for the navigation to complete
            .then((value) => Future.delayed(const Duration(milliseconds: 300)))
            .then((value) {
          _authenticateInProcess = false;
          _timeout = false;
          _timer?.cancel();
        });
      }
      _timer?.cancel();
    }
  }
}
