// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:core';

import 'package:ngwallet/ngwallet.dart';

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
    return other.txId.compareTo(txId);
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
