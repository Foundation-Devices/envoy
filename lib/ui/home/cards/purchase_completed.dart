// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'accounts/accounts_state.dart';

class PurchaseComplete extends ConsumerStatefulWidget {
  const PurchaseComplete(this.account, {super.key});

  final Account account;

  @override
  ConsumerState<PurchaseComplete> createState() => _PurchaseCompleteState();
}

class _PurchaseCompleteState extends ConsumerState<PurchaseComplete> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) async {
        Navigator.of(context).pop();
      },
      child: OnboardPageBackground(
        child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Container(
                    constraints:
                        BoxConstraints.tight(const Size.fromHeight(280)),
                    child: const RiveAnimation.asset(
                      "assets/envoy_loader.riv",
                      fit: BoxFit.contain,
                      animations: ["happy"],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: EnvoySpacing.medium2,
                      horizontal: EnvoySpacing.medium1),
                  child: Column(
                    children: [
                      Text(
                        S().buy_bitcoin_purchaseComplete_heading,
                        style: EnvoyTypography.subheading,
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: EnvoySpacing.large1),
                        child: Text(
                          S().buy_bitcoin_purchaseComplete_subheading,
                          style: EnvoyTypography.info
                              .copyWith(color: EnvoyColors.textTertiary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium1),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return EnvoyButton(
                        label: S().component_continue,
                        onTap: () async {
                          final router = GoRouter.of(context);
                          ref.read(selectedAccountProvider.notifier).state =
                              widget.account;
                          Navigator.of(context).pop();
                          router.go(ROUTE_ACCOUNT_DETAIL,
                              extra: widget.account);
                          await Future.delayed(
                              const Duration(milliseconds: 50));
                        },
                        type: ButtonType.primary,
                        state: ButtonState.defaultState,
                      );
                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
