// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/util/string_utils.dart';
import 'package:wallet/wallet.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';

String getTransactionTitleText(
    Transaction transaction, RBFState? cancelState, bool? isBoosted) {
  if (transaction.type == TransactionType.ramp)
    return S().activity_incomingPurchase;

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
    if (isBoosted == true) {
      if (transaction.isConfirmed) {
        return S().activity_sent_boosted;
      }
      return S().activity_boosted;
    }
  }

  return transaction.amount < 0 ? S().activity_sent : S().activity_received;
}

String getTransactionSubtitleText(Transaction transaction, Locale locale) {
  if (transaction.type == TransactionType.azteco) {
    return S().azteco_account_tx_history_pending_voucher;
  } else if (transaction.type == TransactionType.btcPay) {
    return S().btcpay_pendingVoucher;
  } else if (transaction.type == TransactionType.ramp) {
    return S().activity_pending;
  } else if (transaction.type == TransactionType.normal &&
      transaction.isConfirmed) {
    return timeago
        .format(transaction.date, locale: locale.languageCode)
        .capitalize();
  } else {
    return S().receive_tx_list_awaitingConfirmation;
  }
}

EnvoyIcons? getTransactionIcon(
    Transaction transaction, RBFState? cancelState, bool? isBoosted) {
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
