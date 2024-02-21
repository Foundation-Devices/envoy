// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:envoy/generated/intl/messages_en.dart' as messages_en;
import 'package:envoy/generated/intl/messages_es.dart' as messages_es;
import 'package:envoy/generated/intl/messages_ca.dart' as messages_ca;

final String currentLocale = Platform.localeName;
NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: currentLocale);

String get fiatDecimalSeparator {
  return numberFormat.symbols.DECIMAL_SEP;
}

// Usually this is a thousands separator
String get fiatGroupSeparator {
  return numberFormat.symbols.GROUP_SEP;
}

String? getTranslationByKey(String key) {
  final lookup = () {
    if (currentLocale.startsWith("es")) {
      return messages_es.MessageLookup();
    }

    if (currentLocale.startsWith("ca")) {
      return messages_ca.MessageLookup();
    }

    return messages_en.MessageLookup();
  }();

  try {
    return lookup[key]();
  } catch (_) {
    return null;
  }
}
