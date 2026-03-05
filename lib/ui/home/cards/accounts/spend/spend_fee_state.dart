// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fee_rate.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

/// Shared fee rate state for both normal spend and RBF spend screens.
/// All rates are [FeeRate] objects — see [FeeRate] for unit details.

class FeeChooserState {
  final FeeRate standardFeeRate;
  final FeeRate fasterFeeRate;
  final FeeRate minFeeRate;
  final FeeRate maxFeeRate;

  FeeChooserState({
    required this.standardFeeRate,
    required this.fasterFeeRate,
    required this.minFeeRate,
    required this.maxFeeRate,
  });

  @override
  String toString() =>
      'standardFeeRate: $standardFeeRate, fasterFeeRate: $fasterFeeRate, '
      'minFeeRate: $minFeeRate, maxFeeRate: $maxFeeRate';
}

final _defaultFeeChooserState = FeeChooserState(
  standardFeeRate: FeeRate.fromSatPerKvb(1000),
  fasterFeeRate: FeeRate.fromSatPerKvb(2000),
  minFeeRate: FeeRate.fromSatPerKvb(1000),
  maxFeeRate: FeeRate.fromSatPerKvb(2000),
);

final feeChooserStateProvider = StateProvider<FeeChooserState>((ref) {
  EnvoyAccount? account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return _defaultFeeChooserState;
  }
  return FeeChooserState(
    standardFeeRate: FeeRate.fromSatPerVb(Fees().slowRate(account.network)),
    fasterFeeRate: FeeRate.fromSatPerVb(Fees().fastRate(account.network)),
    minFeeRate: FeeRate.fromSatPerKvb(1000),
    maxFeeRate: FeeRate.fromSatPerVb(Fees().fastRate(account.network)),
  );
});

final spendFeeProcessing = StateProvider((ref) => false);

final spendFeeRateProvider = StateProvider<FeeRate>((ref) {
  EnvoyAccount? account = ref.watch(selectedAccountProvider);
  if (account == null) {
    return FeeRate.fromSatPerKvb(1000);
  }
  return FeeRate.fromSatPerVb(Fees().slowRate(account.network));
});

/// Returns estimated block time for the transaction.
/// TODO: implement better mempool estimation
final spendEstimatedBlockTimeProvider = Provider<String>((ref) {
  final feeRate = ref.watch(spendFeeRateProvider);
  final account = ref.watch(selectedAccountProvider);
  return getAproxTime(account, feeRate);
});

String getAproxTime(EnvoyAccount? account, FeeRate feeRate) {
  if (account == null) {
    return "~10 min";
  }

  Network network = account.network;

  //with in 10 minutes
  int feeRateFast = Fees().fees[network]?.mempoolFastestRate ?? 2;
  //with in 30 minutes
  int feeHalfHourRate = Fees().fees[network]?.mempoolHalfHourRate ?? 1;

  int feeHourRate = Fees().fees[network]?.mempoolHourRate ?? 1;

  // Compare in sat/vB (int)
  int selectedFeeRate = feeRate.satPerVb.toInt();

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

/// fee [sats] = rate.satPerVb * vsize [vB]
int getApproxFeeInSats({
  required FeeRate feeRate,
  required int txVSizeVb,
}) {
  return (feeRate.satPerVb * txVSizeVb).round();
}
