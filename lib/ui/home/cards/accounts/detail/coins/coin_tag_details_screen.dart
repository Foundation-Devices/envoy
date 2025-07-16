// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/components/stripe_painter.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_details_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/coin_selection_overlay.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as new_colors;
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

class CoinTagDetailsScreen extends ConsumerStatefulWidget {
  final bool showCoins;
  final Tag coinTag;

  const CoinTagDetailsScreen(
      {super.key, this.showCoins = false, required this.coinTag});

  @override
  ConsumerState<CoinTagDetailsScreen> createState() => _CoinTagWidgetState();
}

class _CoinTagWidgetState extends ConsumerState<CoinTagDetailsScreen> {
  bool _menuVisible = false;
  final double _menuHeight = 80;
  Output? _selectedCoin;
  final GlobalKey _detailWidgetKey = GlobalKey();

  final scrollController = ScrollController();
  bool isScrollable = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        setState(() {
          isScrollable = scrollController.position.maxScrollExtent > 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedCoin == null,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (_selectedCoin != null) {
          setState(() {
            _selectedCoin = null;
          });
        }
        //if menu is active, close it
        if (_menuVisible) {
          setState(() {
            _menuVisible = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _menuVisible ? Colors.black : Colors.transparent,
            _menuVisible ? Colors.black : Colors.transparent,
            Colors.transparent,
            Colors.transparent,
          ],
        )),
        child: GestureDetector(
          onTapUp: (details) {
            if (_selectedCoin != null) {
              setState(() {
                _selectedCoin = null;
              });
              return;
            }
            try {
              /// if the tap is outside of the coin details widget and menu is not active, pop the screen
              final RenderBox box = _detailWidgetKey.currentContext
                  ?.findRenderObject() as RenderBox;
              final Offset localOffset =
                  box.globalToLocal(details.globalPosition);
              if (box.paintBounds.contains(localOffset) == false &&
                  _menuVisible == false) {
                Navigator.of(context).pop();
              }
            } catch (e) {
              //no-op
            }
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: () {
                  if (_selectedCoin != null) {
                    setState(() {
                      _selectedCoin = null;
                    });
                  } else
                  //if menu is active, close it
                  if (_menuVisible) {
                    setState(() {
                      _menuVisible = false;
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              flexibleSpace: SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      height: 100,
                      child: IndicatorShield(),
                    ),
                    Text(
                      _selectedCoin == null
                          ? S().coinDetails_tagDetails.toUpperCase()
                          : S().coindetails_overlay_heading.toUpperCase(),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ],
                ),
              ),
              actions: [
                !widget.coinTag.untagged && _selectedCoin == null
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _menuVisible = !_menuVisible;
                          });
                        },
                        icon: Icon(_menuVisible
                            ? Icons.close
                            : CupertinoIcons.ellipsis))
                    : const SizedBox.shrink(),
              ],
            ),
            body: PageTransitionSwitcher(
              reverse: _selectedCoin == null,
              transitionBuilder: (
                Widget child,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return SharedAxisTransition(
                  animation: animation,
                  fillColor: Colors.transparent,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.scaled,
                  child: Align(alignment: Alignment.topCenter, child: child),
                );
              },
              child: _selectedCoin != null
                  ? GestureDetector(
                      onTap: () {}, // if you tap inside the window do not exit
                      child: CoinDetailsWidget(
                        output: _selectedCoin!,
                        tag: widget.coinTag,
                      ),
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: coinTagDetails(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget coinTagDetails(BuildContext context) {
    final selectedAccount = ref.read(selectedAccountProvider);
    final tag = ref.watch(tagProvider(widget.coinTag.name)) ?? widget.coinTag;
    final accountAccent = selectedAccount?.color != null
        ? fromHex(selectedAccount!.color)
        : EnvoyColors.accentSecondary;
    Color border = tag.untagged ? const Color(0xff808080) : accountAccent;
    Color cardBackground =
        tag.untagged ? const Color(0xff808080) : accountAccent;
    const cardRadius = EnvoySpacing.medium2;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseHeight = 145.0;
    final itemHeight = 45.0;
    final padding = EnvoySpacing.medium2;

    // 1. Original maxAvailableHeight
    final maxAvailableHeight = screenHeight * 0.8;
    final maxItems1 = ((maxAvailableHeight - baseHeight) / itemHeight).floor();
    final calculatedMaxHeight = baseHeight + itemHeight * maxItems1;

    // 2. With extended overlay
    final maxAvailableHeightWithExtendedOverlay = screenHeight - 350 - padding;

    // 3. With minimized overlay
    final maxAvailableHeightWithMinimizedOverlay = screenHeight - 250 - padding;

    final spendEditMode = ref.watch(spendEditModeProvider);
    final isMinimized = ref.watch(coinSelectionOverlayMinimized);

    final selectedMaxHeight = spendEditMode != SpendOverlayContext.hidden
        ? (isMinimized
            ? maxAvailableHeightWithMinimizedOverlay
            : maxAvailableHeightWithExtendedOverlay)
        : calculatedMaxHeight;

    void animateToIndex(int index) {
      if (!scrollController.hasClients) return;
      if (ref.watch(spendEditModeProvider) == SpendOverlayContext.hidden ||
          !isScrollable) {
        return;
      }

      final isLast = index == tag.utxo.length - 1;
      final maxScroll = scrollController.position.maxScrollExtent;
      final target = (index * itemHeight - 45).clamp(0, maxScroll).toDouble();

      if (isLast && (scrollController.offset - target).abs() > 50) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 45,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        return;
      }

      if (index > 6 && (scrollController.offset - target).abs() > 50) {
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _menuVisible ? _menuHeight : 0,
          padding: const EdgeInsets.only(top: EnvoySpacing.small),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _menuVisible ? 1 : 0,
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(
                children: _getMenuItems(context, tag),
              ),
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              key: _detailWidgetKey,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.all(Radius.circular(cardRadius - 1)),
                border: Border.all(
                    color: Colors.black, width: 2, style: BorderStyle.solid),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cardBackground,
                      Colors.black,
                    ]),
              ),
              child: AnimatedContainer(
                constraints: BoxConstraints(
                  // Fixed maxHeight to ensure consistent layout and prevent coin tags from being cut off across different mobile screen sizes (ENV-2079)
                  maxHeight: selectedMaxHeight,
                ),
                decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.all(Radius.circular(cardRadius - 3)),
                    border: Border.all(
                        color: border, width: 2, style: BorderStyle.solid)),
                duration: const Duration(milliseconds: 300),
                child: RawScrollbar(
                  controller: scrollController,
                  thumbVisibility: isScrollable,
                  padding: const EdgeInsets.only(
                      right: -EnvoySpacing.medium1, top: 100, bottom: -100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.all(Radius.circular(cardRadius - 4)),
                    child: CustomPaint(
                      isComplex: true,
                      willChange: false,
                      painter: StripePainter(
                        EnvoyColors.gray1000.applyOpacity(0.4),
                      ),
                      child: tag.utxo.length == 1
                          ? singleCoinWidget(context, tag)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _coinHeader(context, tag),
                                (tag.utxo.isNotEmpty && tag.utxo.length >= 2)
                                    ? Flexible(
                                        child: Container(
                                          margin: const EdgeInsets.all(
                                              EnvoySpacing.xs),
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      cardRadius - 9))),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(
                                                        cardRadius - 9)),
                                            child: ScrollConfiguration(
                                              behavior: ScrollConfiguration.of(
                                                      context)
                                                  .copyWith(scrollbars: false),
                                              child: ListView(
                                                  controller: scrollController,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  padding: EdgeInsets.zero,
                                                  children: List.generate(
                                                    tag.utxo.length,
                                                    (index) {
                                                      final coin =
                                                          tag.utxo[index];
                                                      return InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          selectCoin(
                                                              context, coin);
                                                        },
                                                        child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child:
                                                                CoinBalanceWidget(
                                                              output: coin,
                                                              coinTag: tag,
                                                              onEnable: () {
                                                                Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                    () {
                                                                  animateToIndex(
                                                                      index);
                                                                });
                                                              },
                                                            )),
                                                      );
                                                    },
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                tag.utxo.isEmpty
                                    ? Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(
                                            EnvoySpacing.xs),
                                        padding: const EdgeInsets.all(
                                            EnvoySpacing.medium1),
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16))),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const GhostListTile(
                                              animate: false,
                                              diagonal: false,
                                              leadingHeight:
                                                  EnvoySpacing.medium2,
                                              minLeadingWidth:
                                                  EnvoySpacing.small,
                                              subtitleRightPadding:
                                                  EnvoySpacing.xl,
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.only(
                                                    top: EnvoySpacing.medium1)),
                                            Text(
                                              S().tagged_tagDetails_emptyState_explainer,
                                              style: EnvoyTypography.subheading
                                                  .copyWith(
                                                fontSize: 11,
                                                color: new_colors
                                                    .EnvoyColors.textTertiary,
                                              ),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.only(
                                                    top: EnvoySpacing.medium1))
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget singleCoinWidget(BuildContext context, Tag tag) {
    TextStyle textStyleWallet =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            );
    return GestureDetector(
      onTap: () {
        if (tag.utxo.length == 1) {
          selectCoin(context, tag.utxo.first);
        }
      },
      child: Consumer(
        builder: (context, ref, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: double.infinity,
                height: 62,
                padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.small, vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag.name,
                      style: textStyleWallet,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    CoinSubTitleText(tag),
                  ],
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return Container(
                    padding: const EdgeInsets.all(EnvoySpacing.xs),
                    height: 44,
                    child: CoinTagBalanceWidget(coinTag: tag),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _getMenuItems(BuildContext context, Tag tag) {
    if (!widget.coinTag.untagged) {
      return [
        GestureDetector(
          //Padding added for better touch target
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              S().tagged_coin_details_menu_cta1,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onTap: () => _editTagName(context),
        ),
        InkWell(
          //Padding added for better touch target
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              S().delete_tag_modal_cta2.toUpperCase(),
              style: const TextStyle(color: EnvoyColors.accentSecondary),
            ),
          ),
          onTap: () {
            if (tag.utxo.isEmpty) {
              _deleteEmptyTag(context);
            } else {
              _deleteTag(context);
            }
          },
        ),
      ];
    } else {
      return [
        GestureDetector(
          //Padding added for better touch target
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              S().tagged_coin_details_menu_cta1,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onTap: () {},
        ),
      ];
    }
  }

  Widget _coinHeader(BuildContext context, Tag tag) {
    TextStyle textStyleWallet =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            );

    return GestureDetector(
      onTap: () {
        if (tag.utxo.length == 1) {
          setState(() {
            _selectedCoin = tag.utxo.first;
          });
        }
      },
      child: Consumer(
        builder: (context, ref, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tag.name,
                            style: textStyleWallet,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          CoinSubTitleText(tag),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.symmetric(
                        vertical: 2, horizontal: 4.5),
                    height: 42,
                    child: CoinTagBalanceWidget(coinTag: tag),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  _deleteTag(BuildContext context) {
    final navigator = Navigator.of(context);
    showEnvoyDialog(
      context: context,
      useRootNavigator: true,
      borderRadius: 20,
      dialog: Builder(
        builder: (context) {
          return DeleteTagDialog(
              dialogSubheading: S().delete_tag_modal_subheading,
              primaryButtonText: S().component_back,
              secondaryButtonText: S().delete_tag_modal_cta2,
              onPrimaryButtonTap: () {
                navigator.pop();
              },
              onSecondaryButtonTap: () async {
                //TODO: use ngwallet
                // await CoinRepository().deleteTag(widget.coinTag);
                //refresh coins list to update deleted tag item
                // ignore: unused_result
                final selectedAccount = ref.read(selectedAccountProvider);
                if (selectedAccount != null) {
                  try {
                    await selectedAccount.handler?.renameTag(
                        existingTag: widget.coinTag.name, newTag: "");
                  } catch (e) {
                    kPrint("Error deleting tag: $e");
                  }
                }
                navigator.pop();
                _menuVisible = false;
                navigator.pop();
              });
        },
      ),
    );
  }

  _deleteEmptyTag(BuildContext context) {
    final navigator = Navigator.of(context);
    showEnvoyDialog(
      context: context,
      useRootNavigator: true,
      borderRadius: 20,
      dialog: Builder(
        builder: (context) {
          return DeleteTagDialog(
              dialogSubheading: S().delete_emptyTag_modal_subheading,
              primaryButtonText: S().component_back,
              secondaryButtonText: S().delete_tag_modal_cta2,
              onPrimaryButtonTap: () {
                navigator.pop();
              },
              onSecondaryButtonTap: () async {
                final selectedAccount = ref.read(selectedAccountProvider);
                if (selectedAccount != null) {
                  try {
                    await selectedAccount.handler?.renameTag(
                        existingTag: widget.coinTag.name, newTag: "");
                  } catch (e) {
                    kPrint("Error deleting empty tag: $e");
                  }
                }
                navigator.pop();
                _menuVisible = false;
                navigator.pop();
              });
        },
      ),
    );
  }

  _editTagName(BuildContext context) {
    final textEntry = TextEntry(
      maxLength: 30,
      placeholder: widget.coinTag.name,
      textAlign: TextAlign.center,
    );
    bool renameInProgress = false;
    showEnvoyDialog(
        context: context,
        linearGradient: true,
        blurColor: Colors.black,
        dialog: EnvoyDialog(
          title: S().tagDetails_EditTagName,
          content: textEntry,
          actions: [
            StatefulBuilder(
              builder: (context, stateSetter) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    EnvoyButton(
                      label: S().component_save,
                      type: ButtonType.primary,
                      state: renameInProgress
                          ? ButtonState.loading
                          : ButtonState.defaultState,
                      onTap: () async {
                        stateSetter(() {
                          renameInProgress = true;
                        });
                        final selectedAccount =
                            ref.read(selectedAccountProvider);
                        if (selectedAccount != null) {
                          await selectedAccount.handler?.renameTag(
                              existingTag: widget.coinTag.name,
                              newTag: textEntry.enteredText);
                        }
                        stateSetter(() {
                          renameInProgress = false;
                        });
                        await Future.delayed(const Duration(milliseconds: 100));
                        if (context.mounted) {
                          setState(() {
                            //update local tag name so it will be used to update instance from provider
                            widget.coinTag.name = textEntry.enteredText;
                            _menuVisible = false;
                          });
                          Navigator.of(context).pop();
                          setState(() {
                            _menuVisible = false;
                          });
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ));
  }

  void selectCoin(BuildContext context, Output coin) {
    final selectedAccount = ref.read(selectedAccountProvider);
    final transactions = ref.read(transactionsProvider(selectedAccount!.id));
    final tx =
        transactions.firstWhereOrNull((element) => element.txId == coin.txId);
    if (tx != null) {
      setState(() {
        _selectedCoin = coin;
      });
    } else {
      EnvoyToast(
        backgroundColor: EnvoyColors.danger,
        replaceExisting: true,
        duration: const Duration(seconds: 4),
        message: "Error: Transaction Not found",
        icon: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
      ).show(context);
    }
  }
}

class DeleteTagDialog extends StatelessWidget {
  const DeleteTagDialog({
    super.key,
    this.dialogHeading = "",
    required this.dialogSubheading,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryButtonTap,
    required this.onSecondaryButtonTap,
  });

  final String dialogHeading;
  final String dialogSubheading;
  final String primaryButtonText;
  final String secondaryButtonText;
  final Function onPrimaryButtonTap;
  final Function onSecondaryButtonTap;

  @override
  Widget build(BuildContext context) {
    final heading =
        dialogHeading.isNotEmpty ? dialogHeading : S().component_warning;

    return EnvoyPopUp(
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
      title: heading,
      showCloseButton: true,
      content: dialogSubheading,
      primaryButtonLabel: primaryButtonText,
      onPrimaryButtonTap: (context) async {
        await onPrimaryButtonTap();
      },
      tertiaryButtonLabel: secondaryButtonText,
      // use tertiary button style
      tertiaryButtonTextColor: EnvoyColors.accentSecondary,
      onTertiaryButtonTap: (context) async {
        await onSecondaryButtonTap();
      },
    );
  }
}
