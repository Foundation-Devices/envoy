// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/list_utils.dart';
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

StreamController<String> isNewAppVersionAvailable =
    StreamController.broadcast();

final isNewExpiredBuyTxAvailable =
    StreamController<List<EnvoyTransaction>>.broadcast();

@JsonSerializable()
class EnvoyNotification {
  final String title;
  final DateTime? date;
  final EnvoyNotificationType type;
  final String body;
  final String id;
  final int? amount;
  final String? accountId;
  final EnvoyTransaction? transaction;

  EnvoyNotification(
      this.title, this.date, this.type, this.body, this.id, this.transaction,
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

final nonTxNotificationStreamProvider =
    Provider<List<EnvoyNotification>>((ref) {
  // Get all notifications from the notificationStreamProvider
  final notifications = ref.watch(notificationStreamProvider).valueOrNull ?? [];

  return notifications
      .where((notification) =>
          notification.type != EnvoyNotificationType.transaction)
      .toList();
});

EnvoyNotification transactionToEnvoyNotification(EnvoyTransaction transaction) {
  return EnvoyNotification(
    "Transaction Notification",
    transaction.isConfirmed
        ? DateTime.fromMillisecondsSinceEpoch(transaction.date!.toInt() * 1000,
            isUtc: true)
        : null,
    EnvoyNotificationType.transaction,
    "Transaction details",
    transaction.txId,
    transaction,
    amount: transaction.amount,
    accountId: NgAccountManager().getAccountIdByTransaction(transaction.txId),
  );
}

List<EnvoyNotification> combineNotifications(
    List<EnvoyNotification> envoyNotifications,
    List<EnvoyTransaction> transactions) {
  List<EnvoyNotification> transactionNotifications =
      transactions.map((transaction) {
    return transactionToEnvoyNotification(transaction);
  }).toList();

  List<EnvoyNotification> combinedItems = [
    ...envoyNotifications,
    ...transactionNotifications
  ];

  combinedItems.sort((a, b) {
    if (b.date == null && a.date == null) return 0;
    if (b.date == null) return 1;
    if (a.date == null) return -1;
    return b.date!.compareTo(a.date!);
  });

  return combinedItems;
}

class Notifications {
  int unread = 0;
  Timer? _syncTimer;
  bool _githubVersionChecked = false;

  StreamController<List<EnvoyNotification>> streamController =
      StreamController();
  List<EnvoyNotification> notifications = [];
  List<EnvoyNotification> notificationsThatWillBeSuppressed = [];

  final LocalStorage _ls = LocalStorage();

  static const String notificationPrefs = "notifications";

  static final Notifications _instance = Notifications._internal();

  factory Notifications() {
    return _instance;
  }

  static Future<Notifications> init() async {
    var singleton = Notifications._instance;
    return singleton;
  }

  Notifications._internal() {
    kPrint("Instance of Notifications created!");
    restoreNotifications();
  }

  add(EnvoyNotification notification) {
    notifications.add(notification);
    _storeNotifications();
    unread++;
    sync();
  }

  void deleteNotification(String id,
      {String? accountId, Duration delay = Duration.zero}) {
    // Find the notification immediately and put it in notificationsThatWillBeSuppressed
    EnvoyNotification? notificationToSuppress = notifications.firstWhereOrNull(
      (notification) =>
          notification.id == id && notification.accountId == accountId,
    );

    if (notificationToSuppress != null) {
      notificationsThatWillBeSuppressed.add(notificationToSuppress);

      // Schedule the deletion from notifications after the delay
      Future.delayed(delay, () {
        notifications.removeWhere((notification) =>
            notification.id == id && notification.accountId == accountId);
        notificationsThatWillBeSuppressed.removeWhere((notification) =>
            notification.id == id && notification.accountId == accountId);
        _storeNotifications();
        sync();
      });
    }
  }

  void deleteSuppressedNotifications(String? accountId) {
    var suppressedNotificationsToDelete = notificationsThatWillBeSuppressed
        .where(
          (notification) => notification.accountId == accountId,
        )
        .toList();

    for (var notification in suppressedNotificationsToDelete) {
      deleteNotification(notification.id, accountId: notification.accountId);
    }
  }

  // TODO: refactor this to monstrosity to use composable providers
  _checkForNotificationsToAdd() async {
    bool newEnvoyVersionAvailable = false;
    if (!_githubVersionChecked) {
      newEnvoyVersionAvailable = await isThereNewEnvoyVersion();
      _githubVersionChecked = true;
    }

    for (var device in Devices().devices) {
      final version = Devices().getDeviceFirmwareVersion(device.serial);

      if (version != null) {
        bool fwUpdateAvailable =
            await UpdatesManager().shouldUpdate(version, device.type);
        final newVersion = await UpdatesManager()
            .getStoredFirmwareVersionString(device.type.index);
        for (var notification in notifications) {
          if (notification.body == newVersion!) {
            fwUpdateAvailable = false;
          }
        }

        if (fwUpdateAvailable) {
          add(EnvoyNotification(
              "Firmware", // TODO: FIGMA
              DateTime.now(),
              EnvoyNotificationType.firmware,
              newVersion!,
              device.type.toString().split('.').last,
              null));
        }
      }
    }

    if (newEnvoyVersionAvailable) {
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
            null));
        if (!isNewAppVersionAvailable.isClosed) {
          isNewAppVersionAvailable.add(latestEnvoyVersion);
        }
      }
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
    _ls.prefs.remove(notificationPrefs);
  }

  dispose() {
    streamController.close();
  }

  _storeNotifications() {
    var jsonMap = {"notifications": notifications};

    String json = jsonEncode(jsonMap);
    _ls.prefs.setString(notificationPrefs, json);
  }

  restoreNotifications() {
    if (_syncTimer != null) {
      _syncTimer!.cancel();
    }

    notifications.clear();

    if (_ls.prefs.containsKey(notificationPrefs)) {
      String? jsonString = _ls.prefs.getString(notificationPrefs);
      if (jsonString != null) {
        var jsonMap = jsonDecode(jsonString);
        for (var notification in jsonMap["notifications"]) {
          EnvoyNotification notificationToRestore =
              EnvoyNotification.fromJson(notification);

          // Only add tx notifications that link to an account
          if (!_shouldBeRemoved(notificationToRestore)) {
            add(notificationToRestore);
          }
        }
      }
    }

    _checkForNotificationsToAdd();
    _startPeriodicSync();
  }

  bool _shouldBeRemoved(EnvoyNotification notification) {
    if (notification.type != EnvoyNotificationType.firmware) {
      return false;
    }
    if (notification.type == EnvoyNotificationType.transaction) {
      return true;
    }
    // Remove notification if already has been stored version with same firmware version
    if (notification.type == EnvoyNotificationType.firmware) {
      for (var alreadyStoredNotification in notifications) {
        if (alreadyStoredNotification.type == EnvoyNotificationType.firmware &&
            alreadyStoredNotification.body == notification.body) {
          return true;
        }
      }
      return false;
    }

    if (notification.accountId == null) {
      return true;
    }

    return !NgAccountManager()
        .accounts
        .any((account) => account.id == notification.accountId);
  }

  _startPeriodicSync() {
    // Sync periodically
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
      } else {
        EnvoyReport().log(
            "EnvoyGHVersionCheck", "Couldn't find tag_name in GitHub response");
        throw Exception("Couldn't find tag_name in GitHub response");
      }
    } else {
      EnvoyReport().log("EnvoyGHVersionCheck",
          "Couldn't reach GitHub,${response.statusCode} ${response.body}");
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
