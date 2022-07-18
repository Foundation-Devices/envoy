// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';

// Generated
part 'passport.g.dart';

@JsonSerializable()
class Passport {
  final String xfp, publicKey, xpub;

  final DateTime? datePaired;

  final int model, fwVersion;

  Passport(this.xfp, this.publicKey, this.xpub, this.datePaired, this.model,
      this.fwVersion);

  // Generated
  factory Passport.fromJson(Map<String, dynamic> json) =>
      _$PassportFromJson(json);
  Map<String, dynamic> toJson() => _$PassportToJson(this);
}
