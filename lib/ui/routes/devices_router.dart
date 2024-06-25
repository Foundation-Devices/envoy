// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names
import 'package:envoy/business/devices.dart';
import 'package:envoy/ui/home/cards/devices/device_card.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:go_router/go_router.dart';

const ROUTE_DEVICES = '/devices';

const _DEVICE_DETAIL = 'details';
const ROUTE_DEVICE_DETAIL = '$ROUTE_DEVICES/$_DEVICE_DETAIL';

final devicesRouter =
    StatefulShellBranch(restorationScopeId: 'devicesScopeId', routes: [
  GoRoute(
      path: ROUTE_DEVICES,
      pageBuilder: (context, state) =>
          wrapWithVerticalAxisAnimation(const DevicesCard()),
      routes: [
        GoRoute(
            path: _DEVICE_DETAIL,
            pageBuilder: (context, state) {
              Device? device;
              if (state.extra is Map) {
                device = Device.fromJson(state.extra as Map<String, dynamic>);
              } else {
                device = state.extra as Device;
              }
              return wrapWithVerticalAxisAnimation(DeviceCard(device));
            }),
      ]),
]);
