// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

library;

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'src/rust/frb_generated.dart';

export 'src/rust/api/btp.dart';
export 'src/rust/api/rpc.dart';
export 'src/rust/api/rpc/app_store.dart';
export 'src/rust/api/rpc/backup.dart';
export 'src/rust/api/rpc/benchmark.dart';
export 'src/rust/api/rpc/bitcoin.dart';
export 'src/rust/api/rpc/firmware.dart';
export 'src/rust/api/rpc/fx.dart';
export 'src/rust/api/rpc/security_check.dart';
export 'src/rust/api/rpc/timezone.dart';
export 'src/rust/api/platform.dart';
export 'src/rust/api/ql_link.dart';
export 'src/rust/api/rust_log.dart';
export 'src/rust/third_party/ql_api/app_store.dart';
export 'src/rust/third_party/ql_api/backup.dart';
export 'src/rust/third_party/ql_api/bitcoin.dart';
export 'src/rust/third_party/ql_api/codec.dart';
export 'src/rust/third_party/ql_api/debug.dart';
export 'src/rust/third_party/ql_api/firmware.dart';
export 'src/rust/third_party/ql_api/fx.dart';
export 'src/rust/third_party/ql_api/onboarding.dart';
export 'src/rust/third_party/ql_api/scv.dart';
export 'src/rust/third_party/ql_api/system.dart';
export 'src/rust/third_party/ql_api/time.dart';
export 'src/rust/frb_generated.dart';

const _unsupportedSubscriptionStreamError = 'qlv2.unsupported_subscription';

bool isUnsupportedSubscriptionError(Object error) =>
    error is AnyhowException &&
    error.message == _unsupportedSubscriptionStreamError;

class Qlv2 {
  const Qlv2._();

  static Future<void> init({ExternalLibrary? externalLibrary}) {
    return RustLib.init(externalLibrary: externalLibrary);
  }
}
