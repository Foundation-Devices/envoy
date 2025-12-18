// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_gradient_progress.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardPrimeFwUpdate extends ConsumerStatefulWidget {
  const OnboardPrimeFwUpdate({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardPrimeFwUpdateState();
}

class _OnboardPrimeFwUpdateState extends ConsumerState<OnboardPrimeFwUpdate> {
  File? _riveFile;
  RiveWidgetController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRive();
  }

  void _initRive() async {
    _riveFile =
        await File.asset("assets/envoy_loader.riv", riveFactory: Factory.rive);
    _controller = RiveWidgetController(
      _riveFile!,
      stateMachineSelector: StateMachineSelector.byName('STM'),
    );

    // Set the boolean input after controller is ready
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller!.stateMachine.boolean('indeterminate')?.value = true;

    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  void _updateAnimState(PrimeFwUpdateStep next) async {
    final stateMachine = _controller?.stateMachine;
    if (stateMachine == null) return;

    switch (next) {
      case PrimeFwUpdateStep.finished:
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean("indeterminate")?.value = false;
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean("happy")?.value = true;
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean("unhappy")?.value = false;
      case PrimeFwUpdateStep.error:
        //need
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean('indeterminate')?.value = true;
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean("unhappy")?.value = false;
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean("happy")?.value = false;
        await Future.delayed(const Duration(milliseconds: 500));
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean('indeterminate')?.value = false;
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean("unhappy")?.value = true;
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean("happy")?.value = false;
      default:
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean('indeterminate')?.value = true;
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean("unhappy")?.value = false;
        //TODO: fix rive with databindings.
        // ignore: deprecated_member_use
        stateMachine.boolean("happy")?.value = false;
        break;
    }
  }

  Future<bool> showExitWarning(BuildContext context) {
    final Completer<bool> completer = Completer<bool>();
    showEnvoyDialog(
      context: context,
      dismissible: true,
      dialog: EnvoyPopUp(
        icon: EnvoyIcons.alert,
        typeOfMessage: PopUpState.warning,
        showCloseButton: true,
        content: "Do you want to exit the onboarding ?",
        primaryButtonLabel: "Cancel",
        secondaryButtonLabel: "Exit",
        onPrimaryButtonTap: (context) async {
          completer.complete(false);
          Navigator.pop(context);
        },
        onSecondaryButtonTap: (context) async {
          completer.complete(true);
          Navigator.pop(context);
        },
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final primeUpdateState = ref.watch(primeUpdateStateProvider);

    ref.listen(onboardingStateStreamProvider, (prev, next) {
      next.whenData((state) {
        if (state == OnboardingState.firmwareUpdateScreen) {
          context.goNamed(ONBOARD_PRIME_FIRMWARE_UPDATE);
        } else if (state == OnboardingState.securingDevice) {
          context.goNamed(ONBOARD_PRIME_CONTINUING_SETUP);
        } else if (state == OnboardingState.walletConected) {
          context.goNamed(ONBOARD_PRIME_CONNECTED_SUCCESS);
        } else if (state == OnboardingState.completed) {
          context.go(ROUTE_ACCOUNTS_HOME);
        }
      });
    });

    ref.listen(primeUpdateStateProvider, (previous, next) async {
      _updateAnimState(next);
    });

    Widget downloadImage = Image.asset(
      "assets/images/fw_download.png",
      alignment: Alignment.bottomCenter,
      width: 184,
      height: 184,
    );

    Widget progressAnimation = SizedBox(
      width: 184,
      height: 184,
      child: _isInitialized && _controller != null
          ? Transform.scale(
              scale: 1.6,
              child: RiveWidget(
                controller: _controller!,
                fit: Fit.contain,
                alignment: Alignment.center,
              ),
            )
          : const SizedBox(),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        final shouldExit = await showExitWarning(context);
        if (shouldExit && context.mounted) {
          context.go(ROUTE_ACCOUNTS_HOME);
        }
      },
      child: OnboardPageBackground(
          child: EnvoyScaffold(
        removeAppBarPadding: true,
        topBarLeading: Padding(
          padding: const EdgeInsets.all(12),
          child: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
            onPressed: () {
              GoRouter.of(context).pop();
            },
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.small, vertical: EnvoySpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 24,
            children: [
              _pageTransitionBuilder(
                  context: context,
                  child: switch (primeUpdateState) {
                    PrimeFwUpdateStep.idle ||
                    PrimeFwUpdateStep.downloading ||
                    PrimeFwUpdateStep.transferring =>
                      downloadImage,
                    _ => progressAnimation
                  }),
              Expanded(
                  child: Column(
                children: [
                  Text(
                    key: ValueKey(_getTitle(context)),
                    _getTitle(context),
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading,
                  ),
                  const SizedBox(height: EnvoySpacing.medium3),
                  Expanded(
                    child: _pageTransitionBuilder(
                      context: context,
                      child: switch (primeUpdateState) {
                        PrimeFwUpdateStep.idle => _updateIntroWidget(context),
                        PrimeFwUpdateStep.downloading ||
                        PrimeFwUpdateStep.transferring =>
                          const PrimeFwDownloadProgress(),
                        PrimeFwUpdateStep.verifying ||
                        PrimeFwUpdateStep.installing ||
                        PrimeFwUpdateStep.rebooting =>
                          const PrimeFwFlashProgress(),
                        PrimeFwUpdateStep.finished =>
                          _updateFinishedWidget(context),
                        PrimeFwUpdateStep.error => _updateErrorWidget(context),
                        // TODO: Handle this case.
                      },
                    ),
                  )
                ],
              )),
            ],
          ),
        ),
      )),
    );
  }

  Widget _pageTransitionBuilder(
      {required BuildContext context, required Widget child}) {
    return PageTransitionSwitcher(
      child: child,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          fillColor: Colors.transparent,
          child: child,
        );
      },
    );
  }

  Widget _updateFinishedWidget(BuildContext context) {
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller?.stateMachine.boolean('happy')?.value = true;

    return Column(
      children: [
        Text(
          S().firmware_updateSuccess_content1(
              "KeyOS v${BluetoothManager().fwUpdateHandler.newVersion}"),
          textAlign: TextAlign.center,
          style:
              EnvoyTypography.body.copyWith(color: EnvoyColors.textSecondary),
        ),
        const SizedBox(height: EnvoySpacing.medium3),
        Text(
          S().firmware_updateSuccess_content2,
          textAlign: TextAlign.center,
          style:
              EnvoyTypography.body.copyWith(color: EnvoyColors.textSecondary),
        ),
      ],
    );
  }

  Widget _updateIntroWidget(BuildContext context) {
    final devices = Devices();
    final connectedPrime = devices.getPrimeDevices.isNotEmpty
        ? devices.getPrimeDevices.first
        : null;

    final currentFwVersion = connectedPrime?.firmwareVersion ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              "KeyOS v${BluetoothManager().fwUpdateHandler.newVersion}",
              textAlign: TextAlign.center,
              style: EnvoyTypography.button
                  .copyWith(color: EnvoyColors.textSecondary),
            ),
            const SizedBox(height: EnvoySpacing.xs),
            Text(
              S().firmware_updateAvailable_estimatedUpdateTime(
                //TODO: proper size based time estimation
                "${Platform.isAndroid ? '~1' : '~2.5'} min",
              ),
              textAlign: TextAlign.center,
              style: EnvoyTypography.body
                  .copyWith(color: EnvoyColors.textSecondary),
            ),
            const SizedBox(height: EnvoySpacing.medium3),
            Padding(
              padding: const EdgeInsets.all(EnvoySpacing.small),
              child: Text(
                S().firmware_updateAvailable_content2(
                    "KeyOS v$currentFwVersion"),
                textAlign: TextAlign.center,
                style: EnvoyTypography.body
                    .copyWith(color: EnvoyColors.textSecondary),
              ),
            ),
          ],
        ),
        // Expanded(
        //     child: Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.small)
        //       .add(const EdgeInsets.only(
        //     top: EnvoySpacing.medium2,
        //   )),
        //   child: const Placeholder(),
        // )),
        // OnboardingButton(
        //     label: "Try to send",
        //     type: EnvoyButtonTypes.primary,
        //     fontWeight: FontWeight.w600,
        //     onTap: (){
        //       BluetoothManager().sendOnboardingState(OnboardingState.receivingUpdate);
        //     }),

        Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
          child: EnvoyButton(
            S().firmware_updateAvailable_whatsNew(
                "KeyOS v${BluetoothManager().fwUpdateHandler.newVersion}"),
            type: EnvoyButtonTypes.secondary,
            onTap: () {
              launchUrl(
                Uri.parse(
                  "https://github.com/Foundation-Devices/KeyOS-Releases/releases/tag/${BluetoothManager().fwUpdateHandler.newVersion}",
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getTitle(BuildContext context) {
    final primeUpdateState = ref.watch(primeUpdateStateProvider);
    //TODO: copy update
    return switch (primeUpdateState) {
      PrimeFwUpdateStep.idle => S().firmware_updateAvailable_header,
      PrimeFwUpdateStep.downloading =>
        S().firmware_updatingDownload_downloading,
      PrimeFwUpdateStep.transferring ||
      PrimeFwUpdateStep.verifying ||
      PrimeFwUpdateStep.installing ||
      PrimeFwUpdateStep.rebooting =>
        S().firmware_updatingDownload_header,
      PrimeFwUpdateStep.finished => S().firmware_updateSuccess_header,
      PrimeFwUpdateStep.error => S().firmware_updateError_header,
    };
  }

  Widget _updateErrorWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        EnvoyButton(
          S().common_button_contactSupport,
          type: EnvoyButtonTypes.secondary,
          onTap: () {},
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
      ],
    );
  }
}

class PrimeFwDownloadProgress extends ConsumerStatefulWidget {
  const PrimeFwDownloadProgress({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PrimeFwDownloadProgressState();
}

class _PrimeFwDownloadProgressState
    extends ConsumerState<PrimeFwDownloadProgress> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: EnvoySpacing.medium1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            S().firmware_updatingDownload_content,
            textAlign: TextAlign.center,
            style: EnvoyTypography.explainer.copyWith(fontSize: 14),
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Expanded(
              child: Wrap(
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: EnvoySpacing.medium1,
            children: [
              const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EnvoyStepItem(
                      step: ref.watch(fwDownloadStateProvider),
                      highlight: false),
                  SizedBox(
                    height: EnvoySpacing.medium1,
                  ),
                  EnvoyStepItem(
                      step: ref.watch(fwTransferStateProvider),
                      highlight: false),
                ],
              ),
              const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
              Consumer(builder: (context, ref, child) {
                final progressAsync = ref.watch(fwTransferProgress);
                return progressAsync.map(
                    data: (progressAsync) {
                      return Column(
                        children: [
                          EnvoyGradientProgress(
                            progress: progressAsync.value.progress,
                          ),
                          const Padding(
                              padding: EdgeInsets.all(EnvoySpacing.small)),
                          if (ref.watch(fwDownloadStateProvider).state ==
                              EnvoyStepState.FINISHED)
                            Text(
                              progressAsync.value.remainingTime.isEmpty
                                  ? "Estimating remaining time..."
                                  : S()
                                      .firmware_downloadingUpdate_timeRemaining(
                                          progressAsync.value.remainingTime), //
                              style: EnvoyTypography.explainer
                                  .copyWith(fontSize: 14),
                            ),
                        ],
                      );
                    },
                    error: (_) => SizedBox.shrink(),
                    loading: (_) => SizedBox.shrink());
              })
            ],
          ))
        ],
      ),
    );
  }
}

class PrimeFwFlashProgress extends ConsumerStatefulWidget {
  const PrimeFwFlashProgress({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PrimeFwFlashProgressState();
}

class _PrimeFwFlashProgressState extends ConsumerState<PrimeFwFlashProgress> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          S().firmware_updatingDownload_content,
          textAlign: TextAlign.center,
          style: EnvoyTypography.explainer.copyWith(fontSize: 14),
        ),
        const SizedBox(height: EnvoySpacing.medium1),
        Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: EnvoySpacing.medium1,
          children: [
            const SizedBox(height: EnvoySpacing.small),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EnvoyStepItem(
                    step: ref.watch(primeFwSigVerifyStateProvider),
                    highlight: false),
                SizedBox(
                  height: EnvoySpacing.medium1,
                ),
                EnvoyStepItem(
                    step: ref.watch(primeFwInstallStateProvider),
                    highlight: false),
                SizedBox(
                  height: EnvoySpacing.medium1,
                ),
                EnvoyStepItem(
                    step: ref.watch(primeFwRebootStateProvider),
                    highlight: false),
                SizedBox(
                  height: EnvoySpacing.medium3,
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          ],
        ),
        Consumer(builder: (context, ref, child) {
          final progress = ref.watch(primeFwRebootStateProvider);
          if (progress.state == EnvoyStepState.LOADING) {
            return Text(S().firmware_updatingPrime_content2,
                textAlign: TextAlign.center, style: EnvoyTypography.body);
          } else {
            return const SizedBox.shrink();
          }
        })
      ],
    );
  }
}
