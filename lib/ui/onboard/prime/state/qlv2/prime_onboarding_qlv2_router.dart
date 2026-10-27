// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart';
import 'package:envoy/ui/onboard/prime/state/qlv2/prime_onboarding_qlv2_security_check.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

QLV2RpcRouter buildPrimeOnboardingQlv2Router(
  PrimeOnboardingController controller, {
  required bool skipSecurityCheck,
  bool Function()? shouldHandle,
}) {
  return QLV2RpcRouter.builder()
      .duplexRpc<
          qlv2.InboundRpc_SecurityCheck,
          qlv2.RunSecurityCheckInitiatorEvent,
          qlv2.RunSecurityCheckResponderEvent>(
        PrimeOnboardingQlv2SecurityCheckHandler(
          controller,
          skipSecurityCheck: skipSecurityCheck,
          shouldHandle: shouldHandle,
        ),
        debugName: "prime_onboarding.security_check",
      )
      .build();
}
