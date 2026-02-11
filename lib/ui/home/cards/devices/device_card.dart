// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/accessory.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
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
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/new_envoy_color.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/list_utils.dart';
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
  // iOS
  AccessoryInfo? accessoryInfo;

  // Android
  bool? isDeviceBonded;

  void _redraw() {
    setState(() {});
  }

  Future loadDevicePairingInfo() async {
    if (widget.device.type != DeviceType.passportPrime) return;

    if (Platform.isIOS) {
      try {
        final accessories = await BluetoothChannel().getAccessories();
        final accessory = accessories.firstWhereOrNull((accessory) =>
            accessory.peripheralId == widget.device.peripheralId);
        setState(() {
          accessoryInfo = accessory;
        });
      } catch (e) {
        // Handle error if needed
      }
    } else if (Platform.isAndroid) {
      try {
        // final bonded =
        //     await BluetoothChannel().isDeviceBonded(widget.device.bleId);
        setState(() {
          isDeviceBonded = false;
        });
      } catch (e) {
        // Handle error if needed
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we there are changes in devices
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadDevicePairingInfo();
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
                  menuVisible ? Icons.close : Icons.more_horiz_outlined,
                ),
              ),
            );
          },
        ),
      );
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
    final listItemTheme = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 14,
          color: NewEnvoyColor.neutral900,
        );
    final isConnected = ref.watch(isPrimeConnectedProvider(widget.device));

    //android status is not required
    final deviceRemovedFromHostSystemSettings =
        widget.device.type == DeviceType.passportPrime
            ? Platform.isIOS
                ? accessoryInfo == null
                : false
            : false;

    final listItemTitleTheme = EnvoyTypography.body.copyWith(
        color: deviceRemovedFromHostSystemSettings
            ? NewEnvoyColor.contentDisabled
            : NewEnvoyColor.contentPrimary);

    final listItemTrailingTheme = EnvoyTypography.body.copyWith(
        color: deviceRemovedFromHostSystemSettings
            ? NewEnvoyColor.contentDisabled
            : NewEnvoyColor.contentSecondary);

    final isConnectedItemTheme = EnvoyTypography.body.copyWith(
        color: deviceRemovedFromHostSystemSettings
            ? NewEnvoyColor.contentDisabled
            : isConnected
                ? NewEnvoyColor.contentPositive
                : NewEnvoyColor.contentNotice);

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: EnvoySpacing.medium2,
                top: EnvoySpacing.medium2,
                right: EnvoySpacing.medium2,
              ),
              child: DeviceListTile(
                widget.device,
                onTap: () {
                  ref.read(homePageOptionsVisibilityProvider.notifier).state =
                      false;
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (context.mounted) {
                      GoRouter.of(context).pop();
                    }
                  });
                },
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.medium2,
                  horizontal: EnvoySpacing.medium2,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.small,
                    horizontal: EnvoySpacing.medium1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.15),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.xs,
                        ),
                        title: Text(
                          S().manage_device_details_deviceSerial,
                          style: listItemTheme,
                        ),
                        trailing: Text(
                          widget.device.serial,
                          style: listItemTheme,
                        ),
                      ),
                      Divider(color: NewEnvoyColor.neutral200, height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.xs,
                        ),
                        title: Text(
                          S().manage_device_details_devicePaired,
                          style: listItemTheme,
                        ),
                        trailing: Text(
                          timeago.format(
                            widget.device.datePaired,
                            locale: activeLocale.languageCode,
                          ),
                          style: listItemTheme,
                        ),
                      ),
                      if (widget.device.type == DeviceType.passportPrime)
                        Divider(color: NewEnvoyColor.neutral200, height: 1),
                      if (widget.device.type == DeviceType.passportPrime)
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.xs,
                          ),
                          title: Text(
                            S().manage_device_details_deviceSerial,
                            style: EnvoyTypography.body
                                .copyWith(color: NewEnvoyColor.contentPrimary),
                          ),
                          trailing: Text(
                            widget.device.serial,
                            style: EnvoyTypography.body.copyWith(
                                color: NewEnvoyColor.contentSecondary),
                          ),
                        ),
                      Divider(
                        color: NewEnvoyColor.neutral200,
                        height: 1,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.xs,
                        ),
                        dense: true,
                        minLeadingWidth: 0,
                        leading: EnvoyIcon(
                          EnvoyIcons.chain,
                          color: deviceRemovedFromHostSystemSettings
                              ? NewEnvoyColor.contentDisabled
                              : Colors.black,
                          size: EnvoyIconSize.small,
                        ),
                        horizontalTitleGap: EnvoySpacing.xs,
                        title: Text(
                          S().manage_device_details_devicePaired,
                          style: listItemTitleTheme,
                        ),
                        trailing: Text(
                          timeago.format(widget.device.datePaired,
                              locale: activeLocale.languageCode),
                          style: listItemTrailingTheme,
                        ),
                      ),
                      if (widget.device.type == DeviceType.passportPrime)
                        Divider(
                          color: NewEnvoyColor.neutral200,
                          height: 1,
                        ),
                      if (widget.device.type == DeviceType.passportPrime)
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.xs,
                          ),
                          dense: true,
                          minLeadingWidth: 0,
                          leading: EnvoyIcon(
                            EnvoyIcons.quantum,
                            color: deviceRemovedFromHostSystemSettings
                                ? NewEnvoyColor.contentDisabled
                                : Colors.black,
                            size: EnvoyIconSize.small,
                          ),
                          horizontalTitleGap: EnvoySpacing.xs,
                          title: Text(
                            S().manage_device_details_QuantumLink,
                            style: listItemTitleTheme,
                          ),
                          //TODO: implement connection status based on device QL heartbeat
                          trailing: Text(
                            isConnected
                                ? S().manage_device_details_active
                                : S().manage_device_details_inactive,
                            style: isConnectedItemTheme,
                          ),
                        ),
                    ],
                  ),
                )),
            if (widget.device.type == DeviceType.passportPrime)
              Expanded(child: PrimeOptionsWidget(device: widget.device)),
          ],
        ),
      ),
    );
  }
}

class PrimeOptionsWidget extends ConsumerStatefulWidget {
  final Device device;

  const PrimeOptionsWidget({super.key, required this.device});

  @override
  ConsumerState createState() => _PrimeOptionsWidgetState();
}

class _PrimeOptionsWidgetState extends ConsumerState<PrimeOptionsWidget> {
  // iOS
  AccessoryInfo? accessoryInfo;

  // Android
  bool? isDeviceBonded;

  bool get deviceRemovedFromHostSystemSettings => Platform.isIOS
      ? accessoryInfo == null
      : Platform.isAndroid
          ? !(isDeviceBonded ?? true)
          : false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadDevicePairingInfo();
    });
  }

  Future loadDevicePairingInfo() async {
    if (Platform.isIOS) {
      try {
        final accessories = await BluetoothChannel().getAccessories();

        final accessory = accessories.firstWhereOrNull(
          (accessory) => accessory.peripheralId == widget.device.peripheralId,
        );
        setState(() {
          accessoryInfo = accessory;
        });
      } catch (e) {
        // Handle error if needed
      }
    } else if (Platform.isAndroid) {
      try {
        setState(() {
          isDeviceBonded = true;
        });
      } catch (e) {
        // Handle error if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: deviceRemovedFromHostSystemSettings
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end,
        children: [
          if (deviceRemovedFromHostSystemSettings)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                EnvoyIcon(
                  EnvoyIcons.alert,
                  color: NewEnvoyColor.lightcopper500,
                  size: EnvoyIconSize.extraSmall,
                ),
                SizedBox(height: EnvoySpacing.xs),
                Text(S().device_deviceDetailsPrimeRemoved_accessoryRemoved,
                    style: EnvoyTypography.body.copyWith(
                      color: NewEnvoyColor.lightcopper500,
                    ))
              ],
            ),
          // TODO: implement later
          // if (deviceRemovedFromHostSystemSettings)
          //   Padding(
          //     padding:
          //         const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
          //     child: EnvoyButton(
          //         Platform.isIOS
          //             ? S()
          //                 .device_deviceDetailsPrimeRemoved_completeAccessorySetup
          //             : S().device_deviceDetailsPrimeRemoved_pairPassportAgain,
          //         onTap: () async {
          //       if (deviceRemovedFromHostSystemSettings) {
          //         await BluetoothChannel().setupBle(widget.device.bleId,
          //             widget.device.color == Colors.black ? 0 : 1);
          //         await loadDevicePairingInfo();
          //       }
          //     }),
          //   ),
          SizedBox(height: EnvoySpacing.xs),
        ],
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
        const SizedBox(height: 10),
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
              dialog: Builder(
                builder: (BuildContext context) {
                  if (!isKeyboardShown) {
                    Future.delayed(const Duration(milliseconds: 200)).then((
                      value,
                    ) {
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
                            widget.device,
                            textEntry.enteredText,
                          );
                          Navigator.pop(context);
                          context.go(ROUTE_DEVICES);
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          child: Text(
            S().manage_device_details_menu_disconnectDevice,
            style: const TextStyle(color: EnvoyColors.copperLight500),
          ),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            showEnvoyDialog(
              context: context,
              dialog: EnvoyPopUp(
                icon: EnvoyIcons.alert,
                typeOfMessage: PopUpState.warning,
                showCloseButton: false,
                title: S().component_areYouSure,
                content: S().manage_device_deletePassportWarning,
                primaryButtonLabel: S().componet_disconnect,
                primaryButtonColor: EnvoyColors.warning,
                onPrimaryButtonTap: (context) {
                  Devices().deleteDevice(widget.device);

                  // Pop the dialog
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  // Go back to devices list
                  context.go(ROUTE_DEVICES);
                },
                secondaryButtonLabel: S().component_cancel,
                onSecondaryButtonTap: (context) {
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
