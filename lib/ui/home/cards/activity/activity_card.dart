// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/ui/components/list_item.dart';
import 'package:intl/intl.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/loader_ghost.dart';

final String defaultLocale = Platform.localeName;

//ignore: must_be_immutable
class ActivityCard extends StatefulWidget {
  @override
  State<ActivityCard> createState() => ActivityCardState();
}

class ActivityCardState extends State<ActivityCard> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    return AnimatedSwitcher(
        duration: Duration(milliseconds: 250), child: TopLevelActivityCard());
  }
}

//ignore: must_be_immutable
class TopLevelActivityCard extends StatelessWidget {
  TopLevelActivityCard() {}

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            EnvoyColors.solidWhite,
            Colors.transparent,
            Colors.transparent,
            EnvoyColors.solidWhite,
          ],
          stops: [0.0, 0.02, 0.97, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
        child: Consumer(
          builder: (context, ref, _) {
            List<EnvoyNotification> notifications =
                ref.watch(filteredNotificationStreamProvider);
            ref.read(notificationTypeFilterProvider.notifier).state = null;

            return CustomScrollView(slivers: [
              notifications.isEmpty
                  ? SliverFillRemaining(
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
                              ActivityGhostListTile(
                                animate: false,
                              ),
                            ],
                          ),
                          Text(
                            S().activity_emptyState_label,
                            style: EnvoyTypography.body
                                .copyWith(color: EnvoyColors.textSecondary),
                          ),
                          SizedBox(
                            height: EnvoySpacing.medium2,
                          ),
                        ],
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          ListView.builder(
                              padding: EdgeInsets.only(top: 15.0),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
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
                    )
            ]);
          },
        ),
      ),
    );
  }
}

String getTransactionDateString(EnvoyNotification notification) {
  return DateFormat.yMd(defaultLocale).format(notification.date);
}

bool showHeader(EnvoyNotification notificationCurrent,
    EnvoyNotification notificationPrevious) {
  return !DateUtils.isSameDay(
      notificationCurrent.date, notificationPrevious.date);
}

class ActivityGhostListTile extends StatelessWidget {
  final bool animate;

  const ActivityGhostListTile({
    this.animate = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      minLeadingWidth: 0,
      horizontalTitleGap: EnvoySpacing.small,
      title: Padding(
        padding: const EdgeInsets.only(top: 2, right: EnvoySpacing.medium2),
        child: LoaderGhost(
          width: 10,
          height: 14,
          animate: animate,
        ),
      ),
      subtitle: Padding(
        padding:
            const EdgeInsets.only(top: 5.0, right: (EnvoySpacing.medium2 + 75)),
        child: LoaderGhost(
          width: 30,
          height: 14,
          animate: animate,
        ),
      ),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoaderGhost(
            width: EnvoySpacing.medium2,
            height: EnvoySpacing.medium2,
            diagonal: false,
            animate: animate,
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            LoaderGhost(
              width: 60,
              height: 14,
              animate: animate,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: LoaderGhost(
                width: 40,
                height: 14,
                animate: animate,
              ),
            )
          ],
        ),
      ),
    );
  }
}
