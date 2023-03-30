// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final Wallet wallet;
  final String deviceSerial;
  @JsonKey(defaultValue: "Account")
  String name;
  final DateTime dateAdded;
  final int number;

  // Flipped the first time we sync
  @JsonKey(
      defaultValue:
          true) // Ensure we don't show ghosting UI for accounts synced before introduction of this field
  bool initialSyncCompleted = false;

  // Multipath specifier as per https://github.com/bitcoin/bitcoin/pull/22838
  // Not yet supported in BDK but showing it as such
  String get descriptor {
    return (wallet.publicExternalDescriptor == null
            ? wallet.externalDescriptor!
            : wallet.publicExternalDescriptor!)
        .replaceAll("/0/", "/<0;1>/");
  }

  Color get color {
    // Postmix accounts are pure red
    if (number == 2147483646) {
      return Colors.red;
    }

    int colorIndex = number % (EnvoyColors.listAccountTileColors.length);
    return EnvoyColors.listAccountTileColors[colorIndex];
  }

  Account(
      this.wallet, this.name, this.deviceSerial, this.dateAdded, this.number);

  // Serialisation
  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
