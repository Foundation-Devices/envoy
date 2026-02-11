// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/animated_qr_image.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/shield_path.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as envoy_colors;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/components/step_indicator.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/routes.dart';

class VerifyCountdownNotifier extends StateNotifier<int> {
  VerifyCountdownNotifier() : super(5);

  Timer? _timer;

  void start() {
    _timer?.cancel();
    state = 5;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state <= 1) {
        state = 0;
        timer.cancel();
      } else {
        state = state - 1;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final verifyCountdownProvider =
    StateNotifierProvider<VerifyCountdownNotifier, int>((ref) {
  return VerifyCountdownNotifier();
});

class PsbtCard extends ConsumerStatefulWidget {
  final DraftTransaction transaction;
  final bool rbfFlow;

  const PsbtCard(this.transaction, this.rbfFlow, {super.key});

  @override
  ConsumerState<PsbtCard> createState() => _PsbtCardState();
}

class _PsbtCardState extends ConsumerState<PsbtCard> {
  @override
  void initState() {
    super.initState();
    // Defer the provider write until after the first frame
    Future.microtask(() {
      ref.read(verifyCountdownProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final account = ref.read(selectedAccountProvider);
    if (account == null) {
      return const SizedBox();
    }

    final countdown = ref.watch(verifyCountdownProvider);

    final isDisabled = countdown > 0;

    // start countdown only once when widget shows
    ref.listen<int>(verifyCountdownProvider, (prev, next) {});

    return Stack(
      children: [
        ClipPath(
          clipper: ShieldClipper(),
          child: SizedBox.expand(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    envoy_colors.EnvoyColors.surface2,
                    envoy_colors.EnvoyColors.surface1,
                  ],
                ),
              ),
            ),
          ),
        ),
        EnvoyScaffold(
          topBarLeading: Padding(
            padding: const EdgeInsets.all(EnvoySpacing.xs),
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.black,
              ),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
          ),
          topBarTitle: StepIndicator(currentStep: 1),
          topBarActions: [
            SizedBox(
              width: EnvoySpacing.large1,
            )
          ],
          removeAppBarPadding: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: EnvoySpacing.medium1),
                  Text(
                    S().send_qr_code_card_heading,
                    style: EnvoyTypography.heading,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: EnvoySpacing.small),
                  Text(
                    S().send_qr_code_card_subheading,
                    style: EnvoyTypography.body.copyWith(
                        color: envoy_colors.EnvoyColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: EnvoySpacing.medium2),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                width: 1,
                                color: envoy_colors.EnvoyColors.border2),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(EnvoySpacing.medium1))),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(EnvoySpacing.medium1),
                              child: AnimatedQrImage(
                                widget.transaction.psbt,
                                urType: "crypto-psbt",
                                binaryCborTag: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: EnvoySpacing.medium1,
                    right: EnvoySpacing.medium1,
                    bottom: EnvoySpacing.large2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EnvoyButton(
                      S().send_QrScan_saveToFile,
                      onTap: () {
                        SharePlus.instance.share(ShareParams(
                          text: base64Encode(widget.transaction.psbt),
                        ));
                      },
                      type: EnvoyButtonTypes.tertiary,
                      leading: EnvoyIcon(
                        EnvoyIcons.sd_card,
                        color: envoy_colors.EnvoyColors.accentPrimary,
                        size: EnvoyIconSize.extraSmall,
                      ),
                    ),
                    SizedBox(
                      height: EnvoySpacing.small,
                    ),
                    EnvoyButton(
                      isDisabled
                          ? '${countdown.toString()}... ${S().send_qrScan_scanQrWithPassportFirst}'
                          : S().send_qrScan_verifyOnPassport,
                      leading: EnvoyIcon(
                        isDisabled ? EnvoyIcons.clock : EnvoyIcons.eye,
                        color: envoy_colors.EnvoyColors.solidWhite,
                        size: EnvoyIconSize.extraSmall,
                      ),
                      enabled: !isDisabled,
                      onTap: () {
                        GoRouter.of(context).pushNamed(
                            widget.rbfFlow
                                ? PSBT_SCAN_QR
                                : ACCOUNT_SEND_SCAN_QR,
                            extra: widget.transaction);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
