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
      vsize: tx.vsize,
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
  final String accountId;
  final DateTime timestamp;

  RampTransaction(
      {required super.txId,
      required this.accountId,
      required this.timestamp,
      required super.amount,
      required super.fee,
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
      super.outputs = const []});
}

class BtcPayTransaction extends EnvoyTransaction {
  String? pullPaymentId;
  final String? currencyAmount;
  final String? currency;
  final String? payoutId;
  final String? btcPayVoucherUri;
  final String accountId;
  final DateTime timestamp;

  BtcPayTransaction({
    required super.txId,
    required this.accountId,
    required this.timestamp,
    required super.amount,
    required super.fee,
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
    super.date,
    required super.vsize,
  });

  void setPullPaymentId(String? pullPaymentId) {
    this.pullPaymentId = pullPaymentId;
  }
}

class AztecoTransaction extends EnvoyTransaction {
  final String accountId;
  final DateTime timestamp;

  AztecoTransaction({
    required super.txId,
    required super.amount,
    required super.fee,
    required super.address,
    required this.accountId,
    required this.timestamp,
    super.blockHeight = 0,
    super.confirmations = 0,
    super.inputs = const [],
    super.isConfirmed = false,
    super.outputs = const [],
    super.date,
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
    super.date,
    required super.vsize,
  });

  static copyFrom(BitcoinTransaction tx) {
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
    );
  }
}
