// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Calculate expected fee percentage from extracted amount and fee
var amount = parseInt(output.amountSats);
var fee = parseInt(output.feeSats);

var expectedPercentage = Math.round((fee / (fee + amount)) * 100);

// Store it so Maestro can use ${output.expectedPercentage} in assertVisible
output.expectedPercentage = '' + expectedPercentage;
