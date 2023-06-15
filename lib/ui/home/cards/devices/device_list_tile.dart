// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/settings.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/business/devices.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:envoy/ui/pages/fw/fw_intro.dart';

class DeviceListTile extends StatefulWidget {
  final void Function() onTap;
  final Device device;
  final bool ghostDevice;

  DeviceListTile(
    this.device, {
    Key? key,
    required this.onTap,
    this.ghostDevice = false,
  }) : super(key: key);

  @override
  State<DeviceListTile> createState() => _DeviceListTileState();
}

class _DeviceListTileState extends State<DeviceListTile> {
  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);

    // Redraw when we change bitcoin unit
    Settings().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();

    ExchangeRate().removeListener(_redraw);
    Settings().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    bool fwUpdateAvailable = UpdatesManager()
        .shouldUpdate(widget.device.firmwareVersion, widget.device.type);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all(
                color: Colors.black, width: 2, style: BorderStyle.solid),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
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
                borderRadius: BorderRadius.all(Radius.circular(18)),
                border: Border.all(
                    color: widget.device.color,
                    width: 2,
                    style: BorderStyle.solid)),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: LinesPainter(
                            color: EnvoyColors.tilesLineDarkColor,
                            opacity: 1.0),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      EnvoyColors.deviceBackgroundGradientGrey,
                                      Colors.white,
                                    ]),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Image.asset(
                                widget.device.type == DeviceType.passportGen12
                                    ? "assets/passport12.png"
                                    : "assets/passport1.png",
                                height: 200,
                              ),
                            ),
                          ),
                        ),
                        Container(
                            height: 75,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.device.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.device.type ==
                                                DeviceType.passportGen12
                                            ? "Passport"
                                            : "Founder's Edition",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(color: Colors.white),
                                      ),
                                      widget.device.type ==
                                                  DeviceType.passportGen1 ||
                                              widget.ghostDevice
                                          ? Text(
                                              " FW " +
                                                  widget.device.firmwareVersion,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      color: Colors.white),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return FwIntroPage(
                                                    onboarding: false,
                                                  );
                                                }));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                  border: Border.all(
                                                      color:
                                                          widget.device.color,
                                                      width: 2,
                                                      style: BorderStyle.solid),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Row(
                                                    children: [
                                                      if (fwUpdateAvailable)
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          child: Container(
                                                            height: 8.0,
                                                            width: 8.0,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                        ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    3.0),
                                                        child: SvgPicture.asset(
                                                            "assets/fw.svg"),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 2.0),
                                                        child: Text(
                                                          " FW " +
                                                              (fwUpdateAvailable
                                                                  ? UpdatesManager()
                                                                      .getStoredFwVersion()!
                                                                  : widget
                                                                      .device
                                                                      .firmwareVersion),
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
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                )),
          )),
    );
  }
}
