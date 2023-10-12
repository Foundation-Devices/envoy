// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/util/tuple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/wallet.dart';

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
    if (account == null) {
      state = state.clone()
        ..canProceed = false
        ..valid = false;
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

      /// to prevent the user from editing the transaction, this is used when user scans signed PSBT
      ..isPSBTFinalized = true
      ..valid = true;
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
  return ((ref.read(selectedAccountProvider)?.wallet.feeRateFast) ?? 0.00001) *
      100000;
});

final rawTransactionProvider = Provider<RawTransaction?>(
    (ref) => ref.watch(spendTransactionProvider).rawTransaction);

/// these providers will extract change-output Address and Amount from the staging transaction
final changeOutputProvider = Provider<Tuple2<String, int>?>((ref) {
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
  return Tuple2(outs.first.address, outs.first.amount);
});

/// these providers will extract receive Address and Amount from the staging transaction
final receiveOutputProvider = Provider<Tuple2<String, int>?>((ref) {
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
  return Tuple2(outs.first.address, outs.first.amount);
});

/// these providers will extract receive and change Amount from the staging transaction
final receiveAmountProvider =
    Provider<int>((ref) => ref.watch(receiveOutputProvider)?.item2 ?? 0);
final changeAmountProvider =
    Provider<int>((ref) => ref.watch(changeOutputProvider)?.item2 ?? 0);

final spendInputTagsProvider = Provider<List<Tuple2<CoinTag, Coin>>?>((ref) {
  RawTransaction? rawTx = ref.watch(rawTransactionProvider);
  Account? account = ref.watch(selectedAccountProvider);
  if (account == null || rawTx == null) {
    return null;
  }
  List<CoinTag> coinTags = ref.read(coinsTagProvider(account.id!));
  List<String> inputs = rawTx.inputs
      .map((e) => "${e.previousOutputHash}:${e.previousOutputIndex}")
      .toList();
  List<Tuple2<CoinTag, Coin>> items = [];
  coinTags.forEach((coinTag) {
    coinTag.coins.forEach((coin) {
      if (inputs.contains(coin.id)) {
        items.add(Tuple2(coinTag, coin));
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

///returns estimated block time for the transaction
///TODO: include medium fee rate for better estimation
final spendEstimatedBlockTimeProvider = Provider<int>((ref) {
  final feeRate = ref.watch(spendFeeRateProvider);
  final account = ref.read(selectedAccountProvider);
  if (account == null) {
    return 10;
  }
  if (account.wallet.feeRateFast <= convertToFeeRate(feeRate)) {
    return 10;
  } else {
    return 30;
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
