// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/bottom_navigation.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_card.dart';
import 'package:envoy/ui/home/cards/activity/activity_card.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:envoy/ui/home/cards/learn/learn_card.dart';
import 'package:envoy/ui/home/cards/privacy/privacy_card.dart';
import 'package:envoy/ui/home/cards/tl_navigation_card.dart';
import 'package:envoy/ui/home/settings/settings_menu.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/tor_warning.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:wallet/wallet.dart';

class HomePageNotification extends Notification {
  final String? title;
  final Function()? leftFunction;
  final Function()? rightFunction;

  final IconData? rightFunctionIcon;

  final Widget? optionsWidget;

  final bool modal;
  final bool showOptions;

  const HomePageNotification(
      {this.title,
      this.leftFunction,
      this.rightFunction,
      this.optionsWidget,
      this.rightFunctionIcon,
      this.modal = false,
      this.showOptions = false});
}

class HomePageCard {
  final TopLevelNavigationCard widget;
  final String label;

  HomePageCard(this.label, this.widget);
}

class HomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  Widget _background = Container();

  bool _backgroundShown = false;
  bool _modalShown = false;

  Widget _options = Container();
  final _optionsKey = GlobalKey();
  bool _optionsShown = false;
  double _optionsHeight = 0;

  double _bottomTabBarHeight = 70.0;

  int _tlCardIndex = 0;
  String _appBarTitle = S().envoy_home_devices.toUpperCase();

  Function()? _leftAction;
  Function()? _rightAction;

  IconData? _rightActionIcon;

  final _animationsDuration = Duration(milliseconds: 350);

  final _tlCardList = [
    HomePageCard(S().bottomNav_devices, DevicesCard()),
    HomePageCard(S().bottomNav_privacy, PrivacyCard()),
    HomePageCard(S().bottomNav_accounts, AccountsCard()),
    HomePageCard(S().bottomNav_activity, ActivityCard()),
    HomePageCard(S().bottomNav_learn, LearnCard()),
  ];

  void initState() {
    super.initState();

    _tabController = TabController(
      length: _tlCardList.length,
      initialIndex: 2,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Sets default home card
      _navigateToCard(2);
    });
    // Home is there for the lifetime of the app so no need to dispose stream
    ConnectivityManager().events.stream.listen((event) {
      // If Tor is broken surface a warning
      if (event == ConnectivityManagerEvent.TorConnectedDoesntWork) {
        if (Settings().usingTor) {
          _notifyAboutTor();
        }
      }
    });

    EnvoyStorage()
        .isPromptDismissed(DismissiblePrompt.secureWallet)
        .listen((dismissed) {
      // if is not dismissed listen balance
      if (!dismissed) {
        AccountManager()
            .isAccountBalanceHigherThanUsd1000Stream
            .stream
            .listen((event) {
          if (ref.read(homePageTabProvider) != HomePageTabState.accounts) {
            return;
          }

          final currentAccount =
              ref.read(homePageAccountsProvider).currentAccount;

          if (currentAccount != null &&
              currentAccount.wallet.hot &&
              currentAccount.wallet.network == Network.Mainnet) {
            _notifyAboutHighBalance();
          }
        });
      }
    });

    EnvoySeed().backupCompletedStream.stream.listen((bool success) {
      if (success)
        EnvoyToast(
          backgroundColor: Colors.lightBlue,
          replaceExisting: true,
          duration: Duration(seconds: 4),
          message: S().manual_toggle_on_seed_backup_in_progress_toast_heading,
          icon: Icon(
            Icons.info_outline,
            color: EnvoyColors.darkTeal,
          ),
        ).show(context);
      else
        EnvoyToast(
          backgroundColor: Colors.lightBlue,
          replaceExisting: true,
          duration: Duration(seconds: 3),
          message: "Unable to backup. Please try again later.",
          icon: Icon(
            Icons.error_outline_rounded,
            color: EnvoyColors.darkCopper,
          ),
        ).show(context);
    });
  }

  _notifyAboutTor() {
    EnvoyToast(
      backgroundColor: Colors.lightBlue,
      replaceExisting: true,
      message: S().tor_connectivity_toast_warning,
      icon: Icon(
        Icons.error_outline_rounded,
        color: EnvoyColors.darkCopper,
      ),
      actionButtonText: S().tor_connectivity_toast_warning_learn_more,
      onActionTap: () {
        EnvoyToast.dismissPreviousToasts(context);
        showEnvoyDialog(dialog: TorWarning(), context: context);
      },
    ).show(context);
  }

  _notifyAboutHighBalance() {
    AccountManager().isAccountBalanceHigherThanUsd1000Stream.close();
    showSecurityDialog(context);
  }

  void _toggleSettings() {
    final background = ref.read(homePageBackgroundProvider.notifier);
    _backgroundShown = !_backgroundShown;

    if (_backgroundShown) {
      background.state = HomePageBackgroundState.menu;
    } else {
      background.state = HomePageBackgroundState.hidden;
    }
  }

  void _toggleOptions() {
    ref.read(homePageOptionsVisibilityProvider.notifier).state =
        !ref.read(homePageOptionsVisibilityProvider);
  }

  void _getOptionsHeight(_) {
    var context = _optionsKey.currentContext;
    if (context == null) return;

    _optionsHeight = _optionsKey.currentContext?.size!.height ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomePageTabState>(homePageTabProvider,
        (HomePageTabState? _, HomePageTabState newState) {
      _navigateToCard(newState.index);
    });

    ref.listen(homePageOptionsVisibilityProvider, (_, bool next) {
      setState(() {
        _optionsShown = next;
      });
    });

    ref.listen<HomePageBackgroundState>(homePageBackgroundProvider,
        (HomePageBackgroundState? oldState, HomePageBackgroundState newState) {
      // TODO: use ref.watch instead (when we're using riverpod throughout)
      setState(() {
        switch (newState) {
          case HomePageBackgroundState.hidden:
            _backgroundShown = false;
            _appBarTitle = _tlCardList[_tlCardIndex].label.toUpperCase();
            //reset right action
            _background = Container();
            _tlCardList[_tlCardIndex].widget.tlCardState?.notifyHomePage();
            break;
          case HomePageBackgroundState.menu:
          case HomePageBackgroundState.settings:
          case HomePageBackgroundState.backups:
          case HomePageBackgroundState.support:
          case HomePageBackgroundState.about:
            _backgroundShown = true;
            _background = SettingsMenu();
            _appBarTitle = "Envoy".toUpperCase();
            break;
          default:
            break;
        }
        ;
      });
    });
    // After we render everything find out the widgets' height
    SchedulerBinding.instance.addPostFrameCallback(_getOptionsHeight);
    //SchedulerBinding.instance.addPostFrameCallback(_getTabBarHeight);

    double _screenHeight = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    double _screenWidth = MediaQuery.of(context).size.width;

    double _topOffset = MediaQuery.of(context).padding.top;
    double _bottomOffset = MediaQuery.of(context).padding.bottom;
    //double _totalOffset = _topOffset + _bottomOffset;

    double _appBarHeight = AppBar().preferredSize.height;
    double _topAppBarOffset = _appBarHeight + 10;
    double _shieldTop = _topOffset + _topAppBarOffset;
    double _shieldTopOptionsShown =
        _shieldTop + _optionsHeight; // TODO: This needs to be programmatic

    double _bottomTabBarShieldOffset = 15;
    double _shieldHeight = _screenHeight -
        _bottomTabBarHeight -
        _bottomOffset -
        _shieldTop -
        _bottomTabBarShieldOffset;

    double _shieldHeightModalShown = _screenHeight * 0.85 - _bottomOffset;
    double _shieldHeightOptionsShown = _screenHeight * 0.76 - _bottomOffset;

    // ignore: unused_local_variable
    double _shieldGlowOffset = 30;

    _leftAction ??= _toggleSettings;

    return NotificationListener(
        onNotification: (HomePageNotification notification) {
          Future.delayed(Duration.zero, () async {
            setState(() {
              _leftAction = notification.leftFunction;
              if (notification.optionsWidget != null) {
                //hide options menu if user press back button (android)
                _options = WillPopScope(
                  onWillPop: () async {
                    if (ref.read(homePageOptionsVisibilityProvider)) {
                      ref
                          .read(homePageOptionsVisibilityProvider.notifier)
                          .state = false;
                      return false;
                    }
                    return true;
                  },
                  child: Container(
                      key: _optionsKey, child: notification.optionsWidget!),
                );

                _rightAction = _toggleOptions;
                if (_rightAction != null) {
                  _rightActionIcon = notification.rightFunctionIcon;
                }
              } else {
                _rightAction = notification.rightFunction;

                if (_rightAction != null) {
                  _rightActionIcon = notification.rightFunctionIcon;
                }

                if (_optionsShown) {
                  _toggleOptions();
                }
              }
              _rightActionIcon = notification.rightFunctionIcon;
              _modalShown = notification.modal;
              if (notification.title != null) {
                _appBarTitle = notification.title!;
              }
            });
          });
          return true;
        },
        child: WillPopScope(
          onWillPop: () async {
            if (_backgroundShown) {
              _leftAction?.call();
              return false;
            } else {
              if (_leftAction != null && _leftAction != _toggleSettings) {
                _leftAction?.call();
                return false;
              } else if (_tabController.index != 2) {
                _navigateToCard(2);
                return false;
              }
              return true;
            }
          },
          child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                // Get rid of the shadow
                elevation: 0,

                backgroundColor: Colors.transparent,
                leading: HamburgerMenu(
                    iconState: _backgroundShown
                        ? 1
                        : _leftAction == _toggleSettings
                            ? 0
                            : -1,
                    onPressed: _leftAction ?? () => {}),
                title: Stack(
                    fit: StackFit.loose,
                    alignment: Alignment.center,
                    children: [
                      AnimatedSwitcher(
                          duration: _animationsDuration,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              _appBarTitle,
                              key: ValueKey<String>(_appBarTitle),
                            ),
                          )),
                      SizedBox(height: 50, child: IndicatorShield())
                    ]),
                centerTitle: true,
                actions: [
                  // Right action
                  AnimatedSwitcher(
                      duration: _animationsDuration, child: buildRightAction())
                ],
              ),
              body: // Something behind
                  Stack(
                children: [
                  // Main background
                  AnimatedPositioned(
                      top: 0,
                      height: _backgroundShown
                          ? _screenHeight + 1500
                          : _screenHeight,
                      left: 0,
                      right: 0,
                      curve: Curves.easeIn,
                      duration: Duration(
                          milliseconds:
                              _animationsDuration.inMilliseconds - 50),
                      child: AppBackground()),
                  // Variable background
                  SafeArea(
                    child: AnimatedSwitcher(
                        duration: _animationsDuration,
                        child: Container(
                          child: _background,
                        )),
                  ),
                  // Tab bar
                  AnimatedOpacity(
                      duration: Duration(
                          milliseconds:
                              _animationsDuration.inMilliseconds ~/ 2),
                      opacity:
                          _backgroundShown || (_modalShown || _optionsShown)
                              ? 0
                              : 1.0,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: IgnorePointer(
                          ignoring: _backgroundShown || _modalShown,
                          child: EnvoyBottomNavigation(
                            onIndexChanged: (selectedIndex) {
                              ref.read(homePageTabProvider.notifier).state =
                                  HomePageTabState.values[selectedIndex];
                              setState(() {
                                _navigateToCard(selectedIndex);
                              });
                            },
                            // indicatorColor: Colors.white10,
                            // labelStyle:
                            //     Theme.of(context).textTheme.bodyLarge,
                            // unselectedLabelColor: Colors.black54,
                            // labelColor: EnvoyColors.darkTeal,
                            // controller: _tabController,
                            // onTap: (selectedIndex) {
                            //   ref.read(homePageTabProvider.notifier).state =
                            //       HomePageTabState.values[selectedIndex];
                            //   setState(() {
                            //     _navigateToCard(selectedIndex);
                            //   });
                            // },
                            // tabs: _tlCardList
                            //     .map((e) => Tab(
                            //           icon: e.icon,
                            //           text: e.label,
                            //         ))
                            //     .toList(),
                          ),
                        ),
                      )),
                  // Glow
                  // AnimatedPositioned(
                  //   duration: _animationsDuration,
                  //   top: _backgroundShown
                  //       ? _screenHeight + 20
                  //       : _optionsShown
                  //           ? _shieldTopOptionsShown - _shieldGlowOffset
                  //           : _shieldTop - _shieldGlowOffset,
                  //   // Sized relative to screen height
                  //   height: _screenWidth,
                  //   left: 0,
                  //   right: 0,
                  //   child: Glow(
                  //     innerColor: EnvoyColors.glowInner,
                  //     middleColor: EnvoyColors.glowMiddle,
                  //     outerColor: EnvoyColors.glowOuter,
                  //     stops: [0.0, 0.5, 1.0],
                  //   ),
                  // ),
                  // Options
                  Positioned(
                      top: _shieldTop - 20,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                          ignoring: !_optionsShown,
                          child: AnimatedOpacity(
                              opacity: _optionsShown ? 1.0 : 0.0,
                              duration: _animationsDuration,
                              child: AnimatedSwitcher(
                                  duration: _animationsDuration,
                                  child: _options)))),
                  // Shield
                  AnimatedPositioned(
                    duration: _animationsDuration,
                    top: _backgroundShown
                        ? _screenHeight + 20
                        : _optionsShown
                            ? _shieldTopOptionsShown
                            : _shieldTop,
                    height: _modalShown
                        ? _shieldHeightModalShown
                        : _optionsShown
                            ? _shieldHeightOptionsShown
                            : _shieldHeight,
                    left: 5,
                    right: 5,
                    child: AnimatedOpacity(
                      opacity: _backgroundShown ? 0.0 : 1.0,
                      duration: _backgroundShown
                          ? Duration(
                              milliseconds:
                                  _animationsDuration.inMilliseconds ~/ 2)
                          : _animationsDuration,
                      curve: _backgroundShown
                          ? Curves.linear
                          : ShieldFadeInAnimationCurve(),
                      child: Hero(
                        tag: "shield",
                        child: Material(
                          type: MaterialType.transparency,
                          child: Shield(
                            child: TabBarView(
                              // Don't scroll
                              physics: NeverScrollableScrollPhysics(),
                              controller: _tabController,
                              children:
                                  _tlCardList.map((e) => e.widget).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }

  void _navigateToCard(int selectedIndex) {
    _tabController.animateTo(selectedIndex);
    _tlCardIndex = selectedIndex;
    _appBarTitle = _tlCardList[_tlCardIndex].label.toUpperCase();

    if (_leftAction != null && _leftAction != _toggleSettings) {
      _leftAction!();
    }
  }

  AbsorbPointer buildRightAction() {
    return AbsorbPointer(
        absorbing: _backgroundShown || _modalShown,
        child: AnimatedOpacity(
            opacity: _backgroundShown || _modalShown ? 0.0 : 1.0,
            duration: _animationsDuration,
            child: AnimatedSwitcher(
                duration: _animationsDuration,
                child: _optionsShown
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                        ),
                        onPressed: _toggleOptions,
                      )
                    : IconButton(
                        icon: Icon(
                          _rightActionIcon,
                          color: Colors.white,
                        ),
                        onPressed: _rightAction,
                      ))));
  }
}

class ShieldFadeInAnimationCurve extends Curve {
  @override
  double transformInternal(double t) {
    if (t < 0.5) {
      return 0.0;
    } else {
      return (t - 0.5) * 2 * t;
    }
  }
}

//animated hamburger menu
class HamburgerMenu extends ConsumerStatefulWidget {
  // 0 for idle
  // 1 for upward icon
  // -1 for back icon
  final int iconState;
  final GestureTapCallback onPressed;

  const HamburgerMenu(
      {super.key, required this.iconState, required this.onPressed});

  @override
  ConsumerState<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends ConsumerState<HamburgerMenu> {
  Artboard? _menuArtBoard;
  StateMachineController? _menuController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _loadMenu());
    super.initState();
  }

  _loadMenu() async {
    ByteData menuRive = await rootBundle.load('assets/hamburger.riv');
    final file = RiveFile.import(menuRive);
    _menuController =
        StateMachineController.fromArtboard(file.mainArtboard, 'statemachine');
    setState(() => _menuArtBoard = file.mainArtboard);
    _menuArtBoard?.addController(_menuController!);
  }

  @override
  void dispose() {
    _menuController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 0 for idle
    /// 1 for upward icon
    /// -1 for back icon
    switch (widget.iconState) {
      case 0:
        _menuController?.findInput<double>("state_pos")?.change(0.0);
        break;
      case 1:
        _menuController?.findInput<double>("state_pos")?.change(1);
        break;
      case -1:
        _menuController?.findInput<double>("state_pos")?.change(-1);
        break;
      default:
        _menuController?.findInput<double>("state_pos")?.change(0.0);
        break;
    }
    return GestureDetector(
      onTap: widget.onPressed,
      child: Center(
        child: Container(
          height: 24,
          width: 24,
          child: SizedBox.fromSize(
            child: _menuArtBoard != null
                ? Rive(
                    artboard: _menuArtBoard!,
                    fit: BoxFit.contain,
                  )
                : SizedBox.square(),
            size: Size.square(24),
          ),
        ),
      ),
    );
  }
}
