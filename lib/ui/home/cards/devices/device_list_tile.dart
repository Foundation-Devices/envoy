// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/devices.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/components/stripe_painter.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

final shouldUpdateProvider =
    FutureProvider.family<bool, Device>((ref, device) async {
  final version = Devices().getDeviceFirmwareVersion(device.serial);
  if (version == null) {
    return false;
  }
  return UpdatesManager().shouldUpdate(version, device.type);
});

class DeviceListTile extends ConsumerStatefulWidget {
  final void Function() onTap;
  final Device device;
  final bool ghostDevice;

  const DeviceListTile(
    this.device, {
    super.key,
    required this.onTap,
    this.ghostDevice = false,
  });

  @override
  ConsumerState<DeviceListTile> createState() => _DeviceListTileState();
}

class _DeviceListTileState extends ConsumerState<DeviceListTile> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(shouldUpdateProvider(widget.device));
    });
  }

  @override
  Widget build(BuildContext context) {
    var fwShouldUpdate = ref.watch(shouldUpdateProvider(widget.device));
    var fwInfo = ref.watch(firmwareStreamProvider(widget.device.type.index));
    bool fwAvailable = fwInfo.hasValue && fwInfo.value != null;

    const double cardRadius = EnvoySpacing.medium2;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.all(Radius.circular(cardRadius - 1)),
            border: Border.all(
                color: Colors.black, width: 2, style: BorderStyle.solid),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [
                  0.6,
                  1.0
                ],
                colors: [
                  Colors.black,
                  widget.device.color,
                ]),
          ),
          child: Container(
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.all(Radius.circular(cardRadius - 3)),
                border: Border.all(
                    color: widget.device.color,
                    width: 2,
                    style: BorderStyle.solid)),
            child: ClipRRect(
                borderRadius:
                    const BorderRadius.all(Radius.circular(cardRadius - 5)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        isComplex: true,
                        willChange: false,
                        painter: StripePainter(
                          EnvoyColors.gray1000.applyOpacity(0.4),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      EnvoyColors.deviceBackgroundGradientGrey,
                                      Colors.white,
                                    ]),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(EnvoySpacing.medium1))),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Image.asset(
                                getProductImage(widget.device.type),
                                height: 200,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: 75,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.device.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                          ),
                                          const SizedBox(),
                                          Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            widget.device.type ==
                                                    DeviceType.passportGen12
                                                ? "Passport" // TODO: FIGMA
                                                : "Founder's Edition",
                                            // TODO: FIGMA
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          widget.ghostDevice
                                              ? Text(
                                                  "FW 2.1.1", // TODO: FIGMA
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          color: Colors.white),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    if (!fwAvailable) {
                                                      return;
                                                    }
                                                    context.goNamed(
                                                        PASSPORT_UPDATE,
                                                        extra: FwPagePayload(
                                                          onboarding: false,
                                                          deviceId: widget
                                                              .device
                                                              .type
                                                              .index,
                                                        ));
                                                    return;
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)),
                                                      color: Colors.black
                                                          .applyOpacity(0.6),
                                                      border: Border.all(
                                                          color: widget
                                                              .device.color,
                                                          width: 2,
                                                          style: BorderStyle
                                                              .solid),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              EnvoySpacing.xs),
                                                      child: Row(
                                                        children: [
                                                          if (fwShouldUpdate.hasValue &&
                                                              fwShouldUpdate
                                                                      .value !=
                                                                  null &&
                                                              fwShouldUpdate
                                                                  .value!)
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      EnvoySpacing
                                                                          .xs),
                                                              child: Container(
                                                                height: 8.0,
                                                                width: 8.0,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                              ),
                                                            ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        3.0),
                                                            child: SvgPicture.asset(
                                                                "assets/fw.svg"),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 2.0),
                                                            child: Text(
                                                              fwAvailable
                                                                  ? ("FW ${fwInfo.value!.storedVersion}")
                                                                  : "Loading",
                                                              // TODO: FIGMA
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                        ])
                                  ],
                                ))),
                      ],
                    ),
                  ],
                )),
          )),
    );
  }

  String getProductImage(DeviceType type) {
    switch (type) {
      case DeviceType.passportGen1:
        return "assets/passport1.png";
      case DeviceType.passportGen12:
        return "assets/passport12.png";
      case DeviceType.passportPrime:
        return "assets/prime_device_tile.png";
    }
  }
}
