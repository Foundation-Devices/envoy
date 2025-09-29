// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/business/bip21.dart';
import 'package:envoy/business/btcpay_voucher.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:envoy/util/console.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class InvalidAddressException implements Exception {
  @override
  toString() => "Not a valid address";
}

//specific QR decoder for home screen scans, handles azteco,BTCPay,
//normal bitcoin address and Payment URI
class PaymentQrDecoder extends ScannerDecoder {
  bool _scanned = false;
  final Function(String, int, String?)? onAddressValidated;
  final Function(AztecoVoucher aztecoVoucher)? onAztecoScan;
  final Function(BtcPayVoucher btcPayVoucher)? btcPayVoucherScan;

  PaymentQrDecoder({
    required this.account,
    required this.onAddressValidated,
    this.onAztecoScan,
    this.btcPayVoucherScan,
  });

  final EnvoyAccount account;

  @override
  Future<void> onDetectBarCode(Barcode barCode) async {
    String code = barCode.code!;
    if (barCode.code == null || _scanned) {
      return;
    }
    if (AztecoVoucher.isVoucher(code)) {
      onAztecoScan?.call(AztecoVoucher(code));
      _scanned = true;
      return;
    }
    if (BtcPayVoucher.isVoucher(code)) {
      final voucher = BtcPayVoucher(code);
      btcPayVoucherScan?.call(voucher);
      _scanned = true;
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
    } catch (e) {
      // kPrint(e, stackTrace: s);
    }
    // Remove bitcoin: prefix in case BIP-21 parsing failed
    address = address.replaceFirst("bitcoin:", "").trim();
    final time = DateTime.now().millisecondsSinceEpoch;
    final valid = await EnvoyAccountHandler.validateAddress(
        address: address, network: account.network);
    final after = DateTime.now().millisecondsSinceEpoch;
    kPrint("Address validation took ${after - time}ms");
    kPrint("address scanned $address $valid");
    if (valid) {
      // Convert the address to lowercase for consistent display in Envoy
      if (address.startsWith('bc') || address.startsWith("tb")) {
        address = address.toLowerCase();
      }
      onAddressValidated!(address, amount, message);
      _scanned = true;
    } else {
      throw InvalidAddressException();
    }
  }
}
