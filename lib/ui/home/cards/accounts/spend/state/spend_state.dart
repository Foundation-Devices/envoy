// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:envoy/util/tuple.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

enum BroadcastProgress {
  inProgress,
  success,
  failed,
  staging,
}

//user can spend coins in 3 contexts, preselectCoins,edit from transaction
//review screen and edit from RBF screen
enum SpendOverlayContext {
  preselectCoins,
  rbfSelection,
  editCoins,
  hidden,
}

enum SpendMode {
  normal,
  rbf,
  sendMax, // this is the maximum amount we can send (possibly excluding some coins)
  sweep, // this is all coins but (possibly) less money sent
}

final draftTransactionProvider = Provider<DraftTransaction?>((ref) {
  return ref.watch(spendTransactionProvider).draftTransaction;
});

/// This model is used to track the state of the transaction composition
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
  bool _broadcastInProgress = false;
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
        uneconomicSpends: model.uneconomicSpends);
  }

  TransactionModel clone() {
    return copy(this);
  }

  bool get canModify {
    if (hotWallet) {
      return true;
    }
    return isFinalized;
  }

  bool get isFinalized {
    return draftTransaction?.isFinalized ?? false;
  }
}

double convertToFeeRate(num feeRate) {
  return (feeRate / 100000);
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
    num feeRate,
    EnvoyAccountHandler? handler,
    String sendTo,
    int spendableBalance,
    List<Output> utxos
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
    );
  }

  Future<bool> setFee(ProviderContainer container) async {
    var (
      account: account,
      amount: amount,
      feeRate: feeRate,
      handler: handler,
      sendTo: sendTo,
      spendableBalance: spendableBalance,
      utxos: utxos
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
        feeRate: BigInt.from(feeRate.toInt()),
        selectedOutputs: utxos,
        note: notes,
        doNotSpendChange: false,
      );

      final draftTx = await handler.composePsbt(transactionParams: params);
      kPrint("composePsbt : ${draftTx.transaction.txId} | isFinalized : ${draftTx.isFinalized}");

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
    } catch (e, stackTrace) {
      _setErrorState(e.toString());
    }
    return false;
  }

  void setNote(String note) async {
    var (
      account: account,
      amount: amount,
      feeRate: feeRate,
      handler: handler,
      sendTo: sendTo,
      spendableBalance: spendableBalance,
      utxos: utxos
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
      note: note,
      tag: state.transactionParams!.tag,
    );
    DraftTransaction tx = state.draftTransaction!;
    DraftTransaction updatedTx = DraftTransaction(
        transaction: tx.transaction.copyWith(note: note),
        psbtBase64: tx.psbtBase64,
        inputTags: tx.inputTags,
        isFinalized: tx.isFinalized);
    _updateWithPreparedTransaction(updatedTx, params);
  }

  void initWithRbfState(){

  }

  void setTag(String? tag) async {
    var (
      account: account,
      amount: amount,
      feeRate: feeRate,
      handler: handler,
      sendTo: sendTo,
      spendableBalance: spendableBalance,
      utxos: utxos
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
      note: state.transactionParams!.note,
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
                  doNotSpend: output.doNotSpend);
            }
            return output;
          }).toList(),
        ),
        psbtBase64: tx.psbtBase64,
        changeOutPutTag: tag,
        inputTags: tx.inputTags,
        isFinalized: tx.isFinalized);
    _updateWithPreparedTransaction(updatedTx, prams);
  }

  Future<bool> validate(ProviderContainer container,
      {bool settingFee = false}) async {
    var (
      account: account,
      amount: amount,
      feeRate: feeRate,
      handler: handler,
      sendTo: sendTo,
      spendableBalance: spendableBalance,
      utxos: utxos
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
      final notes = container.read(stagingTxNoteProvider);
      state = state.clone()
        ..error = null
        ..broadcastProgress = BroadcastProgress.staging
        ..loading = true;
      //remove if there is any duplicates
      bool sendMax = spendableBalance == amount;
      final params = TransactionParams(
          address: sendTo,
          amount: BigInt.from(amount),
          feeRate: BigInt.from(Fees().slowRate(network) * 100000),
          selectedOutputs: utxos,
          note: notes,
          doNotSpendChange: false);

      //calculate max fee only if we are not setting fee
      final feeCalcResult = await handler!.getMaxFee(transactionParams: params);
      final preparedTransaction = feeCalcResult.draftTransaction;

      //update the fee rate
      container.read(feeChooserStateProvider.notifier).state = FeeChooserState(
          standardFeeRate: Fees().slowRate(network) * 100000,
          fasterFeeRate: Fees().fastRate(network) * 100000,
          minFeeRate: feeCalcResult.minFeeRate.toInt(),
          maxFeeRate: feeCalcResult.maxFeeRate.toInt().clamp(2, 5000));

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
      String errorMessage = error.toString();
      if (error is ComposeTxError) {
        ComposeTxError composeTxError = error;
        composeTxError.when(
          coinSelectionError: (field0) {
            // Handle coin selection error
            errorMessage = S().send_keyboard_amount_insufficient_funds_info;
          },
          error: (err) {
            // Handle generic error
            debugPrint("Error: $err");
            errorMessage = S().send_keyboard_amount_enter_valid_address;
          },
          insufficientFunds: (field0) {
            // Handle insufficient funds
            debugPrint("Insufficient funds: $field0");
            errorMessage = S().send_keyboard_amount_insufficient_funds_info;
          },
          insufficientFees: (field0) {
            // Handle insufficient fees
            debugPrint("Insufficient fees: $field0");
            errorMessage = S().send_keyboard_amount_too_low_info;
          },
          insufficientFeeRate: (field0) {
            // Handle insufficient fee rate
            debugPrint("Insufficient fee rate: $field0");
            errorMessage = S().send_keyboard_amount_too_low_info;
          },
        );
      } else {
        container.read(spendValidationErrorProvider.notifier).state =
            S().send_keyboard_amount_insufficient_funds_info;
      }
      _setErrorState(errorMessage.toString());
    }
    return false;
  }

  void reset() {
    state = emptyTransactionModel.clone();
  }

  Future broadcast(ProviderContainer ref) async {
    try {
      EnvoyAccount? account = ref.read(selectedAccountProvider);
      EnvoyAccountHandler? handler = account?.handler;
      if (account == null || handler == null || state._broadcastInProgress) {
        return;
      }
      state = state.clone().._broadcastInProgress = true;
      final server = SyncManager.getElectrumServer(account.network);
      final syncManager = NgAccountManager().syncManager;
      int? port = Settings().getPort(account.network);
      if (port == -1) {
        port = null;
      }
      final _ = await EnvoyAccountHandler.broadcast(
        draftTransaction: state.draftTransaction!,
        electrumServer: server,
        torPort: port,
      );
      await handler.updateBroadcastState(
          draftTransaction: state.draftTransaction!);
      syncManager.syncAccount(account);
      Future.delayed(const Duration(seconds: 100));
      state = state.clone()..broadcastProgress = BroadcastProgress.success;
      return true;
    } catch (e) {
      state = state.clone()..broadcastProgress = BroadcastProgress.failed;
      rethrow;
    } finally {
      state = state.clone().._broadcastInProgress = false;
    }
  }

  resetBroadcastState() {
    state = state.clone()..broadcastProgress = BroadcastProgress.staging;
  }

//for RBF review screen
  void setAmount(int amount) {
    // state = state.clone()..amount = amount;
  }

  void setProgressState(BroadcastProgress progress) {
    state = state.clone()..broadcastProgress = progress;
  }

  Future decodePsbt(ProviderContainer ref, CryptoPsbt decoded) async {
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
          psbtBase64: decoded.decoded);
      kPrint("Decoded PSBT: ${preparedTx.transaction.txId} | isFinalized : ${preparedTx.isFinalized}");
      _updateWithPreparedTransaction(preparedTx, state.transactionParams);
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      state = state.clone()
        ..loading = false
        ..error = e.toString();
      rethrow;
    }
  }

  _updateWithPreparedTransaction(
      DraftTransaction draftTransaction, TransactionParams? params) {
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
  }
}

final emptyTransactionModel = TransactionModel(
  transaction: null,
  draftTransaction: null,
  valid: false,
  loading: false,
);

final spendTransactionProvider =
    StateNotifierProvider<TransactionModeNotifier, TransactionModel>((ref) {
  return TransactionModeNotifier(
      TransactionModel(
        transaction: null,
        draftTransaction: null,
        valid: false,
        loading: false,
      ),
      ref: ref);
});

// Providers needed to show the fee/inputs warning
final coinSelectionChangedProvider = StateProvider<bool>((ref) => false);

// We reset this once user exit tx_review and it is set, to true, once, for the session
final userSelectedCoinsThisSessionProvider =
    StateProvider<bool>((ref) => false);
final userHasChangedFeesProvider = StateProvider<bool>((ref) => false);
final transactionInputsChangedProvider = StateProvider<bool>((ref) => false);

final spendEditModeProvider =
    StateProvider<SpendOverlayContext>((ref) => SpendOverlayContext.hidden);
final spendAddressProvider = StateProvider((ref) => "");
final spendValidationErrorProvider = StateProvider<String?>((ref) => null);
final spendAmountProvider = StateProvider((ref) => 0);

final uneconomicSpendsProvider = Provider<bool>(
    (ref) => ref.watch(spendTransactionProvider).uneconomicSpends);

/// these providers will extract receive Address and Amount from the staging transaction
final receiveOutputProvider = Provider<Tuple<String, int>?>((ref) {
  BitcoinTransaction? preparedTransaction = ref.watch(spendTransactionProvider
      .select((value) => value.draftTransaction?.transaction));
  if (preparedTransaction == null) {
    return null;
  }

  ///output that is destination output
  Output? out = preparedTransaction.outputs.firstWhereOrNull(
      (element) => element.address == preparedTransaction.address);

  if (out == null) {
    return null;
  }
  return Tuple(preparedTransaction.address, out.amount.toInt());
});

final spendInputTagsProvider = Provider<List<Tuple<CoinTag, Coin>>?>((ref) {
  EnvoyAccount? account = ref.watch(selectedAccountProvider);
  BitcoinTransaction? preparedTransaction = ref.watch(spendTransactionProvider
      .select((value) => value.draftTransaction?.transaction));

  if (account == null || preparedTransaction == null) {
    return null;
  }
  //TODO: implement ngwallet
  List<Tuple<CoinTag, Coin>> items = [];
  return items;
});

///returns the total spendable amount for selected account and selected coins
///if the user selected coins then it will return the sum of selected coins
///since total amount calculation rely on CoinRepository.getBlockedCoins which is a Future
///
final _totalSpendableAmountProvider = FutureProvider<int>((ref) async {
  final account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return 0;
  }
  final selectedUtxos = ref.watch(getSelectedCoinsProvider(account.id));
  if (selectedUtxos.isNotEmpty) {
    int amount = 0;
    for (var element in selectedUtxos) {
      amount = amount + element.amount.toInt();
    }
    return amount;
  }
  final lockedCoins = ref
      .read(outputsProvider(account.id))
      .where((element) => element.doNotSpend)
      .toList();
  final blockedAmount = lockedCoins.fold(
      0, (previousValue, element) => previousValue + element.amount.toInt());
  return account.balance.toInt() - blockedAmount;
});

///listens to _totalSpendableAmountProvider provider and updates the value
final totalSpendableAmountProvider = Provider<int>((ref) {
  return ref.watch(_totalSpendableAmountProvider).value ?? 0;
});

/// returns selected coins for a given account
final getTotalSelectedAmount = Provider.family<int, String>((ref, accountId) {
  List<Output> outputs = ref.watch(getSelectedCoinsProvider(accountId));
  return outputs.fold(
      0, (previousValue, element) => previousValue + element.amount.toInt());
});

///these providers are used to track notes and change output tag for staging transaction
///because the transaction needs to be broadcast tx firs and then we can store these values to the database
final stagingTxChangeOutPutTagProvider = StateProvider<Tag?>((ref) => null);
final stagingTxNoteProvider = StateProvider<String?>((ref) => null);

///returns if the user has selected coins
final isCoinsSelectedProvider = Provider<bool>((ref) {
  final account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return false;
  }
  final selectedUtxos =
      ref.watch(getSelectedCoinsProvider(account.id)).toList();
  return selectedUtxos.isNotEmpty;
});

/// validates basic spend form validation
/// the [_spendValidationProviderFuture] is private to but...
/// we will use that in  [spendValidationProvider]. this is to reduce future builders in widget side
final _spendValidationProviderFuture = FutureProvider<bool>((ref) async {
  final address = ref.watch(spendAddressProvider);
  final amount = ref.watch(spendAmountProvider);
  final account = ref.read(selectedAccountProvider);
  final spendableBalance = ref.watch(totalSpendableAmountProvider);

  if (account == null) {
    return false;
  }

  bool validAddress = await EnvoyAccountHandler.validateAddress(
      address: address, network: account.network);
  if (!validAddress) {
    ref.read(spendValidationErrorProvider.notifier).state =
        S().send_keyboard_amount_enter_valid_address;
    return false;
  } else {
    ref.read(spendValidationErrorProvider.notifier).state = null;
  }
  bool validAmount = !(amount > spendableBalance);
  if (!validAmount) {
    ref.read(spendValidationErrorProvider.notifier).state =
        S().send_keyboard_amount_insufficient_funds_info;
    return false;
  } else {
    ref.read(spendValidationErrorProvider.notifier).state = null;
  }
  return validAddress && validAmount;
});

final spendValidationProvider = Provider<bool>((ref) {
  return ref.watch(_spendValidationProviderFuture).value ?? false;
});

/// returns selected coins for a given account
final getSelectedCoinsProvider =
    Provider.family<List<Output>, String>((ref, accountId) {
  List<Output> outputs = ref.watch(outputsProvider(accountId));
  Set<String> selectedCoinIds = ref.watch(coinSelectionStateProvider);
  return outputs
      .where((element) => selectedCoinIds.contains(element.getId()))
      .toList();
});

final showSpendRequirementOverlayProvider = Provider<bool>(
  (ref) {
    EnvoyAccount? account = ref.watch(selectedAccountProvider);
    if (account == null) {
      return false;
    }
    return ref.watch(getTotalSelectedAmount(account.id)) != 0;
  },
);

///clears all the spend related states. this is need once the user exits the spend screen or account details...
///or when the user finishes the spend flow
void clearSpendState(ProviderContainer ref) {
  ref.read(spendAddressProvider.notifier).state = "";
  ref.read(spendAmountProvider.notifier).state = 0;
  //reset fee to default
  ref.read(spendFeeRateProvider.notifier).state = Fees().slowRate(
    ref.read(selectedAccountProvider)!.network,
  );
  ref.read(stagingTxChangeOutPutTagProvider.notifier).state = null;
  ref.read(stagingTxNoteProvider.notifier).state = null;
  ref.read(spendFeeProcessing.notifier).state = false;
  ref.read(sendScreenUnitProvider.notifier).state =
      Settings().displayUnit == DisplayUnit.btc
          ? AmountDisplayUnit.btc
          : AmountDisplayUnit.sat;
  ref.read(displayFiatSendAmountProvider.notifier).state = 0;
}
