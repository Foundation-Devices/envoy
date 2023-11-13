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
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/tuple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tor/tor.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/wallet.dart';

enum BroadcastProgress {
  inProgress,
  success,
  failed,
  staging,
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
      this.error = null});

  static TransactionModel copy(TransactionModel mode) {
    return TransactionModel(
      sendTo: mode.sendTo,
      amount: mode.amount,
      feeRate: mode.feeRate,
      error: mode.error,
      utxos: mode.utxos,
      psbt: mode.psbt,
      rawTransaction: mode.rawTransaction,
      valid: mode.valid,
      loading: mode.loading,
      canProceed: mode.canProceed,
      belowDustLimit: mode.belowDustLimit,
      broadcastProgress: mode.broadcastProgress,
    );
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

  Future<bool> validate(ProviderContainer container) async {
    String sendTo = container.read(spendAddressProvider);
    int amount = container.read(spendAmountProvider);
    num feeRate = container.read(spendFeeRateProvider);
    Account? account = container.read(selectedAccountProvider);
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

    try {
      state = state.clone()
        ..sendTo = sendTo
        ..amount = amount
        ..utxos = utxos
        ..feeRate = feeRate.toDouble()
        ..loading = true;

      List<Utxo>? mustSpend = utxos.isEmpty ? null : utxos;
      List<Utxo>? dontSpend = utxos.isEmpty
          ? null
          : account.wallet.utxos
              .where((element) => !utxos.map((e) => e.id).contains(element.id))
              .toList();

      ///get max fee rate that we can use on this transaction
      int maxFeeRate = await account.wallet.getMaxFeeRate(sendTo, amount,
          dontSpendUtxos: dontSpend, mustSpendUtxos: mustSpend);

      container.read(spendMaxFeeRateProvider.notifier).state = maxFeeRate;

      ///Construct PSBT object from the given parameters
      Psbt psbt = await account.wallet.createPsbt(
          sendTo, amount, convertToFeeRate(feeRate.toInt()),
          dontSpendUtxos: dontSpend, mustSpendUtxos: mustSpend);

      ///Create RawTransaction from PSBT. RawTransaction will include inputs and outputs.
      /// this is used to show staging transaction details
      RawTransaction rawTransaction =
          await Wallet.decodeRawTx(psbt.rawTx, account.wallet.network);
      state = state.clone()
        ..psbt = psbt
        ..loading = false
        ..rawTransaction = rawTransaction
        ..valid = true;
      return true;
    } on InsufficientFunds {
      state = state.clone()
        ..loading = false
        ..psbt = null
        ..rawTransaction = null
        ..canProceed = false;
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
      print("Error ${e}");
      debugPrintStack(stackTrace: stackTrace);

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
      // Increment the change index before broadcasting
      await account.wallet.getChangeAddress();
      this.state = state.clone()
        ..broadcastProgress = BroadcastProgress.inProgress;
      Psbt psbt = state.psbt!;
      //Broadcast transaction
      await account.wallet.broadcastTx(
          Settings().electrumAddress(account.wallet.network),
          Tor.instance.port,
          psbt.rawTx);

      await EnvoyStorage().addPendingTx(psbt.txid, account.id!, DateTime.now(),
          TransactionType.pending, psbt.sent + psbt.fee);

      String? note = ref.read(stagingTxNoteProvider);
      CoinTag? changeOutPutTag = ref.read(stagingTxChangeOutPutTagProvider);
      Tuple<String, int>? changeOutPut = ref.read(changeOutputProvider);
      RawTransaction? transaction = ref.read(rawTransactionProvider);

      if (note != null) {
        await EnvoyStorage().addTxNote(note, psbt.txid);
      }

      try {
        /// add change output to selected/default tag
        if (transaction != null &&
            changeOutPutTag != null &&
            changeOutPut != null) {
          ///store change tag if it is not already stored
          CoinTag tag = ref.read(stagingTxChangeOutPutTagProvider)!;
          final tags = ref
              .read(coinsTagProvider(ref.read(selectedAccountProvider)!.id!));

          if (tags.map((e) => e.id).contains(tag.id) == false &&
              tag.untagged == false) {
            await CoinRepository().addCoinTag(tag);
            await Future.delayed(Duration(milliseconds: 100));
          }

          int index = transaction.outputs.indexWhere((element) =>
              element.address == changeOutPut.item1 &&
              element.amount == changeOutPut.item2);
          if (index != -1) {
            changeOutPutTag.addCoin(Coin(
                Utxo(txid: psbt.txid, vout: index, value: changeOutPut.item2),
                account: account.id!));
            await CoinRepository().updateCoinTag(changeOutPutTag);
            final _ = ref.refresh(accountsProvider);
            await Future.delayed(Duration(seconds: 1));
            await ref.refresh(coinsTagProvider(account.id!));
          }
        }
      } catch (e) {}
      ref.read(stagingTxChangeOutPutTagProvider.notifier).state = null;
      ref.read(stagingTxNoteProvider.notifier).state = null;

      /// wait for bdk to update the transaction list and utxos list
      await Future.delayed(Duration(seconds: 2));

      /// clear staging transaction states
      this.state = state.clone()..broadcastProgress = BroadcastProgress.success;
      return true;
    } catch (e) {
      this.state = state.clone()..broadcastProgress = BroadcastProgress.failed;
      throw e;
    }
  }

  resetBroadcastState() {
    this.state = state.clone()..broadcastProgress = BroadcastProgress.staging;
  }
}

final emptyTransactionModel =
    TransactionModel(sendTo: "", amount: 0, feeRate: 1);
final spendTransactionProvider =
    StateNotifierProvider<TransactionModeNotifier, TransactionModel>(
        (ref) => TransactionModeNotifier(emptyTransactionModel));

final spendEditModeProvider = StateProvider((ref) => false);
final spendAddressProvider = StateProvider((ref) => "");
final spendValidationErrorProvider = StateProvider<String?>((ref) => null);
final spendAmountProvider = StateProvider((ref) => 0);
final spendMaxFeeRateProvider = StateProvider((ref) => 1);
final spendFeeRateProvider = StateProvider<num>((ref) {
  Account? account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return 1;
  }
  return Fees().slowRate(account.wallet.network) * 100000;
});

final rawTransactionProvider = Provider<RawTransaction?>(
    (ref) => ref.watch(spendTransactionProvider).rawTransaction);

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
      .where((element) => element.address == spendAddress)
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
  coinTags.forEach((coinTag) {
    coinTag.coins.forEach((coin) {
      if (inputs.contains(coin.id)) {
        items.add(Tuple(coinTag, coin));
      }
    });
  });
  return items;
});

///returns the total spendable amount for selected account and selected coins
///if the user selected coins then it will return the sum of selected coins
final totalSpendableAmountProvider = Provider<int>((ref) {
  final account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return 0;
  }
  final selectedUtxos = ref
      .watch(getSelectedCoinsProvider(account.id!))
      .map((e) => e.utxo)
      .toList();
  if (selectedUtxos.isNotEmpty) {
    return selectedUtxos.fold(
        0, (previousValue, element) => previousValue + element.value);
  }
  return account.wallet.balance;
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

final spendFeeRateBlockEstimationProvider =
    StateProvider<num>((ref) => ref.read(spendFeeRateProvider));

///returns estimated block time for the transaction
final spendEstimatedBlockTimeProvider = Provider<String>((ref) {
  final feeRate = ref.watch(spendFeeRateBlockEstimationProvider);
  final account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return "~10";
  }

  Network network = account.wallet.network;
  // Network network = Network.Mainnet;

  //with in 10 minutes
  double feeRateFast = Fees().fees[network]!.mempoolFastestRate;
  //with in 30 minutes
  double feeHalfHourRate = Fees().fees[network]!.mempoolHalfHourRate;

  double feeHourRate = Fees().fees[network]!.mempoolHourRate;

  double selectedFeeRate = convertToFeeRate(feeRate);

  if (feeRateFast <= selectedFeeRate) {
    return "~10";
  } else if (feeHalfHourRate <= selectedFeeRate &&
      selectedFeeRate < feeRateFast) {
    return "~20";
  } else if (feeHourRate <= selectedFeeRate &&
      selectedFeeRate < feeHalfHourRate) {
    return "~30";
  } else {
    return "40+";
  }
});

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
  EnvoyReport().log(
      "QA", "Validation amount : ${amount} , Spendable : ${spendableBalance}");
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

///clears all the spend realted states. this is need once the user exits the spend screen or account details...
///or when the user finishes the spend flow
void clearSpendState(ProviderContainer ref) {
  ref.read(spendAddressProvider.notifier).state = "";
  ref.read(spendAmountProvider.notifier).state = 0;
  ref.read(spendFeeRateProvider.notifier).state =
      ((ref.read(selectedAccountProvider)?.wallet.feeRateFast) ?? 0.00001) *
          100000;
  ref.read(spendTransactionProvider.notifier).reset();
}
