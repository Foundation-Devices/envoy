// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:core';

import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/ui/state/transactions_state.dart';

class EnvoyTransaction extends BitcoinTransaction
    implements Comparable<EnvoyTransaction> {
  EnvoyTransaction(
      {required super.txId,
      required super.blockHeight,
      required super.confirmations,
      required super.fee,
      required super.amount,
      required super.address,
      required super.inputs,
      required super.outputs,
      required super.date,
      required super.vsize,
      required super.feeRate,
      required super.note,
      required super.accountId,
      required super.isConfirmed});

  static EnvoyTransaction copyFrom(BitcoinTransaction tx) {
    return EnvoyTransaction(
      txId: tx.txId,
      blockHeight: tx.blockHeight,
      confirmations: tx.confirmations,
      fee: tx.fee,
      amount: tx.amount,
      address: tx.address,
      isConfirmed: tx.isConfirmed,
      inputs: tx.inputs,
      outputs: tx.outputs,
      date: tx.date,
      feeRate: tx.feeRate,
      vsize: tx.vsize,
      accountId: tx.accountId,
      note: tx.note,
    );
  }

  bool isOnChain() {
    return inputs.isNotEmpty && outputs.isNotEmpty;
  }

  @override
  int compareTo(EnvoyTransaction other) {
    return compareTx(other);
  }

  int compareTx(EnvoyTransaction other) {
    // define cutoff (2008-01-01). Adjust if your BigInt is in ms instead of sec
    final cutoff = BigInt.from(1230768000); // seconds since epoch

    final thisDate = date;
    final otherDate = other.date;

    final thisInMempool = thisDate == null || thisDate < cutoff;
    final otherInMempool = otherDate == null || otherDate < cutoff;

    // 1. if both are in mempool (unconfirmed)
    if (thisInMempool && otherInMempool) {
      if (other.inputs.isEmpty) {
        return 1; // If inputs missing for other, it goes on top
      }
      if (inputs.isEmpty) return -1; // If our inputs missing, we go on top

      if (other.inputs.any((i) => i.txId == txId)) {
        return 1; // Our txId is input of other
      }
      if (inputs.any((i) => i.txId == other.txId)) {
        return -1; // Other's txId is input of ours
      }

      return other.txId.compareTo(txId); // fallback: alphabetical
    }

    // 2. if other is mempool → it goes on top
    if (otherInMempool) return 1;

    // 3. if this is mempool → it goes on top
    if (thisInMempool) return -1;

    // 4. both confirmed → compare by date using helper
    final dateComparison = compareTimestamps(otherDate, thisDate);
    if (dateComparison == 0) {
      return other.txId.compareTo(txId);
    } else {
      return dateComparison;
    }
  }
}

class RampTransaction extends EnvoyTransaction {
  final String? purchaseViewToken;
  final String? rampId;
  final int? rampFee;
  final DateTime timestamp;

  RampTransaction(
      {required super.txId,
      required super.accountId,
      required this.timestamp,
      required super.amount,
      required super.fee,
      required super.feeRate,
      required super.address,
      required this.purchaseViewToken,
      required this.rampFee,
      required this.rampId,
      required super.vsize,
      super.blockHeight = 0,
      super.isConfirmed = false,
      super.confirmations = 0,
      super.inputs = const [],
      super.date,
      super.note = "",
      super.outputs = const []});
}

class BtcPayTransaction extends EnvoyTransaction {
  String? pullPaymentId;
  final String? currencyAmount;
  final String? currency;
  final String? payoutId;
  final String? btcPayVoucherUri;
  final DateTime timestamp;

  BtcPayTransaction({
    required super.txId,
    required this.timestamp,
    required super.amount,
    required super.fee,
    required super.feeRate,
    required super.address,
    required this.pullPaymentId,
    required this.currency,
    required this.currencyAmount,
    required this.payoutId,
    required this.btcPayVoucherUri,
    super.blockHeight = 0,
    super.isConfirmed = false,
    super.confirmations = 0,
    super.inputs = const [],
    super.outputs = const [],
    super.note,
    super.date,
    required super.vsize,
    required super.accountId,
  });

  void setPullPaymentId(String? pullPaymentId) {
    this.pullPaymentId = pullPaymentId;
  }
}

class AztecoTransaction extends EnvoyTransaction {
  final DateTime timestamp;

  AztecoTransaction({
    required super.txId,
    required super.amount,
    required super.fee,
    required super.address,
    required this.timestamp,
    required super.accountId,
    super.blockHeight = 0,
    super.confirmations = 0,
    super.inputs = const [],
    super.isConfirmed = false,
    super.outputs = const [],
    required super.feeRate,
    super.date,
    super.note,
    required super.vsize,
  });
}

class PendingTransaction extends BitcoinTransaction {
  PendingTransaction({
    required super.txId,
    required super.blockHeight,
    required super.confirmations,
    required super.fee,
    required super.amount,
    required super.address,
    required super.inputs,
    required super.outputs,
    required super.isConfirmed,
    required super.feeRate,
    required super.accountId,
    super.date,
    required super.vsize,
  });

  static EnvoyTransaction copyFrom(BitcoinTransaction tx) {
    return EnvoyTransaction(
      txId: tx.txId,
      blockHeight: tx.blockHeight,
      confirmations: tx.confirmations,
      fee: tx.fee,
      amount: tx.amount,
      address: tx.address,
      inputs: tx.inputs,
      isConfirmed: tx.isConfirmed,
      outputs: tx.outputs,
      date: tx.date,
      vsize: tx.vsize,
      feeRate: tx.feeRate,
      note: tx.note,
      accountId: tx.accountId,
    );
  }
}

extension CopyWithExtenstion on BitcoinTransaction {
  BitcoinTransaction copyWith({
    String? txId,
    String? note,
    String? address,
    List<Input>? inputs,
    List<Output>? outputs,
    bool? isConfirmed,
    DateTime? date,
  }) {
    return BitcoinTransaction(
      txId: txId ?? this.txId,
      blockHeight: blockHeight,
      confirmations: confirmations,
      fee: fee,
      amount: amount,
      note: note ?? this.note,
      address: address ?? this.address,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      vsize: vsize,
      feeRate: feeRate,
      date: this.date,
      accountId: accountId,
    );
  }
}
