// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/onboard/prime/onboard_prime_ble.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_gradient_progress.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _controller!.stateMachine.boolean('indeterminate')?.value = true;

    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primeUpdateState = ref.watch(primeUpdateStateProvider);
    ref.listen(primeUpdateStateProvider, (previous, next) {
      final stateMachine = _controller?.stateMachine;
      if (stateMachine == null) return;

      switch (next) {
        case PrimeFwUpdateStep.finished:
          stateMachine.boolean("indeterminate")?.value = false;
          stateMachine.boolean("happy")?.value = true;
          stateMachine.boolean("unhappy")?.value = false;
        case PrimeFwUpdateStep.error:
          stateMachine.boolean('indeterminate')?.value = false;
          stateMachine.boolean("unhappy")?.value = true;
          stateMachine.boolean("happy")?.value = false;
        default:
          stateMachine.boolean('indeterminate')?.value = true;
          stateMachine.boolean("unhappy")?.value = false;
          stateMachine.boolean("happy")?.value = false;
          break;
      }
    });

    Widget downloadImage = Image.asset(
      "assets/images/fw_download.png",
      alignment: Alignment.bottomCenter,
      width: 230,
      height: 230,
    );

    Widget progressAnimation = Transform.scale(
      scale: 1.2,
      child: SizedBox(
        width: 230,
        height: 230,
        child: _isInitialized && _controller != null
            ? RiveWidget(
                controller: _controller!,
                fit: Fit.contain,
                alignment: Alignment.center,
              )
            : const SizedBox(),
      ),
    );

    return PopScope(
      canPop: true,
      child: OnboardPageBackground(
          child: EnvoyScaffold(
        removeAppBarPadding: true,
        topBarLeading: CupertinoNavigationBarBackButton(),
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
                  const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
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
    _controller?.stateMachine.boolean('happy')?.value = true;
    return Column(
      children: [
        Text(
          //TODO: Note to devs: {0} in firmware.updateSuccess.content1 should be programmatically replaced by the new keyOS version installed
          S().firmware_updateSuccess_content1("new_keyOS_version"), // TODO
          textAlign: TextAlign.center,
          style: EnvoyTypography.explainer.copyWith(fontSize: 14),
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
        Padding(
          padding: const EdgeInsets.all(EnvoySpacing.small),
          child: Text(
            S().firmware_updateSuccess_content2,
            textAlign: TextAlign.center,
            style: EnvoyTypography.explainer.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _updateIntroWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              S().firmware_updateAvailable_estimatedUpdateTime(
                  "${ref.read(estimatedTimeProvider)} min"),
              textAlign: TextAlign.center,
              style: EnvoyTypography.explainer.copyWith(fontSize: 14),
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            Padding(
              padding: const EdgeInsets.all(EnvoySpacing.small),
              child: Text(
                S().firmware_updateAvailable_content2(
                    ref.read(primeDeviceVersionProvider)),
                textAlign: TextAlign.center,
                style: EnvoyTypography.explainer.copyWith(fontSize: 14),
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
                  BluetoothManager().fwUpdateHandler.newVersion),
              type: EnvoyButtonTypes.secondary, onTap: () {
            launchUrl(Uri.parse(
                "https://github.com/Foundation-Devices/KeyOS-Releases/releases/tag/${ref.read(primeDeviceNewVersionProvider)}"));
          }),
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

  //TODO: add error screen
  SizedBox _updateErrorWidget(BuildContext context) {
    return const SizedBox.shrink();
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
                // final progress = ref.watch(sendProgressProvider);
                final progressNew = ref.watch(fwTransferProgress);
                return progressNew.map(
                    data: (progressNew) {
                      return Column(
                        children: [
                          EnvoyGradientProgress(
                            progress: progressNew.value.progress,
                          ),
                          const Padding(
                              padding: EdgeInsets.all(EnvoySpacing.small)),
                          if (ref.watch(fwDownloadStateProvider).state ==
                              EnvoyStepState.FINISHED)
                            Text(
                              S().firmware_downloadingUpdate_timeRemaining(
                                  progressNew.value.remainingTime), //
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
          Wrap(
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
                ],
              ),
              const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            ],
          ),
          Consumer(builder: (context, ref, child) {
            final progress = ref.watch(primeFwRebootStateProvider);
            if (progress.state == EnvoyStepState.LOADING) {
              return Text(
                S().firmware_updatingPrime_content2,
                textAlign: TextAlign.center,
                style: EnvoyTypography.explainer.copyWith(fontSize: 12),
              );
            } else {
              return const SizedBox.shrink();
            }
          })
        ],
      ),
    );
  }
}
