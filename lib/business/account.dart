// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';
import 'package:wallet/wallet.dart';
import 'dart:ui';
import 'package:envoy/ui/envoy_colors.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final Wallet wallet;
  final String deviceSerial;
  @JsonKey(defaultValue: "Account")
  String name;
  final DateTime dateAdded;
  final int number;

  Color get color {
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
