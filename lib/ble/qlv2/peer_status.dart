// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:qlv2/qlv2.dart';

extension PeerStatusEventReadiness on PeerStatusEvent {
  bool get isActive =>
      status == ConnectionStatus.connected &&
      permissionStatus == PeerPermissionsResponse.updated;

  PeerStatusEvent withPermissionStatus(
    PeerPermissionsResponse? permissionStatus,
  ) {
    return PeerStatusEvent(
      xid: xid,
      status: status,
      permissionStatus: permissionStatus,
    );
  }
}
