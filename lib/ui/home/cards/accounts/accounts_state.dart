// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

//Shared selected account provider.
final selectedAccountProvider = StateProvider<EnvoyAccount?>((ref) => null);
