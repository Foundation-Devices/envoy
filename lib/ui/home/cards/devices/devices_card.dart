// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/business/devices.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/embedded_video.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/components/linear_gradient.dart';

//ignore: must_be_immutable
class DevicesCard extends ConsumerStatefulWidget {
  const DevicesCard({
    super.key,
  });

  @override
  ConsumerState createState() => DevicesCardState();
}

// The mixin is necessary to maintain state when widgets is not visible
// Unfortunately it seems to only work with TabView
class DevicesCardState extends ConsumerState<DevicesCard>
    with AutomaticKeepAliveClientMixin {
  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // });

    // Redraw when we there are changes in devices
    Devices().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    Devices().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ignore: unused_local_variable

    return DevicesList();
  }

  @override
  bool get wantKeepAlive => false;
}

//ignore: must_be_immutable
class DevicesList extends ConsumerStatefulWidget {
  DevicesList() : super(key: UniqueKey());

  @override
  ConsumerState<DevicesList> createState() => _DevicesListState();
}

class _DevicesListState extends ConsumerState<DevicesList> {
  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    // Redraw when we there are changes in devices
    Devices().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    Devices().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Devices().devices.isEmpty
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GhostDevice(),
                ),
              ],
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
              child: ScrollGradientMask(
                start: 0.03,
                topGradientValue: 0.075,
                bottomGradientValue: 0.905,
                end: 0.97,
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                        child: SizedBox(
                      height: EnvoySpacing.medium2,
                    )),
                    const SliverPadding(
                        padding: EdgeInsets.symmetric(
                            vertical: EnvoySpacing.xs / 2)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          var device = Devices().devices[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: EnvoySpacing.medium1),
                            child: DeviceListTile(
                              device,
                              onTap: () async {
                                ref
                                    .read(homePageOptionsVisibilityProvider
                                        .notifier)
                                    .state = false;
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  if (context.mounted) {
                                    context.go(ROUTE_DEVICE_DETAIL,
                                        extra: device);
                                  }
                                });
                                // widget.navigator!.push(DeviceCard(
                                //     device,
                                //     widget.navigator,
                                //     DeviceOptions(
                                //       device,
                                //       navigator: widget.navigator,
                                //     )));
                              },
                            ),
                          );
                        },
                        childCount: Devices().devices.length,
                      ),
                    ),
                    const SliverPadding(
                        padding: EdgeInsets.symmetric(
                            vertical: EnvoySpacing.medium2)),
                    const SliverToBoxAdapter(
                        child: SizedBox(
                      height: EnvoySpacing.medium2,
                    )),
                  ],
                ),
              ),
            ),
    );
  }
}

class GhostDevice extends StatelessWidget {
  GhostDevice({
    super.key,
  });

  final device = Device(
      "Primary",
      DeviceType.passportGen12,
      "serial", // TODO: FIGMA
      DateTime.now(),
      "2.1.1",
      Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color.fromRGBO(255, 255, 255, 0.75),
              BlendMode.hardLight,
            ),
            child: DeviceListTile(
              device,
              onTap: () {},
              ghostDevice: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  S().devices_empty_text_explainer,
                  style: EnvoyTypography.explainer,
                ),
                const SizedBox(width: EnvoySpacing.small),
                GestureDetector(
                  child: Text(S().component_learnMore,
                      style: EnvoyTypography.explainer
                          .copyWith(color: EnvoyColors.accentPrimary)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: const DeviceEmptyVideo());
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class DeviceEmptyVideo extends StatelessWidget {
  const DeviceEmptyVideo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var ctaTextStyle = const TextStyle(
        color: Colors.white,
        fontFamily: 'Montserrat',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        fontSize: 14);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.black,
        Color(0x00000000),
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(children: [
        SizedBox(
          height: 100,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    S().bottomNav_learn.toUpperCase(),
                    style: ctaTextStyle.copyWith(
                        fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.white,
                    blurRadius: 10,
                    offset: Offset(0, 0),
                    spreadRadius: 1),
              ],
            ),
            child: const EmbeddedVideo(
              path: "assets/videos/passport_ad.m4v",
              aspectRatio: 16 / 9,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Text(S().devices_empty_modal_video_cta2,
                    style: ctaTextStyle),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              GestureDetector(
                child: Text(
                  S().devices_empty_modal_video_cta1,
                  style:
                      ctaTextStyle.copyWith(color: EnvoyColors.accentPrimary),
                ),
                onTap: () {
                  launchUrlString("https://foundation.xyz/passport/");
                },
              ),
            ],
          ),
        )
      ]),
    );
  }
}
