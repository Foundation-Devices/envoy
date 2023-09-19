// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/devices.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

//ignore: must_be_immutable
class DeviceCard extends ConsumerStatefulWidget {
  final Device device;

  DeviceCard(this.device) : super(key: UniqueKey()) {}

  @override
  ConsumerState<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends ConsumerState<DeviceCard> {
  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we there are changes in devices
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(homePageTitleProvider.notifier).state =
          S().manage_device_details_heading.toUpperCase();
      ref.read(homeShellOptionsProvider.notifier).state = HomeShellOptions(
          optionsWidget: DeviceOptions(widget.device),
          rightAction: Consumer(
            builder: (context, ref, child) {
              bool menuVisible = ref.watch(homePageOptionsVisibilityProvider);
              return IconButton(
                  onPressed: () {
                    HomePageState.of(context)?.toggleOptions();
                  },
                  icon: Icon(
                      menuVisible ? Icons.close : Icons.more_horiz_outlined));
            },
          ));
    });

    Devices().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    Devices().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
        child: DeviceListTile(widget.device, onTap: () {
          GoRouter.of(context).pop();
        }),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 18.0, left: 35.0),
        child: Text(S().envoy_device_serial + ": " + widget.device.serial),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 35.0),
        child: Text(S().envoy_device_paired +
            " " +
            timeago.format(widget.device.datePaired)),
      ),
    ]);
  }
}

class DeviceOptions extends ConsumerStatefulWidget {
  final Device device;

  DeviceOptions(this.device);

  @override
  ConsumerState<DeviceOptions> createState() => _DeviceOptionsState();
}

class _DeviceOptionsState extends ConsumerState<DeviceOptions> {
  late TextEntry textEntry;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().envoy_device_edit_device_name.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            bool isKeyboardShown = false;
            showEnvoyDialog(
                context: context,
                dialog: Builder(builder: (BuildContext context) {
                  if (!isKeyboardShown) {
                    Future.delayed(Duration(milliseconds: 200)).then((value) {
                      FocusScope.of(context).requestFocus(focusNode);
                    });
                    isKeyboardShown = true;
                    textEntry = TextEntry(
                      focusNode: focusNode,
                      maxLength: 20,
                      placeholder: widget.device.name,
                    );
                  }
                  return EnvoyDialog(
                    title: S().envoy_device_rename,
                    content: textEntry,
                    actions: [
                      EnvoyButton(
                        S().component_save.toUpperCase(),
                        type: EnvoyButtonTypes.primaryModal,
                        onTap: () {
                          Devices().renameDevice(
                              widget.device, textEntry.enteredText);
                          Navigator.pop(context);
                          context.go(ROUTE_DEVICES);
                        },
                      ),
                    ],
                  );
                }));
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(S().component_delete.toUpperCase(),
              style: TextStyle(color: EnvoyColors.lightCopper)),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            showEnvoyDialog(
                context: context,
                dialog: EnvoyDialog(
                  title:
                      S().envoy_device_delete_are_you_sure(widget.device.name),
                  content: Text(S().envoy_device_delete_explainer),
                  actions: [
                    EnvoyButton(
                      S().component_delete.toUpperCase(),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      type: EnvoyButtonTypes.primaryModal,
                      onTap: () {
                        Devices().deleteDevice(widget.device);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ));
          },
        ),
      ],
    );
  }
}
