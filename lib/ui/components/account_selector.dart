import 'dart:ui';

import 'package:envoy/business/account.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/linear_gradient.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

class StackedAccountChooser extends StatefulWidget {
  final Account account;
  final Function(Account account) onAccountSelected;
  final Function(bool overlayVisible) onOverlayChanges;
  final List<Account> accounts;

  const StackedAccountChooser({
    super.key,
    required this.accounts,
    required this.account,
    required this.onAccountSelected,
    required this.onOverlayChanges,
  });

  @override
  State<StackedAccountChooser> createState() => StackedAccountChooserState();
}

OverlayEntry? _entry;

class StackedAccountChooserState extends State<StackedAccountChooser> {
  //key for each card, this will passed to AccountChooserOverlay to calculate the position of the card
  final Map<String, GlobalKey> _cardStackKeys = {};

  late Account _selectedAccount = widget.account;

  final GlobalKey<AccountChooserOverlayState> accountChooserKey = GlobalKey();

  // flag dictates if the stack widget should be visible or not
  // if the overlay is visible means we have to hide
  bool _overlayVisible = false;

  //animation status from AccountChooserOverlay
  AnimationStatus _status = AnimationStatus.dismissed;

  get account => widget.account;

  get accounts => widget.accounts;

  bool get chooserOpen => _overlayVisible;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var element in widget.accounts) {
        _cardStackKeys[element.id!] = GlobalKey();
      }
    });
  }

  List<Account> get _backStack {
    return accounts
        .where(
          (element) => _selectedAccount.id != element.id,
        )
        .toList();
  }

  double _getBackStackOffset(int index) {
    //if the accounts length is below 2 or below that means only one card will needs offset
    // 0 index is already handled by the selected account, so only 1 needs to render
    if (accounts.length <= 2) {
      index = 1;
    }
    //alignment offset for partially visible cards
    //only two cards will be shown partially. the front card will be rendered outside
    //rest of the cards will draw behind ( 0.0 )
    return {
          0: -1.6,
          1: -0.8,
        }[index] ??
        -0.8;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: GestureDetector(
        onTap: () {
          openChooserOverlay(context);
          return;
        },
        child: Offstage(
          offstage: _status.isAnimating,
          child: Stack(
            children: [
              for (var (account) in _backStack)
                Align(
                  alignment: Alignment(
                      0, _getBackStackOffset(_backStack.indexOf(account))),
                  child: Opacity(
                    opacity: _overlayVisible ? 0 : 1,
                    child: AccountListTile(
                      account,
                      key: _cardStackKeys[account.id!],
                      onTap: () {
                        openChooserOverlay(context);
                        return;
                      },
                      draggable: false,
                    ),
                  ),
                ),
              for (var (account) in accounts)
                if (account.id == _selectedAccount.id)
                  Align(
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: _overlayVisible ? 0 : 1,
                      child: AccountListTile(
                        key: _cardStackKeys[account.id!],
                        account,
                        onTap: () {
                          openChooserOverlay(context);
                          return;
                        },
                        draggable: false,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant StackedAccountChooser oldWidget) {
    if (oldWidget.account == _selectedAccount ||
        widget.accounts.length != oldWidget.accounts.length) return;
    super.didUpdateWidget(oldWidget);
  }

  void openChooserOverlay(
    BuildContext context,
  ) {
    //check if overlay is already open
    if (_entry?.mounted == true) {
      return;
    }
    final theme = Theme.of(context);
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (context) {
        return Theme(
          data: theme,
          child: AccountChooserOverlay(
            key: accountChooserKey,
            account: _selectedAccount,
            cardStackKeys: _cardStackKeys,
            onAnimChanges: (animStatus) {
              if (mounted) {
                setState(() {
                  _status = animStatus;
                });
              } else {
                _entry?.remove();
              }
            },
            onAccountSelected: (account) {
              if (mounted) {
                setState(() {
                  _selectedAccount = account;
                });
                widget.onAccountSelected(account);
              } else {
                _entry?.remove();
              }
            },
            accounts: widget.accounts,
            onOverlayChanges: (bool onVisible) {
              widget.onOverlayChanges(onVisible);
              if (mounted) {
                setState(() {
                  _overlayVisible = onVisible;
                });
              }
            },
          ),
        );
      },
    );
    overlay.insert(_entry!);
  }

  dismiss() {
    accountChooserKey.currentState?.dismiss();
  }
}

// Overlay widget for the account chooser.
// The parent widget will pass all widget keys as a map along with account IDs.
// This widget contains a ListView with accounts and will calculate the coordinates
// of the list and the passed widgets (using a global key from parameters). It then creates a
// RectTween to create a hero-like transition.
// The widget uses physics animation to make it feel more natural.
class AccountChooserOverlay extends StatefulWidget {
  final Account account;
  final List<Account> accounts;
  final Map<String, GlobalKey<State<StatefulWidget>>> cardStackKeys;
  final Function(Account account) onAccountSelected;
  final Function(AnimationStatus animStatus) onAnimChanges;
  final Function(bool onVisible) onOverlayChanges;

  const AccountChooserOverlay({
    super.key,
    required this.account,
    required this.accounts,
    required this.onAccountSelected,
    required this.onAnimChanges,
    required this.cardStackKeys,
    required this.onOverlayChanges,
  });

  @override
  State<AccountChooserOverlay> createState() => AccountChooserOverlayState();
}

class AccountChooserOverlayState extends State<AccountChooserOverlay>
    with SingleTickerProviderStateMixin {
  GlobalKey key = GlobalKey();
  final Map<String, GlobalKey> _shuttleCardKeys = {};
  final Map<String, Rect> _listCardRect = {};
  final Map<String, Rect> _stackCardRect = {};

  //flag to hide listview when the widget is not ready
  bool isReady = false;

  //local copy of the selected account,used to track local state change
  late Account _selectedAccount;

  //unbounded controller since the animations are physics based
  late final animationController = AnimationController.unbounded(vsync: this);

  // forward the spring properties, defines how bouncy the list items are
  final SpringDescription _forwardSpring = const SpringDescription(
    mass: 1.2,
    stiffness: 130.0,
    damping: 13.5,
  );

  // return spring properties, defines how bouncy the stacked accounts are
  final SpringDescription _reverseSpring = const SpringDescription(
    mass: 1.6,
    stiffness: 120.0,
    damping: 12.0,
  );

  //spring simulation to animate the cards
  late final _forwardSimulation =
      SpringSimulation(_forwardSpring, 0.0, 1.0, 0.0);
  late final _reverseSpringSimulation =
      SpringSimulation(_reverseSpring, 1.0, 0.0, 0.0);

  @override
  void initState() {
    _selectedAccount = widget.account;

    for (var account in widget.accounts) {
      _shuttleCardKeys[account.id!] = GlobalKey();
    }
    animationController.addListener(() {
      setState(() {});
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _calcStackCardRect();
        _calcListCardRect();
        setState(() {
          isReady = true;
        });
        widget.onOverlayChanges(true);
        animationController.animateWith(_forwardSimulation);
      },
    );
  }

  //calculates list card rect from
  _calcListCardRect() {
    _shuttleCardKeys.forEach((key, value) {
      Rect? rect = _getRect(value);
      if (rect == null) {
        return;
      }
      _listCardRect[key] = rect;
    });
  }

  //calculates stacked card rect from cardStackKeys
  _calcStackCardRect() {
    widget.cardStackKeys.forEach((key, value) {
      Rect? rect = _getRect(value);
      if (rect == null) {
        return;
      }
      _stackCardRect[key] = rect;
    });
  }

  //calculate rect from GlobalKey
  Rect? _getRect(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    final Offset? offset =
        renderBox != null && renderBox.attached && renderBox.hasSize
            ? renderBox.localToGlobal(
                Offset.zero,
              )
            : null;
    if (renderBox == null || offset == null) {
      return null;
    }
    return offset & renderBox.size;
  }

  _selectAccount(Account account) async {
    setState(() {
      _selectedAccount = account;
    });
    widget.onAccountSelected(account);
    // addPostFrameCallback is necessary to ensure the widget changes are applied before
    // the return animation is triggered.
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _calcListCardRect();
        _calcStackCardRect();
        setState(() {
          _exiting = true;
        });
        animationController.animateWith(_reverseSpringSimulation).then((value) {
          widget.onAnimChanges(animationController.status);
          widget.onOverlayChanges(false);
          _entry?.remove();
        });
      },
    );
  }

  // denotes if the overlay is currently exiting, this flag will be used to
  // used to animate background gradient and blur
  bool _exiting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (!animationController.isAnimating ||
                    animationController.value > 0.85) {
                  _selectAccount(widget.account);
                }
              },
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: _exiting ? 100 : 300),
                tween: ColorTween(
                    begin: _exiting ? Colors.black : Colors.transparent,
                    end: _exiting ? Colors.transparent : Colors.black),
                builder: (context, value, child) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                          value ?? Colors.transparent,
                          const Color(0x00000000),
                        ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                    child: child,
                  );
                },
                child: TweenAnimationBuilder(
                  duration: Duration(milliseconds: _exiting ? 100 : 300),
                  tween: _exiting
                      ? Tween<double>(begin: 5, end: 0)
                      : Tween<double>(begin: 0, end: 5),
                  builder: (context, value, child) {
                    return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                        child: child);
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: AnimatedOpacity(
                        duration: Duration(milliseconds: _exiting ? 100 : 300),
                        opacity: _exiting ? 0 : 1,
                        child: Text(
                          S().header_chooseAccount,
                          style: EnvoyTypography.subheading
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      leading: AnimatedOpacity(
                        duration: Duration(milliseconds: _exiting ? 100 : 300),
                        opacity: _exiting ? 0 : 1,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () {
                            _selectAccount(widget.account);
                          },
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1),
                      child: ScrollGradientMask(
                        child: Offstage(
                          offstage: animationController.isAnimating || !isReady,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                                top: EnvoySpacing.medium1),
                            itemBuilder: (context, index) {
                              final account = widget.accounts[index];
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: AccountListTile(
                                  key: _shuttleCardKeys[account.id!],
                                  account,
                                  onTap: () async {
                                    _selectAccount(account);
                                  },
                                  draggable: false,
                                ),
                              );
                            },
                            itemCount: widget.accounts.length,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          //if the widget is animating,show hero accounts for transition
          if (animationController.isAnimating)
            Positioned.fill(
              child: ScrollGradientMask(
                child: Stack(
                  children: [
                    for (var (account) in widget.accounts.where(
                      (element) => element.id != _selectedAccount.id,
                    ))
                      _buildHeroOverlay(account),
                    for (var (account) in widget.accounts.where(
                      (element) => element.id == _selectedAccount.id,
                    ))
                      _buildHeroOverlay(account),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  dispose() {
    animationController.dispose();
    super.dispose();
  }

  // builds account tile for hero like animation,
  _buildHeroOverlay(Account account) {
    final startRect = _stackCardRect[account.id!];
    final endRect = _listCardRect[account.id!];
    if (startRect == null || endRect == null) {
      return const SizedBox();
    }
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final tween = RectTween(begin: startRect, end: endRect)
            .transform(animationController.value);
        return Positioned.fromRect(
            rect: tween!,
            child: IgnorePointer(
              //allow user to choose item as soon as hero finishes, .85 is the spot where card is fully transitioned
              //rest of the progress will be spring simulation oscillations, at this point user can go back if they want
              ignoring: animationController.value < .85,
              child: Opacity(
                  opacity: animationController.isAnimating ? 1 : 0,
                  child: child),
            ));
      },
      child: AccountListTile(
        account,
        onTap: () {
          _selectAccount(account);
        },
        draggable: false,
      ),
    );
  }

  //dismiss overlay by selecting default selected account
  void dismiss() {
    _selectAccount(widget.account);
  }
}
