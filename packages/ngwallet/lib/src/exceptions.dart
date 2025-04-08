// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ffi';

import 'package:ngwallet/src/utils.dart';

class NotSupportedPlatform implements Exception {
  NotSupportedPlatform(String s);
}

class InsufficientFunds implements Exception {
  final int needed;
  final int available;

  InsufficientFunds(String s, this.needed, this.available);
  @override
  String toString() {
    return "InsufficientFunds: needed=$needed available=${available}";
  }
}

class BelowDustLimit implements Exception {}

class InvalidPort implements Exception {}

class TimedOut implements Exception {}

class InvalidNetwork implements Exception {}

class InvalidMnemonic implements Exception {}

Exception _getRustException(String rustError) {
  if (rustError.startsWith('Insufficient')) {
    int available = int.parse(captureBetween(rustError, 'funds: ', ' sat'));
    int needed = int.parse(captureBetween(rustError, 'of ', ' sat needed'));
    return InsufficientFunds(rustError, needed, available);
  } else if (rustError.startsWith('invalid port')) {
    return InvalidPort();
  } else if (rustError.contains('timed out')) {
    return TimedOut();
  } else if (rustError.contains('dust limit')) {
    return BelowDustLimit();
  } else if (rustError.contains('InvalidNetwork')) {
    return InvalidNetwork();
  } else if (rustError.contains('invalid checksum')) {
    return InvalidMnemonic();
  } else {
    return Exception(rustError);
  }
}

throwRustException(DynamicLibrary lib) {
  String rustError = _lastErrorMessage(lib);
  throw _getRustException(rustError);
}

//TODO: last
String _lastErrorMessage(DynamicLibrary lib) {
  return "";
}
