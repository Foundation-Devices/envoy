// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';

/// Shared Fee rate state for both normal spend and RBF spend screens

class FeeChooserState {
  final num standardFeeRate;
  final num fasterFeeRate;
  final int minFeeRate;
  final int maxFeeRate;

  FeeChooserState({
    required this.standardFeeRate,
    required this.fasterFeeRate,
    required this.minFeeRate,
    required this.maxFeeRate,
  });
}

final _defaultFeeChooserState = FeeChooserState(
  standardFeeRate: 1,
  fasterFeeRate: 2,
  minFeeRate: 1,
  maxFeeRate: 2,
);

final feeChooserStateProvider = StateProvider<FeeChooserState>((ref) {
  Account? account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return _defaultFeeChooserState;
  }
  return FeeChooserState(
    standardFeeRate: Fees().slowRate(account.wallet.network) * 100000,
    fasterFeeRate: Fees().fastRate(account.wallet.network) * 100000,
    minFeeRate: 1,
    maxFeeRate: (Fees().fastRate(account.wallet.network) * 100000).floor(),
  );
});

final spendFeeProcessing = StateProvider((ref) => false);
// final spendMaxFeeRateProvider = StateProvider((ref) => 2);
// final spendMinFeeRateProvider = StateProvider((ref) => 1);

final spendFeeRateProvider = StateProvider<num>((ref) {
  Account? account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return 1;
  }
  return Fees().slowRate(account.wallet.network) * 100000;
});

final spendFeeRateBlockEstimationProvider =
    StateProvider<num>((ref) => ref.read(spendFeeRateProvider));

///returns estimated block time for the transaction
///TODO: implement better mempool estimation
final spendEstimatedBlockTimeProvider = Provider<String>((ref) {
  final feeRate = ref.watch(spendFeeRateBlockEstimationProvider);
  final account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return "~10";
  }

  Network network = account.wallet.network;

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
