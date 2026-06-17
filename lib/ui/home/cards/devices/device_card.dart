// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/ble_device_info.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_menu_list.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/home/setup_overlay.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/new_envoy_color.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _DeviceCardState extends ConsumerState<DeviceCard>
    with WidgetsBindingObserver {
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
      if (!mounted) return;
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
        optionsWidget: Container(),
        rightAction: Consumer(
          builder: (context, ref, child) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    transitionDuration: const Duration(milliseconds: 280),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 280),
                    barrierColor: Colors.transparent,
                    pageBuilder: (_, __, ___) => DeviceOptions(widget.device),
                  ),
                );
              },
              child: Container(
                height: 55,
                width: 55,
                color: Colors.transparent,
                child: Icon(
                  Icons.more_horiz_outlined,
                ),
              ),
            );
          },
        ),
      );
    });

    Devices().addListener(_redraw);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Devices().removeListener(_redraw);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      loadDevicePairingInfo();
    }
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

    // Prime cleared its QL keys via UnpairingRequest
    final primeUnpaired = widget.device.type == DeviceType.passportPrime &&
        (widget.device.xid == null || widget.device.xid!.isEmpty);

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.xs),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
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
                        GoRouter.of(context).pop();
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
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: MediaQuery.withClampedTextScaling(
                                      maxScaleFactor: 1.3,
                                      child: Text(
                                        S().manage_device_details_deviceSerial,
                                        style: listItemTheme,
                                      ),
                                    ),
                                  ),
                                  MediaQuery.withClampedTextScaling(
                                    maxScaleFactor: 1.3,
                                    child: Text(
                                      widget.device.serial,
                                      style: listItemTheme,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: NewEnvoyColor.neutral200, height: 1),
                            if (primeUnpaired)
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: EnvoySpacing.xs,
                                ),
                                dense: true,
                                minLeadingWidth: 0,
                                leading: EnvoyIcon(
                                  EnvoyIcons.chain,
                                  color: Colors.black,
                                  size: EnvoyIconSize.small,
                                ),
                                horizontalTitleGap: EnvoySpacing.xs,
                                title: Text(
                                  S().manage_device_details_unpaired,
                                  style: listItemTheme,
                                ),
                              )
                            else
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
                                  style: listItemTheme?.copyWith(
                                    color: deviceRemovedFromHostSystemSettings
                                        ? NewEnvoyColor.contentDisabled
                                        : Colors.black,
                                  ),
                                ),
                                trailing: Text(
                                  timeago.format(
                                    widget.device.datePaired,
                                    locale: activeLocale.languageCode,
                                  ),
                                  style: listItemTheme?.copyWith(
                                    color: deviceRemovedFromHostSystemSettings
                                        ? NewEnvoyColor.contentDisabled
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            if (!primeUnpaired &&
                                widget.device.type == DeviceType.passportPrime)
                              Divider(
                                  color: NewEnvoyColor.neutral200, height: 1),
                            if (!primeUnpaired &&
                                widget.device.type == DeviceType.passportPrime)
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
                    Expanded(
                      child: PrimeOptionsWidget(
                        device: widget.device,
                        deviceRemovedFromHostSystemSettings:
                            deviceRemovedFromHostSystemSettings,
                        primeUnpaired: primeUnpaired,
                        onRepairComplete: () {
                          loadDevicePairingInfo();
                        },
                      ),
                    ),
                    SizedBox(
                      height: EnvoySpacing.large1,
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimeOptionsWidget extends ConsumerStatefulWidget {
  final Device device;
  final bool deviceRemovedFromHostSystemSettings;
  final bool primeUnpaired;
  final VoidCallback onRepairComplete;

  const PrimeOptionsWidget(
      {super.key,
      required this.device,
      this.deviceRemovedFromHostSystemSettings = false,
      this.primeUnpaired = false,
      required this.onRepairComplete});

  @override
  ConsumerState createState() => _PrimeOptionsWidgetState();
}

class _PrimeOptionsWidgetState extends ConsumerState<PrimeOptionsWidget> {
  /// Re-pair the host BLE accessory after the user removed it in system
  /// settings. If Bluetooth is off (Android only), prompt to enable it and
  Future<void> _repairAccessory() async {
    try {
      final qlConnection = await BluetoothChannel().setupBle(
        widget.device.bleId,
        widget.device.color == Colors.black ? 0 : 1,
      );
      // after repairing the connection, restore XID's
      await qlConnection.reconnect(widget.device);
      widget.onRepairComplete.call();
    } on PlatformException catch (e) {
      if (e.code == "BLUETOOTH_DISABLED") {
        final allowed = await BluetoothChannel().requestEnableBle();
        if (allowed == true) {
          await _repairAccessory();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceRemovedFromHostSystemSettings =
        widget.deviceRemovedFromHostSystemSettings;
    final primeUnpaired = widget.primeUnpaired;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final verticalActionPadding = devicePixelRatio >= 3.0
        ? EnvoySpacing.medium1
        : devicePixelRatio >= 2.0
            ? EnvoySpacing.medium1
            : EnvoySpacing.small;

    return ColoredBox(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: deviceRemovedFromHostSystemSettings && !primeUnpaired
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end,
        children: [
          if (primeUnpaired)
            Padding(
              padding: EdgeInsets.only(
                  left: EnvoySpacing.medium2,
                  right: EnvoySpacing.medium2,
                  bottom: EnvoySpacing.xs),
              child: EnvoyButton(
                S().manage_deviceDetailsUnpaired_pairAgain,
                onTap: () async {
                  scanForDevice(context, ref);
                },
              ),
            ),
          if (!primeUnpaired && deviceRemovedFromHostSystemSettings) ...[
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
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.body.copyWith(
                      color: NewEnvoyColor.lightcopper500,
                    ))
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: EnvoySpacing.medium2,
                  vertical: verticalActionPadding),
              child: EnvoyButton(
                Platform.isIOS
                    ? S()
                        .device_deviceDetailsPrimeRemoved_completeAccessorySetup
                    : S().device_deviceDetailsPrimeRemoved_pairPassportAgain,
                onTap: _repairAccessory,
              ),
            ),
          ],
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
    final navigator = Navigator.of(context);

    return EnvoyMenuList(
      children: [
        const SizedBox(height: EnvoySpacing.xs),
        MenuItem(
          label: S().manage_device_details_menu_editDevice,
          icon: EnvoyIcons.edit,
          onTap: () {
            navigator.pop();
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
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        MenuItem(
          label: S().manage_device_details_menu_unpairPassport,
          icon: EnvoyIcons.close,
          color: EnvoyColors.warning,
          onTap: () {
            navigator.pop();
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
