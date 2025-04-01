import 'package:ngwallet/ngwallet.dart';

enum TransactionType { normal, azteco, pending, btcPay, ramp }

class EnvoyTransaction extends BitcoinTransaction {
  EnvoyTransaction(
      {required super.txId,
      required super.blockHeight,
      required super.confirmations,
      required super.fee,
      required super.amount,
      required super.inputs,
      required super.outputs});
}

//   String key,
//     String accountId,
//     DateTime timestamp,
//     wallet.TransactionType type,
//     int amount,
//     int fee,
//     String address,
// class AztecoTransaction extends EnvoyTransaction {
//   String? pullPaymentId;
//   final String? purchaseViewToken;
//   final String? currencyAmount;
//   final String? currency;
//   final String? payoutId;
//   final String? btcPayVoucherUri;
//   String? rampId;
//   int? rampFee;
//
//   AztecoTransaction(
//       {required super.txId,
//       required super.confirmations,
//       required super.fee,
//       required super.amount,
//       required super.inputs,
//       required super.outputs,
//       this.pullPaymentId,
//       this.purchaseViewToken,
//       this.currencyAmount,
//       this.currency,
//       this.payoutId,
//       this.btcPayVoucherUri,
//       this.rampId,
//       this.rampFee})
//       : super(
//           blockHeight: 0,
//           amount: amount,
//           inputs: [],
//           outputs: [],
//           txId: txId,
//           confirmations: confirmations,
//         );
// }
