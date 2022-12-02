// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/account_manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:envoy/business/local_storage.dart';
import 'dart:convert';

import 'account.dart';

part 'notifications.g.dart';

enum EnvoyNotificationType { firmware, transaction, security }

@JsonSerializable()
class EnvoyNotification {
  final String title;
  final DateTime date;
  final EnvoyNotificationType type;
  final String body;
  final String id;
  final int? amount;
  final String? walletName;

  EnvoyNotification(this.title, this.date, this.type, this.body, this.id,
      {this.amount, this.walletName});

  // Serialisation
  factory EnvoyNotification.fromJson(Map<String, dynamic> json) =>
      _$EnvoyNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$EnvoyNotificationToJson(this);
}

class Notifications {
  int unread = 0;
  late DateTime lastUpdated = DateTime.now();
  Timer? _syncTimer;

  List<EnvoyNotification> notifications = [];
  LocalStorage _ls = LocalStorage();

  static const String _NOTIFICATIONS_PREFS = "notifications";

  static final Notifications _instance = Notifications._internal();

  factory Notifications() {
    return _instance;
  }

  static Future<Notifications> init() async {
    var singleton = Notifications._instance;
    return singleton;
  }

  Notifications._internal() {
    print("Instance of Notifications created!");
    _restoreNotifications();
  }

  add(EnvoyNotification notification) {
    notifications.add(notification);
    notifications.sort((a, b) => b.date.compareTo(a.date));
    _storeNotifications();
    unread++;
  }

  _checkForNotificationsToAdd() {
    bool _notificationsAdded = false;
    for (var account in AccountManager().accounts) {
      for (var tx in account.wallet.transactions) {
        if ((tx.date.isAfter(lastUpdated) || !tx.isConfirmed) &&
            tx.amount > 0) {
          bool skip = false;

          for (var notification in notifications) {
            if (notification.id == tx.txId) {
              skip = true;
            }
          }

          if (!skip) {
            add(EnvoyNotification(
                "Transaction",
                tx.isConfirmed ? tx.date : DateTime.now(),
                EnvoyNotificationType.transaction,
                tx.txId,
                tx.txId,
                amount: tx.amount,
                walletName: account.wallet.name));

            _notificationsAdded = true;
          }
        }
      }
    }

    if (_notificationsAdded) {
      lastUpdated = DateTime.now();
    }
  }

  deleteFromAccount(Account account) {
    for (var notification in notifications) {
      if (notification.walletName != null &&
          notification.walletName == account.wallet.name) {
        notifications.remove(notification);
      }
    }
  }

  //ignore:unused_element
  _clearNotifications() {
    _ls.prefs.remove(_NOTIFICATIONS_PREFS);
  }

  _storeNotifications() {
    var jsonMap = {
      "last_updated": lastUpdated.toIso8601String(),
      "notifications": notifications
    };

    String json = jsonEncode(jsonMap);
    _ls.prefs.setString(_NOTIFICATIONS_PREFS, json);
  }

  _restoreNotifications() {
    if (_syncTimer != null) {
      _syncTimer!.cancel();
    }

    if (_ls.prefs.containsKey(_NOTIFICATIONS_PREFS)) {
      var jsonMap = jsonDecode(_ls.prefs.getString(_NOTIFICATIONS_PREFS)!);

      lastUpdated = DateTime.parse(jsonMap["last_updated"]);

      for (var notification in jsonMap["notifications"]) {
        notifications.add(EnvoyNotification.fromJson(notification));
        notifications.sort((a, b) => b.date.compareTo(a.date));
      }
    }

    _checkForNotificationsToAdd();
    _startPeriodicSync();
  }

  _startPeriodicSync() {
    // Sync periodically
    _syncTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      _checkForNotificationsToAdd();
    });
  }
}
