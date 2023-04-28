// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/notifications/notifications_page.dart';
import 'package:envoy/ui/home/cards/learn/learn_card.dart';
import 'package:envoy/ui/home/settings/settings_menu.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_card.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/envoy_icons.dart';

//import 'package:envoy/ui/glow.dart';
import 'package:envoy/ui/home/cards/tl_navigation_card.dart';

import 'package:envoy/ui/tor_warning.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final Icon icon;
  final String label;
  final TopLevelNavigationCard widget;

  HomePageCard(this.icon, this.label, this.widget);
}

class HomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  Widget _background = Container();
  bool _notificationsShown = false;
  bool _backgroundShown = false;
  bool _modalShown = false;

  Widget _options = Container();
  final _optionsKey = GlobalKey();
  bool _optionsShown = false;
  double _optionsHeight = 0;

  int _tlCardIndex = 0;
  String _appBarTitle = S().envoy_home_devices.toUpperCase();

  Function()? _leftAction;
  Function()? _rightAction;

  IconData? _rightActionIcon = Icons.add;

  final _animationsDuration = Duration(milliseconds: 350);

  // TODO: Get the names from localisation
  final _tlCardList = [
    HomePageCard(
        const Icon(EnvoyIcons.devices), S().envoy_home_devices, DevicesCard()),
    HomePageCard(const Icon(EnvoyIcons.accounts), S().envoy_home_accounts,
        AccountsCard()),
    HomePageCard(
        const Icon(EnvoyIcons.lightbulb), S().envoy_home_learn, LearnCard()),
  ];

  void initState() {
    super.initState();

    _tabController = TabController(
      length: _tlCardList.length,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bool? onboarded = LocalStorage().prefs.getBool("onboarded");
      if (onboarded != true) {
        Navigator.pushNamed(context, "/splash");
      }
    });
    // Home is there for the lifetime of the app so no need to dispose stream
    ConnectivityManager().events.stream.listen((event) {
      // If Tor is broken surface a warning
      if (event == ConnectivityManagerEvent.TorConnectedDoesntWork) {
        _notifyAboutTor();
      }
    });
  }

  _notifyAboutTor() {
    EnvoyToast(
      backgroundColor: Colors.lightBlue,
      replaceExisting: true,
      message: "Issue establishing Tor connectivity",
      icon: Icon(
        Icons.error_outline_rounded,
        color: EnvoyColors.darkCopper,
      ),
      actionButtonText: "Learn More",
      onActionTap: () {
        EnvoyToast.dismissPreviousToasts(context);
        showEnvoyDialog(dialog: TorWarning(), context: context);
      },
    ).show(context);
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

  void _toggleNotifications() async {
    final background = ref.read(homePageBackgroundProvider.notifier);
    _backgroundShown = !_backgroundShown;
    _notificationsShown = _backgroundShown;

    if (_backgroundShown) {
      background.state = HomePageBackgroundState.notifications;
    } else {
      background.state = HomePageBackgroundState.hidden;
    }
  }

  void _toggleOptions() {
    setState(() {
      _optionsShown = !_optionsShown;
    });
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

    ref.listen<HomePageBackgroundState>(homePageBackgroundProvider,
        (HomePageBackgroundState? oldState, HomePageBackgroundState newState) {
      // TODO: use ref.watch instead (when we're using riverpod throughout)
      setState(() {
        switch (newState) {
          case HomePageBackgroundState.hidden:
            _backgroundShown = false;
            _notificationsShown = false;
            _appBarTitle = _tlCardList[_tlCardIndex].label.toUpperCase();
            //reset right action
            _rightAction = _toggleOptions;

            _background = Container();
            _tlCardList[_tlCardIndex].widget.tlCardState!.notifyHomePage();
            break;
          case HomePageBackgroundState.menu:
          case HomePageBackgroundState.settings:
          case HomePageBackgroundState.backups:
          case HomePageBackgroundState.support:
          case HomePageBackgroundState.about:
            _backgroundShown = true;
            _notificationsShown = false;
            _background = SettingsMenu();
            _appBarTitle = "Envoy".toUpperCase();
            break;
          case HomePageBackgroundState.notifications:
            _backgroundShown = true;
            _notificationsShown = true;
            _appBarTitle = "Activity".toUpperCase();
            _background = NotificationsPage();
            _leftAction = _toggleNotifications;
            break;
          default:
            break;
        }
      });
    });

    // After we render everything find out the options widgets height
    SchedulerBinding.instance.addPostFrameCallback(_getOptionsHeight);

    double _screenHeight = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    double _screenWidth = MediaQuery.of(context).size.width;

    double _topOffset = MediaQuery.of(context).padding.top;
    double _bottomOffset = MediaQuery.of(context).padding.bottom;
    //double _totalOffset = _topOffset + _bottomOffset;

    double _appBarHeight = AppBar().preferredSize.height;

    double _shieldTop = _topOffset + _appBarHeight + 10;
    double _shieldTopOptionsShown =
        _shieldTop + _optionsHeight; // TODO: This needs to be programmatic

    double _shieldHeight = _screenHeight * 0.76 - _bottomOffset;
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
                _options = Container(
                    key: _optionsKey, child: notification.optionsWidget!);
                _rightAction = _toggleOptions;
              } else {
                _rightAction = notification.rightFunction;
                if (_optionsShown) {
                  _toggleOptions();
                }
              }

              if (notification.rightFunctionIcon != null) {
                _rightActionIcon = notification.rightFunctionIcon;
              }

              _modalShown = notification.modal;
              if (notification.title != null) {
                _appBarTitle = notification.title!;
              }

              if (_optionsShown && !notification.showOptions) {
                _toggleOptions();
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
              if (_tabController.index != 1) {
                _tabController.animateTo(1);
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
                leading: AbsorbPointer(
                    absorbing: _optionsShown,
                    child: AnimatedOpacity(
                      opacity: _optionsShown ? 0.0 : 1.0,
                      duration: _animationsDuration,
                      child: IconButton(
                        icon: AnimatedRotation(
                          duration: _animationsDuration,
                          turns: _backgroundShown
                              ? _leftAction == _toggleSettings ||
                                      _notificationsShown
                                  ? 0.25 //Icons.arrow_upward
                                  : 0.0 //Icons.arrow_back
                              : _leftAction == _toggleSettings
                                  ? -0.25 //Icons.arrow_downward
                                  : 0.0, //Icons.arrow_back,
                          child: Icon(Icons.keyboard_arrow_left_sharp),
                        ),
                        onPressed: _leftAction,
                      ),
                    )),
                title: Stack(
                    fit: StackFit.loose,
                    alignment: Alignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: _animationsDuration,
                        child: Text(
                          _appBarTitle,
                          key: ValueKey<String>(_appBarTitle),
                        ),
                      ),
                      SizedBox(height: 50, child: IndicatorShield())
                    ]),
                centerTitle: true,
                actions: [
                  // Notifications
                  AnimatedSwitcher(
                      duration: _animationsDuration,
                      child: _tlCardIndex != 2
                          ? buildNotificationAction()
                          : IgnorePointer(
                              child: IconButton(
                              icon: Icon(null),
                              onPressed: () {},
                            ))),
                  // Right action
                  AnimatedSwitcher(
                      duration: _animationsDuration,
                      child: _tlCardIndex != 2
                          ? buildRightAction()
                          : buildNotificationAction())
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
                  AnimatedSwitcher(
                      duration: _animationsDuration, child: _background),
                  // Tab bar
                  Padding(
                    padding: EdgeInsets.only(bottom: _bottomOffset),
                    child: AnimatedOpacity(
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
                            child: TabBar(
                              indicatorColor: Colors.white10,
                              labelStyle: Theme.of(context).textTheme.bodyLarge,
                              unselectedLabelColor: Colors.black54,
                              labelColor: EnvoyColors.darkTeal,
                              controller: _tabController,
                              onTap: (selectedIndex) {
                                ref.read(homePageTabProvider.notifier).state =
                                    HomePageTabState.values[selectedIndex];
                                setState(() {
                                  _navigateToCard(selectedIndex);
                                });
                              },
                              tabs: _tlCardList
                                  .map((e) => Tab(
                                        icon: e.icon,
                                        text: e.label,
                                      ))
                                  .toList(),
                            ),
                          ),
                        )),
                  ),
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
                        child: Shield(
                          child: TabBarView(
                            // Don't scroll
                            physics: NeverScrollableScrollPhysics(),
                            controller: _tabController,
                            children: _tlCardList.map((e) => e.widget).toList(),
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
                        ),
                        onPressed: _rightAction,
                      ))));
  }

  AbsorbPointer buildNotificationAction() {
    return AbsorbPointer(
        absorbing: (_backgroundShown || _optionsShown) || _modalShown,
        child: AnimatedOpacity(
            opacity:
                (_backgroundShown || _optionsShown) || _modalShown ? 0.0 : 1.0,
            duration: _animationsDuration,
            child: IconButton(
              icon: Icon(
                Icons.notifications,
              ),
              onPressed: _toggleNotifications,
            )));
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
