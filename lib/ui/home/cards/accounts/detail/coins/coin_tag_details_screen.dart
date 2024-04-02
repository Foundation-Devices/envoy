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
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_details_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as new_colors;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/list_utils.dart';
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
  final double _menuHeight = 80;
  Coin? _selectedCoin;
  final GlobalKey _detailWidgetKey = GlobalKey();

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
                    SizedBox(
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
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium2),
                      child: CoinDetailsWidget(
                        coin: _selectedCoin!,
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
    final scrollController = ScrollController();
    final tag = widget.coinTag;

    Color border = tag.untagged
        ? const Color(0xff808080)
        : tag.getAccount()?.color ?? EnvoyColors.listAccountTileColors[0];
    Color cardBackground = tag.untagged
        ? const Color(0xff808080)
        : tag.getAccount()?.color ?? EnvoyColors.listAccountTileColors[0];

    //Listen to coin tag lock states
    ref.watch(coinTagLockStateProvider(widget.coinTag));

    const cardRadius = 24.0;
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
                    const BorderRadius.all(Radius.circular(cardRadius)),
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
              child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.all(Radius.circular(cardRadius)),
                    border: Border.all(
                        color: border, width: 2, style: BorderStyle.solid)),
                child: RawScrollbar(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                      right: -EnvoySpacing.medium1, top: 100, bottom: -100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.all(Radius.circular(cardRadius - 2)),
                    child: StripesBackground(
                      child: tag.coins.length == 1
                          ? singleCoinWidget(context)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _coinHeader(context),
                                (tag.coins.isNotEmpty && tag.coins.length >= 2)
                                    ? Flexible(
                                        child: Container(
                                          margin: const EdgeInsets.all(
                                              EnvoySpacing.xs),
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      cardRadius - 5.5))),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    cardRadius - 5.5)),
                                            child: ScrollConfiguration(
                                              behavior: ScrollConfiguration.of(
                                                      context)
                                                  .copyWith(scrollbars: false),
                                              child: ListView(
                                                  controller: scrollController,
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  children: List.generate(
                                                    tag.coins.length,
                                                    (index) {
                                                      Coin coin =
                                                          tag.coins[index];
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
                                                              coin: coin,
                                                            )),
                                                      );
                                                    },
                                                  )),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                tag.coins.isEmpty
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
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: EnvoySpacing.medium1)),
                                            Text(
                                              S().tagged_tagDetails_emptyState_explainer,
                                              style: EnvoyTypography.heading
                                                  .copyWith(
                                                fontSize: 11,
                                                color: new_colors
                                                    .EnvoyColors.textTertiary,
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
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

  Widget singleCoinWidget(BuildContext context) {
    CoinTag tag = widget.coinTag;
    TextStyle textStyleWallet =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            );
    return GestureDetector(
      onTap: () {
        if (tag.coins.length == 1) {
          selectCoin(context, tag.coins.first);
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
                      widget.coinTag.name,
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

  List<Widget> _getMenuItems(BuildContext context, CoinTag tag) {
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
              style: const TextStyle(color: EnvoyColors.lightCopper),
            ),
          ),
          onTap: () {
            if (tag.coins.isEmpty) {
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

  Widget _coinHeader(BuildContext context) {
    CoinTag tag = widget.coinTag;
    TextStyle textStyleWallet =
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
                            widget.coinTag.name,
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
                await CoinRepository().deleteTag(widget.coinTag);
                //refresh coins list to update deleted tag item
                // ignore: unused_result
                ref.refresh(coinsProvider(widget.coinTag.account));
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
                await CoinRepository().deleteTag(widget.coinTag);
                //refresh coins list to update deleted tag item
                // ignore: unused_result
                ref.refresh(coinsProvider(widget.coinTag.account));
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
                S().component_save,
                onTap: () async {
                  final navigator = Navigator.of(context);
                  widget.coinTag.name = textEntry.enteredText;
                  int updated =
                      await CoinRepository().updateCoinTag(widget.coinTag);
                  if (updated != 0) {
                    //Update local instance
                    setState(() {
                      widget.coinTag.name = textEntry.enteredText;
                    });
                    navigator.pop();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void selectCoin(BuildContext context, Coin coin) {
    final selectedAccount = ref.read(selectedAccountProvider);
    final transactions = ref.read(transactionsProvider(selectedAccount!.id));
    final tx = transactions
        .firstWhereOrNull((element) => element.txId == coin.utxo.txid);
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
              alignment: Alignment.centerRight.add(const Alignment(.1, 0)),
              child: IconButton(
                icon: const Icon(Icons.close),
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
                    .copyWith(color: new_colors.EnvoyColors.textPrimary),
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
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
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
