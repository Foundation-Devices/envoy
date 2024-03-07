// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:envoy/util/tuple.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/wallet.dart';

enum BroadcastProgress {
  inProgress,
  success,
  failed,
  staging,
}

enum SpendMode {
  normal,
  sendMax, // this is the maximum amount we can send (possibly excluding some coins)
  sweep, // this is all coins but (possibly) less money sent
}

/// This model is used to track the state of the transaction composition
class TransactionModel {
  String sendTo;
  int amount;
  double feeRate;
  Psbt? psbt;
  RawTransaction? rawTransaction;
  List<Utxo>? utxos;
  bool valid = false;
  bool canProceed = false;
  bool belowDustLimit = false;
  bool loading = false;
  BroadcastProgress broadcastProgress = BroadcastProgress.staging;
  bool isPSBTFinalized = false;
  String? error;
  SpendMode mode = SpendMode.normal;
  bool uneconomicSpends = false;

  TransactionModel(
      {required this.sendTo,
      required this.amount,
      required this.feeRate,
      this.utxos,
      this.psbt,
      this.rawTransaction,
      this.valid = false,
      this.loading = false,
      this.belowDustLimit = false,
      this.canProceed = false,
      this.broadcastProgress = BroadcastProgress.staging,
      this.error,
      this.mode = SpendMode.normal,
      this.uneconomicSpends = false});

  static TransactionModel copy(TransactionModel model) {
    return TransactionModel(
        sendTo: model.sendTo,
        amount: model.amount,
        feeRate: model.feeRate,
        error: model.error,
        utxos: model.utxos,
        psbt: model.psbt,
        rawTransaction: model.rawTransaction,
        valid: model.valid,
        loading: model.loading,
        canProceed: model.canProceed,
        belowDustLimit: model.belowDustLimit,
        broadcastProgress: model.broadcastProgress,
        mode: model.mode,
        uneconomicSpends: model.uneconomicSpends);
  }

  TransactionModel clone() {
    return copy(this);
  }
}

double convertToFeeRate(num feeRate) {
  return (feeRate / 100000);
}

class TransactionModeNotifier extends StateNotifier<TransactionModel> {
  TransactionModeNotifier(super.state);

  Future<bool> validate(ProviderContainer container,
      {bool settingFee = false}) async {
    final String sendTo = container.read(spendAddressProvider);
    final int spendableBalance = container.read(totalSpendableAmountProvider);
    final num feeRate = container.read(spendFeeRateProvider);
    final Account? account = container.read(selectedAccountProvider);
    int amount = container.read(spendAmountProvider);

    if (sendTo.isEmpty ||
        amount == 0 ||
        account == null ||
        state.broadcastProgress == BroadcastProgress.inProgress) {
      return false;
    }
    List<Utxo> utxos = container
        .read(getSelectedCoinsProvider(account.id!))
        .map((e) => e.utxo)
        .toList();

    ///If the user selected to spend max.
    ///subsequent validation calls will stick to the original amount user entered
    if (state.mode == SpendMode.sendMax) {
      //if user choose new coins, we reset the mode to normal since the tx is no longer sendMax
      if ((state.utxos ?? []).length != utxos.length) {
        state = state.clone()..mode = SpendMode.normal;
      } else {
        amount = spendableBalance;
      }
    }

    try {
      state = state.clone()
        ..sendTo = sendTo
        ..utxos = utxos
        ..feeRate = feeRate.toDouble()
        ..loading = true;

      List<Utxo>? dontSpend = utxos.isEmpty
          ? null
          : account.wallet.utxos
              .where((element) => !utxos.map((e) => e.id).contains(element.id))
              .toList();

      List locked = await CoinRepository().getBlockedCoins();

      for (var utxo in account.wallet.utxos) {
        if (locked.contains(utxo.id)) {
          dontSpend ??= [];
          dontSpend.add(utxo);
        }
      }

      //remove if there is any duplicates
      dontSpend = dontSpend?.unique((e) => e.id).toList();
      container.read(dontSpendCoinsProvider.notifier).state = dontSpend ?? [];

      bool sendMax = spendableBalance == amount;

      Psbt psbt = await getPsbt(
          convertToFeeRate(feeRate.toInt()), account, sendTo, amount,
          dontSpend: dontSpend, mustSpend: null);

      //calculate max fee only if we are not setting fee
      if (!settingFee) {
        int maxFeeRate = await account.wallet
            .getMaxFeeRate(state.sendTo, amount, dontSpendUtxos: dontSpend);
        container.read(feeChooserStateProvider.notifier).state =
            FeeChooserState(
                standardFeeRate:
                    Fees().slowRate(account.wallet.network) * 100000,
                fasterFeeRate: Fees().fastRate(account.wallet.network) * 100000,
                minFeeRate: 1,
                maxFeeRate: maxFeeRate.clamp(2, 5000));
        kPrint("Max fee Rate $maxFeeRate");
      }

      ///get max fee rate that we can use on this transaction
      ///when we are sending max, this is basically infinite

      ///Create RawTransaction from PSBT. RawTransaction will include inputs and outputs.
      /// this is used to show staging transaction details
      RawTransaction rawTransaction = await account.wallet
          .decodeWalletRawTx(psbt.rawTx, account.wallet.network);

      state = state.clone()
        ..psbt = psbt
        ..loading = false
        ..rawTransaction = rawTransaction
        ..valid = true;

      ///get all input that selected for the current PSBT
      final utxoSet = rawTransaction.inputs
          .map((e) => "${e.previousOutputHash}:${e.previousOutputIndex}");

      /// in the case of sendMax we need, receive amount might be different from the amount we are sending
      /// Make sure psbt is the source of truth for the amount
      bool foundOutput = false;
      for (var output in rawTransaction.outputs) {
        if (output.path == TxOutputPath.NotMine) {
          foundOutput = true;
          state = state.clone()..amount = output.amount;
        }
      }

      ///if user is trying to send it themself
      if (!foundOutput) {
        for (var output in rawTransaction.outputs) {
          if (output.path == TxOutputPath.External) {
            state = state.clone()..amount = output.amount;
          }
        }
      }

      if (sendMax) {
        state = state.clone()
          ..mode = SpendMode.sendMax
          ..uneconomicSpends = (state.amount + psbt.fee) != spendableBalance;
      }

      ///If the UTXO selection is exclusively from one tag, the change needs to go to that tag.
      container.read(coinsTagProvider(account.id ?? "")).forEach((element) {
        ///if current inputs are part of a single tag, use that tag as change output tag
        if (element.coinsId.containsAll(utxoSet)) {
          container.read(stagingTxChangeOutPutTagProvider.notifier).state =
              element;
        }
      });
      return true;
    } on InsufficientFunds {
      // FIXME: This is to avoid redraws while we search for a valid PSBT
      // FIXME: See setFee in fee_slider
      if (!settingFee) {
        state = state.clone()
          ..loading = false
          ..rawTransaction = null
          ..psbt = null
          ..canProceed = false;
      }
      container.read(spendValidationErrorProvider.notifier).state =
          S().send_keyboard_amount_insufficient_funds_info;
    } on BelowDustLimit {
      state = state.clone()
        ..loading = false
        ..psbt = null
        ..rawTransaction = null
        ..belowDustLimit = true
        ..canProceed = false;
      container.read(spendValidationErrorProvider.notifier).state =
          S().send_keyboard_amount_too_low_info;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        kPrint("Error $e");
        debugPrintStack(stackTrace: stackTrace);
      }

      state = state.clone()
        ..loading = false
        ..psbt = null
        ..rawTransaction = null
        ..error = e.toString();
    }
    return false;
  }

  void reset() {
    state = emptyTransactionModel.clone();
  }

  /// used to update finalized PSBT ( for hardware wallet signing)
  void updateWithFinalPSBT(Psbt psbt) {
    state = state.clone()
      ..psbt = psbt
      ..loading = false
      ..broadcastProgress = BroadcastProgress.staging

      /// to prevent the user from editing the transaction, this is used when user scans signed PSBT
      ..isPSBTFinalized = true
      ..valid = true;
  }

  Future broadcast(ProviderContainer ref) async {
    try {
      Account? account = ref.read(selectedAccountProvider);
      if (!(account != null &&
          state.psbt != null &&
          (state.broadcastProgress != BroadcastProgress.success ||
              state.broadcastProgress != BroadcastProgress.inProgress))) {
        return;
      }
      final coins = ref.read(coinsProvider(account.id!));
      final coinTags = ref.read(coinsTagProvider(account.id!));
      final rawTx = state.rawTransaction!;

      final inputCoins = rawTx.inputs.map((input) {
        return coins.firstWhere((element) => element.id == input.id);
      }).toList();

      // Increment the change index before broadcasting
      await account.wallet.getChangeAddress();
      state = state.clone()..broadcastProgress = BroadcastProgress.inProgress;
      Psbt psbt = state.psbt!;
      //Broadcast transaction
      int port = Settings().getPort(account.wallet.network);
      await account.wallet.broadcastTx(
          Settings().electrumAddress(account.wallet.network), port, psbt.rawTx);

      await EnvoyStorage().addPendingTx(
          psbt.txid,
          account.id!,
          DateTime.now(),
          TransactionType.pending,
          psbt.sent + psbt.fee,
          psbt.fee,
          state.sendTo);

      String? note = ref.read(stagingTxNoteProvider);
      CoinTag? changeOutPutTag = ref.read(stagingTxChangeOutPutTagProvider);
      Tuple<String, int>? changeOutPut = ref.read(changeOutputProvider);
      RawTransaction? transaction = ref.read(rawTransactionProvider);

      await EnvoyStorage().addTxNote(note!, psbt.txid);

      try {
        /// add change output to selected/default tag
        if (transaction != null &&
            changeOutPutTag != null &&
            changeOutPut != null) {
          ///store change tag if it is not already stored
          CoinTag tag = ref.read(stagingTxChangeOutPutTagProvider)!;
          final tags = ref
              .read(coinsTagProvider(ref.read(selectedAccountProvider)!.id!));

          for (var coin in inputCoins) {
            final coinTag = coinTags.firstWhereOrNull((element) =>
                element.coinsId.contains(coin.id) &&
                element.account == account.id);
            await EnvoyStorage().addCoinHistory(
                coin.id,
                InputCoinHistory(
                    account.id!,
                    coinTag?.name ?? S().account_details_untagged_card,
                    psbt.txid,
                    coin));
          }

          ///add change tag if its new and if it is not already added to the database
          if (tags.map((e) => e.id).contains(tag.id) == false &&
              tag.untagged == false) {
            await CoinRepository().addCoinTag(tag);
            await Future.delayed(const Duration(milliseconds: 100));
          }

          int index = transaction.outputs.indexWhere((element) =>
              element.address == changeOutPut.item1 &&
              element.amount == changeOutPut.item2);

          ///add change tag to the database
          if (index != -1) {
            changeOutPutTag.addCoin(Coin(
                Utxo(txid: psbt.txid, vout: index, value: changeOutPut.item2),
                account: account.id!));
            await CoinRepository().updateCoinTag(changeOutPutTag);
            final _ = ref.refresh(accountsProvider);
            await Future.delayed(const Duration(seconds: 1));
            ref.refresh(coinsTagProvider(account.id!));
          }
        }
      } catch (e) {
        kPrint(e);
      }
      ref.read(stagingTxChangeOutPutTagProvider.notifier).state = null;
      ref.read(stagingTxNoteProvider.notifier).state = null;
      ref.read(spendEditModeProvider.notifier).state = false;

      /// wait for bdk to update the transaction list and utxos list
      await Future.delayed(const Duration(seconds: 2));

      /// clear staging transaction states
      state = state.clone()..broadcastProgress = BroadcastProgress.success;
      return true;
    } catch (e) {
      state = state.clone()..broadcastProgress = BroadcastProgress.failed;
      rethrow;
    }
  }

  resetBroadcastState() {
    state = state.clone()..broadcastProgress = BroadcastProgress.staging;
  }

  //for RBF review screen
  void setAmount(int amount) {
    state = state.clone()..amount = amount;
  }
}

final emptyTransactionModel =
    TransactionModel(sendTo: "", amount: 0, feeRate: 1);
final spendTransactionProvider =
    StateNotifierProvider<TransactionModeNotifier, TransactionModel>(
        (ref) => TransactionModeNotifier(emptyTransactionModel));

final dontSpendCoinsProvider = StateProvider<List<Utxo>>((ref) {
  ref.listenSelf((previous, next) {
    if (previous == null) {
      return;
    }

    final previousIds = previous.map((e) => e.id).toList();
    final nextIds = next.map((e) => e.id).toList();

    if (!listEquals(previousIds, nextIds)) {
      ref.read(coinSelectionChangedProvider.notifier).state = true;
    }
  });
  return [];
});

// Providers needed to show the fee/inputs warning
final coinSelectionChangedProvider = StateProvider<bool>((ref) => false);

// We reset this once user exit tx_review and it is set, to true, once, for the session
final userSelectedCoinsThisSessionProvider =
    StateProvider<bool>((ref) => false);
final userHasChangedFeesProvider = StateProvider<bool>((ref) => false);
final transactionInputsChangedProvider = StateProvider<bool>((ref) => false);

final spendEditModeProvider = StateProvider((ref) => false);
final spendAddressProvider = StateProvider((ref) => "");
final spendValidationErrorProvider = StateProvider<String?>((ref) => null);
final spendAmountProvider = StateProvider((ref) => 0);

final rawTransactionProvider = Provider<RawTransaction?>((ref) {
  ref.listenSelf((previous, next) {
    if (previous == null || next == null) {
      return;
    }

    final previousIds = previous.inputs
        .map((e) => "${e.previousOutputHash}:${e.previousOutputIndex}")
        .toList();
    final nextIds = next.inputs
        .map((e) => "${e.previousOutputHash}:${e.previousOutputIndex}")
        .toList();

    if (!listEquals(previousIds, nextIds)) {
      ref.read(transactionInputsChangedProvider.notifier).state = true;
    }
  });
  return ref.watch(spendTransactionProvider).rawTransaction;
});

final uneconomicSpendsProvider = Provider<bool>(
    (ref) => ref.watch(spendTransactionProvider).uneconomicSpends);

/// these providers will extract change-output Address and Amount from the staging transaction
final changeOutputProvider = Provider<Tuple<String, int>?>((ref) {
  RawTransaction? rawTx = ref.watch(rawTransactionProvider);
  String spendAddress = ref.watch(spendAddressProvider);
  if (rawTx == null) {
    return null;
  }

  ///outputs that are not the destination output
  List<RawTransactionOutput> outs = rawTx.outputs
      .where((element) => element.address != spendAddress)
      .toList();

  if (outs.isEmpty) {
    return null;
  }

  ///take the output that is not the destination output
  return Tuple(outs.first.address, outs.first.amount);
});

/// these providers will extract receive Address and Amount from the staging transaction
final receiveOutputProvider = Provider<Tuple<String, int>?>((ref) {
  RawTransaction? rawTx = ref.watch(rawTransactionProvider);
  String spendAddress = ref.watch(spendAddressProvider);
  if (rawTx == null) {
    return null;
  }

  ///output that is destination output
  List<RawTransactionOutput> outs = rawTx.outputs
      .where((element) =>
          element.address.toLowerCase() == spendAddress.toLowerCase())
      .toList();

  if (outs.isEmpty) {
    return null;
  }
  return Tuple(outs.first.address, outs.first.amount);
});

/// these providers will extract receive and change Amount from the staging transaction
final receiveAmountProvider =
    Provider<int>((ref) => ref.watch(receiveOutputProvider)?.item2 ?? 0);
final changeAmountProvider =
    Provider<int>((ref) => ref.watch(changeOutputProvider)?.item2 ?? 0);

final spendInputTagsProvider = Provider<List<Tuple<CoinTag, Coin>>?>((ref) {
  RawTransaction? rawTx = ref.watch(rawTransactionProvider);
  Account? account = ref.watch(selectedAccountProvider);
  if (account == null || rawTx == null) {
    return null;
  }
  List<CoinTag> coinTags = ref.read(coinsTagProvider(account.id!));
  List<String> inputs = rawTx.inputs
      .map((e) => "${e.previousOutputHash}:${e.previousOutputIndex}")
      .toList();
  List<Tuple<CoinTag, Coin>> items = [];
  for (var coinTag in coinTags) {
    for (var coin in coinTag.coins) {
      if (inputs.contains(coin.id)) {
        items.add(Tuple(coinTag, coin));
      }
    }
  }
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
  final selectedUtxos = ref
      .watch(getSelectedCoinsProvider(account.id!))
      .map((e) => e.utxo)
      .toList();
  if (selectedUtxos.isNotEmpty) {
    int amount = 0;
    for (var element in selectedUtxos) {
      amount = amount + element.value;
    }
    return amount;
  }
  final lockedCoinsIds = await CoinRepository().getBlockedCoins();
  final lockedCoins = account.wallet.utxos
      .where((element) => lockedCoinsIds.contains(element.id))
      .toList();
  final blockedAmount = lockedCoins.fold(
      0, (previousValue, element) => previousValue + element.value);
  return account.wallet.balance - blockedAmount;
});

///listens to _totalSpendableAmountProvider provider and updates the value
final totalSpendableAmountProvider = Provider<int>((ref) {
  return ref.watch(_totalSpendableAmountProvider).value ?? 0;
});

/// returns selected coins for a given account
final getTotalSelectedAmount = Provider.family<int, String>((ref, accountId) {
  List<Coin> coins = ref.watch(getSelectedCoinsProvider(accountId));
  return coins.fold(
      0, (previousValue, element) => previousValue + element.amount);
});

///these providers are used to track notes and change output tag for staging transaction
///because the transaction needs to be broadcast tx firs and then we can store these values to the database
final stagingTxChangeOutPutTagProvider = StateProvider<CoinTag?>((ref) => null);
final stagingTxNoteProvider = StateProvider<String?>((ref) => null);

///returns if the user has selected coins
final isCoinsSelectedProvider = Provider<bool>((ref) {
  final account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return false;
  }
  final selectedUtxos = ref
      .watch(getSelectedCoinsProvider(account.id!))
      .map((e) => e.utxo)
      .toList();
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

  bool validAddress = await account.wallet.validateAddress(address);
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
    Provider.family<List<Coin>, String>((ref, accountId) {
  List<Coin> coins = ref.watch(coinsProvider(accountId));
  Set<String> selectedCoinIds = ref.watch(coinSelectionStateProvider);
  return coins
      .where((element) => selectedCoinIds.contains(element.id))
      .toList();
});

final showSpendRequirementOverlayProvider = Provider<bool>(
  (ref) {
    Account? account = ref.watch(selectedAccountProvider);
    if (account == null) {
      return false;
    }
    return ref.watch(getTotalSelectedAmount(account.id!)) != 0;
  },
);

///clears all the spend related states. this is need once the user exits the spend screen or account details...
///or when the user finishes the spend flow
void clearSpendState(ProviderContainer ref) {
  ref.read(spendAddressProvider.notifier).state = "";
  ref.read(spendAmountProvider.notifier).state = 0;
  ref.read(spendFeeRateProvider.notifier).state =
      ((ref.read(selectedAccountProvider)?.wallet.feeRateFast) ?? 0.00001) *
          100000;
  ref.read(stagingTxChangeOutPutTagProvider.notifier).state = null;
  ref.read(stagingTxNoteProvider.notifier).state = null;
  ref.read(spendFeeProcessing.notifier).state = false;
}

Future<Psbt> getPsbt(
    double feeRate, Account account, String initialAddress, int amount,
    {List<Utxo>? dontSpend, List<Utxo>? mustSpend}) async {
  Psbt returnPsbt = Psbt(0, 0, 0, "", "", "");

  try {
    returnPsbt = await account.wallet.createPsbt(
        initialAddress, amount, feeRate,
        dontSpendUtxos: dontSpend, mustSpendUtxos: mustSpend);
  } on InsufficientFunds catch (e) {
    // TODO: figure out why this can happen
    if (e.available < 0) rethrow;

    // Get another one with correct amount
    var fee = e.needed - e.available;
    try {
      returnPsbt = await account.wallet.createPsbt(
          initialAddress, amount - fee, feeRate,
          dontSpendUtxos: dontSpend, mustSpendUtxos: mustSpend);
    } on InsufficientFunds catch (e) {
      kPrint(
          "Insufficient funds! Available: ${e.available} Needed: ${e.needed}");

      rethrow;
    }
  }

  return returnPsbt;
}

///Will return the raw transaction for a given txId
///this can be used as a cache mechanism to avoid decoding the same transaction multiple times
final rawWalletTransactionProvider =
    FutureProvider.family((ref, String rawTx) async {
  Account? account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return null;
  }
  return await account.wallet.decodeWalletRawTx(rawTx, account.wallet.network);
});
