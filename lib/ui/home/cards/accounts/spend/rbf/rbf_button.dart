// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_checkbox.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_spend_screen.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/generated_bindings.dart' as rust;
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class RBFSpendState {
  Psbt psbt;
  rust.RBFfeeRates rbfFeeRates;
  String receiveAddress;
  num receiveAmount;
  int feeRate;
  Transaction originalTx;

  RBFSpendState(
      {required this.psbt,
      required this.rbfFeeRates,
      required this.receiveAddress,
      required this.receiveAmount,
      required this.feeRate,
      required this.originalTx});
}

class TxRBFButton extends ConsumerStatefulWidget {
  final Transaction tx;

  const TxRBFButton({super.key, required this.tx});

  @override
  ConsumerState<TxRBFButton> createState() => _TxRBFButtonState();
}

class _TxRBFButtonState extends ConsumerState<TxRBFButton> {
  bool _isPressed = false;
  bool _isLoading = false;
  bool _canBoost = false;

  @override
  void initState() {
    super.initState();
    _checkIfCanBoost();
  }

  Future<void> _checkIfCanBoost() async {
    try {
      final account = ref.read(selectedAccountProvider);
      if (account == null) {
        return;
      }
      final lockedUtxos = ref.read(lockedUtxosProvider(account.id!));

      rust.RBFfeeRates? rates = await account.wallet
          .getBumpedPSBTMaxFeeRate(widget.tx.txId, lockedUtxos);

      if (rates.min_fee_rate > 0) {
        setState(() {
          _canBoost = true;
        });
        return;
      }
    } catch (e) {
      kPrint(e);
    }
  }

  Future _checkRBF(BuildContext context) async {
    final navigator = Navigator.of(context);
    setState(() {
      _isLoading = true;
    });
    if (ref.read(getTransactionProvider(widget.tx.txId))?.isConfirmed == true) {
      EnvoyToast(
        backgroundColor: EnvoyColors.danger,
        replaceExisting: true,
        duration: const Duration(seconds: 4),
        message: "Error: Transaction Confirmed",
        // TODO: Figma
        icon: const Icon(
          Icons.info_outline,
          color: EnvoyColors.solidWhite,
        ),
      ).show(context);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final account = ref.read(selectedAccountProvider);
      if (account == null) {
        return;
      }
      final lockedUtxos = ref.read(lockedUtxosProvider(account.id!));

      rust.RBFfeeRates? rates = await account.wallet
          .getBumpedPSBTMaxFeeRate(widget.tx.txId, lockedUtxos);

      if (rates.min_fee_rate > 0) {
        double minFeeRate = rates.min_fee_rate.ceil().toDouble();
        Psbt? psbt = await account.wallet.getBumpedPSBT(
            widget.tx.txId, convertToFeeRate(minFeeRate), lockedUtxos);
        final rawTxx = await account.wallet
            .decodeWalletRawTx(psbt.rawTx, account.wallet.network);

        RawTransactionOutput receiveOutPut =
            rawTxx.outputs.firstWhere((element) {
          return (element.path == TxOutputPath.NotMine ||
              element.path == TxOutputPath.External);
        }, orElse: () => rawTxx.outputs.first);

        RBFSpendState rbfSpendState = RBFSpendState(
            psbt: psbt,
            rbfFeeRates: rates,
            receiveAddress: receiveOutPut.address,
            receiveAmount: 0,
            feeRate: minFeeRate.toInt(),
            originalTx: widget.tx);

        ref.read(spendAddressProvider.notifier).state = receiveOutPut.address;
        ref.read(spendAmountProvider.notifier).state = receiveOutPut.amount;

        int minRate = minFeeRate.toInt();
        int maxRate = rates.max_fee_rate.toInt();
        int fasterFeeRate = minRate + 1;

        ///TODO: this is a hack to make sure the faster fee rate is always higher than the standard fee rate
        if (minRate == maxRate) {
          fasterFeeRate = maxRate;
        } else {
          if (minRate < maxRate) {
            fasterFeeRate = (maxRate + 1).clamp(minRate, maxRate);
          }
        }
        ref.read(feeChooserStateProvider.notifier).state = FeeChooserState(
          standardFeeRate: minFeeRate,
          fasterFeeRate: fasterFeeRate,
          minFeeRate: rates.min_fee_rate.ceil().toInt(),
          maxFeeRate: rates.max_fee_rate.floor().toInt(),
        );
        navigator.push(MaterialPageRoute(
          builder: (context) {
            return RBFSpendScreen(
              rbfSpendState: rbfSpendState,
            );
          },
        ));
        return;
      }
    } catch (e, stackTrace) {
      kPrint(stackTrace);
      if (context.mounted) {
        showNoBoostNoFundsDialog(context);
      }
      setState(() {
        _isLoading = false;
      });
      kPrint(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTap: () {
        if (_isLoading || !_canBoost) return;
        _showRBFDialog(context);
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: _buildButtonContainer(
          active: _canBoost,
          child: _isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium3),
                      child: SizedBox.square(
                        dimension: 12,
                        child: CircularProgressIndicator(
                          color: EnvoyColors.solidWhite,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Icon(
                      Icons.fast_forward_outlined,
                      color: Colors.white,
                    ),
                    const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                    Text(
                      S().coindetails_overlay_confirmation_boost,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                )),
    );
  }

  Widget _buildButtonContainer({
    required Widget child,
    bool active = true,
  }) {
    Color buttonColor = active
        ? (_isPressed
            ? EnvoyColors.teal500.withOpacity(0.8)
            : EnvoyColors.teal500)
        : Colors.grey;

    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
        decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(EnvoySpacing.small)),
        child: child);
  }

  void _showRBFDialog(BuildContext context) async {
    if (!(await EnvoyStorage()
        .checkPromptDismissed(DismissiblePrompt.rbfWarning)) && context.mounted) {
      showEnvoyDialog(
        context: context,
        dialog: EnvoyDialog(
          paddingBottom: 0,
          content: RBFWarning(
            onConfirm: () {
              Navigator.pop(context);
              _checkRBF(context);
            },
          ),
        ),
      );
    } else {
      _checkRBF(context);
    }
  }
}

class RBFWarning extends StatefulWidget {
  final GestureTapCallback onConfirm;

  const RBFWarning({super.key, required this.onConfirm});

  @override
  State<RBFWarning> createState() => _RBFWarningState();
}

class _RBFWarningState extends State<RBFWarning> {
  bool dismissed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: EnvoySpacing.medium1),
          child: EnvoyIcon(
            EnvoyIcons.info,
            size: EnvoyIconSize.big,
            color: EnvoyColors.accentPrimary,
          ),
        ),
        Text(
          S().replaceByFee_coindetails_overlay_modal_heading,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
        Text(
          S().replaceByFee_coindetails_overlay_modal_subheading,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
        GestureDetector(
          child: Text(
            S().component_learnMore,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EnvoyColors.accentPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
          onTap: () {
            launchUrl(Uri.parse(
                "https://docs.foundationdevices.com/en/envoy/accounts#boost-or-cancel-a-transaction"));
          },
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
        GestureDetector(
          onTap: () {
            setState(() {
              dismissed = !dismissed;
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: EnvoyCheckbox(
                  value: dismissed,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        dismissed = value;
                      });
                    }
                  },
                ),
              ),
              Text(
                S().component_dontShowAgain,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dismissed ? Colors.black : const Color(0xff808080),
                    ),
              ),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
        EnvoyButton(
            label: S().component_continue,
            onTap: () {
              if (dismissed) {
                EnvoyStorage().addPromptState(DismissiblePrompt.rbfWarning);
              }
              widget.onConfirm();
            },
            type: ButtonType.primary,
            state: ButtonState.defaultState),
      ],
    );
  }
}

void showNoBoostNoFundsDialog(BuildContext context) {
  showEnvoyDialog(
      context: context,
      dialog: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium3),
                  child: EnvoyIcon(
                    EnvoyIcons.alert,
                    size: EnvoyIconSize.big,
                    color: EnvoyColors.danger,
                  ),
                ),
                Text(
                  S().coindetails_overlay_noBoostNoFunds_heading,
                  textAlign: TextAlign.center,
                  style: EnvoyTypography.subheading,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: EnvoySpacing.medium1),
                  child: Text(
                    S().coindetails_overlay_noBoostNoFunds_subheading,
                    style: EnvoyTypography.info
                        .copyWith(color: EnvoyColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    S().component_learnMore,
                    style: EnvoyTypography.button.copyWith(
                      color: EnvoyColors.accentPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    launchUrl(Uri.parse(
                        "https://docs.foundationdevices.com/en/troubleshooting#why-cant-envoy-boost-or-cancel-my-transaction"));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: EnvoySpacing.medium3),
                  child: EnvoyButton(
                    label: S().component_continue,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    type: ButtonType.primary,
                    state: ButtonState.defaultState,
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
}
