// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/fee_rate.dart';
import 'package:ngwallet/ngwallet.dart';

class TransactionModel {
  //inputs for the transaction
  String note = "";
  SpendMode mode = SpendMode.normal;
  TransactionParams? transactionParams;

  //composed transaction state
  DraftTransaction? draftTransaction;
  BitcoinTransaction? transaction;
  String? changeOutPutTag;
  List<String> inputTags;

  //spend state flags
  bool uneconomicSpends = false;
  bool broadcastInProgress = false;
  bool hotWallet = false;
  bool canProceed = false;
  bool belowDustLimit = false;
  bool valid = false;
  bool loading = false;
  BroadcastProgress broadcastProgress = BroadcastProgress.staging;
  String? error;

  TransactionModel({
    this.note = "",
    this.mode = SpendMode.normal,
    this.transactionParams,
    this.draftTransaction,
    this.transaction,
    this.changeOutPutTag,
    this.inputTags = const [],
    this.uneconomicSpends = false,
    this.canProceed = false,
    this.hotWallet = false,
    this.belowDustLimit = false,
    this.valid = false,
    this.loading = false,
    this.broadcastProgress = BroadcastProgress.staging,
    this.error,
  });

  static TransactionModel copy(TransactionModel model) {
    return TransactionModel(
      error: model.error,
      draftTransaction: model.draftTransaction,
      transactionParams: model.transactionParams,
      valid: model.valid,
      loading: model.loading,
      canProceed: model.canProceed,
      belowDustLimit: model.belowDustLimit,
      broadcastProgress: model.broadcastProgress,
      transaction: model.transaction,
      changeOutPutTag: model.changeOutPutTag,
      inputTags: model.inputTags,
      mode: model.mode,
      note: model.note,
      hotWallet: model.hotWallet,
      uneconomicSpends: model.uneconomicSpends,
    );
  }

  TransactionModel clone() {
    return copy(this);
  }

  bool get canModify {
    if (hotWallet) {
      return true;
    }
    return !isFinalized;
  }

  bool get isFinalized {
    return draftTransaction?.isFinalized ?? false;
  }
}

class TransactionModeNotifier extends StateNotifier<TransactionModel> {
  final Ref ref;

  TransactionModeNotifier(super.state, {required this.ref});

  void _setErrorState(String errorMessage) {
    state = state.clone()
      ..loading = false
      ..error = errorMessage
      ..canProceed = false;
  }

  ({
    EnvoyAccount? account,
    int amount,
    FeeRate feeRate,
    EnvoyAccountHandler? handler,
    String sendTo,
    int spendableBalance,
    List<Output> utxos,
    String changeOutput,
    String note,
  }) _getCommonDeps() {
    final account = ref.read(selectedAccountProvider);
    final handler = account?.handler;
    final accountId = account?.id;
    return (
      account: account,
      amount: ref.read(spendAmountProvider),
      feeRate: ref.read(spendFeeRateProvider),
      handler: handler,
      sendTo: ref.read(spendAddressProvider),
      spendableBalance: ref.read(totalSpendableAmountProvider),
      utxos: accountId != null
          ? ref.read(getSelectedCoinsProvider(accountId)).toList()
          : <Output>[],
      changeOutput: ref.read(stagingTxChangeOutPutTagProvider) ?? "",
      note: ref.read(stagingTxNoteProvider) ?? "",
    );
  }

  Future<bool> setFee() async {
    var (
      account: account,
      amount: amount,
      feeRate: feeRate,
      handler: handler,
      sendTo: sendTo,
      spendableBalance: spendableBalance,
      utxos: utxos,
      changeOutput: changeOutput,
      note: note,
    ) = _getCommonDeps();

    if (handler == null) {
      return false;
    }

    if (sendTo.isEmpty ||
        amount == 0 ||
        account == null ||
        state.broadcastProgress == BroadcastProgress.inProgress) {
      return false;
    }

    ///If the user selected to spend max.
    ///subsequent validation calls will stick to the original amount user entered
    if (state.mode == SpendMode.sendMax) {
      //if user choose new coins,
      //we reset the mode to normal since the tx is no longer sendMax
      if ((state.transactionParams?.selectedOutputs ?? []).length !=
          utxos.length) {
        state = state.clone()..mode = SpendMode.normal;
      } else {
        amount = spendableBalance;
      }
    }
    try {
      final notes = ref.read(stagingTxNoteProvider);
      state = state.clone()
        ..error = null
        ..broadcastProgress = BroadcastProgress.staging
        ..loading = true;

      bool sendMax = spendableBalance == amount;
      final params = TransactionParams(
        address: sendTo,
        amount: BigInt.from(amount),
        feeRate: FeeRateSatPerKvb(field0: feeRate.asBigInt),
        selectedOutputs: utxos,
        note: notes,
        doNotSpendChange: false,
      );

      final draftTx = await handler.composePsbt(transactionParams: params);
      kPrint(
        "composePSBT : ${draftTx.transaction.txId} | isFinalized : ${draftTx.isFinalized}",
      );

      _updateWithPreparedTransaction(draftTx, params);

      if (sendMax) {
        int fee = state.draftTransaction?.transaction.fee.toInt() ?? 0;
        state = state.clone()
          ..mode = SpendMode.sendMax
          ..uneconomicSpends =
              (state.transactionParams?.amount.toInt() ?? 0 + fee) !=
                  spendableBalance;
      }
      return true;
    } catch (e, stack) {
      EnvoyReport().log("Spend", "Error composing transaction: $e");
      debugPrintStack(stackTrace: stack);
      ref.read(spendFeeRateProvider.notifier).state = FeeRate.fromBigInt(
        state.draftTransaction?.transaction.feeRate.field0 ?? BigInt.from(1000),
      );
      kPrint("setFee:Fallback fee rate: ${ref.read(spendFeeRateProvider)}");
      _handleComposeError(e);
    }
    return false;
  }

  Future setNote(String? stagingNote) async {
    var (
      account: account,
      amount: amount,
      feeRate: feeRate,
      handler: handler,
      sendTo: sendTo,
      spendableBalance: spendableBalance,
      utxos: utxos,
      changeOutput: changeOutput,
      note: note,
    ) = _getCommonDeps();

    TransactionParams? params = state.transactionParams;

    if (handler == null || params == null) {
      return;
    }
    params = TransactionParams(
      address: state.transactionParams!.address,
      amount: state.transactionParams!.amount,
      feeRate: state.transactionParams!.feeRate,
      selectedOutputs: state.transactionParams!.selectedOutputs,
      doNotSpendChange: state.transactionParams!.doNotSpendChange,
      note: stagingNote,
      tag: changeOutput,
    );
    DraftTransaction tx = state.draftTransaction!;
    DraftTransaction updatedTx = DraftTransaction(
      changeOutPutTag: state.changeOutPutTag,
      transaction: tx.transaction.copyWith(note: stagingNote),
      psbt: tx.psbt,
      inputTags: tx.inputTags,
      isFinalized: tx.isFinalized,
    );
    kPrint("NoteUpdated : ${updatedTx.transaction.note}");
    _updateWithPreparedTransaction(updatedTx, params);
  }

  void setTag(String? tag) async {
    var (
      account: account,
      amount: amount,
      feeRate: feeRate,
      handler: handler,
      sendTo: sendTo,
      spendableBalance: spendableBalance,
      utxos: utxos,
      changeOutput: changeOutput,
      note: note,
    ) = _getCommonDeps();
    final params = state.transactionParams;

    if (handler == null || params == null) {
      return;
    }
    final prams = TransactionParams(
      address: state.transactionParams!.address,
      amount: state.transactionParams!.amount,
      feeRate: state.transactionParams!.feeRate,
      selectedOutputs: state.transactionParams!.selectedOutputs,
      doNotSpendChange: state.transactionParams!.doNotSpendChange,
      note: note,
      tag: tag,
    );
    DraftTransaction tx = state.draftTransaction!;
    DraftTransaction updatedTx = DraftTransaction(
      transaction: tx.transaction.copyWith(
        outputs: tx.transaction.outputs.map((output) {
          if (output.keychain == KeyChain.internal) {
            return Output(
              txId: output.txId,
              vout: output.vout,
              amount: output.amount,
              isConfirmed: output.isConfirmed,
              address: output.address,
              tag: tag,
              date: output.date,
              keychain: output.keychain,
              doNotSpend: output.doNotSpend,
            );
          }
          return output;
        }).toList(),
      ),
      psbt: tx.psbt,
      changeOutPutTag: tag,
      inputTags: tx.inputTags,
      isFinalized: tx.isFinalized,
    );
    kPrint("Tag Updated : ${updatedTx.changeOutPutTag}");
    _updateWithPreparedTransaction(updatedTx, prams);
  }

  Future<bool> validate(
    ProviderContainer container, {
    bool settingFee = false,
  }) async {
    try {
      var (
        account: account,
        amount: amount,
        feeRate: feeRate,
        handler: handler,
        sendTo: sendTo,
        spendableBalance: spendableBalance,
        utxos: utxos,
        changeOutput: changeOutput,
        note: note,
      ) = _getCommonDeps();

      if (handler == null && account == null) {
        return false;
      }
      final network = account!.network;
      state = state.clone()..hotWallet = account.isHot;
      if (sendTo.isEmpty ||
          amount == 0 ||
          state.broadcastProgress == BroadcastProgress.inProgress) {
        return false;
      }

      try {
        state = state.clone()
          ..error = null
          ..broadcastProgress = BroadcastProgress.staging
          ..loading = true;
        bool sendMax = spendableBalance == amount;
        final slowRate = FeeRate.fromSatPerVb(Fees().slowRate(network));
        final params = TransactionParams(
          address: sendTo,
          amount: BigInt.from(amount),
          feeRate: FeeRateSatPerKvb(field0: slowRate.asBigInt),
          selectedOutputs: utxos,
          note: note,
          tag: changeOutput,
          doNotSpendChange: false,
        );

        if (handler == null) {
          kPrint("Handler is null");
          return false;
        }
        //calculate max fee only if we are not setting fee
        final feeCalcResult = await handler.getMaxFee(
          transactionParams: params,
        );
        final preparedTransaction = feeCalcResult.draftTransaction;

        // ngwallet's getMaxFee assumes the slow-rate input set, but
        // composePsbt may pick more / different inputs at higher rates
        // (especially when the user sends close to the full balance),
        // making the reported max overoptimistic. Verify by probing.
        final reportedMax = FeeRate.fromBigInt(feeCalcResult.maxFeeRate.field0)
            .clamp(FeeRate.fromSatPerKvb(0), FeeRate.fromSatPerVb(5000));
        final verifiedMax = await _findFeasibleMaxFee(
          handler: handler,
          baseParams: params,
          knownFeasibleSatPerKvb: slowRate.satPerKvb,
          candidateMaxSatPerKvb: reportedMax.satPerKvb,
        );

        container.read(feeChooserStateProvider.notifier).state =
            FeeChooserState(
          standardFeeRate: FeeRate.fromSatPerVb(Fees().slowRate(network)),
          fasterFeeRate: FeeRate.fromSatPerVb(Fees().fastRate(network)),
          minFeeRate: FeeRate.fromBigInt(feeCalcResult.minFeeRate.field0),
          maxFeeRate: verifiedMax,
        );

        _updateWithPreparedTransaction(preparedTransaction, params);

        if (sendMax) {
          int fee = state.draftTransaction?.transaction.fee.toInt() ?? 0;
          state = state.clone()
            ..mode = SpendMode.sendMax
            ..uneconomicSpends =
                (state.transactionParams?.amount.toInt() ?? 0 + fee) !=
                    spendableBalance;
        }

        return true;
      } catch (error, stackTrace) {
        if (kDebugMode) {
          debugPrintStack(stackTrace: stackTrace);
        }
        _handleComposeError(error);
      }
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
    return false;
  }

  /// Returns the highest fee rate at which a tx can actually be composed for
  /// [baseParams]. Probes the [candidateMaxSatPerKvb] reported by
  /// `getMaxFee` first; if that fails, binary-searches down to the highest
  /// feasible rate within ~1 sat/vB. [knownFeasibleSatPerKvb] is treated as a
  /// guaranteed lower bound (e.g. the slow rate that already composed).
  Future<FeeRate> _findFeasibleMaxFee({
    required EnvoyAccountHandler handler,
    required TransactionParams baseParams,
    required int knownFeasibleSatPerKvb,
    required int candidateMaxSatPerKvb,
  }) async {
    if (candidateMaxSatPerKvb <= knownFeasibleSatPerKvb) {
      return FeeRate.fromSatPerKvb(knownFeasibleSatPerKvb);
    }
    // Fast path: most sends succeed at the reported max.
    if (await _canComposeAt(handler, baseParams, candidateMaxSatPerKvb)) {
      return FeeRate.fromSatPerKvb(candidateMaxSatPerKvb);
    }
    int lo = knownFeasibleSatPerKvb;
    int hi = candidateMaxSatPerKvb;
    // Converge to within 1 sat/vB (= 1000 sat/kvB).
    while (hi - lo > 1000) {
      final mid = (lo + hi) ~/ 2;
      if (await _canComposeAt(handler, baseParams, mid)) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return FeeRate.fromSatPerKvb(lo);
  }

  Future<bool> _canComposeAt(
    EnvoyAccountHandler handler,
    TransactionParams baseParams,
    int satPerKvb,
  ) async {
    try {
      final params = TransactionParams(
        address: baseParams.address,
        amount: baseParams.amount,
        feeRate: FeeRateSatPerKvb(field0: BigInt.from(satPerKvb)),
        selectedOutputs: baseParams.selectedOutputs,
        note: baseParams.note,
        tag: baseParams.tag,
        doNotSpendChange: baseParams.doNotSpendChange,
      );
      await handler.composePsbt(transactionParams: params);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Compose a draft transaction at [feeRate] without mutating notifier state.
  /// Used by the fee chooser to show the real fee and detect unfeasible rates
  /// while the user is still scrolling.
  Future<({BitcoinTransaction? transaction, String? error})> previewFee(
    FeeRate feeRate,
  ) async {
    final account = ref.read(selectedAccountProvider);
    final handler = account?.handler;
    if (handler == null || account == null) {
      return (transaction: null, error: null);
    }
    final sendTo = ref.read(spendAddressProvider);
    var amount = ref.read(spendAmountProvider);
    final spendableBalance = ref.read(totalSpendableAmountProvider);
    final utxos = ref.read(getSelectedCoinsProvider(account.id)).toList();
    final notes = ref.read(stagingTxNoteProvider);

    if (sendTo.isEmpty ||
        amount == 0 ||
        state.broadcastProgress == BroadcastProgress.inProgress) {
      return (transaction: null, error: null);
    }

    // Preserve sendMax semantics from setFee — pin amount to the spendable
    // balance when the selected coin set hasn't changed — but don't mutate
    // state.
    if (state.mode == SpendMode.sendMax &&
        (state.transactionParams?.selectedOutputs ?? []).length ==
            utxos.length) {
      amount = spendableBalance;
    }

    try {
      final params = TransactionParams(
        address: sendTo,
        amount: BigInt.from(amount),
        feeRate: FeeRateSatPerKvb(field0: feeRate.asBigInt),
        selectedOutputs: utxos,
        note: notes,
        doNotSpendChange: false,
      );
      final draftTx = await handler.composePsbt(transactionParams: params);
      return (transaction: draftTx.transaction, error: null);
    } catch (e) {
      return (transaction: null, error: _composeErrorMessage(e));
    }
  }

  void reset() {
    state = emptyTransactionModel.clone();
  }

  Future broadcast(ProviderContainer ref) async {
    try {
      EnvoyAccount? account = ref.read(selectedAccountProvider);
      EnvoyAccountHandler? handler = account?.handler;
      if (account == null || handler == null || state.broadcastInProgress) {
        return;
      }
      state = state.clone()..broadcastInProgress = true;
      final server = Settings().electrumAddress(account.network);
      final syncManager = SyncManager();
      int? port = Settings().getTorPort(account.network, server);

      final _ = await EnvoyAccountHandler.broadcast(
        draftTransaction: state.draftTransaction!,
        electrumServer: server,
        torPort: port,
        validateDomain: Settings().validateDomain(server),
      );
      await handler.updateBroadcastState(
        draftTransaction: state.draftTransaction!,
      );
      syncManager.syncAccount(account);

      final feeRate = state.transactionParams?.feeRate ??
          FeeRateSatPerKvb(field0: BigInt.from(1000));
      if (Settings().subSatFeeEnabled &&
          !Settings().usingDefaultElectrumServer &&
          FeeRate.fromBigInt(feeRate.field0).isSubSat) {
        // Sub-sat txs may be silently dropped by the node if minrelaytxfee
        // is too high. Poll the wallet tx list for up to ~15s to confirm.
        final txId = state.draftTransaction!.transaction.txId;
        bool found = false;
        for (int i = 0; i < 8 && !found; i++) {
          await Future.delayed(const Duration(seconds: 2));
          syncManager.syncAccount(account);
          await Future.delayed(const Duration(milliseconds: 500));
          final txs = ref.read(transactionsProvider(account.id));
          if (txs.any((tx) => tx.txId == txId)) {
            found = true;
          }
        }
        if (!found) {
          state = state.clone()
            ..broadcastProgress = BroadcastProgress.subsatFailed;
          return false;
        }
      }

      state = state.clone()..broadcastProgress = BroadcastProgress.success;
      return true;
    } catch (e) {
      state = state.clone()..broadcastProgress = BroadcastProgress.failed;
      rethrow;
    } finally {
      state = state.clone()..broadcastInProgress = false;
    }
  }

  void resetBroadcastState() {
    state = state.clone()..broadcastProgress = BroadcastProgress.staging;
  }

  //for RBF review screen
  void setAmount(int amount) {
    // state = state.clone()..amount = amount;
  }

  void setProgressState(BroadcastProgress progress) {
    state = state.clone()..broadcastProgress = progress;
  }

  Future decodePSBT(ProviderContainer ref, CryptoPsbt decoded) async {
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    EnvoyAccountHandler? handler = account?.handler;
    if (account == null ||
        handler == null ||
        state.draftTransaction == null ||
        state.broadcastProgress == BroadcastProgress.inProgress) {
      return;
    }
    try {
      final preparedTx = await EnvoyAccountHandler.decodePsbt(
        draftTransaction: state.draftTransaction!,
        psbt: decoded.decoded,
      );
      kPrint(
        "Decoded PSBT: ${preparedTx.transaction.txId} | isFinalized : ${preparedTx.isFinalized}",
      );
      _updateWithPreparedTransaction(preparedTx, state.transactionParams);
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e, stack) {
      _setErrorState("Unable to decode PSBT");
      EnvoyReport().log(
        "Spend",
        "Unable to decode PSBT: $e",
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future decodePrimePsbt(ProviderContainer ref, Uint8List psbt) async {
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    EnvoyAccountHandler? handler = account?.handler;
    if (account == null ||
        handler == null ||
        state.draftTransaction == null ||
        state.broadcastProgress == BroadcastProgress.inProgress) {
      return;
    }
    try {
      final preparedTx = await EnvoyAccountHandler.decodePsbt(
        draftTransaction: state.draftTransaction!,
        psbt: psbt,
      );
      kPrint(
        "Decoded PSBT: ${preparedTx.transaction.txId} | isFinalized : ${preparedTx.isFinalized}",
      );
      _updateWithPreparedTransaction(preparedTx, state.transactionParams);
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e, stack) {
      _setErrorState("Unable to decode PSBT");
      EnvoyReport().log(
        "Spend",
        "Unable to decode PSBT: $e",
        stackTrace: stack,
      );
      rethrow;
    }
  }

  void _updateWithPreparedTransaction(
    DraftTransaction draftTransaction,
    TransactionParams? params,
  ) {
    state = state.clone()
      ..loading = false
      ..draftTransaction = draftTransaction
      ..transaction = draftTransaction.transaction
      ..changeOutPutTag = draftTransaction.changeOutPutTag
      ..inputTags = draftTransaction.inputTags
      ..valid = true
      ..transactionParams = params
      ..note = draftTransaction.transaction.note ?? ""
      ..canProceed = true;

    // Preserve user-chosen values if the freshly-composed draft doesn't
    // echo them back — otherwise re-composing a draft (e.g. after coin
    // control apply) silently clears the user's change-tag and note.
    final newChangeTag = draftTransaction.changeOutPutTag;
    if (newChangeTag != null && newChangeTag.isNotEmpty) {
      ref.read(stagingTxChangeOutPutTagProvider.notifier).state = newChangeTag;
    }
    final newNote = draftTransaction.transaction.note;
    if (newNote != null && newNote.isNotEmpty) {
      ref.read(stagingTxNoteProvider.notifier).state = newNote;
    }
  }

  void _handleComposeError(Object error) {
    if (error is TxComposeError) {
      EnvoyReport().log(
        "Spend",
        "Spend validation failed : ${error.field0.toString()}",
      );
    }
    _setErrorState(_composeErrorMessage(error));
  }

  String _composeErrorMessage(Object error) {
    if (error is! TxComposeError) {
      return S().send_keyboard_amount_insufficient_funds_info;
    }
    String msg = S().send_keyboard_amount_insufficient_funds_info;
    error.when(
      coinSelectionError: (_) {
        msg = S().send_keyboard_amount_insufficient_funds_info;
      },
      error: (err) {
        msg = err.contains("OutputBelowDustLimit")
            ? S().send_keyboard_amount_too_low_info
            : S().send_keyboard_amount_insufficient_funds_info;
      },
      insufficientFunds: (_) {
        msg = S().send_keyboard_amount_insufficient_funds_info;
      },
      insufficientFees: (_) {
        msg = "Insufficient fees";
      },
      insufficientFeeRate: (_) {
        msg = S().send_keyboard_amount_too_low_info;
      },
      lockedUtxoSelected: (_) {
        msg = "Selected coin is locked. Unlock it or pick another.";
      },
    );
    return msg;
  }
}
