// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/ble_device_info.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
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
  // Host OS pairing/connection metadata for this Prime device
  BleDeviceInfo? _accessoryInfo;
  bool _loadingAccessoryInfo = true;

  void _redraw() {
    setState(() {});
  }

  Future loadDevicePairingInfo() async {
    if (widget.device.type != DeviceType.passportPrime) return;
    if (!Platform.isIOS && !Platform.isAndroid) return;
    try {
      final accessories = await BluetoothChannel().getAccessories();
      final accessory = accessories.firstWhereOrNull(
        (accessory) => accessory.peripheralId == widget.device.peripheralId,
      );
      setState(() {
        _accessoryInfo = accessory;
        _loadingAccessoryInfo = false;
      });
    } catch (e) {
      // Ignore and keep current state
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
    ref.listen(isPrimeConnectedProvider(widget.device), (_, next) {
      loadDevicePairingInfo();
    });
    ref.listen(primeQLActivityProvider(widget.device), (_, next) {
      loadDevicePairingInfo();
    });
    final listItemTheme = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 14,
          color: NewEnvoyColor.neutral900,
        );
    final bleConnected = ref.watch(isPrimeConnectedProvider(widget.device));
    final qlActive = ref.watch(primeQLActivityProvider(widget.device));

    final isConnected = bleConnected && qlActive;

    bool deviceRemovedFromHostSystemSettings =
        widget.device.type == DeviceType.passportPrime
            ? _accessoryInfo == null
            : false;

    //loading state for accessory info,
    //to fix flickering of connection status when page is first opened
    if (_loadingAccessoryInfo) {
      deviceRemovedFromHostSystemSettings = false;
    }

    final listItemTitleTheme = EnvoyTypography.body.copyWith(
        color: deviceRemovedFromHostSystemSettings
            ? NewEnvoyColor.contentDisabled
            : NewEnvoyColor.contentPrimary);

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
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
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
            if (widget.device.type == DeviceType.passportPrime) ...[
              PrimeOptionsWidget(
                device: widget.device,
                deviceRemovedFromHostSystemSettings:
                    deviceRemovedFromHostSystemSettings,
                onRepairComplete: () {
                  loadDevicePairingInfo();
                },
              ),
              SizedBox(
                height: EnvoySpacing.large1,
              )
            ]
          ],
        ),
      ),
    );
  }
}

class PrimeOptionsWidget extends ConsumerStatefulWidget {
  final Device device;
  final bool deviceRemovedFromHostSystemSettings;
  final VoidCallback onRepairComplete;

  const PrimeOptionsWidget(
      {super.key,
      required this.device,
      this.deviceRemovedFromHostSystemSettings = false,
      required this.onRepairComplete});

  @override
  ConsumerState createState() => _PrimeOptionsWidgetState();
}

class _PrimeOptionsWidgetState extends ConsumerState<PrimeOptionsWidget> {
  @override
  Widget build(BuildContext context) {
    final deviceRemovedFromHostSystemSettings =
        widget.deviceRemovedFromHostSystemSettings;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final verticalActionPadding = devicePixelRatio >= 3.0
        ? EnvoySpacing.medium1
        : devicePixelRatio >= 2.0
            ? EnvoySpacing.medium1
            : EnvoySpacing.small;
    //missing QL keys.
    final unpaired = widget.device.xid == null || widget.device.xid!.isEmpty;

    final needsBleRepair = deviceRemovedFromHostSystemSettings && !unpaired;

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: deviceRemovedFromHostSystemSettings
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.end,
      children: [
        if (needsBleRepair)
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
              Text(
                S().device_deviceDetailsPrimeRemoved_accessoryRemoved,
                style: EnvoyTypography.body.copyWith(
                  color: NewEnvoyColor.lightcopper500,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        if (needsBleRepair)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium2,
                vertical: verticalActionPadding),
            child: EnvoyButton(
                Platform.isIOS
                    ? S()
                        .device_deviceDetailsPrimeRemoved_completeAccessorySetup
                    : S().device_deviceDetailsPrimeRemoved_pairPassportAgain,
                onTap: () async {
              if (deviceRemovedFromHostSystemSettings) {
                final qlConnection = await BluetoothChannel().setupBle(
                    widget.device.bleId,
                    widget.device.color == Colors.black ? 0 : 1);
                //after repairing the connection,  restore XID's
                await qlConnection.reconnect(widget.device);
                widget.onRepairComplete.call();
              }
            }),
          ),
        if (unpaired)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium2,
                vertical: verticalActionPadding),
            child: EnvoyButton(S().manage_deviceDetailsUnpaired_pairAgain,
                onTap: () async {
              context.pushNamed(ONBOARD_PRIME, queryParameters: {
                "p": Platform.isIOS
                    ? widget.device.peripheralId
                    : widget.device.bleId,
                "o": "1",
                "c": widget.device.deviceColor == DeviceColor.light ? "0" : "1"
              });
            }),
          ),
        SizedBox(height: EnvoySpacing.xs),
      ],
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
            S().manage_device_details_menu_unpairPassport,
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
                primaryButtonLabel: S().component_unpair,
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
