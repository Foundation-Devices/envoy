// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_checkbox.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/choose_coins_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/coin_selection_overlay.dart';
import 'package:envoy/ui/home/cards/accounts/spend/fee_slider.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_tagging.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_notifier.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/transaction_review_card.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/shield_path.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:rive/rive.dart' as rive;

final primeConnectedStateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  return StepNotifier(
      stepName: S().onboarding_connectionIntro_connectedToPrime,
      state: EnvoyStepState.FINISHED);
});

final transferTransactionStateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  return StepNotifier(
      stepName: "Transferring Transaction", // TODO: localazy
      state: EnvoyStepState.IDLE);
});

final signTransactionStateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  return StepNotifier(
      stepName: "Wait for Signing", // TODO: localazy
      state: EnvoyStepState.IDLE);
});

//ignore: must_be_immutable
class TxReview extends ConsumerStatefulWidget {
  TxReview() : super(key: UniqueKey());

  @override
  ConsumerState<TxReview> createState() => _TxReviewState();
}

class _TxReviewState extends ConsumerState<TxReview> {
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadRiveAnimation();
  }

  void _loadRiveAnimation() async {
    try {
      _riveFile = await rive.File.asset('assets/envoy_loader.riv',
          riveFactory: rive.Factory.rive);
      _controller = rive.RiveWidgetController(
        _riveFile!,
        stateMachineSelector: rive.StateMachineSelector.byName('STM'),
      );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      kPrint('Error loading Rive file: $e');
    }

    Future.microtask(() => _resetPrimeProviderStates());
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EnvoyAccount? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);

    if (account == null) {
      return MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: EnvoyColors.textPrimary,
                  ),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                )),
            body: const Center(
              child: Text("Unable to build transaction"), //TODO: figma
            )),
      );
    }

    return PageTransitionSwitcher(
      reverse: transactionModel.broadcastProgress == BroadcastProgress.staging,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      child: transactionModel.broadcastProgress == BroadcastProgress.staging
          ? Padding(
              key: const Key("review"),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: TransactionReviewScreen(
                onBroadcast: () => _onBroadCast(context),
              ),
            )
          : _buildBroadcastProgress(),
    );
  }

  void _resetPrimeProviderStates() {
    ref.read(primeConnectedStateProvider.notifier).updateStep(
          S().onboarding_connectionIntro_connectedToPrime,
          EnvoyStepState.FINISHED,
        );
    ref.read(transferTransactionStateProvider.notifier).updateStep(
          "Transferring Transaction", //TODO: localazy
          EnvoyStepState.IDLE,
        );
    ref.read(signTransactionStateProvider.notifier).updateStep(
          "Waiting for Signing ", //TODO: localazy
          EnvoyStepState.IDLE,
        );
  }

  Future<void> _handleQRExchange(EnvoyAccount account, BuildContext rootContext,
      ProviderContainer providerScope) async {
    TransactionModel transactionModel = ref.read(spendTransactionProvider);
    Uint8List? psbt = transactionModel.draftTransaction?.psbt;

    final Device? device =
        Devices().getDeviceBySerial(account.deviceSerial ?? "");
    final bool isPrime = device?.type == DeviceType.passportPrime;
    if (isPrime && psbt != null) {
      kPrint("Sending to prime $psbt");
      ref.read(transferTransactionStateProvider.notifier).updateStep(
            "Transferring Transaction", //TODO: localazy
            EnvoyStepState.LOADING,
          );

      await BluetoothManager().sendPsbt(account.id, psbt);
      ref.read(transferTransactionStateProvider.notifier).updateStep(
            "Transaction transferred", //TODO: localazy
            EnvoyStepState.FINISHED,
          );
      ref.read(signTransactionStateProvider.notifier).updateStep(
            "Waiting for Signing ", //TODO: localazy
            EnvoyStepState.LOADING,
          );
    } else {
      TransactionModeNotifier transactionModeNotifier =
          ref.read(spendTransactionProvider.notifier);
      bool received = false;
      final cryptoPsbt = await GoRouter.of(rootContext).pushNamed(
          ACCOUNT_SEND_SCAN_PSBT,
          extra: transactionModel.draftTransaction);
      if (cryptoPsbt is CryptoPsbt && received == false) {
        transactionModeNotifier.decodePSBT(providerScope, cryptoPsbt);
        received = true;
      }
    }
    return;
  }

  Future _onBroadCast(BuildContext context) async {
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    TransactionModel transactionModel = ref.read(spendTransactionProvider);
    BuildContext rootContext = context;
    if (account == null ||
        transactionModel.draftTransaction == null ||
        transactionModel.broadcastProgress == BroadcastProgress.inProgress) {
      return;
    }
    final providerScope = ProviderScope.containerOf(context);
    final transaction = transactionModel.transaction!;
    final userChosenTag = ref.read(stagingTxChangeOutPutTagProvider);
    final inputTags = transaction.inputs
        .map((e) => e.tag ?? "Untagged")
        .map((e) => e.isEmpty ? "Untagged" : e)
        .toSet();

    final hasChange = transaction.outputs
            .firstWhereOrNull((e) => e.keychain == KeyChain.internal) !=
        null;
    //then show the tag selection dialog
    //spending from multiple tags and no tag is selected for change
    if (userChosenTag == null && inputTags.length > 1 && hasChange) {
      if (context.mounted) {
        final continueBroadcast = await _showTagDialog(
            context, account, rootContext, transactionModel);
        if (!continueBroadcast) {
          return;
        }
      }
    }
    if (context.mounted) {
      //for non hot wallets,note dialog already before finalizing the tx
      await _showNotesDialog(context, account);

      if (account.isHot) {
        ref
            .read(spendTransactionProvider.notifier)
            .setProgressState(BroadcastProgress.inProgress);
        await Future.delayed(const Duration(milliseconds: 200));
        if (context.mounted) _broadcastToNetwork(context);
      } else {
        if (transactionModel.isFinalized) {
          //start the broadcast,by setting the progress state to in progress
          //rive onInit will start the broadcast
          ref
              .read(spendTransactionProvider.notifier)
              .setProgressState(BroadcastProgress.inProgress);
          await Future.delayed(const Duration(milliseconds: 200));
          if (context.mounted) _broadcastToNetwork(context);
        } else {
          if (context.mounted) {
            _handleQRExchange(account, rootContext, providerScope);
          }
        }
      }
    }
  }

  Widget _buildBroadcastProgress() {
    final spendState = ref.watch(spendTransactionProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        return;
      },
      child: Padding(
        key: const Key("progress"),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 260,
                  child: _isInitialized && _controller != null
                      ? rive.RiveWidget(
                          controller: _controller!,
                          fit: rive.Fit.contain,
                        )
                      : const SizedBox(),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.all(28)),
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    String title =
                        S().stalls_before_sending_tx_scanning_heading;
                    String subTitle =
                        S().stalls_before_sending_tx_scanning_subheading;
                    if (spendState.broadcastProgress !=
                        BroadcastProgress.inProgress) {
                      if (spendState.broadcastProgress ==
                          BroadcastProgress.success) {
                        title = S()
                            .stalls_before_sending_tx_scanning_broadcasting_success_heading;
                        subTitle = S()
                            .stalls_before_sending_tx_scanning_broadcasting_success_subheading;
                      } else {
                        title = S()
                            .stalls_before_sending_tx_scanning_broadcasting_fail_heading;
                        subTitle = S()
                            .stalls_before_sending_tx_scanning_broadcasting_fail_subheading;
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title,
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.heading),
                          const Padding(padding: EdgeInsets.all(18)),
                          Text(subTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 44),
                    child: _ctaButtons(context),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _ctaButtons(BuildContext context) {
    final spendState = ref.watch(spendTransactionProvider);
    if (spendState.broadcastProgress == BroadcastProgress.inProgress) {
      return const SizedBox();
    }
    if (spendState.broadcastProgress == BroadcastProgress.success) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          EnvoyButton(
            S().component_continue,
            onTap: () async {
              final providerScope = ProviderScope.containerOf(context);
              providerScope.read(coinSelectionStateProvider.notifier).reset();
              GoRouter.of(context).go(ROUTE_ACCOUNT_DETAIL);
              clearSpendState(providerScope);
            },
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        EnvoyButton(
          enabled: spendState.broadcastProgress != BroadcastProgress.inProgress,
          S().component_tryAgain,
          type: EnvoyButtonTypes.secondary,
          onTap: () {
            _broadcastToNetwork(context);
          },
        ),
        const Padding(padding: EdgeInsets.all(6)),
        EnvoyButton(
          enabled: spendState.broadcastProgress != BroadcastProgress.inProgress,
          S().coincontrol_txDetail_ReviewTransaction,
          onTap: () {
            ref.read(spendTransactionProvider.notifier).resetBroadcastState();
          },
        ),
      ],
    );
  }

  Future<bool> _showTagDialog(BuildContext context, EnvoyAccount account,
      BuildContext rootContext, TransactionModel transactionModel) async {
    final completer = Completer<bool>();
    if (!account.isHot && transactionModel.isFinalized) {
      //tags already added before finalizing the tx

      completer.complete(true);
      return completer.future;
    }
    await showEnvoyDialog(
        useRootNavigator: true,
        context: context,
        builder: Builder(
          builder: (context) => ChooseTagForStagingTx(
            accountId: account.id,
            onEditTransaction: () {
              Navigator.pop(context);
              //exit broadcast flow and move to review screen
              completer.complete(false);
              editTransaction(context, ref);
            },
            hasMultipleTagsInput: true,
            onTagUpdate: () async {
              Navigator.pop(context);
              ref
                  .read(spendTransactionProvider.notifier)
                  .setTag(ref.read(stagingTxChangeOutPutTagProvider));
              completer.complete(true);
            },
          ),
        ),
        alignment: const Alignment(0.0, -.6));
    if (!completer.isCompleted) {
      completer.complete(true);
    }
    return completer.future;
  }

  Future _showNotesDialog(BuildContext context, EnvoyAccount account) async {
    final completer = Completer();
    TransactionModel transactionModel = ref.read(spendTransactionProvider);
    if (!account.isHot && transactionModel.isFinalized) {
      //notes already added before finalizing the tx
      completer.complete();
      return completer.future;
    }
    final notes = ref.read(stagingTxNoteProvider) ?? "";
    final notesParam = transactionModel.transactionParams?.note ?? "";
    if (notesParam.isEmpty && notes.isEmpty) {
      await showEnvoyDialog(
          context: context,
          useRootNavigator: true,
          dialog: TxReviewNoteDialog(
            onAdd: (note) async {
              await ref.read(spendTransactionProvider.notifier).setNote(note);
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
            noteSubTitle:
                S().stalls_before_sending_tx_add_note_modal_subheading,
            noteTitle: S().add_note_modal_heading,
            value: transactionModel.note,
          ));
    }
    if (!completer.isCompleted) completer.complete();

    return completer.future;
  }

  void _broadcastToNetwork(BuildContext context) async {
    final providerContainer = ProviderScope.containerOf(context);
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    TransactionModel transactionModel = ref.read(spendTransactionProvider);
    if (account == null || transactionModel.draftTransaction == null) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      _setAnimState(BroadcastProgress.inProgress);
      await Future.delayed(const Duration(milliseconds: 600));
      await ref
          .read(spendTransactionProvider.notifier)
          .broadcast(providerContainer);
      TransactionModel transactionModel = ref.read(spendTransactionProvider);
      _setAnimState(transactionModel.broadcastProgress);
      await Future.delayed(const Duration(milliseconds: 100));
      addHapticFeedback();
    } catch (e, s) {
      kPrint(e, stackTrace: s);
      _setAnimState(BroadcastProgress.failed);
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  void _setAnimState(BroadcastProgress progress) {
    if (_controller?.stateMachine == null) return;

    bool happy = progress == BroadcastProgress.success;
    bool unhappy = progress == BroadcastProgress.failed;
    bool indeterminate = progress == BroadcastProgress.inProgress;

    final stateMachine = _controller!.stateMachine;
    stateMachine.boolean("indeterminate")?.value = indeterminate;
    stateMachine.boolean("happy")?.value = happy;
    stateMachine.boolean("unhappy")?.value = unhappy;
  }

  bool hapticCalled = false;

  void addHapticFeedback() async {
    if (hapticCalled) return;
    hapticCalled = true;
    await Future.delayed(const Duration(milliseconds: 700));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }
}

class TransactionReviewScreen extends ConsumerStatefulWidget {
  final Function onBroadcast;

  const TransactionReviewScreen({super.key, required this.onBroadcast});

  @override
  ConsumerState createState() => _TransactionReviewScreenState();
}

class _TransactionReviewScreenState
    extends ConsumerState<TransactionReviewScreen> {
  StepModel _primeConnectionState = StepModel(
      stepName: S().onboarding_connectionIntro_connectedToPrime,
      state: EnvoyStepState.IDLE);
  StreamSubscription<QuantumLinkMessage_BroadcastTransaction>?
      _primeTransactionsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _initTxStream();
        final isConnected = ref.read(isPrimeConnectedProvider(
            ref.read(selectedAccountProvider)?.deviceSerial ?? ""));
        final EnvoyAccount? account = ref.read(selectedAccountProvider);
        final Device? device =
            Devices().getDeviceBySerial(account?.deviceSerial ?? "");
        if (!isConnected && device != null) {
          BluetoothManager().connect(id: device.bleId);
        }
      },
    );
  }

  void _initTxStream() {
    try {
      _primeTransactionsSubscription = BluetoothManager()
          .transactionStream
          .listen((QuantumLinkMessage_BroadcastTransaction message) async {
        if (!mounted) {
          return;
        }
        final providerScope = ProviderScope.containerOf(context);
        kPrint("Got the Broadcast Transaction");
        try {
          final signedPsbt = message.field0;
          kPrint("Signed Psbt $signedPsbt");

          //TODO: fix quantum link with Uint8List psbt
          await ref
              .read(spendTransactionProvider.notifier)
              .decodePrimePsbt(providerScope, signedPsbt.psbt);

          ref.read(signTransactionStateProvider.notifier).updateStep(
                "Transaction ready", //TODO: localazy
                EnvoyStepState.FINISHED,
              );
        } catch (e, stack) {
          debugPrintStack(stackTrace: stack);
          kPrint(e);
        }
      });
      // TODO: fix quantum link with Uint8List psbt
      // await BluetoothManager().send(QuantumLinkMessage_SignPsbt(SignPsbt(
      //   accountId: account.id,
      //   psbt: psbt,
      // )));
      kPrint("Waiting for prime response...");
      //wait for response from prime. maybe show some dialog while waiting?
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      kPrint("Error sending to prime: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTest = const bool.fromEnvironment('IS_TEST', defaultValue: true);

    EnvoyAccount? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);
    String address = ref.watch(spendAddressProvider);
    String? error = transactionModel.error;
    DraftTransaction? preparedTransaction = ref.watch(draftTransactionProvider);
    BitcoinTransaction? transaction = preparedTransaction?.transaction;

    final coinSelectionChanged = ref.watch(coinSelectionChangedProvider);
    final userSelectedCoinsThisSession =
        ref.watch(userSelectedCoinsThisSessionProvider);
    final transactionInputsChanged =
        ref.watch(transactionInputsChangedProvider);
    final userHasChangedFees = ref.watch(userHasChangedFeesProvider);

    final showFeeChangeNotice = userSelectedCoinsThisSession &&
        coinSelectionChanged &&
        transactionInputsChanged &&
        userHasChangedFees;

    if (account == null || transaction == null) {
      return const Center(
        child: Text("Unable to build transaction"), //TODO: figma
      );
    }

    final Device? device =
        Devices().getDeviceBySerial(account.deviceSerial ?? "");
    bool isPrime = device?.type == DeviceType.passportPrime;
    final bool isConnected =
        ref.watch(isPrimeConnectedProvider(device?.bleId ?? ""));
    if (isConnected) {
      _primeConnectionState = StepModel(
          stepName: S().onboarding_connectionIntro_connectedToPrime,
          state: EnvoyStepState.FINISHED);
    } else {
      _primeConnectionState = StepModel(
          stepName: "Reconnecting to Prime", // TODO: localazy
          state: EnvoyStepState.LOADING);
    }

    ref.listen(isPrimeConnectedProvider(device?.bleId ?? ""), (previous, next) {
      if (isPrime) {
        if (next == false) {
          ref.read(primeConnectedStateProvider.notifier).updateStep(
                "Reconnecting to Passport", // todo: localazy
                EnvoyStepState.LOADING,
              );
          // try to connect to prime
          if (device != null) {
            BluetoothManager().connect(id: device.bleId);
          }
        } else {
          ref.read(primeConnectedStateProvider.notifier).updateStep(
              S().onboarding_connectionIntro_connectedToPrime,
              EnvoyStepState.FINISHED);
        }
      }
    });

    String header = (account.isHot || transactionModel.isFinalized)
        ? S().coincontrol_tx_detail_heading
        : S().coincontrol_txDetail_heading_passport;

    String subHeading = (account.isHot || transactionModel.isFinalized)
        ? S().coincontrol_tx_detail_subheading
        : S().coincontrol_txDetail_subheading_passport;

    int feePercentage = ((transaction.fee.toInt() /
                (transaction.fee.toInt() + transaction.amount.abs())) *
            100)
        .round();

    final enableButton = !transactionModel.loading &&
        ((account.isHot || transactionModel.isFinalized) ||
            (isPrime && isConnected));
    return EnvoyScaffold(
      backgroundColor: Colors.transparent,
      hasScrollBody: true,
      extendBody: true,
      extendBodyBehindAppBar: true,
      removeAppBarPadding: true,
      topBarLeading: IconButton(
        icon: const EnvoyIcon(
          EnvoyIcons.chevron_left,
          color: EnvoyColors.textPrimary,
        ),
        onPressed: () {
          GoRouter.of(context).pop();
        },
      ),
      bottom: ClipPath(
        clipper: ShieldClipper(isBlurShield: true),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ).add(const EdgeInsets.only(bottom: EnvoySpacing.large1)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (transactionModel.canModify)
                  EnvoyButton(
                    enabled: !transactionModel.loading,
                    S().replaceByFee_boost_reviewCoinSelection,
                    type: EnvoyButtonTypes.secondary,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(EnvoySpacing.small)),
                    onTap: () {
                      ref.read(userHasChangedFeesProvider.notifier).state =
                          false;
                      editTransaction(context, ref);
                    },
                  ),
                const Padding(padding: EdgeInsets.all(6)),
                EnvoyButton(
                  enabled: enableButton,
                  borderRadius: const BorderRadius.all(
                      Radius.circular(EnvoySpacing.small)),
                  leading: isPrime
                      ? EnvoyIcon(
                          transactionModel.isFinalized
                              ? EnvoyIcons.send
                              : EnvoyIcons.quantum,
                          color: EnvoyColors.solidWhite,
                          size: EnvoyIconSize.small,
                        )
                      : null,
                  (account.isHot || transactionModel.isFinalized)
                      ? S().coincontrol_tx_detail_cta1
                      : S().coincontrol_txDetail_cta1_passport,
                  onTap: () {
                    widget.onBroadcast();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: EnvoySpacing.small, horizontal: EnvoySpacing.medium1),
            child: ListTile(
              title: Text(header,
                  textAlign: TextAlign.center, style: EnvoyTypography.heading),
              subtitle: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: EnvoySpacing.small),
                child: Text(
                  subHeading,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 160),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer(builder: (context, ref, child) {
                            return TransactionReviewCard(
                              transaction: transaction,
                              onTxDetailTap: () {
                                _showTxDetailsPage(
                                    context, ref, preparedTransaction);
                              },
                              canModifyPsbt: transactionModel.canModify,
                              loading: transactionModel.loading,
                              address: address,
                              feeTitle: S().coincontrol_tx_detail_fee,
                              feeChooserWidget: FeeChooser(
                                onFeeSelect: (fee, context, bool customFee) {
                                  setFee(fee, context, customFee);
                                  ref
                                      .read(userHasChangedFeesProvider.notifier)
                                      .state = true;
                                },
                              ),
                            );
                          }),
                          if (feePercentage >= 25)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: EnvoySpacing.medium1),
                              child: feeOverSpendWarning(feePercentage),
                            ),
                          if (isPrime)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: EnvoySpacing.medium1),
                              child: transactionPrimeStatus(context),
                            ),
                          if (isTest)
                            const SizedBox(height: EnvoySpacing.medium1)
                        ]),

                    if (error != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: EnvoySpacing.small),
                            child: EnvoyIcon(EnvoyIcons.alert,
                                size: EnvoyIconSize.extraSmall,
                                color: EnvoyColors.copper500),
                          ),
                          Text(error,
                              style: EnvoyTypography.button
                                  .copyWith(color: EnvoyColors.copper500)),
                        ],
                      ),

                    // Special warning if we are sending max or the fee changed the TX
                    if (transactionModel.mode == SpendMode.sendMax ||
                        showFeeChangeNotice)
                      ListTile(
                        subtitle: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: EnvoySpacing.small),
                            child: Padding(
                              padding: const EdgeInsets.all(EnvoySpacing.small),
                              child: Text(
                                showFeeChangeNotice
                                    ? S()
                                        .coincontrol_tx_detail_feeChange_information
                                    : S().send_reviewScreen_sendMaxWarning,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _primeTransactionsSubscription?.cancel();
    super.dispose();
  }

  void checkConnectivity(bool isConnected, Device device) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (isConnected) {
      ref.read(primeConnectedStateProvider.notifier).updateStep(
          S().onboarding_connectionIntro_connectedToPrime,
          EnvoyStepState.FINISHED);
    } else if (!isConnected) {
      ref.read(primeConnectedStateProvider.notifier).updateStep(
            "Reconnecting to Passport", // todo: localazy
            EnvoyStepState.LOADING,
          );
      // try to connect to prime
      BluetoothManager().connect(id: device.bleId);
    }
  }

  Column transactionPrimeStatus(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnvoyStepItem(step: _primeConnectionState, highlight: false),
        SizedBox(
          height: EnvoySpacing.medium1,
        ),
        EnvoyStepItem(
            step: ref.watch(transferTransactionStateProvider),
            highlight: false),
        SizedBox(
          height: EnvoySpacing.medium1,
        ),
        EnvoyStepItem(
            step: ref.watch(signTransactionStateProvider), highlight: false),
      ],
    );
  }

  Widget feeOverSpendWarning(int feePercentage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: EnvoySpacing.small),
          child: EnvoyIcon(EnvoyIcons.alert,
              size: EnvoyIconSize.extraSmall, color: EnvoyColors.copper500),
        ),
        Text(S().coincontrol_tx_detail_fee_alert(feePercentage),
            style:
                EnvoyTypography.button.copyWith(color: EnvoyColors.copper500)),
      ],
    );
  }

  void setFee(int fee, BuildContext context, bool customFee) async {
    if (!mounted) {
      return;
    }
    // Set the fee
    ref.read(spendFeeProcessing.notifier).state = true;
    int selectedItem = fee;
    ref.read(spendFeeRateProvider.notifier).state = selectedItem.toDouble();
    await ref.read(spendTransactionProvider.notifier).setFee();
    ref.read(spendFeeProcessing.notifier).state = false;
    //hide fee slider bottom-sheet
    if (customFee && context.mounted) {
      Navigator.pop(context);
    }
  }

  void _showTxDetailsPage(BuildContext context, WidgetRef ref,
      DraftTransaction? preparedTransaction) {
    Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          if (preparedTransaction == null) {
            return const Center(
                child: Text("Unable to fetch Staged transaction"));
          }
          return StagingTxDetails(
            draftTransaction: preparedTransaction,
            onTagUpdate: () {
              ref
                  .read(spendTransactionProvider.notifier)
                  .setTag(ref.read(stagingTxChangeOutPutTagProvider));
            },
            onTxNoteUpdated: () {
              ref
                  .read(spendTransactionProvider.notifier)
                  .setNote(ref.read(stagingTxNoteProvider));
            },
          );
        },
        transitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        opaque: false,
        fullscreenDialog: true));
  }
}

Future navigateWithTransition(BuildContext context, Widget page) async {
  final router = Navigator.of(context, rootNavigator: true);

  await router.push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          fillColor: Colors.transparent,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
    ),
  );
}

void editTransaction(BuildContext context, WidgetRef ref) async {
  /// The user has is in edit mode and if the psbt
  /// has inputs then use them to populate the coin selection state
  List<String> inputs = ref
      .read(spendTransactionProvider.select(
        (value) => value.transaction?.inputs ?? [],
      ))
      .map((e) => "${e.txId}:${e.vout}")
      .toList();

  ref.read(coinSelectionStateProvider.notifier).reset();
  ref.read(coinSelectionStateProvider.notifier).addAll(inputs);

  ///make a copy of wallet selected coins so that we can backtrack to it
  ref.read(coinSelectionFromWallet.notifier).reset();
  ref.read(coinSelectionFromWallet.notifier).addAll(inputs);

  if (ref.read(selectedAccountProvider) != null) {
    coinSelectionOverlayKey.currentState?.show(SpendOverlayContext.editCoins);
  }

  final scope = ProviderScope.containerOf(context);
  await navigateWithTransition(context, const ChooseCoinsWidget());
  await ref.read(spendTransactionProvider.notifier).validate(scope);
}

class DiscardTransactionDialog extends ConsumerStatefulWidget {
  const DiscardTransactionDialog({super.key});

  @override
  ConsumerState<DiscardTransactionDialog> createState() =>
      _DiscardTransactionDialogState();
}

class _DiscardTransactionDialogState
    extends ConsumerState<DiscardTransactionDialog> {
  @override
  Widget build(BuildContext context) {
    EnvoyAccount? account = ref.watch(selectedAccountProvider);

    return EnvoyPopUp(
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
      title: S().manage_account_remove_heading,
      showCloseButton: false,
      content: S().coincontrol_tx_detail_passport_subheading,
      primaryButtonLabel: S().coincontrol_txDetail_ReviewTransaction,
      onPrimaryButtonTap: (context) {
        Navigator.of(context).pop(false);
      },
      secondaryButtonLabel: S().coincontrol_tx_detail_passport_cta2,
      onSecondaryButtonTap: (context) async {
        final router = GoRouter.of(context);
        resetFeeChangeNoticeUserInteractionProviders(ref);
        router.pop(true);
        await Future.delayed(const Duration(milliseconds: 50));
        ref.read(selectedAccountProvider.notifier).state = account;
        router.pushReplacement(ROUTE_ACCOUNT_DETAIL, extra: account);
        await Future.delayed(const Duration(milliseconds: 50));
        router.pop();
      },
    );
  }
}

void resetFeeChangeNoticeUserInteractionProviders(WidgetRef ref) {
  ref.read(userSelectedCoinsThisSessionProvider.notifier).state = false;
  ref.read(userHasChangedFeesProvider.notifier).state = false;
  ref.read(transactionInputsChangedProvider.notifier).state = false;
  ref.read(coinSelectionChangedProvider.notifier).state = false;
}

class TxReviewNoteDialog extends ConsumerStatefulWidget {
  final Function(String) onAdd;
  final String noteTitle;
  final String? value;
  final String noteSubTitle;

  const TxReviewNoteDialog({
    super.key,
    required this.noteTitle,
    this.value,
    required this.onAdd,
    required this.noteSubTitle,
  });

  @override
  ConsumerState<TxReviewNoteDialog> createState() => _TxNoteDialogState();
}

class _TxNoteDialogState extends ConsumerState<TxReviewNoteDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  bool dismissed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// if value is passed as param, use that
      if (widget.value != null) {
        _textEditingController.text = widget.value!;
      }
      EnvoyStorage()
          .checkPromptDismissed(DismissiblePrompt.addTxNoteWarning)
          .then((value) {
        setState(() {
          dismissed = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 380,
      padding: const EdgeInsets.all(EnvoySpacing.small),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            padding: const EdgeInsets.only(
                left: EnvoySpacing.medium1,
                right: EnvoySpacing.medium1,
                top: EnvoySpacing.medium1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.noteTitle, style: EnvoyTypography.heading),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.noteSubTitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: EnvoySpacing.xs),
                  child: Container(
                    decoration: BoxDecoration(
                        color: EnvoyColors.surface4,
                        borderRadius:
                            BorderRadius.circular(EnvoySpacing.small)),
                    child: TextFormField(
                      maxLines: 1,
                      maxLength: 34,
                      controller: _textEditingController,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 14),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(EnvoySpacing.small),
                        border: InputBorder.none,
                        counter: SizedBox.shrink(),
                        fillColor: Colors.redAccent,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 180,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: EnvoySpacing.medium1,
            vertical: EnvoySpacing.small,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    dismissed = !dismissed;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: EnvoyCheckbox(
                        value: dismissed,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              dismissed = value;
                            });
                          }
                        },
                      ),
                    ),
                    Text(
                      S().component_dontShowAgain,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dismissed
                                ? Colors.black
                                : const Color(0xff808080),
                          ),
                    ),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              EnvoyButton(S().stalls_before_sending_tx_add_note_modal_cta2,
                  onTap: () {
                Navigator.of(context).pop(false);
                if (dismissed) {
                  EnvoyStorage()
                      .addPromptState(DismissiblePrompt.addTxNoteWarning);
                }
              }, type: EnvoyButtonTypes.tertiary),
              const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
              EnvoyButton(
                S().component_save,
                onTap: () {
                  Navigator.of(context).pop(_textEditingController.text);
                  widget.onAdd(_textEditingController.text);
                  if (dismissed) {
                    EnvoyStorage()
                        .addPromptState(DismissiblePrompt.addTxNoteWarning);
                  }
                },
                type: EnvoyButtonTypes.primaryModal,
              )
            ],
          ),
        ),
      ),
    );
  }
}
