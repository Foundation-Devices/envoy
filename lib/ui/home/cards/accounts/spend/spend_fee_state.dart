// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fees.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

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
  @override
  String toString() {
    return "standardFeeRate: $standardFeeRate, fasterFeeRate: $fasterFeeRate, minFeeRate: $minFeeRate, maxFeeRate: $maxFeeRate";
  }
}

final _defaultFeeChooserState = FeeChooserState(
  standardFeeRate: 1,
  fasterFeeRate: 2,
  minFeeRate: 1,
  maxFeeRate: 2,
);

final feeChooserStateProvider = StateProvider<FeeChooserState>((ref) {
  EnvoyAccount? account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return _defaultFeeChooserState;
  }
  return FeeChooserState(
    standardFeeRate: Fees().slowRate(account.network),
    fasterFeeRate: Fees().fastRate(account.network),
    minFeeRate: 1,
    maxFeeRate: (Fees().fastRate(account.network)).floor(),
  );
});

final spendFeeProcessing = StateProvider((ref) => false);
// final spendMaxFeeRateProvider = StateProvider((ref) => 2);
// final spendMinFeeRateProvider = StateProvider((ref) => 1);

final spendFeeRateProvider = StateProvider<num>((ref) {
  EnvoyAccount? account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return 1;
  }
  return Fees().slowRate(account.network);
});

///returns estimated block time for the transaction
///TODO: implement better mempool estimation
final spendEstimatedBlockTimeProvider = Provider<String>((ref) {
  final feeRate = ref.watch(spendFeeRateProvider);
  final account = ref.watch(selectedAccountProvider);
  return getAproxTime(account, feeRate);
});

String getAproxTime(EnvoyAccount? account, num feeRate) {
  if (account == null) {
    return "~10 min";
  }

  Network network = account.network;

  //with in 10 minutes
  int feeRateFast = Fees().fees[network]?.mempoolFastestRate ?? 2;
  //with in 30 minutes
  int feeHalfHourRate = Fees().fees[network]?.mempoolHalfHourRate ?? 1;

  int feeHourRate = Fees().fees[network]?.mempoolHourRate ?? 1;

  int selectedFeeRate = feeRate.toInt();

  if (feeRateFast <= selectedFeeRate) {
    return "~10 min";
  } else if (feeHalfHourRate <= selectedFeeRate &&
      selectedFeeRate < feeRateFast) {
    return "~20 min";
  } else if (feeHourRate <= selectedFeeRate &&
      selectedFeeRate < feeHalfHourRate) {
    return "~30 min";
  } else {
    return "40+ min";
  }
}

int getApproxFeeInSats({
  required int feeRateSatsPerVb,
  required int txVSizeVb,
}) {
  // fee [sats] = rate [sats/vB] * vsize [vB]
  return feeRateSatsPerVb * txVSizeVb;
}
