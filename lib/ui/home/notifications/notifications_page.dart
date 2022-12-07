// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/ui/amount.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  EnvoyNotificationType? _notificationType;

  @override
  Widget build(BuildContext context) {
    double _topOffset = MediaQuery.of(context).padding.top;
    //double _appBarHeight = AppBar().preferredSize.height;
    double _paddingTop = _topOffset + 10;

    var n = Notifications().notifications;
    List<EnvoyNotification> filtered = _notificationType == null
        ? n
        : n.where((element) => element.type == _notificationType).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return Consumer(
      builder: (context, ref, _) {
        List<EnvoyNotification> notifications =
            ref.watch(filteredNotificationStreamProvider);
        return Container(
          color: Colors.black,
          child: Padding(
            padding: EdgeInsets.only(top: _paddingTop, left: 20, right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: NotificationTypeToggle((type) {
                    ref.read(notificationTypeFilterProvider.notifier).state =
                        type;
                  }),
                ),
                ListView.builder(
                    padding: EdgeInsets.only(top: 15.0),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          //if (index == 0) Text("Just now"),
                          NotificationTile(notifications[index]),
                        ],
                      );
                    },
                    itemCount: notifications.length)
              ],
            ),
          ),
        );
      },
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile(
    this.notification, {
    Key? key,
  }) : super(key: key);

  final EnvoyNotification notification;

  @override
  Widget build(BuildContext context) {
    IconData? icon;
    String? title;

    if (notification.type == EnvoyNotificationType.transaction) {
      icon = notification.amount! >= 0
          ? Icons.arrow_circle_down
          : Icons.arrow_circle_up;
      title = notification.amount! >= 0 ? "Received" : "Sent";
    } else if (notification.type == EnvoyNotificationType.firmware) {
      icon = Icons.settings_backup_restore;
      title = notification.title;
    } else if (notification.type == EnvoyNotificationType.security) {
      icon = Icons.pan_tool_outlined;
      title = notification.title;
    }

    return ListTile(
      leading: Icon(
        icon,
        color: EnvoyColors.white80,
        size: 35,
      ),
      title: Text(title!, style: TextStyle(color: EnvoyColors.white80)),
      subtitle: Text(timeago.format(notification.date),
          style: TextStyle(color: EnvoyColors.white80)),
      trailing: notification.type == EnvoyNotificationType.transaction
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(getFormattedAmount(notification.amount!),
                    style: TextStyle(color: EnvoyColors.white80)),
                Text(ExchangeRate().getFormattedAmount(notification.amount!),
                    style: TextStyle(color: EnvoyColors.white80))
              ],
            )
          : SizedBox.shrink(),
    );
  }
}

class NotificationTypeToggle extends StatefulWidget {
  final Function(EnvoyNotificationType? type) callback;

  NotificationTypeToggle(this.callback);

  @override
  State<NotificationTypeToggle> createState() => _NotificationTypeToggleState();
}

class _NotificationTypeToggleState extends State<NotificationTypeToggle> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NeumorphicToggle(
        height: 30,
        selectedIndex: _selectedIndex,
        displayForegroundOnlyIfSelected: true,
        style: NeumorphicToggleStyle(disableDepth: true),
        children: [
          NotificationsToggleElement("All"),
          NotificationsToggleElement("Txs"),
          NotificationsToggleElement("Updates"),
          NotificationsToggleElement("Security"),
        ],
        thumb: Neumorphic(),
        onChanged: (value) {
          setState(() {
            _selectedIndex = value;
          });

          EnvoyNotificationType? type;

          if (_selectedIndex == 1) {
            type = EnvoyNotificationType.transaction;
          } else if (_selectedIndex == 2) {
            type = EnvoyNotificationType.firmware;
          } else if (_selectedIndex == 3) {
            type = EnvoyNotificationType.security;
          }

          widget.callback(type);
        });
  }
}

class NotificationsToggleElement implements ToggleElement {
  final String label;

  NotificationsToggleElement(this.label);

  @override
  Widget? get background => NotificationsToggleButton(label: label, dark: true);

  @override
  Widget? get foreground => NotificationsToggleButton(label: label);
}

class NotificationsToggleButton extends StatelessWidget {
  const NotificationsToggleButton({
    this.dark: false,
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: EnvoyColors.darkTeal, //color of border
            width: 1, //width of border
          ),
          color: dark ? Colors.black : EnvoyColors.darkTeal,
        ),
        child: Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              label,
              style: TextStyle(
                  color: dark ? EnvoyColors.darkTeal : Colors.black,
                  fontSize: 11.5),
            ),
          ),
        ),
      ),
    );
  }
}
