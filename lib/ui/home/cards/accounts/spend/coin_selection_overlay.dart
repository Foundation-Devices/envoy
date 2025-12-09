// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fees.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_tag_list_screen.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/create_coin_tag_dialog.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/warning_dialogs.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/haptics.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

final coinSelectionOverlayMinimized = StateProvider<bool>((ref) => false);

OverlayEntry? overlayEntry;
final GlobalKey<CoinSelectionOverlayState> coinSelectionOverlayKey =
    GlobalKey<CoinSelectionOverlayState>();

class CoinSelectionOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const CoinSelectionOverlay({super.key, required this.child});

  static CoinSelectionOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<CoinSelectionOverlayState>();
  }

  @override
  ConsumerState<CoinSelectionOverlay> createState() =>
      CoinSelectionOverlayState();
}

class CoinSelectionOverlayState extends ConsumerState<CoinSelectionOverlay> {
  @override
  Widget build(BuildContext context) {
    ///shows/hide spend overlay for account detail page, overlay is only needed within account detail page..
    /// any other navigation should hide the overlay (except coin tag screens)
    ref.listen(
      routePathProvider,
      (previous, nextPath) {
        ///shows/hide spend overlay for account detail page, ovelay is only needed within account detail page..
        /// any other navigation should hide the overlay (except coin tag screens)
        if (nextPath == ROUTE_ACCOUNT_DETAIL) {
          if (ref.read(showSpendRequirementOverlayProvider) ||
              ref.read(coinSelectionStateProvider).isNotEmpty) {
            final account = ref.read(selectedAccountProvider);
            if (account != null) show(SpendOverlayContext.preselectCoins);
          } else {
            if (ref.read(spendEditModeProvider) != SpendOverlayContext.hidden) {
              hideCoinSnack(ref);
            }
          }
        }
      },
    );

    ///show spend overlay for account detail page
    ref.listen(showSpendRequirementOverlayProvider, (previous, next) {
      if (next) {
        if (ref.read(spendEditModeProvider) ==
            SpendOverlayContext.rbfSelection) {
        } else if (ref.read(spendEditModeProvider) !=
            SpendOverlayContext.editCoins) {
          final requiredAmount = ref.watch(spendAmountProvider);
          final account = ref.read(selectedAccountProvider);
          if (account != null) {
            show(requiredAmount != 0
                ? SpendOverlayContext.editCoins
                : SpendOverlayContext.preselectCoins);
          }
        }
      } else {
        if (ref.read(spendEditModeProvider) ==
            SpendOverlayContext.preselectCoins) {
          ref.read(coinSelectionStateProvider.notifier).reset();
          ref.read(hideBottomNavProvider.notifier).state = false;
          ref.read(spendEditModeProvider.notifier).state =
              SpendOverlayContext.hidden;
        }
      }
    });
    return widget.child;
  }

  Future show(SpendOverlayContext overlayContext) async {
    ref.read(spendEditModeProvider.notifier).state = overlayContext;
    final account = ref.read(selectedAccountProvider);
    if (account == null || overlayEntry != null) return;
    overlayEntry = OverlayEntry(
        builder: (context) {
          return SpendRequirementOverlay(account: account);
        },
        maintainState: true,
        opaque: false);
    if (context.mounted) {
      Overlay.of(context, rootOverlay: true).insert(overlayEntry!);
    }
  }
}

class SpendRequirementOverlay extends ConsumerStatefulWidget {
  final EnvoyAccount account;

  const SpendRequirementOverlay({super.key, required this.account});

  @override
  ConsumerState createState() => SpendRequirementOverlayState();
}

class SpendRequirementOverlayState
    extends ConsumerState<SpendRequirementOverlay>
    with SingleTickerProviderStateMixin {
  ///overlay is visible in the viewport
  final Alignment _endAlignment = const Alignment(0.0, 1.01);

  ///overlay is minimized
  final Alignment _minimizedAlignment = const Alignment(0.0, 1.3);

  ///hidden from the viewport
  final Alignment _startAlignment = const Alignment(0.0, 1.99);

  late Alignment _dragAlignment = _startAlignment;

  AnimationController? _animationController;
  Animation<Alignment>? _appearAnimation;

  @override
  void initState() {
    if (_animationController != null) {
      _animationController?.dispose();
      _animationController = null;
    }
    _animationController = AnimationController(
      vsync: this,
      reverseDuration: const Duration(milliseconds: 300),
    );
    _appearAnimation = AlignmentTween(
      begin: _dragAlignment,
      end: _endAlignment,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: EnvoyEasing.easeInOut,
      ),
    );
    _animationController?.addListener(() {
      setState(() {
        _dragAlignment = _appearAnimation!.value;
      });
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animationController?.animateTo(1,
          duration: const Duration(milliseconds: 250),
          curve: EnvoyEasing.easeInOut);
    });
  }

  /// run physics simulation to animate overlay,
  /// parameter alignment will be used as end state of the animation
  TickerFuture _runSpringSimulation(
      Offset pixelsPerSecond, Alignment alignment, Size size) {
    _appearAnimation = _animationController!.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: alignment,
      ),
    );
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    SpringDescription spring = SpringDescription.withDampingRatio(
        mass: 1, stiffness: 330, ratio: 0.700);

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    return _animationController!.animateWith(simulation);
  }

  ///hide overlay to show dialogs
  bool _hideOverlay = false;
  bool _isInMinimizedState = false;

  bool _isDialogShown = false;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  void _dismiss() {
    final size = MediaQuery.of(context).size;

    if (_isInMinimizedState) {
      _runSpringSimulation(const Offset(0, 0), _startAlignment, size)
          .then((value) {
        ref.read(hideBottomNavProvider.notifier).state = false;
        _removeOverlay();
      });
    } else {
      _animationController?.reverse().then((value) {
        ref.read(hideBottomNavProvider.notifier).state = false;
        _removeOverlay();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChangeOutput = ref.watch(rbfChangeOutputProvider);
    int totalSelectedAmount =
        ref.watch(getTotalSelectedAmount(widget.account.id));
    final size = MediaQuery.of(context).size;

    ref.listen(spendEditModeProvider, (previous, next) {
      if (next == SpendOverlayContext.hidden && overlayEntry != null) {
        _dismiss();
        //always show bottom nav when overlay is hidden
      }
    });

    ref.listen(coinSelectionStateProvider, (previous, next) {
      if (!setEquals(previous, next)) {
        ref.read(userSelectedCoinsThisSessionProvider.notifier).state = true;
      }
    });

    final spendEditMode = ref.watch(spendEditModeProvider);
    final requiredAmount = ref.watch(spendAmountProvider);
    bool inTagSelectionMode = requiredAmount == 0;

    bool showRequiredAmount = !inTagSelectionMode;

    if (spendEditMode == SpendOverlayContext.rbfSelection) {
      totalSelectedAmount += selectedChangeOutput?.amount.toInt() ?? 0;
    }

    bool valid =
        (totalSelectedAmount != 0 && totalSelectedAmount >= requiredAmount);

    if (spendEditMode == SpendOverlayContext.rbfSelection) {
      showRequiredAmount = false;
      valid = totalSelectedAmount != 0;
    }

    //hide when dialog is shown, we dont want to remove overlay from the widget tree
    //if the user chose to stay in the coin selection screen and we need to show the overlay again

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (inTagSelectionMode && !ref.read(coinDetailsActiveProvider)) {
          if (!_isDialogShown) {
            await cancel(context); // Make sure to await the async call
          }
        }
        if (inTagSelectionMode && ref.read(coinDetailsActiveProvider)) {
          if (context.mounted) {
            Navigator.of(context).pop();
            //wait for coin details screen to animate out
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
        // Return true to always intercept the back button and avoid app exit
        return true;
      },
      child: AnimatedOpacity(
        opacity: _hideOverlay ? 0 : 1,
        duration: const Duration(milliseconds: 120),
        child: GestureDetector(
          onPanDown: (details) {
            _animationController!.stop();
          },
          onPanUpdate: (details) {
            setState(() {
              Alignment update = _dragAlignment;
              update += Alignment(
                0,
                details.delta.dy / (size.height / 2),
              );
              if (update.y >= _endAlignment.y) {
                _dragAlignment = update;
              }
            });
          },
          onPanEnd: (details) {
            _isInMinimizedState = false;
            ref.read(coinSelectionOverlayMinimized.notifier).state = false;

            double currentY = _dragAlignment.y;
            if (currentY < 1.5) {
              _runSpringSimulation(
                  details.velocity.pixelsPerSecond, _endAlignment, size);
            }
            final unitsPerSecondX =
                details.velocity.pixelsPerSecond.dx / size.width;
            final unitsPerSecondY =
                details.velocity.pixelsPerSecond.dy / size.height;
            final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
            final unitVelocity = unitsPerSecond.distance;

            if (unitVelocity >= 1.8) {
              _runSpringSimulation(
                  details.velocity.pixelsPerSecond, _endAlignment, size);
            }
            //threshold to show dismiss dialog
            if (currentY >= 1.2) {
              _isInMinimizedState = true;
              ref.read(coinSelectionOverlayMinimized.notifier).state = true;
              _runSpringSimulation(
                  details.velocity.pixelsPerSecond, _minimizedAlignment, size);
            }
          },
          onTap: () {
            if (_isInMinimizedState) {
              _isInMinimizedState = false;
              ref.read(coinSelectionOverlayMinimized.notifier).state = false;
              _runSpringSimulation(const Offset(0, 0), _endAlignment, size);
            } else {
              _isInMinimizedState = true;
              ref.read(coinSelectionOverlayMinimized.notifier).state = true;
              _runSpringSimulation(
                  const Offset(0, 0), _minimizedAlignment, size);
            }
          },
          child: Align(
            alignment: _dragAlignment,
            child: Transform.scale(
              scale: 1.0,
              child: SizedBox(
                  height: 245,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.applyOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset:
                              const Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 100,
                      shadowColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(EnvoySpacing.medium1),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          //Handle
                          Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(
                                  top: EnvoySpacing.xs,
                                  bottom: EnvoySpacing.small),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              )),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: EnvoySpacing.small,
                                    vertical: EnvoySpacing.small,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: EnvoySpacing.xs)),
                                      showRequiredAmount
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal:
                                                          EnvoySpacing.small),
                                              child: Row(
                                                children: [
                                                  Text(S()
                                                      .coincontrol_edit_transaction_requiredAmount),
                                                  const Spacer(),
                                                  EnvoyAmount(
                                                      amountSats:
                                                          requiredAmount,
                                                      amountWidgetStyle:
                                                          AmountWidgetStyle
                                                              .sendScreen,
                                                      account: widget.account)
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                                      const Padding(
                                          padding:
                                              EdgeInsets.all(EnvoySpacing.xs)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: EnvoySpacing.small),
                                        child: Builder(builder: (_) {
                                          List<Widget> sheetOptions = [];
                                          if (inTagSelectionMode) {
                                            sheetOptions.add(GestureDetector(
                                              onTap: () {
                                                cancel(context);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  margin: const EdgeInsets.only(
                                                      right: EnvoySpacing.xs),
                                                  decoration: BoxDecoration(
                                                    color: EnvoyColors.surface2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            EnvoySpacing
                                                                .medium1),
                                                  ),
                                                  child: const Icon(Icons.close,
                                                      size: 14),
                                                ),
                                              ),
                                            ));
                                          }

                                          sheetOptions.addAll([
                                            Text(
                                              S().coincontrol_edit_transaction_selectedAmount,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                            const Spacer(),
                                            EnvoyAmount(
                                                amountSats: totalSelectedAmount,
                                                amountWidgetStyle:
                                                    AmountWidgetStyle
                                                        .sendScreen,
                                                account: widget.account)
                                          ]);
                                          return Row(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: sheetOptions,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: _isInMinimizedState ? 0 : 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: EnvoySpacing.small,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        EnvoyButton(
                                          enabled: valid,
                                          type: EnvoyButtonTypes.primaryModal,
                                          inTagSelectionMode
                                              ? S().tagged_tagDetails_sheet_cta1
                                              : S().component_continue,
                                          onTap: () =>
                                              onPrimaryButtonTap(context),
                                        ),
                                        const Padding(
                                            padding: EdgeInsets.all(
                                                EnvoySpacing.xs)),
                                        inTagSelectionMode
                                            ? coinSelectionButton(
                                                valid: valid,
                                                inTagSelectionMode:
                                                    inTagSelectionMode)
                                            : transactionEditButton(context),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                        .padding
                                                        .bottom +
                                                    EnvoySpacing.medium3))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }

  bool dialogOpen = false;

  Widget coinSelectionButton(
      {required bool inTagSelectionMode, required bool valid}) {
    EnvoyAccount? selectedAccount = ref.read(selectedAccountProvider);
    Set<String> selection = ref.watch(coinSelectionStateProvider);
    String buttonText = S().component_cancel;
    if (inTagSelectionMode) {
      List<Tag> tags = ref.read(tagsProvider(selectedAccount?.id ?? "")) ?? [];
      bool isCoinsOnlyPartOfUntagged = false;
      Tag? untagged = tags.firstWhereOrNull((element) => element.untagged);
      if (untagged == null) {
        isCoinsOnlyPartOfUntagged = false;
      } else {
        isCoinsOnlyPartOfUntagged = true;

        /// check if selected coins are only part of untagged coins
        selection.toList().forEach((selectionId) {
          if (!untagged.utxo.map((e) => e.getId()).contains(selectionId)) {
            isCoinsOnlyPartOfUntagged = false;
          }
        });
      }

      buttonText = isCoinsOnlyPartOfUntagged
          ? S().tagged_tagDetails_sheet_cta2
          : S().tagged_tagDetails_sheet_retag_cta2;
    }
    return EnvoyButton(
      enabled: valid,
      type: EnvoyButtonTypes.secondary,
      buttonText,
      onTap: () async {
        if (dialogOpen) return; // Prevent opening multiple dialogs
        NavigatorState navigator = Navigator.of(context, rootNavigator: true);
        if (!inTagSelectionMode) {
          SpendRequirementOverlayState().cancel(context);
          return;
        }
        if (selectedAccount == null) {
          return;
        }
        bool dismissed = await EnvoyStorage()
            .checkPromptDismissed(DismissiblePrompt.createCoinTagWarning);
        setState(() {
          _hideOverlay = true;
        });
        final selectedOutputs = _getSelectedOutputs(selectedAccount.id);
        if (dismissed && mounted) {
          dialogOpen = true;
          await showEnvoyDialog(
            context: context,
            useRootNavigator: true,
            onDispose: () {
              dialogOpen = false;
            },
            builder: Builder(
              builder: (context) => CreateCoinTag(
                accountId: selectedAccount.id,
                coins: selectedOutputs,
                onTagUpdate: (context) async {
                  final container = ProviderScope.containerOf(context);
                  container.read(coinSelectionStateProvider.notifier).reset();
                  await Future.delayed(const Duration(milliseconds: 100));
                  Haptics.lightImpact();
                  navigator.popUntil((route) {
                    return route.settings is MaterialPage;
                  });
                },
              ),
            ),
            alignment: const Alignment(0.0, -.6),
          );
        } else if (mounted) {
          setState(() {
            dialogOpen = true;
          });
          await showEnvoyDialog(
            useRootNavigator: true,
            context: context,
            onDispose: () {
              // setState(() {
              dialogOpen = false;
              // });
            },
            builder: Builder(
              builder: (context) {
                return CreateCoinTagWarning(onContinue: () async {
                  Navigator.pop(context); // Close warning dialog
                  await showEnvoyDialog(
                    context: context,
                    useRootNavigator: true,
                    onDispose: () {
                      if (mounted) {
                        setState(() {
                          dialogOpen = false;
                        });
                      }
                    },
                    builder: Builder(
                      builder: (context) => CreateCoinTag(
                        accountId: selectedAccount.id,
                        coins: selectedOutputs,
                        onTagUpdate: (context) async {
                          Haptics.lightImpact();
                          ProviderScope.containerOf(context)
                              .read(coinSelectionStateProvider.notifier)
                              .reset();
                          NavigatorState navigator =
                              Navigator.of(context, rootNavigator: true);
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          navigator.popUntil((route) {
                            return route.settings is MaterialPage;
                          });
                        },
                      ),
                    ),
                    alignment: const Alignment(0.0, -.6),
                  );
                });
              },
            ),
            alignment: const Alignment(0.0, -.6),
          );
        }
        ref.read(coinSelectionStateProvider.notifier).reset();
      },
    );
  }

  Future<void> onPrimaryButtonTap(BuildContext context) async {
    final scope = ProviderScope.containerOf(context);
    final navigator = Navigator.of(context);
    final mode = ref.read(spendEditModeProvider);
    final account = ref.read(selectedAccountProvider);
    Set<String> walletSelection = ref.read(coinSelectionFromWallet);
    Set<String> coinSelection = ref.read(coinSelectionStateProvider);
    Set coinSelectionDiff1 = walletSelection.difference(coinSelection);
    Set coinSelectionDiff2 = coinSelection.difference(walletSelection);
    Set coinSelectionDiff = coinSelectionDiff1
        .union(coinSelectionDiff2); // all the diff (excluding all duplicates)

    if (mode == SpendOverlayContext.editCoins) {
      if (ref.read(coinDetailsActiveProvider)) {
        navigator.pop();
        //wait for coin details screen to animate out
        await Future.delayed(const Duration(milliseconds: 320));
      }
      await Future.delayed(const Duration(milliseconds: 120));

      ///if the user changed the selection, validate the transaction
      if (coinSelectionDiff.isNotEmpty) {
        ///reset fees if coin selection changed
        ref.read(spendFeeRateProvider.notifier).state =
            Fees().slowRate(account!.network);
        ref.read(spendTransactionProvider.notifier).validate(scope);
      }

      ref.read(spendEditModeProvider.notifier).state =
          SpendOverlayContext.hidden;
      await Future.delayed(const Duration(milliseconds: 120));
      //pop coin selection screen, specifically for edit coins for spend screen
      navigator.pop();
      return;
    } else if (mode == SpendOverlayContext.rbfSelection) {
      if (ref.read(coinDetailsActiveProvider)) {
        navigator.pop();
        //wait for coin details screen to animate out
        await Future.delayed(const Duration(milliseconds: 320));
      }
      navigator.pop(coinSelectionDiff);
    } else {
      if (ref.read(coinDetailsActiveProvider)) {
        navigator.pop();
        //wait for coin details screen to animate out
        await Future.delayed(const Duration(milliseconds: 320));
      }

      ref.read(spendEditModeProvider.notifier).state =
          SpendOverlayContext.hidden;
      ref.read(hideBottomNavProvider.notifier).state = false;
      _dismiss();
      mainRouter.go(ROUTE_ACCOUNT_SEND);
      return;
    }
  }

  Widget transactionEditButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(getTotalSelectedAmount(widget.account.id));
        Set<String> walletSelection = ref.watch(coinSelectionFromWallet);
        Set<String> coinSelection = ref.watch(coinSelectionStateProvider);
        Set coinSelectionDiff1 = walletSelection.difference(coinSelection);
        Set coinSelectionDiff2 = coinSelection.difference(walletSelection);
        Set diff = coinSelectionDiff1.union(
            coinSelectionDiff2); // all the diff (excluding all duplicates)
        bool selectionChanged = diff.isNotEmpty;
        return EnvoyButton(
          selectionChanged
              ? S().tagged_coin_details_inputs_fails_cta2
              : S().component_cancel,
          type: EnvoyButtonTypes.secondary,
          onTap: () async {
            if (selectionChanged) {
              ref.read(coinSelectionStateProvider.notifier).reset();
              ref
                  .read(coinSelectionStateProvider.notifier)
                  .addAll(walletSelection.toList());
              return;
            }
            final navigator = Navigator.of(context);
            //reset to previous coin selection
            ref
                .read(coinSelectionStateProvider.notifier)
                .addAll(walletSelection.toList());

            if (ref.read(coinDetailsActiveProvider)) {
              navigator.pop();
              //wait for coin details screen to animate out
              await Future.delayed(const Duration(milliseconds: 320));
            }
            if (ref.read(spendEditModeProvider) ==
                SpendOverlayContext.rbfSelection) {
              navigator.pop();
            } else if (navigator.canPop()) {
              navigator.popUntil((route) {
                return route.settings is MaterialPage;
              });
            }
          },
        );
      },
    );
  }

  Future<void> cancel(BuildContext context) async {
    /// if the user is in utxo details screen we need to wait animations to finish
    /// before we can pop back to home screen
    ProviderContainer container = ProviderScope.containerOf(context);
    if (await EnvoyStorage()
        .checkPromptDismissed(DismissiblePrompt.txDiscardWarning)) {
      ref.read(coinSelectionStateProvider.notifier).reset();
      ref.read(spendEditModeProvider.notifier).state =
          SpendOverlayContext.hidden;
      return;
    }
    setState(() {
      _hideOverlay = true;
    });
    if (context.mounted) {
      _isDialogShown = true;
      bool discard = await showEnvoyDialog(
          dismissible: false,
          context: context,
          useRootNavigator: true,
          dialog: const SpendSelectionCancelWarning(),
          onDispose: () {
            _isDialogShown = false;
          });
      await Future.delayed(const Duration(milliseconds: 130));
      setState(() {
        _hideOverlay = false;
      });
      if (discard) {
        ref.read(coinSelectionStateProvider.notifier).reset();
        ref.read(hideBottomNavProvider.notifier).state = false;
        ref.read(spendEditModeProvider.notifier).state =
            SpendOverlayContext.hidden;
        clearSpendState(container);
      }
    }
  }

  List<Output> _getSelectedOutputs(String id) {
    List<Output> coins = [];
    ref.read(tagsProvider(id)).map((e) => e.utxo).forEach((element) {
      coins.addAll(element);
    });
    Set<String> selection = ref.read(coinSelectionStateProvider);

    return coins
        .where((element) => selection.contains(element.getId()))
        .toList();
  }
}

void hideCoinSnack(WidgetRef ref) {
  ref.read(spendEditModeProvider.notifier).state = SpendOverlayContext.hidden;
  ref.read(hideBottomNavProvider.notifier).state = false;
}

class SpendSelectionCancelWarning extends ConsumerStatefulWidget {
  const SpendSelectionCancelWarning({super.key});

  @override
  ConsumerState<SpendSelectionCancelWarning> createState() =>
      _SpendSelectionCancelWarningState();
}

class _SpendSelectionCancelWarningState
    extends ConsumerState<SpendSelectionCancelWarning> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDismissed = ref
        .watch(arePromptsDismissedProvider(DismissiblePrompt.txDiscardWarning));
    return EnvoyPopUp(
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
      showCloseButton: false,
      content: S().manual_coin_preselection_dialog_description,
      primaryButtonLabel: S().component_yes,
      onPrimaryButtonTap: (context) {
        hideCoinSnack(ref);
        Navigator.of(context).pop(true);
      },
      tertiaryButtonLabel: S().component_no,
      onTertiaryButtonTap: (context) {
        Navigator.of(context).pop(false);
      },
      checkBoxText: S().component_dontShowAgain,
      checkedValue: isDismissed,
      onCheckBoxChanged: (checkedValue) async {
        if (checkedValue) {
          await EnvoyStorage()
              .addPromptState(DismissiblePrompt.txDiscardWarning);
        } else {
          await EnvoyStorage()
              .removePromptState(DismissiblePrompt.txDiscardWarning);
        }
      },
    );
  }
}
