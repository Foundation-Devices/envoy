// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_details_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as newColors;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/easing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoinTagDetailsScreen extends ConsumerStatefulWidget {
  final bool showCoins;
  final CoinTag coinTag;

  const CoinTagDetailsScreen(
      {super.key, this.showCoins = false, required this.coinTag});

  @override
  ConsumerState<CoinTagDetailsScreen> createState() => _CoinTagWidgetState();
}

class _CoinTagWidgetState extends ConsumerState<CoinTagDetailsScreen> {
  bool _menuVisible = false;
  double _menuHeight = 80;
  Coin? _selectedCoin = null;
  ScrollController scrollController = ScrollController();
  GlobalKey _detailWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_menuVisible,
      onPopInvoked: (bool didPop) async {
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
                    Container(
                      height: 100,
                      child: IndicatorShield(),
                    ),
                    Text(
                      _selectedCoin == null
                          ? S()
                              .untagged_coin_details_locked_heading
                              .toUpperCase()
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
                    : SizedBox.shrink(),
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
                  child: child,
                );
              },
              child: _selectedCoin != null
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.medium2),
                        child: CoinDetailsWidget(
                          coin: _selectedCoin!,
                          tag: widget.coinTag,
                        ),
                      ))
                  : CoinTagDetails(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget CoinTagDetails(BuildContext context) {
    final tag = widget.coinTag;
    final maxContainerHeight = MediaQuery.of(context).size.height * 0.50;
    double totalTagHeight = tag.coins.length == 1 ? 98 : 108;
    double coinListHeight =
        (tag.coins.length * 38).toDouble().clamp(34, maxContainerHeight);
    if (widget.showCoins) {
      totalTagHeight += coinListHeight;
    }
    Color border = tag.untagged
        ? Color(0xff808080)
        : tag.getAccount()?.color ?? EnvoyColors.listAccountTileColors[0];
    Color cardBackground = tag.untagged
        ? Color(0xff808080)
        : tag.getAccount()?.color ?? EnvoyColors.listAccountTileColors[0];

    if (tag.coins.isEmpty) {
      ///for empty state
      totalTagHeight = 240;
    }
    //Listen to coin tag lock states
    ref.watch(coinTagLockStateProvider(widget.coinTag));
    if (tag.coins.length == 1) {
      ///only show header of the tag
      totalTagHeight = 100;
    }
    return RawScrollbar(
      thumbColor: Colors.white38,
      thumbVisibility: totalTagHeight >= maxContainerHeight,

      ///to show scroller outside of the main container widget
      padding: EdgeInsets.only(top: 200, right: 24, left: 2),

      interactive: true,

      ///sets up top margin for scroller
      mainAxisMargin: -100,
      thickness: 6,
      controller: scrollController,
      trackRadius: Radius.circular(EnvoySpacing.medium1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
      ),
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
                    children: _getMenuItems(context, tag),
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: totalTagHeight,
                      key: _detailWidgetKey,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
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
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                            border: Border.all(
                                color: border,
                                width: 2,
                                style: BorderStyle.solid)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                            child: StripesBackground(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  _coinHeader(context),
                                  tag.coins.isNotEmpty
                                      ? Expanded(
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(16))),
                                            child: Container(
                                              height: coinListHeight,
                                              child: ListView.builder(
                                                controller: scrollController,
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount: tag.coins.length,
                                                itemBuilder: (context, index) {
                                                  Coin coin = tag.coins[index];
                                                  return InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedCoin = coin;
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      height: 38,
                                                      child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          child:
                                                              CoinBalanceWidget(
                                                            coin: coin,
                                                          )),
                                                    ),
                                                  );
                                                },
                                                padding: tag.coins.length >= 8
                                                    ? EdgeInsets.only(
                                                        bottom: 4, top: 4)
                                                    : EdgeInsets.zero,
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                  tag.coins.isEmpty
                                      ? Expanded(
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 4),
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(16))),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GhostListTile(
                                                  animate: false,
                                                ),
                                                Text(
                                                  S().tagged_tagDetails_emptyState_explainer,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink()
                                ],
                              ),
                            )),
                      ),
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

  List<Widget> _getMenuItems(BuildContext context, CoinTag tag) {
    if (!widget.coinTag.untagged) {
      return [
        GestureDetector(
          //Padding added for better touch target
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              S().tagged_coin_details_menu_cta1,
              style: TextStyle(color: Colors.white),
            ),
          ),
          onTap: () => _editTagName(context),
        ),
        InkWell(
          //Padding added for better touch target
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              S().tagged_coin_details_menu_cta2,
              style: TextStyle(color: EnvoyColors.lightCopper),
            ),
          ),
          onTap: () {
            if (tag.coins.isEmpty)
              _deleteEmptyTag(context);
            else
              _deleteTag(context);
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
              style: TextStyle(color: Colors.white),
            ),
          ),
          onTap: () {},
        ),
      ];
    }
  }

  Widget _coinHeader(BuildContext context) {
    CoinTag tag = widget.coinTag;
    TextStyle _textStyleWallet =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            );

    return GestureDetector(
      onTap: () {
        if (tag.coins.length == 1) {
          setState(() {
            _selectedCoin = tag.coins.first;
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
                            "${widget.coinTag.name}",
                            style: _textStyleWallet,
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
    showEnvoyDialog(
      context: context,
      useRootNavigator: true,
      borderRadius: 20,
      dialog: Builder(
        builder: (context) {
          return DeleteTagDialog(
              dialogSubheading: S().delete_tag_modal_subheading,
              primaryButtonText: S().delete_tag_modal_cta1,
              secondaryButtonText: S().delete_tag_modal_cta2,
              onPrimaryButtonTap: () {
                Navigator.pop(context);
              },
              onSecondaryButtonTap: () async {
                await CoinRepository().deleteTag(widget.coinTag);
                //refresh coins list to update deleted tag item
                final __ = ref.refresh(coinsProvider(widget.coinTag.account));
                Navigator.pop(context);
                _menuVisible = false;
                Navigator.pop(context);
              });
        },
      ),
    );
  }

  _deleteEmptyTag(BuildContext context) {
    showEnvoyDialog(
      context: context,
      useRootNavigator: true,
      borderRadius: 20,
      dialog: Builder(
        builder: (context) {
          return DeleteTagDialog(
              dialogSubheading: S().delete_emptyTag_modal_subheading,
              primaryButtonText: S().delete_emptyTag_modal_cta1,
              secondaryButtonText: S().delete_emptyTag_modal_cta2,
              onPrimaryButtonTap: () {
                Navigator.pop(context);
              },
              onSecondaryButtonTap: () async {
                await CoinRepository().deleteTag(widget.coinTag);
                //refresh coins list to update deleted tag item
                final __ = ref.refresh(coinsProvider(widget.coinTag.account));
                Navigator.pop(context);
                _menuVisible = false;
                Navigator.pop(context);
              });
        },
      ),
    );
  }

  _editTagName(BuildContext context) {
    final textEntry = TextEntry(
      maxLength: 30,
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
                        "Edit Tag Name", // TODO: FIGMA
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
                "Return to my coins", // TODO: FIGMA
                onTap: () {
                  Navigator.pop(context);
                },
                type: EnvoyButtonTypes.tertiary,
              ),
              EnvoyButton(
                S().add_note_modal_cta,
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

class DeleteTagDialog extends StatelessWidget {
  const DeleteTagDialog({
    super.key,
    required this.dialogSubheading,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryButtonTap,
    required this.onSecondaryButtonTap,
  });

  final String dialogSubheading;
  final String primaryButtonText;
  final String secondaryButtonText;
  final Function onPrimaryButtonTap;
  final Function onSecondaryButtonTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 270,
        maxWidth: MediaQuery.of(context).size.width * 0.80,
      ),
      child: Padding(
        padding: const EdgeInsets.all(EnvoySpacing.medium2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight.add(Alignment(.1, 0)),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
              child: Image.asset("assets/exclamation_triangle.png", width: 68),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
              child: Text(
                dialogSubheading,
                textAlign: TextAlign.center,
                style: EnvoyTypography.info
                    .copyWith(color: newColors.EnvoyColors.textPrimary),
              ),
            ),
            EnvoyButton(
              secondaryButtonText,
              textStyle: EnvoyTypography.body
                  .copyWith(color: EnvoyColors.copper, fontSize: 16),
              onTap: () async {
                await onSecondaryButtonTap();
              },
              type: EnvoyButtonTypes.tertiary,
            ),
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
              child: EnvoyButton(
                primaryButtonText,
                textStyle: EnvoyTypography.body
                    .copyWith(color: EnvoyColors.white100, fontSize: 16),
                type: EnvoyButtonTypes.primaryModal,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                onTap: () async {
                  await onPrimaryButtonTap();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
