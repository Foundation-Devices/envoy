// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/string_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

String getTransactionTitleText(
    EnvoyTransaction transaction, RBFState? cancelState, bool? isBoosted) {
  bool isSent = transaction.amount < 0;

  if (cancelState != null) {
    if (cancelState.originalTxId == transaction.txId) {
      if (!transaction.isConfirmed) {
        return S().activity_canceling;
      }
    }
    if (cancelState.newTxId == transaction.txId) {
      if (transaction.isConfirmed) {
        return S().activity_sent_canceled;
      } else {
        return S().activity_canceling;
      }
    }
  } else {
    if (isBoosted == true && isSent) {
      if (transaction.isConfirmed) {
        return S().activity_sent_boosted;
      }
      return S().activity_boosted;
    }
  }

  return isSent ? S().activity_sent : S().activity_received;
}

String getTransactionSubtitleText(EnvoyTransaction transaction, Locale locale) {
  if (transaction is AztecoTransaction) {
    return S().azteco_account_tx_history_pending_voucher;
  } else if (transaction is BtcPayTransaction) {
    return S().btcpay_pendingVoucher;
  } else if (transaction is RampTransaction) {
    return S().ramp_pendingVoucher;
  } else if (transaction.isOnChain() && transaction.isConfirmed) {
    if (transaction.date == null) {
      return S().receive_tx_list_awaitingConfirmation;
    }
    return timeago
        .format(
            DateTime.fromMillisecondsSinceEpoch(transaction.date!.toInt(),
                isUtc: true),
            locale: locale.languageCode)
        .capitalize();
  } else {
    return S().receive_tx_list_awaitingConfirmation;
  }
}

EnvoyIcons? getTransactionIcon(
    EnvoyTransaction transaction, RBFState? cancelState, bool? isBoosted) {
  if (cancelState == null) {
    return transaction.amount < 0 ? EnvoyIcons.spend : EnvoyIcons.receive;
  }

  if (isBoosted == true) {
    return EnvoyIcons.rbf_boost;
  }

  if (!transaction.isConfirmed) {
    return EnvoyIcons.alert;
  } else if (cancelState.newTxId == transaction.txId) {
    return EnvoyIcons.close;
  } else {
    return transaction.amount < 0 ? EnvoyIcons.spend : EnvoyIcons.receive;
  }
}
