// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/console.dart';
import 'package:file_picker/file_picker.dart';
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1),
                      child: Text(
                        S().send_review_subheader,
                        style: EnvoyTypography.body.copyWith(
                            color: envoy_colors.EnvoyColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
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

    // Delivers a decoded PSBT (from QR or file) back to the transaction
    // review screen, closing the scanner on the way out.
    Future<void> deliver(CryptoPsbt cryptoPsbt) async {
      navigator.pop(); // close scanner dialog
      await Future.delayed(const Duration(milliseconds: 100));

      goRouter.pop(); // pop qr_review
      goRouter.pop(
          cryptoPsbt); // pop scan (PsbtCard) → back to TxReview with result
    }

    final decoder = CryptoTxDecoder(
      onScan: (CryptoPsbt cryptoPsbt) => deliver(cryptoPsbt),
    );

    showScannerDialog(
      context: context,
      onBackPressed: (ctx) {
        Navigator.pop(ctx);
      },
      decoder: decoder,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              left: EnvoySpacing.medium1,
              right: EnvoySpacing.medium1,
              bottom: EnvoySpacing.large3,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _importSignedTransactionFromFile(deliver),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EnvoyIcon(
                    EnvoyIcons.file,
                    color: Colors.white,
                    size: EnvoyIconSize.small,
                  ),
                  const SizedBox(width: EnvoySpacing.xs),
                  Text(
                    S().signMessage_qrCamera_importFromFile,
                    style: EnvoyTypography.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _importSignedTransactionFromFile(
    Future<void> Function(CryptoPsbt) deliver,
  ) async {
    Uint8List? psbtBytes;
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null) {
        // Cancelled — leave the camera running.
        return;
      }
      final file = result.files.single;
      Uint8List? raw = file.bytes;
      if (raw == null && file.path != null) {
        raw = await File(file.path!).readAsBytes();
      }
      if (raw != null) {
        psbtBytes = _normalizePsbtBytes(raw);
      }
    } catch (e) {
      kPrint(e);
      psbtBytes = null;
    }

    if (!mounted) return;

    if (psbtBytes == null) {
      // Surface the failure on top of the still-open camera.
      _showCantReadSignedTxModal();
      return;
    }

    final cryptoPsbt = CryptoPsbt.fromPayload(psbtBytes)..decoded = psbtBytes;
    await deliver(cryptoPsbt);
  }

  Uint8List? _normalizePsbtBytes(Uint8List raw) {
    // Binary PSBT magic: "psbt" + 0xff.
    bool isPsbt(List<int> b) =>
        b.length >= 5 &&
        b[0] == 0x70 &&
        b[1] == 0x73 &&
        b[2] == 0x62 &&
        b[3] == 0x74 &&
        b[4] == 0xff;

    if (isPsbt(raw)) return Uint8List.fromList(raw);

    // Otherwise the file is text holding a hex- or base64-encoded PSBT.
    String text;
    try {
      text = utf8.decode(raw).trim();
    } catch (_) {
      return null;
    }
    text = text.replaceAll(RegExp(r'\s'), '');
    if (text.isEmpty) return null;

    // Hex-encoded PSBT (Passport writes "70736274ff...").
    if (text.length.isEven && RegExp(r'^[0-9a-fA-F]+$').hasMatch(text)) {
      try {
        final bytes = Uint8List(text.length ~/ 2);
        for (int i = 0; i < bytes.length; i++) {
          bytes[i] = int.parse(text.substring(i * 2, i * 2 + 2), radix: 16);
        }
        if (isPsbt(bytes)) return bytes;
      } catch (_) {}
    }

    // Base64-encoded PSBT (starts with "cHNidP").
    try {
      final bytes = base64.decode(text);
      if (isPsbt(bytes)) return Uint8List.fromList(bytes);
    } catch (_) {}

    return null;
  }

  void _showCantReadSignedTxModal() {
    showEnvoyPopUp(
      context,
      S().manual_setup_import_backup_fails_modal_subheading,
      S().component_continue,
      (ctx) {
        Navigator.of(ctx).pop();
      },
      title: S().send_qrReviewModalCantReadSignedTx_header,
      typeOfMessage: PopUpState.warning,
      icon: EnvoyIcons.alert,
      dismissible: false,
      showCloseButton: false,
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
