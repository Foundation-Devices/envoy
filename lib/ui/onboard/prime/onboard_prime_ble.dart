// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:bluart/bluart.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/prime/connection_lost_dialog.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:envoy/ui/widgets/scanner/decoders/prime_ql_payload_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/ui/widgets/tutorial_page.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: remove this, store somewhere else
final primeDeviceVersionProvider = StateProvider<String>((ref) => '');

final primeDeviceNewVersionProvider = StateProvider<String>((ref) => '');

final estimatedTimeProvider = StateProvider<int>((ref) => 0);

class OnboardPrimeBluetooth extends ConsumerStatefulWidget {
  const OnboardPrimeBluetooth({super.key});

  @override
  ConsumerState<OnboardPrimeBluetooth> createState() =>
      _OnboardPrimeBluetoothState();
}

PairingResponse? pairingResponse;

class _OnboardPrimeBluetoothState extends ConsumerState<OnboardPrimeBluetooth>
    with SingleTickerProviderStateMixin {
  final s = Settings();
  bool scanForPayload = false;

  Completer<QuantumLinkMessage_BroadcastTransaction>? _completer;

  Completer<QuantumLinkMessage_BroadcastTransaction>? get completer =>
      _completer;

  StreamSubscription<PassportMessage>? _passportMessagesSubscription;

  @override
  void initState() {
    super.initState();
    _listenForPassportMessages();
    _startBluetoothDisconnectionListener(context);
  }

  @override
  void dispose() {
    _passportMessagesSubscription?.cancel();
    _connectionMonitorSubscription?.cancel();
    super.dispose();
  }

  void _listenForPassportMessages() {
    _passportMessagesSubscription = BluetoothManager()
        .passportMessageStream
        .listen((PassportMessage message) async {
      kPrint("Got the Passport Message : ${message.message}");

      switch (message.message) {
        case QuantumLinkMessage_PairingResponse(field0: final response):
          pairingResponse = response;
        // uncomment this to add prime to devices list, to test ble reconnect.
        // if (pairingResponse != null) {
        //   final deviceColor =
        //       pairingResponse!.passportColor == PassportColor.dark
        //           ? DeviceColor.dark
        //           : DeviceColor.light;
        //   BluetoothManager().addDevice(
        //       pairingResponse!.passportSerial.field0,
        //       pairingResponse!.passportFirmwareVersion.field0,
        //       BluetoothManager().bleId,
        //       deviceColor);
        //   kPrint("Got a pairing AccountUpdate device!");
        //   break;
        // }

        //  final response = message.message as QuantumLinkMessage_PairingResponse;
        // Create the thing that I'm gonna reveal later
        // await AccountNg().restore(response.field0.descriptor);
        //
        // Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        //     builder: (context) => Theme(
        //           data: Theme.of(context),
        //           child: NGWalletUi(),
        //         )));

        //add to prime to devices list
        case QuantumLinkMessage_AccountUpdate():
          kPrint("Got a pairing response!");
          if (pairingResponse != null) {
            final deviceColor =
                pairingResponse!.passportColor == PassportColor.dark
                    ? DeviceColor.dark
                    : DeviceColor.light;
            await BluetoothManager().addDevice(
                pairingResponse!.passportSerial.field0,
                pairingResponse!.passportFirmwareVersion.field0,
                BluetoothManager().bleId,
                deviceColor);
            kPrint("Got a pairing AccountUpdate device!");
            break;
          }
          // AccountUpdate is handled in BluetoothManager; no action needed here
          break;

        case QuantumLinkMessage_OnboardingState(:final field0):
          final onboardingState = field0;
          kPrint("Got onboarding message: $onboardingState");
          _handleOnboardingState(onboardingState);

        case QuantumLinkMessage_SecurityCheck(field0: final check):
          switch (check) {
            case SecurityCheck_ChallengeResponse(field0: final proofResult):
              switch (proofResult) {
                case ChallengeResponseResult_Success(data: final proofData):
                  bool isVerified =
                      await ScvServer().isProofVerified(proofData);

                  kPrint("challenge res $isVerified");

                  if (isVerified) {
                    await ref.read(deviceSecurityProvider.notifier).updateStep(
                        S().onboarding_connectionChecking_SecurityPassed,
                        EnvoyStepState.FINISHED);

                    await BluetoothManager()
                        .sendSecurityChallengeVerificationResult(
                            VerificationResult.success());
                  } else {
                    await ref.read(deviceSecurityProvider.notifier).updateStep(
                        S().onboarding_connectionIntroError_securityCheckFailed,
                        EnvoyStepState.ERROR);

                    await BluetoothManager()
                        .sendSecurityChallengeVerificationResult(
                            VerificationResult.error(
                                error: "verification failed"));
                  }

                case ChallengeResponseResult_Error(error: final proofError):
                  kPrint("challege proof failed $proofError");

                  await ref.read(deviceSecurityProvider.notifier).updateStep(
                      S().onboarding_connectionIntroError_securityCheckFailed,
                      EnvoyStepState.ERROR);
              }

            // we send these to Prime
            // though it would make sense for prime to have an re-check messsage as well...
            case SecurityCheck_ChallengeRequest():
            case SecurityCheck_VerificationResult():
              kPrint("received invalid security messsage ${message.message}");
          }

        case QuantumLinkMessage_FirmwareUpdateCheckRequest(
            field0: final updateRequest
          ):
          kPrint("received firmware update check request {updateRequest}");
          final currentVersion = updateRequest.currentVersion;

          ref.read(primeDeviceVersionProvider.notifier).state = currentVersion;

          await ref.read(firmWareUpdateProvider.notifier).updateStep(
              S().onboarding_connectionChecking_forUpdates,
              EnvoyStepState.LOADING);

          final patches = await Server().fetchPrimePatches(currentVersion);

          if (patches.isNotEmpty) {
            ref.read(primeDeviceNewVersionProvider.notifier).state =
                patches.last.version;
          }

          await BluetoothManager().sendFirmwareUpdateInfo(patches);

          await ref.read(firmWareUpdateProvider.notifier).updateStep(
              patches.isNotEmpty
                  ? S().onboarding_connectionUpdatesAvailable_updatesAvailable
                  : S().onboarding_connectionNoUpdates_noUpdates,
              EnvoyStepState.FINISHED);

          int estimatedTime = await getEstimatedUpdateTimeInMinutes(patches);
          ref.read(estimatedTimeProvider.notifier).state = estimatedTime;

        case QuantumLinkMessage_FirmwareFetchRequest(field0: final request):
          handleFirmwareFetchRequest(request.currentVersion);

        // TODO: are these "ref" things correct?
        case QuantumLinkMessage_FirmwareUpdateResult(field0: final result):
          switch (result) {
            // prime has applied an update
            case FirmwareUpdateResult_Success(installedVersion: final version):
              kPrint("installed version $version");

              ref.read(fwTransferStateProvider.notifier).updateStep(
                  S().firmware_updateSuccess_header, EnvoyStepState.FINISHED);
              ref.read(primeUpdateStateProvider.notifier).state =
                  PrimeFwUpdateStep.finished;

            // prime fails to apply update
            case FirmwareUpdateResult_Error(field0: final error):
              kPrint("failed to apply update: $error");

              ref.read(fwTransferStateProvider.notifier).updateStep(
                  S().firmware_updateError_installFailed,
                  EnvoyStepState.FINISHED);
              ref.read(primeUpdateStateProvider.notifier).state =
                  PrimeFwUpdateStep.error;
          }

        default:
          kPrint("received spurious message ${message.message}");
      }
    });
  }

  StreamSubscription? _connectionMonitorSubscription;

  void _startBluetoothDisconnectionListener(BuildContext context) {
    _connectionMonitorSubscription
        ?.cancel(); // Cancel any existing subsciption to avoid duplicates

    _connectionMonitorSubscription = BluetoothManager().events?.listen((event) {
      if (event is Event_DeviceDisconnected) {
        if (context.mounted) {
          showEnvoyDialog(
            context: context,
            useRootNavigator: true,
            dismissible: false,
            dialog: const ConnectionLostDialog(),
          );
        }
      }
    });
  }

  Future<int> getEstimatedUpdateTimeInMinutes(List<PrimePatch> patches) async {
    const double minutesPerMB = 6.0;
    if (patches.isEmpty) {
      return 0;
    }

    try {
      List<Uint8List> patchBinaries = [];
      for (final patch in patches) {
        final binary = await Server().fetchPrimePatchBinary(patch);
        if (binary == null) {
          throw Exception("A required patch binary could not be downloaded.");
        }
        patchBinaries.add(binary);
      }

      final totalSizeInBytes =
          patchBinaries.fold<int>(0, (prev, binary) => prev + binary.length);

      final double totalSizeInMB = totalSizeInBytes / (1024 * 1024);

      final double estimatedMinutes = totalSizeInMB * minutesPerMB;

      //Return the final time, rounded to the nearest minute.
      return estimatedMinutes.round();
    } catch (e) {
      return 0;
    }
  }

  Future<void> _handleOnboardingState(OnboardingState state) async {
    switch (state) {
      case OnboardingState.firmwareUpdateScreen:
        if (mounted) {
          context.goNamed(ONBOARD_PRIME_FIRMWARE_UPDATE);
        }
        break;
      case OnboardingState.downloadingUpdate:
        break;
      case OnboardingState.receivingUpdate:
        break;
      case OnboardingState.veryfyingSignatures:
        ref.read(fwTransferStateProvider.notifier).updateStep(
            S().firmware_downloadingUpdate_transferring,
            EnvoyStepState.FINISHED);

        ref.read(primeUpdateStateProvider.notifier).state =
            PrimeFwUpdateStep.verifying;
        ref.read(primeFwSigVerifyStateProvider.notifier).updateStep(
            S().firmware_updatingPrime_verifying, EnvoyStepState.LOADING);
        break;
      case OnboardingState.installingUpdate:
        ref.read(primeFwSigVerifyStateProvider.notifier).updateStep(
            S().firmware_updatingPrime_verified, EnvoyStepState.FINISHED);
        ref.read(primeFwInstallStateProvider.notifier).updateStep(
            S().firmware_updatingPrime_installingUpdate,
            EnvoyStepState.LOADING);

        ref.read(primeUpdateStateProvider.notifier).state =
            PrimeFwUpdateStep.installing;
        break;
      case OnboardingState.rebooting:
        ref.read(primeFwInstallStateProvider.notifier).updateStep(
            S().firmware_updatingPrime_updateInstalled,
            EnvoyStepState.FINISHED);
        ref.read(primeFwRebootStateProvider.notifier).updateStep(
            S().firmware_updatingPrime_primeRestarting, EnvoyStepState.LOADING);

        ref.read(primeUpdateStateProvider.notifier).state =
            PrimeFwUpdateStep.rebooting;
        break;
      case OnboardingState.firmwareUpdated:
        ref
            .read(primeFwRebootStateProvider.notifier)
            .updateStep("Rebooted", EnvoyStepState.FINISHED);
        ref.read(primeUpdateStateProvider.notifier).state =
            PrimeFwUpdateStep.finished;
        break;
      case OnboardingState.securingDevice:
        if (mounted) {
          context.goNamed(ONBOARD_PRIME_CONTINUING_SETUP);
        }
        break;
      case OnboardingState.deviceSecured:
        ref.read(creatingPinProvider.notifier).updateStep(
            S().finalize_catchAll_pinCreated, EnvoyStepState.FINISHED);
        break;
      case OnboardingState.walletCreationScreen:
        ref.read(setUpMasterKeyProvider.notifier).updateStep(
            S().finalize_catchAll_settingUpMasterKey, EnvoyStepState.LOADING);
        // context.goNamed(ONBOARD_PRIME_SEED_SETUP);
        break;
      case OnboardingState.creatingWallet:
        // TODO: Handle creating wallet
        break;
      case OnboardingState.walletCreated:
        ref.read(setUpMasterKeyProvider.notifier).updateStep(
            S().finalize_catchAll_masterKeySetUp, EnvoyStepState.FINISHED);
        break;
      case OnboardingState.magicBackupScreen:
        ref.read(backUpMasterKeyProvider.notifier).updateStep(
            S().finalize_catchAll_backingUpMasterKey, EnvoyStepState.LOADING);
        break;
      case OnboardingState.creatingMagicBackup:
        // TODO: Handle creating magic backup
        break;
      case OnboardingState.magicBackupCreated:
        ref.read(backUpMasterKeyProvider.notifier).updateStep(
            S().finalize_catchAll_masterKeyBackedUp, EnvoyStepState.FINISHED);
        break;
      case OnboardingState.creatingManualBackup:
        ref.read(backUpMasterKeyProvider.notifier).updateStep(
            S().finalize_catchAll_backingUpMasterKey, EnvoyStepState.LOADING);
        break;
      case OnboardingState.creatingKeycardBackup:
        // TODO: Handle creating keycard backup
        break;
      case OnboardingState.writingDownSeedWords:
        // TODO: Handle writing down seed words
        break;
      case OnboardingState.connectingWallet:
        ref.read(connectAccountProvider.notifier).updateStep(
            S().finalize_catchAll_connectingAccount, EnvoyStepState.LOADING);
        break;
      case OnboardingState.walletConected:
        if (mounted) {
          context.goNamed(ONBOARD_PRIME_CONNECTED_SUCCESS);
        }
        break;
      case OnboardingState.completed:
        resetOnboardingPrimeProviders(ref);
        mainRouter.go(ROUTE_ACCOUNTS_HOME);
        _notifyAfterOnboardingTutorial(context);
        break;
      case OnboardingState.securityChecked:
        break;
      case OnboardingState.updateAvailable:
        break;
      case OnboardingState.updateNotAvailable:
        break;
      case OnboardingState.securityCheckFailed:
        break;
    }
  }

  Future<void> _handleFirmwareError(String errorBody,
      StateNotifierProvider<StepNotifier, StepModel> failedStepProvider) async {
    ref.read(primeUpdateStateProvider.notifier).state = PrimeFwUpdateStep.error;

    ref
        .read(failedStepProvider.notifier)
        .updateStep(errorBody, EnvoyStepState.ERROR);

    await BluetoothManager()
        .sendFirmwareFetchEvent(FirmwareFetchEvent.error(errorBody));
  }

  Future<void> handleFirmwareFetchRequest(String currentVersion) async {
    ref.read(primeUpdateStateProvider.notifier).state =
        PrimeFwUpdateStep.downloading;

    ref.read(fwDownloadStateProvider.notifier).updateStep(
        S().firmware_updatingDownload_downloading, EnvoyStepState.LOADING);

    List<PrimePatch> patches = [];

    try {
      patches = await Server().fetchPrimePatches(currentVersion);
    } catch (e) {
      kPrint("failed to fetch patches: $e");
      await _handleFirmwareError(
          S().firmware_updateError_downloadFailed, fwDownloadStateProvider);
      return;
    }

    if (patches.isEmpty) {
      await BluetoothManager()
          .sendFirmwareFetchEvent(FirmwareFetchEvent.updateNotAvailable());
    } else {
      await BluetoothManager().sendFirmwareFetchEvent(
          FirmwareFetchEvent.starting(updateAvailableMessage(patches)));

      List<Uint8List> patchBinaries = [];

      try {
        for (final patch in patches) {
          final binary = await Server().fetchPrimePatchBinary(patch);
          if (binary == null) {
            throw Exception("Must get all the patches!");
          }

          patchBinaries.add(binary);
        }
      } catch (e) {
        kPrint("failed to download patch binaries: $e");
        await _handleFirmwareError(
            S().firmware_updateError_downloadFailed, fwDownloadStateProvider);
        return;
      }

      ref.read(fwDownloadStateProvider.notifier).updateStep(
          S().firmware_downloadingUpdate_downloaded, EnvoyStepState.FINISHED);

      ref.read(fwTransferStateProvider.notifier).updateStep(
          S().firmware_downloadingUpdate_transferring, EnvoyStepState.LOADING);

      ref.read(primeUpdateStateProvider.notifier).state =
          PrimeFwUpdateStep.transferring;

      try {
        await BluetoothManager().sendFirmwarePayload(patchBinaries);
      } catch (e) {
        kPrint("failed to transfer firmware: $e");
        await _handleFirmwareError(
            S().firmware_updateError_receivingFailed, fwTransferStateProvider);
        return;
      }
    }
  }

  // patches must be non-empty
  FirmwareUpdateAvailable updateAvailableMessage(List<PrimePatch> patches) {
    final latest = patches.last;

    final changelog =
        patches.reversed.fold("", (acc, p) => "$acc\n${p.changelog}");

    return FirmwareUpdateAvailable(
      version: latest.version,
      changelog: changelog,
      timestamp: latest.releaseDate.millisecondsSinceEpoch,
      // TODO: fix
      totalSize: 100,
      patchCount: patches.length,
    );
  }

  void _notifyAfterOnboardingTutorial(BuildContext context) async {
    final accounts = ref.read(accountsProvider);

    if (accounts.length == 2) {
      // make sure there are two wallets hot and prime
      final hasHotWallet = accounts.any((account) => account.isHot);

      if (hasHotWallet) {
        if (context.mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AccountTutorialOverlay(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: update copy based on s.syncToCloud
    // bool enabledMagicBackup = s.syncToCloud;
    return EnvoyPatternScaffold(
        gradientHeight: 1.8,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kToolbarHeight,
          backgroundColor: Colors.transparent,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () {
              context.pop();
              return;
            },
          ),
          automaticallyImplyLeading: false,
        ),
        header: Transform.translate(
          offset: const Offset(0, 70),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(end: 1.0, begin: 0.0),
            curve: Curves.decelerate,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Image.asset(
              "assets/images/prime_bluetooth_shield.png",
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width * 0.8,
              height: 320,
            ),
          ),
        ),
        shield: PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return SharedAxisTransition(
                  fillColor: Colors.transparent,
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  child: child);
            },
            child: quantumLinkIntro(context)));
  }

  Widget quantumLinkIntro(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: EnvoySpacing.medium1),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 300,
            ),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.medium3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: EnvoySpacing.medium2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                S().onboarding_bluetoothIntro_header,
                                textAlign: TextAlign.center,
                                style: EnvoyTypography.body.copyWith(
                                  fontSize: 20,
                                  color: EnvoyColors.gray1000,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: EnvoySpacing.small),
                              Text(
                                S().onboarding_bluetoothIntro_content,
                                style: EnvoyTypography.info.copyWith(
                                  color: EnvoyColors.inactiveDark,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: EnvoySpacing.medium1,
            right: EnvoySpacing.medium1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //const SizedBox(height: EnvoySpacing.medium1),
              // Consumer(
              //   builder: (context, ref, child) {
              //     final payload = GoRouter.of(context)
              //         .state
              //         ?.uri
              //         .queryParameters["p"];
              //     return Text("Debug Payload : $payload");
              //   },
              // ),
              const SizedBox(height: EnvoySpacing.medium1),
              LinkText(
                text: S().component_learnMore,
                textStyle: EnvoyTypography.button.copyWith(
                  color: EnvoyColors.accentPrimary,
                ),
                linkStyle: EnvoyTypography.button
                    .copyWith(color: EnvoyColors.accentPrimary),
                onTap: () {
                  launchUrl(Uri.parse(
                      "https://foundation.xyz/2025/01/quantumlink-reinventing-secure-wireless-communication/"));
                },
              ),
              const SizedBox(height: EnvoySpacing.medium1),
              EnvoyButton(S().onboarding_bluetoothIntro_connect, onTap: () {
                showCommunicationModal(context);
              }),
              const SizedBox(height: EnvoySpacing.small),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> pairWithPrime(XidDocument payload) async {
    await BluetoothManager().pair(payload);
  }

  Future<void> showCommunicationModal(BuildContext context) async {
    if (!context.mounted) return;

    showEnvoyDialog(
      context: context,
      dismissible: false,
      dialog: QuantumLinkCommunicationInfo(
        onContinue: () async {
          final qrDecoder = await getQrDecoder();

          if (!context.mounted) return;

          await showScannerDialog(
            showInfoDialog: true,
            context: context,
            onBackPressed: (ctx) {
              if (ctx.mounted) Navigator.pop(ctx);
            },
            decoder: PrimeQlPayloadDecoder(
              decoder: qrDecoder,
              onScan: (XidDocument payload) async {
                // TODO: process XidDocument for connection

                if (!context.mounted) return;

                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                await Future.delayed(const Duration(milliseconds: 200));

                if (!context.mounted) return;
                context.goNamed(ONBOARD_PRIME_PAIR);

                kPrint("XID payload: $payload");
                await pairWithPrime(payload);
              },
            ),
          );
        },
      ),
    );
  }
}

//TODO: implement platform specific copy with appropriate
class QuantumLinkCommunicationInfo extends StatefulWidget {
  final GestureTapCallback onContinue;

  const QuantumLinkCommunicationInfo({super.key, required this.onContinue});

  @override
  State<QuantumLinkCommunicationInfo> createState() =>
      _QuantumLinkCommunicationInfoState();
}

class _QuantumLinkCommunicationInfoState
    extends State<QuantumLinkCommunicationInfo> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      //TODO: test for different sizes
      height: 550,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            Column(
              children: [
                SvgPicture.asset(
                  "assets/images/bluetooth_communication_info.svg",
                  height: 100,
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.small,
                        horizontal: EnvoySpacing.xs),
                    child: Text(
                      //TODO: copy update
                      "The Communication is Secured",
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.info,
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.small,
                        horizontal: EnvoySpacing.medium1),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height *
                            0.6, // max size of PageView
                      ),
                      child: SingleChildScrollView(
                        child: ExpandablePageView(
                          controller: _pageController,
                          children: [
                            LinkText(
                              text: Platform.isAndroid
                                  ? S()
                                      .wallet_security_modal_1_4_android_subheading
                                  : S()
                                      .wallet_security_modal_1_4_ios_subheading,
                              linkStyle: EnvoyTypography.info.copyWith(
                                color: EnvoyColors.accentPrimary,
                              ),
                              onTap: () => launchUrl(
                                Uri.parse(
                                  Platform.isAndroid
                                      ? "https://developer.android.com/guide/topics/data/autobackup"
                                      : "https://support.apple.com/en-us/HT202303",
                                ),
                              ),
                            ),
                            Text(
                              S().backups_erase_wallets_and_backups_modal_2_2_subheading,
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.info,
                            ),
                          ],
                        ),
                      ),
                    )),
                DotsIndicator(
                  totalPages: 2,
                  pageController: _pageController,
                ),
              ],
            ),
            OnboardingButton(
                type: EnvoyButtonTypes.tertiary,
                label: S().component_cancel,
                onTap: () {
                  context.pop(context);
                }),
            OnboardingButton(
                type: EnvoyButtonTypes.primaryModal,
                label: S().component_continue,
                onTap: () {
                  context.pop();
                  widget.onContinue();
                }),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          ],
        ),
      ),
    );
  }
}

class OnboardBluetoothDenied extends StatelessWidget {
  const OnboardBluetoothDenied({super.key});

  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
        gradientHeight: 1.8,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kToolbarHeight,
          backgroundColor: Colors.transparent,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () {
              context.pop();
              return;
            },
          ),
          automaticallyImplyLeading: false,
        ),
        header: Transform.translate(
          offset: const Offset(0, 70),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(end: 1.0, begin: 0.0),
            curve: Curves.decelerate,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Image.asset(
              "assets/images/bluetooth_shield_denied.png",
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width * 0.8,
              height: 320,
            ),
          ),
        ),
        shield: PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return SharedAxisTransition(
                  fillColor: Colors.transparent,
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  child: child);
            },
            child: bluetoothPermission(context)));
  }

  Widget bluetoothPermission(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: EnvoySpacing.medium1),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 300,
            ),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.medium3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: EnvoySpacing.medium2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                S().onboarding_bluetoothDisabled_header,
                                textAlign: TextAlign.center,
                                style: EnvoyTypography.body.copyWith(
                                  fontSize: 20,
                                  color: EnvoyColors.gray1000,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: EnvoySpacing.medium2),
                              Text(
                                S().onboarding_bluetoothDisabled_content,
                                style: EnvoyTypography.info.copyWith(
                                  color: EnvoyColors.inactiveDark,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: EnvoySpacing.medium1,
            right: EnvoySpacing.medium1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: EnvoySpacing.medium1),
              LinkText(
                text: S().component_learnMore,
                textStyle: EnvoyTypography.button.copyWith(
                  color: EnvoyColors.accentPrimary,
                ),
                linkStyle: EnvoyTypography.button
                    .copyWith(color: EnvoyColors.accentPrimary),
                onTap: () {
                  launchUrl(Uri.parse(
                      "https://foundation.xyz/2025/01/quantumlink-reinventing-secure-wireless-communication/"));
                },
              ),
              const SizedBox(height: EnvoySpacing.medium1),
              EnvoyButton(S().onboarding_bluetoothDisabled_enable, onTap: () {
                context.pop();
                openAppSettings();
              }),
              const SizedBox(height: EnvoySpacing.small),
            ],
          ),
        ),
      ],
    );
  }
}
