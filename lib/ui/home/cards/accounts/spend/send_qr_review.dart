// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/transaction_review_card.dart';
import 'package:envoy/ui/shield_path.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as envoy_colors;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/scanner/decoders/crypto_tx_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/ui/components/step_indicator.dart';
import 'package:envoy/ui/envoy_button.dart';

class SendQrReview extends ConsumerStatefulWidget {
  final DraftTransaction transaction;

  const SendQrReview(this.transaction, {super.key});

  @override
  ConsumerState<SendQrReview> createState() => _SendQrReviewState();
}

class _SendQrReviewState extends ConsumerState<SendQrReview> {
  @override
  Widget build(BuildContext context) {
    final account = ref.read(selectedAccountProvider);
    if (account == null) {
      return const SizedBox();
    }

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
                    envoy_colors.EnvoyColors.surface1
                  ])),
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
          topBarTitle: StepIndicator(currentStep: 2),
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
                      S().send_review_header,
                      style: EnvoyTypography.heading,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: EnvoySpacing.small),
                    Text(
                      S().send_review_subheader,
                      style: EnvoyTypography.body.copyWith(
                          color: envoy_colors.EnvoyColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: EnvoySpacing.medium2),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.medium1),
                        child: TransactionReviewCard(
                          account: account,
                          transaction: widget.transaction.transaction,
                          onTxDetailTap: () {
                            // _showTxDetailsPage(
                            //     context, ref, preparedTransaction);
                          },
                          canModifyPsbt: false,
                          loading: false,
                          address: widget.transaction.transaction.address,
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
                        S().send_qrReview_viewDetails,
                        onTap: () {
                          _showTxDetailsPage(context, ref, widget.transaction);
                        },
                        type: EnvoyButtonTypes.tertiary,
                      ),
                      SizedBox(
                        height: EnvoySpacing.small,
                      ),
                      EnvoyButton(
                        S().send_qrReview_scanSignedTransaction,
                        onTap: () {
                          _scanSignedTransaction(context);
                        },
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ],
    );
  }

  void _scanSignedTransaction(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    final goRouter = GoRouter.of(context);

    final decoder = CryptoTxDecoder(
      onScan: (CryptoPsbt cryptoPsbt) async {
        navigator.pop(); // close scanner dialog
        await Future.delayed(const Duration(milliseconds: 100));

        goRouter.pop(); // pop qr_review
        goRouter.pop(
            cryptoPsbt); // pop scan (PsbtCard) → back to TxReview with result
      },
    );

    showScannerDialog(
      context: context,
      onBackPressed: (ctx) {
        Navigator.pop(ctx);
      },
      decoder: decoder,
    );
  }

  void _showTxDetailsPage(BuildContext context, WidgetRef ref,
      DraftTransaction? preparedTransaction) {
    Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          if (preparedTransaction == null) {
            return const Center(
                child: Text("Unable to fetch Staged transaction"));
          }
          return StagingTxDetails(
            draftTransaction: preparedTransaction,
            canEdit: false,
            onTxNoteUpdated: () {
              ref
                  .read(spendTransactionProvider.notifier)
                  .setNote(ref.read(stagingTxNoteProvider));
            },
          );
        },
        transitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        opaque: false,
        fullscreenDialog: true));
  }
}
