// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_checkbox.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_spend_screen.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:url_launcher/url_launcher.dart';

class RBFSpendState {
  String receiveAddress;
  num receiveAmount;
  int feeRate;
  int originalAmount;
  DraftTransaction draftTx;
  BitcoinTransaction originalTx;

  RBFSpendState(
      {required this.receiveAddress,
      required this.receiveAmount,
      required this.feeRate,
      required this.originalTx,
      required this.originalAmount,
      required this.draftTx});

  RBFSpendState? copyWith({
    required int feeRate,
    required DraftTransaction preparedTx,
  }) {
    return RBFSpendState(
        receiveAddress: receiveAddress,
        receiveAmount: receiveAmount,
        feeRate: feeRate,
        originalTx: originalTx,
        originalAmount: originalAmount,
        draftTx: preparedTx);
  }

  BitcoinTransaction get getBumpedTransaction {
    return draftTx.transaction;
  }
}

class TxRBFButton extends ConsumerStatefulWidget {
  final EnvoyTransaction tx;

  const TxRBFButton({super.key, required this.tx});

  @override
  ConsumerState<TxRBFButton> createState() => _TxRBFButtonState();
}

class _TxRBFButtonState extends ConsumerState<TxRBFButton> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkBoost();
      setState(() {
        _isLoading = true;
      });
    });
  }

  Future<void> _checkBoost() async {
    try {
      ref.watch(rbfSpendStateProvider.notifier).state = null;
      final account = ref.read(selectedAccountProvider);
      final handler = account?.handler;
      if (account == null || handler == null) {
        return;
      }
      setState(() {
        _isLoading = true;
      });
      BitcoinTransaction originalTx = widget.tx;

      TransactionFeeResult result = await handler.getMaxBumpFeeRates(
          selectedOutputs: [], bitcoinTransaction: originalTx);

      setState(() {
        _isLoading = false;
      });
      int minRate = result.minFeeRate.toInt();
      int maxRate = result.maxFeeRate.toInt();
      int fasterFeeRate = minRate + 1;
      if (minRate == maxRate) {
        fasterFeeRate = maxRate;
      } else {
        if (minRate < maxRate) {
          fasterFeeRate = (minRate + 1).clamp(minRate, maxRate);
        }
      }
      ref.read(feeChooserStateProvider.notifier).state = FeeChooserState(
        standardFeeRate: minRate,
        fasterFeeRate: fasterFeeRate,
        minFeeRate: minRate,
        maxFeeRate: maxRate,
      );
      ref.read(rbfSpendStateProvider.notifier).state = RBFSpendState(
        receiveAddress: result.draftTransaction.transaction.address,
        receiveAmount: originalTx.amount,
        feeRate: minRate,
        originalTx: originalTx,
        originalAmount: originalTx.amount,
        draftTx: result.draftTransaction,
      );
    } catch (e) {
      EnvoyReport().log("RBF", "RBF check failed : $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future _checkRBF(BuildContext context) async {
    final navigator = Navigator.of(context);
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    final originalTx = ref.read(getTransactionProvider(widget.tx.txId));
    final rbfSpendState = ref.read(rbfSpendStateProvider);
    if (rbfSpendState != null) {
      ref.read(spendFeeRateProvider.notifier).state = rbfSpendState.feeRate;
      ref.read(stagingTxNoteProvider.notifier).state = originalTx?.note ?? "";
      ref.read(stagingTxChangeOutPutTagProvider.notifier).state =
          rbfSpendState.draftTx.changeOutPutTag;
      for (var element in rbfSpendState.originalTx.outputs) {
        if (element.keychain == KeyChain.internal) {
          ref.read(stagingTxChangeOutPutTagProvider.notifier).state =
              element.tag;
        }
      }
      // Update RBF state with latest transaction data
      // The original transaction may have changed since we started the RBF check,
      // as calculations happen in the background while viewing transaction details
      ref.read(rbfSpendStateProvider.notifier).state = rbfSpendState.copyWith(
        originalTx: originalTx ?? rbfSpendState.originalTx,
        preparedTx: rbfSpendState.draftTx,
        feeRate: rbfSpendState.feeRate,
      );
      navigator.push(MaterialPageRoute(
        builder: (context) {
          return const RBFSpendScreen();
        },
      ));
      return;
    } else {
      showNoBoostNoFundsDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isLoading) return;
        _showRBFDialog(context);
      },
      child: _buildButtonContainer(
          active: ref.watch(rbfSpendStateProvider) != null || _isLoading,
          child: _isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: EnvoySpacing.xs),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium2,
                          vertical: EnvoySpacing.xs),
                      child: SizedBox.square(
                        dimension: 12,
                        child: CircularProgressIndicator(
                          color: EnvoyColors.solidWhite,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    SizedBox(width: EnvoySpacing.xs),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const EnvoyIcon(
                      EnvoyIcons.rbf_boost,
                      color: Colors.white,
                    ),
                    const SizedBox(width: EnvoySpacing.xs),
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
    Color buttonColor = EnvoyColors.teal500.applyOpacity(active ? 1 : 0.5);

    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 28,
        padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.medium1,
        ),
        decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(EnvoySpacing.small)),
        child: child);
  }

  void _showRBFDialog(BuildContext context) async {
    if (_isLoading) {
      return;
    }
    if (ref.read(rbfSpendStateProvider) == null) {
      showNoBoostNoFundsDialog(context);
      return;
    }
    if (!(await EnvoyStorage()
            .checkPromptDismissed(DismissiblePrompt.rbfWarning)) &&
        context.mounted) {
      showEnvoyDialog(
        context: context,
        dialog: EnvoyDialog(
          paddingBottom: 0,
          content: RBFWarning(
            onConfirm: () {
              Navigator.pop(context);
              _showBoostScreen(context);
            },
          ),
        ),
      );
    } else {
      _showBoostScreen(context);
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
                "https://docs.foundation.xyz/envoy/envoy-menu/account/#boost-or-cancel-a-transaction"));
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
    dialog: EnvoyPopUp(
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
      title: S().coindetails_overlay_noBoostNoFunds_heading,
      showCloseButton: true,
      content: S().coindetails_overlay_noBoostNoFunds_subheading,
      learnMoreText: S().component_learnMore,
      onLearnMore: () {
        launchUrl(Uri.parse(
            "https://docs.foundation.xyz/troubleshooting/envoy/#boosting-or-canceling-transactions"));
      },
      primaryButtonLabel: S().component_continue,
      onPrimaryButtonTap: (context) {
        Navigator.of(context, rootNavigator: true).pop();
      },
    ),
  );
}
