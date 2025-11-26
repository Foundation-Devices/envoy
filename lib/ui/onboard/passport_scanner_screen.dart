// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/home/setup_overlay.dart';
import 'package:envoy/ui/widgets/scanner/decoders/device_decoder.dart';
import 'package:envoy/ui/widgets/scanner/decoders/pair_decoder.dart';

class PassportScannerScreen extends ConsumerWidget {
  const PassportScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String path = ref.watch(routePathProvider);
    final bool onboardingCompleted =
        LocalStorage().prefs.getBool(PREFS_ONBOARDED) ?? false;

    void handleBack() {
      if (onboardingCompleted) {
        context.goNamed("/");
      } else {
        Navigator.of(context).pop();
      }
    }

    // Prevents the camera from running in the background
    return (path == "/onboard/passport_scan")
        ? GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 200) {
                Navigator.of(context).maybePop();
              }
            },
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (_, __) {
                handleBack();
              },
              child: QrScanner(
                showInfoDialog: true,
                onBackPressed: (_) => handleBack(),
                decoder: DeviceDecoder(pairPayloadDecoder: PairPayloadDecoder(
                  onScan: (binary) {
                    addPassportAccount(binary, context);
                  },
                ), onScan: (String payload) {
                  final uri = Uri.parse(payload);
                  final params = uri.queryParameters;

                  if (params.containsKey("p")) {
                    context.goNamed(ONBOARD_PRIME, queryParameters: params);
                  } else if (params.containsKey("t")) {
                    context.goNamed(ONBOARD_PASSPORT_TOU,
                        queryParameters: params);
                  } else {
                    EnvoyToast(
                      replaceExisting: true,
                      duration: const Duration(seconds: 6),
                      message: "Invalid QR code",
                      isDismissible: true,
                      onActionTap: () {
                        EnvoyToast.dismissPreviousToasts(context);
                      },
                      icon: const Icon(
                        Icons.info_outline,
                        color: EnvoyColors.accentPrimary,
                      ),
                    ).show(context);
                  }
                }),
                child: LegacyFirmwareAlert(),
              ),
            ),
          )
        : Container();
  }
}

class LegacyFirmwareAlert extends StatefulWidget {
  const LegacyFirmwareAlert({super.key});

  @override
  State<LegacyFirmwareAlert> createState() => _LegacyFirmwareAlertState();
}

class _LegacyFirmwareAlertState extends State<LegacyFirmwareAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  void _toggleAdvanced() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium3),
          alignment: Alignment.center,
          child: Column(
            children: [
              GestureDetector(
                onTap: _toggleAdvanced,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * pi,
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_up_sharp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizeTransition(
                sizeFactor: _heightAnimation,
                axisAlignment: -1.0, // slide down from top
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium3,
                      vertical: EnvoySpacing.small),
                  child: Column(
                    children: [
                      Text(
                        S().onboarding_passpportSelectCamera_sub235VersionAlert,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: EnvoyColors.textPrimaryInverse,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(EnvoySpacing.small),
                        child: TextButton(
                          child: Text(
                            S().onboarding_passpportSelectCamera_tapHere,
                            style: EnvoyTypography.button.copyWith(
                              color: EnvoyColors.textPrimaryInverse,
                            ),
                          ),
                          onPressed: () async {
                            context.goNamed(ONBOARD_PASSPORT_SETUP);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
