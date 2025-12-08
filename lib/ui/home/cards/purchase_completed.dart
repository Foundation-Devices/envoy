// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/business/stripe.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/util/envoy_storage.dart';

class PurchaseComplete extends ConsumerStatefulWidget {
  const PurchaseComplete(this.account, this.address, {super.key});

  final EnvoyAccount account;
  final String address;

  @override
  ConsumerState<PurchaseComplete> createState() => _PurchaseCompleteState();
}

class _PurchaseCompleteState extends ConsumerState<PurchaseComplete> {
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;
  bool? _isPaymentSuccess;
  String? sessionId;
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    _initRive().then((_) => _startPaymentFlow());
  }

  Future<void> _initRive() async {
    _riveFile = await rive.File.asset(
      'assets/envoy_loader.riv',
      riveFactory: rive.Factory.rive,
    );

    _controller = rive.RiveWidgetController(
      _riveFile!,
      stateMachineSelector: rive.StateMachineSelector.byName('STM'),
    );

    // Start in indeterminate/loading mode
    _setAnimationState(
      happy: false,
      unhappy: false,
      indeterminate: true,
    );

    setState(() => _isInitialized = true);
  }

  void _setAnimationState({
    required bool happy,
    required bool unhappy,
    required bool indeterminate,
  }) {
    if (_controller?.stateMachine == null) return;
    final stateMachine = _controller!.stateMachine;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean('happy')?.value = happy;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean('unhappy')?.value = unhappy;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean('indeterminate')?.value = indeterminate;
  }

  Future<void> _startPaymentFlow() async {
    if (!mounted) return;

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _launched = true;
      });
    });

    final (success, session) = await launchOnrampSession(
      context,
      widget.address,
      selectedAccount: widget.account,
    );

    if (!mounted) return;

    setState(() {
      _isPaymentSuccess = success;
      sessionId = session?.id;
    });

    // Update Rive animation state based on result
    _setAnimationState(
      happy: success,
      unhappy: !success,
      indeterminate: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final success = _isPaymentSuccess == true;

    return PopScope(
      onPopInvokedWithResult: (_, __) async {
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.only(
          right: EnvoySpacing.medium2,
          left: EnvoySpacing.medium2,
          top: EnvoySpacing.large3,
          bottom: EnvoySpacing.large2,
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Container(
                      constraints:
                          BoxConstraints.tight(const Size.fromHeight(280)),
                      child: _isInitialized && _controller != null
                          ? rive.RiveWidget(
                              controller: _controller!,
                              fit: rive.Fit.contain,
                            )
                          : const SizedBox(),
                    ),
                  ),
                  Text(
                    _isPaymentSuccess == null
                        ? ""
                        : success
                            ? S().buy_bitcoin_purchaseComplete_heading
                            : S().buy_bitcoin_purchaseError_heading,
                    style: EnvoyTypography.heading,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: EnvoySpacing.medium3,
                  ),
                  Text(
                    _isPaymentSuccess == null
                        ? ""
                        : success
                            ? S().buy_bitcoin_purchaseComplete_subheading
                            : S().buy_bitcoin_purchaseError_contactStripe,
                    style: EnvoyTypography.body.copyWith(
                        color: success
                            ? EnvoyColors.textSecondary
                            : EnvoyColors.teal500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: EnvoySpacing.medium3,
                  ),
                  if (_isPaymentSuccess == false)
                    Text(
                      "${S().buy_bitcoin_purchaseError_purchaseID} $sessionId",
                      style: EnvoyTypography.body
                          .copyWith(color: EnvoyColors.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),

              // Continue button appears only when finished
              if (_isPaymentSuccess != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.small,
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return EnvoyButton(
                        S().component_continue,
                        borderRadius:
                            BorderRadius.circular(EnvoySpacing.medium1),
                        onTap: () async {
                          final router = GoRouter.of(context);
                          ref.read(selectedAccountProvider.notifier).state =
                              widget.account;
                          Navigator.of(context).pop();
                          if (success) {
                            router.go(
                              ROUTE_ACCOUNT_DETAIL,
                              extra: widget.account,
                            );
                          }
                          await Future.delayed(
                              const Duration(milliseconds: 50));
                        },
                      );
                    },
                  ),
                ),

              if (_isPaymentSuccess == null && _launched)
                Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.small,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EnvoyButton(
                          S().component_cancel,
                          type: EnvoyButtonTypes.secondary,
                          borderRadius:
                              BorderRadius.circular(EnvoySpacing.medium1),
                          onTap: () async {
                            await EnvoyStorage()
                                .deleteOnrampSession(sessionId ?? "");
                            await EnvoyStorage()
                                .deletePendingTx(sessionId ?? "");

                            if (context.mounted) {
                              final router = GoRouter.of(context);
                              Navigator.of(context).pop();

                              router.go(ROUTE_BUY_BITCOIN);
                            }
                            await Future.delayed(
                                const Duration(milliseconds: 50));
                          },
                        ),
                        SizedBox(
                          height: EnvoySpacing.medium1,
                        ),
                        EnvoyButton(
                          S().component_retry,
                          borderRadius:
                              BorderRadius.circular(EnvoySpacing.medium1),
                          onTap: () async {
                            await EnvoyStorage()
                                .deleteOnrampSession(sessionId ?? "");
                            await EnvoyStorage()
                                .deletePendingTx(sessionId ?? "");
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            await Future.delayed(
                                const Duration(milliseconds: 50));
                          },
                        ),
                      ],
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
