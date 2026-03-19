// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

output.jpyFiat = maestro.copiedText.trim();

if (output.jpyFiat === output.usdFiat) {
    throw 'JPY fiat value (' + output.jpyFiat + ') should differ from USD fiat value (' + output.usdFiat + ')';
}
