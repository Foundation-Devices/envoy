// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_switch.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/create_coin_tag_dialog.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/warning_dialogs.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoinDetailsScreen extends ConsumerStatefulWidget {
  final bool showCoins;
  final CoinTag coinTag;

  const CoinDetailsScreen(
      {super.key, this.showCoins = false, required this.coinTag});

  @override
  ConsumerState<CoinDetailsScreen> createState() => _CoinTagWidgetState();
}

class _CoinTagWidgetState extends ConsumerState<CoinDetailsScreen> {
  bool _menuVisible = false;
  double _menuHeight = 80;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 300))
        .then((value) => Haptics.lightImpact());
  }

  @override
  Widget build(BuildContext context) {
    // if (_childKey.currentContext?.findRenderObject() != null)
    //   print("_childKey ${(_childKey.currentContext?.findRenderObject() as RenderBox).size}");

    final tag = widget.coinTag;
    double totalTagHeight = 108;
    double coinListHeight = (tag.coins.length * 38).toDouble().clamp(38, 260);
    if (widget.showCoins) {
      totalTagHeight += coinListHeight;
    }
    Color border =
        tag.untagged ? Color(0xff808080) : EnvoyColors.listAccountTileColors[0];
    Color cardBackground =
        tag.untagged ? Color(0xff808080) : EnvoyColors.listAccountTileColors[0];

    return WillPopScope(
      onWillPop: () async {
        //if menu is active, close it
        if (_menuVisible) {
          setState(() {
            _menuVisible = false;
          });
          return false;
        }
        return true;
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
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
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () {
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
                  Container(
                    height: 100,
                    child: IndicatorShield(),
                  ),
                  Text(
                    "COIN DETAILS",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              !widget.coinTag.untagged
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _menuVisible = !_menuVisible;
                        });
                      },
                      icon: Icon(
                          _menuVisible ? Icons.close : CupertinoIcons.ellipsis))
                  : SizedBox.shrink(),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SizedBox(
                  height: _menuHeight,
                  child: Column(
                    children: [
                      Container(
                        height: _menuHeight,
                        padding: EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            //TODO: localize
                            GestureDetector(
                              //Padding added for better touch target
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: Text(
                                  "Edit Tag Name".toUpperCase(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              onTap: () => _editTagName(context),
                            ),
                            InkWell(
                              //Padding added for better touch target
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: Text(
                                  "Delete Tag".toUpperCase(),
                                  style:
                                      TextStyle(color: EnvoyColors.lightCopper),
                                ),
                              ),
                              onTap: () => _deleteTag(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                  top: _menuVisible ? _menuHeight - 8 : 0,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  curve: EnvoyEasing.easeInOut,
                  duration: Duration(milliseconds: 250),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // minHeight: coinListHeight,
                        maxHeight: 680,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: totalTagHeight,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                              border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                  style: BorderStyle.solid),
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    cardBackground,
                                    Colors.black,
                                  ]),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(24)),
                                  border: Border.all(
                                      color: border,
                                      width: 2,
                                      style: BorderStyle.solid)),
                              child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(24)),
                                  child: StripesBackground(
                                    child: Column(
                                      children: [
                                        _coinHeader(context),
                                        RawScrollbar(
                                          thumbVisibility: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12)),
                                          ),
                                          trackVisibility: true,
                                          thickness: 4,
                                          trackBorderColor: Colors.transparent,
                                          trackRadius: Radius.zero,
                                          padding: EdgeInsets.only(
                                              top: 12, right: 7, bottom: 8),
                                          trackColor: Colors.transparent,
                                          thumbColor: EnvoyColors.grey85,
                                          child: Container(
                                            margin: EdgeInsets.only(top: 4),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12))),
                                              height: coinListHeight,
                                              child: ListView.builder(
                                                controller: scrollController,
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount: tag.coins.length,
                                                itemBuilder: (context, index) {
                                                  Coin coin = tag.coins[index];
                                                  return SizedBox(
                                                    height: 38,
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                vertical: 0,
                                                                horizontal: 4),
                                                        child:
                                                            CoinBalanceWidget(
                                                          amount:
                                                              coin.utxo.value,
                                                          locked: coin.locked,
                                                          onLockTap: () async {
                                                            if (!coin.locked) {
                                                              bool dismissed =
                                                                  await EnvoyStorage()
                                                                      .checkPromptDismissed(
                                                                          DismissiblePrompt
                                                                              .coinLockWarning);
                                                              if (!dismissed) {
                                                                showEnvoyDialog(
                                                                    context:
                                                                        context,
                                                                    alignment:
                                                                        Alignment(
                                                                            0.0,
                                                                            -.6),
                                                                    builder:
                                                                        Builder(
                                                                      builder:
                                                                          (context) {
                                                                        return CoinLockWarning(
                                                                          buttonTitle:
                                                                              "Lock Coins",
                                                                          promptType:
                                                                              DismissiblePrompt.coinLockWarning,
                                                                          warningMessage:
                                                                              "You’re about to lock coins.\nThis will prevent them from being used in transactions.",
                                                                          onContinue:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                            _lockUnLockCoin(coin);
                                                                          },
                                                                        );
                                                                      },
                                                                    ));
                                                              } else {
                                                                _lockUnLockCoin(
                                                                    coin);
                                                              }
                                                            } else {
                                                              bool dismissed =
                                                                  await EnvoyStorage()
                                                                      .checkPromptDismissed(
                                                                          DismissiblePrompt
                                                                              .coinUnlockWarning);
                                                              if (!dismissed) {
                                                                showEnvoyDialog(
                                                                    context:
                                                                        context,
                                                                    alignment:
                                                                        Alignment(
                                                                            0.0,
                                                                            -.6),
                                                                    builder:
                                                                        Builder(
                                                                      builder:
                                                                          (context) {
                                                                        return CoinLockWarning(
                                                                          buttonTitle:
                                                                              "Unlock coins",
                                                                          promptType:
                                                                              DismissiblePrompt.coinUnlockWarning,
                                                                          warningMessage:
                                                                              "Unlocking coins will make them available for use in transactions.",
                                                                          onContinue:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                            _lockUnLockCoin(coin);
                                                                          },
                                                                        );
                                                                      },
                                                                    ));
                                                              } else {
                                                                _lockUnLockCoin(
                                                                    coin);
                                                              }
                                                            }
                                                          },
                                                          switchWidget:
                                                              Consumer(
                                                            builder: (context,
                                                                ref, child) {
                                                              final isSelected =
                                                                  ref.watch(
                                                                      isCoinSelectedProvider(
                                                                          coin.id));
                                                              return CoinTagSwitch(
                                                                value: isSelected
                                                                    ? CoinTagSwitchState
                                                                        .on
                                                                    : CoinTagSwitchState
                                                                        .off,
                                                                onChanged:
                                                                    (value) {
                                                                  final selectionState =
                                                                      ref.read(
                                                                          coinSelectionStateProvider
                                                                              .notifier);
                                                                  if (value ==
                                                                      CoinTagSwitchState
                                                                          .on) {
                                                                    selectionState
                                                                        .add(coin
                                                                            .id);
                                                                  } else {
                                                                    selectionState
                                                                        .remove(
                                                                            coin.id);
                                                                  }
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        )),
                                                  );
                                                },
                                                padding: tag.coins.length >= 8
                                                    ? EdgeInsets.only(
                                                        bottom: 4, top: 4)
                                                    : EdgeInsets.zero,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final selections =
                                  ref.watch(coinSelectionStateProvider);
                              bool anythingSelected = widget.coinTag
                                      .getNumSelectedCoins(selections) !=
                                  0;
                              return AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: anythingSelected ? 1.0 : 0.0,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 24),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      EnvoyButton(
                                          S()
                                              .untagged_coin_details_spendable_cta2,
                                          type: EnvoyButtonTypes.tertiary,
                                          onTap: () async {
                                        //Shows warning dialog
                                        bool dismissed = await EnvoyStorage()
                                            .checkPromptDismissed(
                                                DismissiblePrompt
                                                    .createCoinTagWarning);
                                        if (dismissed) {
                                          showEnvoyDialog(
                                              context: context,
                                              builder: Builder(
                                                builder: (context) =>
                                                    CreateCoinTag(
                                                  accountId: tag.account,
                                                  tag: tag,
                                                ),
                                              ),
                                              alignment: Alignment(0.0, -.6));
                                        } else {
                                          showEnvoyDialog(
                                              context: context,
                                              builder:
                                                  Builder(builder: (context) {
                                                return CreateCoinTagWarning(
                                                    onContinue: () {
                                                  //pop warning dialog
                                                  Navigator.pop(context);
                                                  //Shows Coin create dialog
                                                  showEnvoyDialog(
                                                      context: context,
                                                      builder: Builder(
                                                        builder: (context) =>
                                                            CreateCoinTag(
                                                          accountId:
                                                              tag.account,
                                                          tag: tag,
                                                        ),
                                                      ),
                                                      alignment:
                                                          Alignment(0.0, -.6));
                                                });
                                              }),
                                              alignment: Alignment(0.0, -.6));
                                        }
                                      },
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  color: EnvoyColors.white100,
                                                  fontWeight: FontWeight.w600)),
                                      Opacity(
                                        opacity: 0.4,
                                        child: EnvoyButton(
                                            S()
                                                .untagged_coin_details_spendable_cta1,
                                            type: EnvoyButtonTypes.tertiary,
                                            enabled: false,
                                            onTap: () {},
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                    color: EnvoyColors.white100,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _lockUnLockCoin(Coin coin) async {
    setState(() {
      coin.setLock(!coin.locked);
      //if coin is locked, remove it from selection
      if (coin.locked) {
        ref.read(coinSelectionStateProvider.notifier).remove(coin.id);
      }
    });
    Future.delayed(Duration(milliseconds: 100))
        .then((value) => Haptics.lightImpact());
  }

  Widget _coinHeader(BuildContext context) {
    CoinTag tag = widget.coinTag;
    TextStyle _textStyleWallet =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            );

    return Consumer(
      builder: (context, ref, child) {
        final selections = ref.watch(coinSelectionStateProvider);
        int selectedItems = widget.coinTag.getNumSelectedCoins(selections);

        CoinTagSwitchState coinTagSwitchState = selectedItems == 0
            ? CoinTagSwitchState.off
            : CoinTagSwitchState.partial;
        if (selectedItems == tag.numOfCoins) {
          coinTagSwitchState = CoinTagSwitchState.on;
        }
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
                          "${widget.coinTag.name}",
                          style: _textStyleWallet,
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
                //TODO: hide tag balance using [ balanceHideStateStatusProvider]
                // final hide = ref.watch(balanceHideStateStatusProvider(account));
                // final hide = false;
                // if (hide) {
                //   return Container();
                // }
                if (tag.coins.isEmpty) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Center(
                        child: Text("No coins"),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Container(
                    height: 40,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    child: CoinBalanceWidget(
                      amount: tag.totalAmount,
                      showLock: true,
                      onLockTap: () {
                        setState(() {
                          tag.updateLockState(!tag.isAllCoinsLocked);
                          if (tag.isAllCoinsLocked) {
                            tag.coins_id.forEach((coinId) {
                              ref
                                  .read(coinSelectionStateProvider.notifier)
                                  .remove(coinId);
                            });
                          }
                        });
                        Haptics.lightImpact();
                      },
                      switchWidget: CoinTagSwitch(
                        onChanged: (switchState) {
                          final coinSelectionState =
                              ref.read(coinSelectionStateProvider.notifier);
                          if (coinTagSwitchState == CoinTagSwitchState.off) {
                            coinSelectionState.addAll(
                                tag.selectableCoins.map((e) => e.id).toList());
                          } else if (coinTagSwitchState ==
                              CoinTagSwitchState.partial) {
                            coinSelectionState.removeAll(
                                tag.selectableCoins.map((e) => e.id).toList());
                          } else {
                            coinSelectionState.removeAll(
                                tag.selectableCoins.map((e) => e.id).toList());
                          }
                        },
                        triState: true,
                        value: coinTagSwitchState,
                      ),
                      locked: tag.isAllCoinsLocked,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  _deleteTag(BuildContext context) {
    showEnvoyDialog(
      context: context,
      dialog: Builder(
        builder: (context) {
          return EnvoyDialog(
            content: Builder(
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Image.asset("assets/exclamation_triangle.png",
                          width: 48),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Warning\n\nYou’re about to delete a tag.The coins will be marked as untagged once tag is deleted.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: [
              EnvoyButton(
                "Delete Tag anyway",
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: EnvoyColors.darkCopper),
                onTap: () async {
                  await CoinRepository().deleteTag(widget.coinTag);
                  //refresh coins list to update deleted tag item
                  final __ = ref.refresh(coinsProvider(widget.coinTag.account));
                  // await Future.delayed(Duration(milliseconds: 200));
                  Navigator.pop(context);
                  _menuVisible = false;
                  Navigator.pop(context);
                },
                type: EnvoyButtonTypes.tertiary,
              ),
              EnvoyButton(
                "Return to my coins",
                onTap: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  _editTagName(BuildContext context) {
    final textEntry = TextEntry(
      maxLength: 20,
      placeholder: widget.coinTag.name,
    );
    showEnvoyDialog(
      context: context,
      dialog: Builder(
        builder: (context) {
          return EnvoyDialog(
            content: Builder(
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Edit Tag Name",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    textEntry,
                  ],
                );
              },
            ),
            actions: [
              EnvoyButton(
                "Return to my coins",
                onTap: () {
                  Navigator.pop(context);
                },
                type: EnvoyButtonTypes.tertiary,
              ),
              EnvoyButton(
                S().component_save.toUpperCase(),
                onTap: () async {
                  widget.coinTag.name = textEntry.enteredText;
                  int updated =
                      await CoinRepository().updateCoinTag(widget.coinTag);
                  if (updated != 0) {
                    //Update local instance
                    setState(() {
                      widget.coinTag.name = textEntry.enteredText;
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class StripesBackground extends StatelessWidget {
  final Widget child;

  const StripesBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.minHeight,
          width: constraints.maxWidth,
          child: CustomPaint(
            isComplex: true,
            willChange: false,
            child: child,
            painter: LinesPainter(
                color: EnvoyColors.tilesLineDarkColor, opacity: 1.0),
          ),
        );
      },
    );
  }
}
