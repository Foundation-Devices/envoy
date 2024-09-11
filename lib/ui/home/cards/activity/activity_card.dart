// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
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
import 'package:envoy/business/locale.dart';
import 'package:envoy/ui/components/linear_gradient.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/state/transactions_state.dart';

class ActivityCard extends StatefulWidget {
  const ActivityCard({super.key});

  @override
  State<ActivityCard> createState() => ActivityCardState();
}

class ActivityCardState extends State<ActivityCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AnimatedSwitcher(
        duration: Duration(milliseconds: 250), child: TopLevelActivityCard());
  }
}

//ignore: must_be_immutable
class TopLevelActivityCard extends ConsumerStatefulWidget {
  const TopLevelActivityCard({super.key});

  @override
  TopLevelActivityCardState createState() => TopLevelActivityCardState();
}

class TopLevelActivityCardState extends ConsumerState<TopLevelActivityCard> {
  @override
  void initState() {
    super.initState();
    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);
  }

  @override
  void dispose() {
    ExchangeRate().removeListener(_redraw);
    super.dispose();
  }

  _redraw() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider);
    List<EnvoyNotification> nonTxNotifications =
        ref.watch(nonTxNotificationStreamProvider);
    List<Transaction> transactions = ref.watch(allTxProvider);

    List<CombinedNotifications> combinedNotifications =
        combineAndSortByDate(nonTxNotifications, transactions);

    return ScrollGradientMask(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
        child: CustomScrollView(slivers: [
          combinedNotifications.isEmpty
              ? SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: EnvoySpacing.small,
                          ),
                          ListHeader(
                            title: S().activity_listHeader_Today,
                          ),
                          const ActivityGhostListTile(
                            animate: false,
                          ),
                        ],
                      ),
                      Text(
                        S().activity_emptyState_label,
                        style: EnvoyTypography.body
                            .copyWith(color: EnvoyColors.textSecondary),
                      ),
                      const SizedBox(
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
                          padding: const EdgeInsets.only(top: 15.0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                if (index == 0 ||
                                    showHeader(combinedNotifications[index],
                                        combinedNotifications[index - 1]))
                                  Column(
                                    children: [
                                      if (index != 0)
                                        const SizedBox(
                                          height: EnvoySpacing.medium2,
                                        ),
                                      if (index == 0)
                                        const SizedBox(
                                          height: EnvoySpacing.small,
                                        ),
                                      ListHeader(
                                          title: getTransactionDateString(
                                              combinedNotifications[index])),
                                    ],
                                  ),
                                ActivityListTile(combinedNotifications[index]),
                              ],
                            );
                          },
                          itemCount: combinedNotifications.length),
                      const SizedBox(height: EnvoySpacing.large2)
                    ],
                  ),
                )
        ]),
      ),
    );
  }
}

class CombinedNotifications {
  final DateTime? date;
  final Transaction? transaction;
  final EnvoyNotification? notification;

  CombinedNotifications(
      {required this.date, this.transaction, this.notification});
}

List<CombinedNotifications> combineAndSortByDate(
    List<EnvoyNotification> envoyNotifications,
    List<Transaction> transactions) {
  List<CombinedNotifications> combinedItems = [];

  for (var notification in envoyNotifications) {
    combinedItems.add(CombinedNotifications(
        date: notification.date ?? DateTime.now(), notification: notification));
  }

  for (var transaction in transactions) {
    combinedItems.add(CombinedNotifications(
        date: transaction.isConfirmed ? transaction.date : null,
        transaction: transaction));
  }

  combinedItems.sort((a, b) {
    if (b.date == null && a.date == null) return 0;
    // Sort null dates (indicating pending transactions) to the top
    if (b.date == null) return 1;
    if (a.date == null) return -1;
    return b.date!.compareTo(a.date!);
  });

  return combinedItems;
}

String getTransactionDateString(CombinedNotifications notification) {
  return DateFormat.yMd(currentLocale)
      .format(notification.date ?? DateTime.now());
}

bool showHeader(CombinedNotifications notificationCurrent,
    CombinedNotifications notificationPrevious) {
  return !DateUtils.isSameDay(notificationCurrent.date ?? DateTime.now(),
      notificationPrevious.date ?? DateTime.now());
}

class ActivityGhostListTile extends StatelessWidget {
  final bool animate;

  const ActivityGhostListTile({
    this.animate = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
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
