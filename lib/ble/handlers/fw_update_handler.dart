// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'dart:async';

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:foundation_api/foundation_api.dart' as api;

class FwUpdateState {
  final String message;
  final EnvoyStepState step;

  FwUpdateState(this.message, this.step);
}

class FwUpdateHandler extends PassportMessageHandler {
  FwUpdateHandler(super.writer);
  //
  // final _fetch_state =
  //     StreamController<FwUpdateState>.broadcast();
  //
  // Stream<FwUpdateState> get fetchStateStream =>
  //     _fetch_state.stream.asBroadcastStream();

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_FirmwareUpdateCheckRequest ||
        message is api.QuantumLinkMessage_FirmwareFetchRequest;
  }

  @override
  Future<void> handleMessage(
      api.QuantumLinkMessage message, String bleId) async {
    if (message
        case api.QuantumLinkMessage_FirmwareUpdateCheckRequest updateRequest) {
      final currentVersion = updateRequest.field0.currentVersion;
      _handleFwUpdateCheckRequest(currentVersion);
    }
  }

  Future<void> _handleFwUpdateCheckRequest(String currentVersion) async {
    // print("Handling FW update check for version: $currentVersion");
    // _fetch_state.sink.add(FwUpdateState(
    //     S().onboarding_connectionChecking_forUpdates, EnvoyStepState.LOADING));
    //
    // final patches = await Server().fetchPrimePatches(currentVersion);
    //
    // print("Found ${patches.length} patches for version $currentVersion");
    // if (patches.isEmpty) {
    //   _fetch_state.sink.add(FwUpdateState(
    //       S().onboarding_connectionChecking_forUpdates,
    //       EnvoyStepState.LOADING));
    //   if (patches.isEmpty) {
    //     print("sending not available response");
    //     writer.writeMessage(api.QuantumLinkMessage.firmwareUpdateCheckResponse(
    //         api.FirmwareUpdateCheckResponse_NotAvailable()));
    //     return;
    //   }
    //
    //   final response = api.QuantumLinkMessage.firmwareUpdateCheckResponse(
    //       api.FirmwareUpdateCheckResponse.available(api.FirmwareUpdateAvailable(
    //           version: patches.last.version,
    //           timestamp: patches.last.releaseDate.millisecondsSinceEpoch,
    //           totalSize: 100,
    //           changelog: patches.last.changelog,
    //           patchCount: patches.length)));
    //
    //   await writer.writeMessage(response);
    // }
    //
    // final stepUpdate = patches.isNotEmpty
    //     ? S().onboarding_connectionUpdatesAvailable_updatesAvailable
    //     : S().onboarding_connectionNoUpdates_noUpdates;
    //
    // print("Sending available response with message: $stepUpdate");
    // _fetch_state.sink.add(FwUpdateState(stepUpdate, EnvoyStepState.FINISHED));
  }
}
