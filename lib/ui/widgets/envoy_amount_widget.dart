// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/business/locale.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/account.dart';

class EnvoyAmount extends StatelessWidget {
  const EnvoyAmount({
    super.key,
    required this.amountSats,
    required this.amountWidgetStyle,
    required this.account,
    this.alignToEnd = true,
    this.unit,
  });

  final int amountSats;
  final AmountWidgetStyle amountWidgetStyle;
  final Account account;
  final bool alignToEnd;
  final AmountDisplayUnit? unit;

  @override
  Widget build(BuildContext context) {
    Color? badgeColor;
    if (account.wallet.network != Network.Mainnet) {
      badgeColor = account.color;
    }

    AmountDisplayUnit mainUnit = Settings().displayUnitSat()
        ? AmountDisplayUnit.sat
        : AmountDisplayUnit.btc;

    // In case we need to override
    if (unit != null) {
      mainUnit = unit!;
    }

    String? selectedFiat = Settings().selectedFiat;
    bool showFiat = selectedFiat != null &&
        (kDebugMode || account.wallet.network == Network.Mainnet);
    AmountDisplayUnit primaryUnit = mainUnit;
    AmountDisplayUnit? secondaryUnit = showFiat ? AmountDisplayUnit.fiat : null;
    String symbolFiat = ExchangeRate().getSymbol();
    double? fxRateFiat = ExchangeRate().selectedCurrencyRate;

    return AmountWidget(
      amountSats: amountSats,
      primaryUnit: primaryUnit,
      style: amountWidgetStyle,
      fxRateFiat: fxRateFiat,
      secondaryUnit: secondaryUnit,
      symbolFiat: symbolFiat,
      badgeColor: badgeColor,
      network: account.wallet.network,
      alignToEnd: alignToEnd,
      locale: currentLocale,
    );
  }
}
