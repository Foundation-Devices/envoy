// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:intl/intl.dart';

final String currentLocale = Platform.localeName;
NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: currentLocale);

String get fiatDecimalSeparator {
  return numberFormat.symbols.DECIMAL_SEP;
}

// Usually this is a thousands separator
String get fiatGroupSeparator {
  return numberFormat.symbols.GROUP_SEP;
}
