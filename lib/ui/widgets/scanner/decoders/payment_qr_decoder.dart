// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/business/bip21.dart';
import 'package:envoy/business/btcpay_voucher.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:envoy/util/console.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class InvalidAddressException implements Exception {
  @override
  toString() => "Not a valid address";
}

//specific QR decoder for home screen scans, handles azteco,BTCPay,
//normal bitcoin address and Payment URI
class PaymentQrDecoder extends ScannerDecoder {
  final Function(String, int, String?)? onAddressValidated;
  final Function(AztecoVoucher aztecoVoucher)? onAztecoScan;
  final Function(BtcPayVoucher btcPayVoucher)? btcPayVoucherScan;

  PaymentQrDecoder({
    required this.account,
    required this.onAddressValidated,
    this.onAztecoScan,
    this.btcPayVoucherScan,
  });

  final Account account;

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    String code = barCode.code!.toLowerCase();
    if (barCode.code == null) {
      return;
    }
    if (AztecoVoucher.isVoucher(code)) {
      onAztecoScan?.call(AztecoVoucher(code));
      return;
    }
    if (BtcPayVoucher.isVoucher(code)) {
      final voucher = BtcPayVoucher(code);
      btcPayVoucherScan?.call(voucher);
      return;
    }

    String address = code;
    int amount = 0;
    String? message;

    // Try to decode with BIP21
    try {
      var bip21 = Bip21.decode(address);
      address = bip21.address;
      message = bip21.message;
      // BIP-21 amounts are in BTC
      amount = (bip21.amount * 100000000.0).toInt();
    } catch (e, s) {
      kPrint(e, stackTrace: s);
    }
    // Remove bitcoin: prefix in case BIP-21 parsing failed
    address = address.replaceFirst("bitcoin:", "").trim();
    kPrint("address scanned $address");
    if (await account.wallet.validateAddress(address)) {
      // Convert the address to lowercase for consistent display in Envoy
      if (address.startsWith('bc') || address.startsWith("tb")) {
        address = address.toLowerCase();
      }

      onAddressValidated!(address, amount, message);
    } else {
      throw InvalidAddressException();
    }
  }
}
