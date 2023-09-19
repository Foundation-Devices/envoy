// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:uuid/uuid.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  const Account._();

  static generateNewId() {
    return Uuid().v4();
  }

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
    if (isPostmix()) {
      return Colors.red;
    }
    int colorIndex = (wallet.hot ? number + 1 : number) %
        (EnvoyColors.listAccountTileColors.length);
    return EnvoyColors.listAccountTileColors[colorIndex];
  }

  bool isPostmix() {
    return number == 2147483646;
  }

  const factory Account(
      {required Wallet wallet,
      // ignore: invalid_annotation_target
      @JsonKey(defaultValue: "Account") required String name,
      required String deviceSerial,
      required DateTime dateAdded,
      required int number,
      // ignore: invalid_annotation_target
      @JsonKey(defaultValue: Account.generateNewId) required String? id,
      // Flipped the first time we sync
      // ignore: invalid_annotation_target
      @JsonKey(defaultValue: null) required DateTime? dateSynced}) = _Account;

  // Serialisation
  factory Account.fromJson(Map<String, Object?> json) =>
      _$AccountFromJson(json);
}
