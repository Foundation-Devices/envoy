// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

//ignore: must_be_immutable
class DeviceCard extends ConsumerStatefulWidget {
  final Device device;

  DeviceCard(this.device) : super(key: UniqueKey());

  @override
  ConsumerState<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends ConsumerState<DeviceCard> {
  void _redraw() {
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
              return SizedBox(
                height: 55,
                width: 55,
                child: IconButton(
                    onPressed: () {
                      HomePageState.of(context)?.toggleOptions();
                    },
                    icon: Icon(
                        menuVisible ? Icons.close : Icons.more_horiz_outlined)),
              );
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
    final Locale activeLocale = Localizations.localeOf(context);
    final isConnected =
        ref.watch(connectedDeviceProvider).value?.connected ?? false;

    return PopScope(
      canPop: !ref.watch(homePageOptionsVisibilityProvider),
      onPopInvokedWithResult: (bool didPop, _) async {
        if (!didPop) {
          HomePageState.of(context)?.toggleOptions();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: EnvoySpacing.medium2,
                  top: EnvoySpacing.medium2,
                  right: EnvoySpacing.medium2),
              child: DeviceListTile(widget.device, onTap: () {
                ref.read(homePageOptionsVisibilityProvider.notifier).state =
                    false;
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (context.mounted) {
                    GoRouter.of(context).pop();
                  }
                });
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0, left: 35.0),
              child: Text(
                  "${S().manage_device_details_deviceSerial}: ${widget.device.serial}"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 35.0),
              child: Text(
                  "${S().manage_device_details_devicePaired} ${timeago.format(widget.device.datePaired, locale: activeLocale.languageCode)}"),
            ),
            if (widget.device.type == DeviceType.passportPrime)
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 35.0),
                child: Text(
                    isConnected ? "Device connected" : "Device disconnected"),
              ),
          ],
        ),
      ),
    );
  }
}

class DeviceOptions extends ConsumerStatefulWidget {
  final Device device;

  const DeviceOptions(this.device, {super.key});

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
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().manage_device_details_menu_editDevice,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            bool isKeyboardShown = false;
            showEnvoyDialog(
                context: context,
                dialog: Builder(builder: (BuildContext context) {
                  if (!isKeyboardShown) {
                    Future.delayed(const Duration(milliseconds: 200))
                        .then((value) {
                      if (context.mounted) {
                        FocusScope.of(context).requestFocus(focusNode);
                      }
                    });
                    isKeyboardShown = true;
                    textEntry = TextEntry(
                      focusNode: focusNode,
                      maxLength: 20,
                      placeholder: widget.device.name,
                    );
                  }
                  return EnvoyDialog(
                    title: S().manage_device_rename_modal_heading,
                    content: textEntry,
                    actions: [
                      EnvoyButton(
                        S().component_save,
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
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(S().component_delete.toUpperCase(),
              style: const TextStyle(color: EnvoyColors.copperLight500)),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            showEnvoyDialog(
                context: context,
                dialog: EnvoyPopUp(
                  icon: EnvoyIcons.alert,
                  typeOfMessage: PopUpState.warning,
                  showCloseButton: true,
                  content: S().manage_device_deletePassportWarning,
                  primaryButtonLabel: S().component_delete,
                  onPrimaryButtonTap: (context) {
                    Devices().deleteDevice(widget.device);

                    // Pop the dialog
                    Navigator.pop(context);

                    // Go back to devices list
                    context.go(ROUTE_DEVICES);
                  },
                ));
          },
        ),
      ],
    );
  }
}
