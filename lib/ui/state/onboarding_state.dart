// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tor/tor.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/wallet.dart';

final privacyOnboardSelectionProvider = StateProvider((ref) => true);
final isNodeRequiredTorProvider = StateProvider((ref) => false);

final nodeConnectionStateProvider =
    StateNotifierProvider<NodeConnectionStateNotifier, NodeConnectionState>(
        (ref) => NodeConnectionStateNotifier(NodeConnectionState.getDefault()));

class NodeConnectionState {
  bool isConnected;
  bool isConnecting;
  String? error;
  String? server;
  ElectrumServerFeatures? electrumServerFeatures;

  NodeConnectionState(
      {required this.isConnected,
      required this.isConnecting,
      this.error,
      this.server,
      this.electrumServerFeatures});

  static getDefault() {
    return NodeConnectionState(isConnected: false, isConnecting: false);
  }
}

class NodeConnectionStateNotifier extends StateNotifier<NodeConnectionState> {
  NodeConnectionStateNotifier(super.state);

  Future validateServer(String address, bool torRequired) async {
    try {
      state = NodeConnectionState(isConnected: false, isConnecting: true);
      Tor tor = Tor.instance;
      Settings().setTorEnabled(torRequired);
      if (torRequired) {
        tor.enable();
        if (!tor.bootstrapped) {
          await tor.isReady();
        }
      } else {
        //disable tor this wont stop the tor process
        Tor.instance.disable();
      }
      ElectrumServerFeatures features =
          await Wallet.getServerFeatures(address, Tor.instance.port);
      Settings().setCustomElectrumAddress(address);
      ConnectivityManager().electrumSuccess();
      Haptics.mediumImpact();
      state = NodeConnectionState(
          isConnected: true,
          isConnecting: false,
          electrumServerFeatures: features);
    } catch (e, c) {
      debugPrintStack(stackTrace: c);
      ConnectivityManager().electrumFailure();
      if (e is InvalidPort) {
        kPrint("Your port is invalid");
      }
      state = NodeConnectionState(
          isConnected: false, isConnecting: false, error: "${e}");
      kPrint(e);
    }
  }

  reset() {
    state = NodeConnectionState.getDefault();
  }
}
