// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_tor/http_tor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tor/tor.dart';
import 'dart:convert';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/scheduler.dart';

part 'notifications.g.dart';

enum EnvoyNotificationType { firmware, transaction, security, envoyUpdate }

const String updateAppId = "updateApp";

@JsonSerializable()
class EnvoyNotification {
  final String title;
  final DateTime date;
  final EnvoyNotificationType type;
  final String body;
  final String id;
  final int? amount;
  final String? accountId;

  EnvoyNotification(this.title, this.date, this.type, this.body, this.id,
      {this.amount, this.accountId});

  // Serialisation
  factory EnvoyNotification.fromJson(Map<String, dynamic> json) =>
      _$EnvoyNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$EnvoyNotificationToJson(this);
}

final notificationStreamProvider = StreamProvider<List<EnvoyNotification>>(
    (ref) => Notifications().getNotificationsStream());

// filter state provider for notifications
final notificationTypeFilterProvider =
    StateProvider.autoDispose<EnvoyNotificationType?>((ref) => null);

// order provider for notification sort. 0 for descending, 1 for ascending
final notificationOrderProvider = StateProvider<int>((ref) => 0);

final filteredNotificationStreamProvider =
    Provider.autoDispose<List<EnvoyNotification>>((ref) {
  List<EnvoyNotification> notifications =
      ref.watch(notificationStreamProvider).valueOrNull ?? [];
  EnvoyNotificationType? filter = ref.watch(notificationTypeFilterProvider);
  int order = ref.watch(notificationOrderProvider);

  if (order == 0) {
    notifications.sort((a, b) => b.date.compareTo(a.date));
  }
  if (filter == null) {
    return List<EnvoyNotification>.from(notifications);
  } else {
    return notifications.where((element) => element.type == filter).toList();
  }
});

class Notifications {
  int unread = 0;
  late DateTime lastUpdated = DateTime.now();
  Timer? _syncTimer;

  StreamController<List<EnvoyNotification>> streamController =
      StreamController();
  List<EnvoyNotification> notifications = [];
  LocalStorage _ls = LocalStorage();

  static const String NOTIFICATIONS_PREFS = "notifications";

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
    _storeNotifications();
    unread++;
    sync();
  }

  _checkForNotificationsToAdd() async {
    bool _notificationsAdded = false;
    bool _newEnvoyVersionAvailable = await isThereNewEnvoyVersion();

    for (var account in AccountManager().accounts) {
      for (var tx in account.wallet.transactions) {
        if ((tx.date.isAfter(lastUpdated) || !tx.isConfirmed)) {
          bool skip = false;

          for (var notification in notifications) {
            if (notification.id == tx.txId &&
                notification.amount == tx.amount) {
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
                accountId: account.id));
            _notificationsAdded = true;
          }
        }
      }
    }

    for (var device in Devices().devices) {
      final version = Devices().getDeviceFirmwareVersion(device.serial);
      bool _fwUpdateAvailable =
          await UpdatesManager().shouldUpdate(version, device.type);
      final newVersion =
          await UpdatesManager().getStoredFwVersion(device.type.index);
      for (var notification in notifications) {
        if (notification.id == device.type.toString().split('.').last) {
          if (notification.body == newVersion!) {
            _fwUpdateAvailable = false;
          }
        }
      }

      if (_fwUpdateAvailable) {
        add(EnvoyNotification(
          "Firmware", // TODO: FIGMA
          DateTime.now(),
          EnvoyNotificationType.firmware,
          newVersion!,
          device.type.toString().split('.').last,
        ));
        _notificationsAdded = true;
      }
    }

    if (_newEnvoyVersionAvailable) {
      var latestEnvoyVersion = await fetchLatestEnvoyVersionFromGit();
      bool skip = false;
      for (var notification in notifications) {
        if (notification.type == EnvoyNotificationType.envoyUpdate) {
          if (notification.body == latestEnvoyVersion) {
            skip = true;
          }
        }
      }
      if (!skip) {
        add(EnvoyNotification(
          "App Update", // TODO: FIGMA
          DateTime.now(),
          EnvoyNotificationType.envoyUpdate,
          latestEnvoyVersion,
          EnvoyNotificationType.envoyUpdate.name,
        ));
        _notificationsAdded = true;
      }
    }

    if (_notificationsAdded) {
      lastUpdated = DateTime.now();
    }
  }

  deleteFromAccount(Account account) {
    notifications.removeWhere((element) => account.id == element.accountId);
    _storeNotifications();
    sync();
  }

  getNotificationsStream() {
    return streamController.stream;
  }

  //ignore:unused_element
  _clearNotifications() {
    _ls.prefs.remove(NOTIFICATIONS_PREFS);
  }

  dispose() {
    streamController.close();
  }

  _storeNotifications() {
    var jsonMap = {
      "last_updated": lastUpdated.toIso8601String(),
      "notifications": notifications
    };

    String json = jsonEncode(jsonMap);
    _ls.prefs.setString(NOTIFICATIONS_PREFS, json);
  }

  _restoreNotifications() {
    if (_syncTimer != null) {
      _syncTimer!.cancel();
    }

    if (_ls.prefs.containsKey(NOTIFICATIONS_PREFS)) {
      var jsonMap = jsonDecode(_ls.prefs.getString(NOTIFICATIONS_PREFS)!);

      lastUpdated = DateTime.parse(jsonMap["last_updated"]);

      for (var notification in jsonMap["notifications"]) {
        notifications.add(EnvoyNotification.fromJson(notification));
      }
      sync();
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

  Future<String> fetchLatestEnvoyVersionFromGit() async {
    HttpTor http = HttpTor(Tor.instance, EnvoyScheduler().parallel);
    final response = await http.get(
        'https://api.github.com/repos/Foundation-Devices/envoy/releases/latest',
        headers: {'User-Agent': 'request'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('tag_name')) {
        final version = data['tag_name'];
        return version;
      } else
        throw Exception("Couldn't find tag_name in GitHub response");
    } else {
      throw Exception("Couldn't reach GitHub");
    }
  }

  Future<bool> isThereNewEnvoyVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Version envoyVersionOnPhone = Version.parse(packageInfo.version);

    String versionOnGitHub;

    try {
      versionOnGitHub = await fetchLatestEnvoyVersionFromGit();
    } on Exception catch (_) {
      return false;
    }

    var latestGitHubVersion =
        Version.parse(versionOnGitHub.replaceAll("v", ""));
    return latestGitHubVersion > envoyVersionOnPhone;
  }

  void sync() {
    streamController.sink.add(notifications);
  }
}
