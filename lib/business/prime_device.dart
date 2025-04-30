// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'prime_device.g.dart';

/// Custom converter for Uint8List <-> Base64 String
class Uint8ListBase64Converter implements JsonConverter<Uint8List, String> {
  const Uint8ListBase64Converter();

  @override
  Uint8List fromJson(String json) => base64Decode(json);

  @override
  String toJson(Uint8List object) => base64Encode(object);
}

@JsonSerializable(explicitToJson: true)
class PrimeDevice {
  final String bleId;

  @Uint8ListBase64Converter()
  final Uint8List xidDocument;

  PrimeDevice(this.bleId, this.xidDocument);

  factory PrimeDevice.fromJson(Map<String, dynamic> json) =>
      _$PrimeDeviceFromJson(json);

  Map<String, dynamic> toJson() => _$PrimeDeviceToJson(this);
}
