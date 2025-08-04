// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legacy_account.g.dart';

@JsonSerializable()
class LegacyAccount {
  @JsonKey(name: 'wallet')
  final LegacyWallet wallet;

  final String name;
  String deviceSerial;
  final String dateAdded;
  final int number;
  final String id;
  final String? dateSynced;

  LegacyAccount({
    required this.wallet,
    required this.name,
    required this.deviceSerial,
    required this.dateAdded,
    required this.number,
    required this.id,
    required this.dateSynced,
  });

  // Factory constructor to create a LegacyAccount from JSON
  factory LegacyAccount.fromJson(Map<String, dynamic> json) =>
      _$LegacyAccountFromJson(json);

  // Method to convert LegacyAccount to JSON
  Map<String, dynamic> toJson() => _$LegacyAccountToJson(this);

  String getUnificationId() {
    return NgAccountManager.getUniqueAccountId(
        deviceSerial: deviceSerial,
        network: wallet.network.toLowerCase(),
        number: number,
        fingerprint: extractFingerprint() ?? "");
  }

  String? extractFingerprint() {
    final descriptor =
        wallet.externalDescriptor ?? wallet.publicExternalDescriptor ?? "";
     return NgAccountManager.getFingerprint(descriptor);
  }
}

@JsonSerializable()
class LegacyWallet {
  final String name;
  final String? externalDescriptor;
  final String? internalDescriptor;

  final String? publicExternalDescriptor;

  final String? publicInternalDescriptor;

  final String type;
  final String network;
  final bool hot;
  final bool hasPassphrase;

  final int balance;
  final double feeRateFast;
  final double feeRateSlow;

  LegacyWallet({
    required this.name,
    this.externalDescriptor,
    this.internalDescriptor,
    this.publicExternalDescriptor,
    this.publicInternalDescriptor,
    required this.type,
    required this.network,
    required this.hot,
    required this.hasPassphrase,
    required this.balance,
    required this.feeRateFast,
    required this.feeRateSlow,
  });

  // Factory constructor to create a Wallet from JSON
  factory LegacyWallet.fromJson(Map<String, dynamic> json) =>
      _$WalletFromJson(json);

  // Method to convert Wallet to JSON
  Map<String, dynamic> toJson() => _$WalletToJson(this);
}
