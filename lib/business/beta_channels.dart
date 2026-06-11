// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/server.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BetaChannelsManager extends ChangeNotifier {
  static final BetaChannelsManager _instance =
      BetaChannelsManager._internal();

  factory BetaChannelsManager() => _instance;

  BetaChannelsManager._internal();

  List<BetaChannel> _channels = [];
  Object? _error;
  bool _loading = false;

  List<BetaChannel> get channels => List.unmodifiable(_channels);
  Object? get error => _error;
  bool get loading => _loading;

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _channels = await Server().fetchBetaChannels();
    } catch (e, stack) {
      _error = e;
      EnvoyReport().log(
        "BetaChannels",
        "Failed to fetch beta channels: $e",
        stackTrace: stack,
      );
      kPrint("Failed to fetch beta channels: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

final betaChannelsProvider = ChangeNotifierProvider<BetaChannelsManager>(
  (ref) => BetaChannelsManager(),
);
