// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_notifier.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:envoy/util/tuple.dart';
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
  sendMax, // this is the maximum amount we can send (possibly excluding some coins)
  sweep, // this is all coins but (possibly) less money sent
}

final draftTransactionProvider = Provider<DraftTransaction?>((ref) {
  return ref.watch(spendTransactionProvider).draftTransaction;
});

// If the user performed coin selection on a non-hot wallet transaction,
// they should see a confirmation dialog before exiting the review screen.
final isTransactionCancellableProvider = Provider<bool>((ref) {
  EnvoyAccount? account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return false;
  }
  TransactionModel spendState = ref.watch(spendTransactionProvider);
  bool userChangedCoins = ref.watch(userSelectedCoinsThisSessionProvider);
  final txNotFinalized =
      spendState.broadcastProgress != BroadcastProgress.success;
  bool cancellable = false;

  if (txNotFinalized && userChangedCoins) {
    cancellable = true;
  }

  return cancellable;
});

final emptyTransactionModel = TransactionModel(
    transaction: null,
    draftTransaction: null,
    valid: false,
    loading: false,
    error: null);

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
  final selectedAccount = ref.watch(selectedAccountProvider);
  if (selectedAccount == null) {
    return 0;
  }
  final accountState = ref.watch(accountStateProvider(selectedAccount.id));
  final selectedUtxos = ref.watch(getSelectedCoinsProvider(selectedAccount.id));
  if (accountState == null) {
    return 0;
  }
  if (selectedUtxos.isNotEmpty) {
    int amount = 0;
    for (var element in selectedUtxos) {
      amount = amount + element.amount.toInt();
    }
    return amount;
  }
  final lockedCoins = ref
      .read(outputsProvider(selectedAccount.id))
      .where((element) => element.doNotSpend)
      .toList();
  final blockedAmount = lockedCoins.fold(
      0, (previousValue, element) => previousValue + element.amount.toInt());
  return accountState.balance.toInt() - blockedAmount;
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
final stagingTxChangeOutPutTagProvider = StateProvider<String?>((ref) => null);
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
  try {
    ref.read(spendAddressProvider.notifier).state = "";
    ref.read(spendAmountProvider.notifier).state = 0;
    //reset fee to default
    if (ref.read(selectedAccountProvider) != null) {
      ref.read(spendFeeRateProvider.notifier).state = Fees().slowRate(
        ref.read(selectedAccountProvider)!.network,
      );
    }

    ref.read(stagingTxChangeOutPutTagProvider.notifier).state = null;
    ref.read(stagingTxNoteProvider.notifier).state = null;
    ref.read(spendFeeProcessing.notifier).state = false;
    ref.read(sendScreenUnitProvider.notifier).state =
        Settings().displayUnit == DisplayUnit.btc
            ? AmountDisplayUnit.btc
            : AmountDisplayUnit.sat;
    ref.read(displayFiatSendAmountProvider.notifier).state = 0;
    ref.read(coinSelectionStateProvider.notifier).reset();
    ref.read(spendTransactionProvider.notifier).reset();
  } catch (e, s) {
    kPrint("Error clearing spend state: $e", stackTrace: s);
  }
}
