// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/ui/home/cards/tl_navigation_card.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/ui/components/list_item.dart';
import 'package:intl/intl.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';

final String defaultLocale = Platform.localeName;

//ignore: must_be_immutable
class ActivityCard extends StatefulWidget with TopLevelNavigationCard {
  @override
  TopLevelNavigationCardState<TopLevelNavigationCard> createState() {
    var state = ActivityCardState();
    tlCardState = state;
    return state;
  }
}

class ActivityCardState extends State<ActivityCard>
    with TopLevelNavigationCardState {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    push(TopLevelActivityCard());
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 250), child: cardStack.last);
  }
}

//ignore: must_be_immutable
class TopLevelActivityCard extends StatelessWidget with NavigationCard {
  TopLevelActivityCard() {}

  @override
  IconData? rightFunctionIcon = null;

  @override
  bool modal = false;

  @override
  CardNavigator? navigator;

  @override
  Function()? onPop;

  @override
  Widget? optionsWidget = null;

  @override
  Function()? rightFunction;

  @override
  String? title = S().bottomNav_activity.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EnvoyColors.surface1,
      child: Padding(
        padding: EdgeInsets.all(EnvoySpacing.medium2),
        child: Consumer(
          builder: (context, ref, _) {
            List<EnvoyNotification> notifications =
                ref.watch(filteredNotificationStreamProvider);
            ref.read(notificationTypeFilterProvider.notifier).state = null;

            return notifications.isEmpty
                ? Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: EnvoySpacing.small,
                            ),
                            ListHeader(
                              title: S().activity_listHeader_Today,
                            ),
                            GhostListTile(
                              animate: false,
                              isLeadingRound: true,
                            ),
                          ],
                        ),
                        Text(
                          S().activity_emptyState_label,
                          style: EnvoyTypography.body2Medium
                              .copyWith(color: EnvoyColors.textSecondary),
                        ),
                        SizedBox(
                          height: EnvoySpacing.medium2,
                        ),
                      ],
                    ),
                  )
                : Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ListView.builder(
                            padding: EdgeInsets.only(top: 15.0),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  if (index == 0 ||
                                      showHeader(notifications[index],
                                          notifications[index - 1]))
                                    Column(
                                      children: [
                                        if (index != 0)
                                          SizedBox(
                                            height: EnvoySpacing.medium2,
                                          ),
                                        ListHeader(
                                            title: getTransactionDateString(
                                                notifications[index])),
                                      ],
                                    ),
                                  ActivityListTile(notifications[index]),
                                ],
                              );
                            },
                            itemCount: notifications.length)
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}

String getTransactionDateString(EnvoyNotification notification) {
  return DateFormat('dd/MM/yy', defaultLocale).format(notification.date);
}

bool showHeader(EnvoyNotification notificationCurrent,
    EnvoyNotification notificationPrevious) {
  return !DateUtils.isSameDay(
      notificationCurrent.date, notificationPrevious.date);
}
