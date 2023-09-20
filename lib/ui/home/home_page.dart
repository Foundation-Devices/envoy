// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/bottom_navigation.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_card.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/home/top_bar_home.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/tor_warning.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class HomePage extends ConsumerStatefulWidget {
  final StatefulNavigationShell mainNavigationShell;

  HomePage({required this.mainNavigationShell});

  @override
  ConsumerState<HomePage> createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  bool _backgroundShown = false;
  bool _modalShown = false;

  final _optionsKey = GlobalKey();
  bool _optionsShown = false;
  double _optionsHeight = 0;

  double _bottomTabBarHeight = 70.0;

  Function()? _rightAction;

  IconData? _rightActionIcon;

  final _animationsDuration = Duration(milliseconds: 350);

  void initState() {
    super.initState();

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

  void toggleSettings() {
    final background = ref.read(homePageBackgroundProvider.notifier);
    _backgroundShown = !_backgroundShown;
    if (_backgroundShown) {
      background.state = HomePageBackgroundState.menu;
    } else {
      background.state = HomePageBackgroundState.hidden;
    }
  }

  void toggleOptions() {
    ref.read(homePageOptionsVisibilityProvider.notifier).state =
        !ref.read(homePageOptionsVisibilityProvider);
  }

  @override
  Widget build(BuildContext context) {
    bool _optionsShown = ref.watch(homePageOptionsVisibilityProvider);

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

    bool _modalShown = ref.watch(homePageModalModeProvider);
    bool _hideAppBar = ref.watch(homepageHideAppBar);
    HomePageBackgroundState _homepageBackDropState =
        ref.watch(homePageBackgroundProvider);

    _backgroundShown = _homepageBackDropState != HomePageBackgroundState.hidden;
    Widget _background = ref.watch(backdropWidgetProvider);

    HomeShellOptions? homeShellOptions = ref.watch(homeShellOptionsProvider);

    Widget? optionsWidget = homeShellOptions?.optionsWidget;

    Widget _options = Container(
      key: _optionsKey,
      child: optionsWidget,
    );

    ref.listen(
      homeShellOptionsProvider,
      (previous, next) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _optionsHeight = _optionsKey.currentContext?.size!.height ?? 0;
          });
        });
      },
    );

    double shieldTotalTop = _backgroundShown
        ? _screenHeight + 20
        : _optionsShown
            ? _shieldTopOptionsShown
            : _shieldTop;

    double shieldTotalHeight = _modalShown
        ? _shieldHeightModalShown
        : _optionsShown
            ? _shieldHeightOptionsShown
            : _shieldHeight;

    if (_hideAppBar) {
      shieldTotalTop = AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight;
      shieldTotalHeight = MediaQuery.of(context).size.height * 0.88;
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
            child: AnimatedOpacity(
                child: HomeAppBar(backGroundShown: false),
                opacity: _hideAppBar ? 0.0 : 1.0,
                duration: _animationsDuration),
            preferredSize: Size.fromHeight(
                AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight)),
        body: // Something behind
            Stack(
          children: [
            // Main background
            AnimatedPositioned(
                top: 0,
                height: _backgroundShown ? _screenHeight + 1500 : _screenHeight,
                left: 0,
                right: 0,
                curve: Curves.easeIn,
                duration: Duration(
                    milliseconds: _animationsDuration.inMilliseconds - 50),
                child: AppBackground()),
            // Variable background
            SafeArea(
              child: AnimatedSwitcher(
                  duration: _animationsDuration,
                  child: Container(
                    child: _backgroundShown ? _background : Container(),
                  )),
            ),
            // Tab bar
            AnimatedOpacity(
                duration: Duration(
                    milliseconds: _animationsDuration.inMilliseconds ~/ 2),
                opacity: _backgroundShown ||
                        (_modalShown || _optionsShown || _hideAppBar)
                    ? 0
                    : 1.0,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: IgnorePointer(
                    ignoring: _backgroundShown || _modalShown || _hideAppBar,
                    child: EnvoyBottomNavigation(
                      onIndexChanged: (selectedIndex) {
                        widget.mainNavigationShell.goBranch(selectedIndex);
                      },
                    ),
                  ),
                )),
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
                            duration: _animationsDuration, child: _options)))),
            // Shield
            AnimatedPositioned(
              duration: _animationsDuration,
              top: shieldTotalTop,
              height: shieldTotalHeight,
              left: 5,
              right: 5,
              child: AnimatedOpacity(
                opacity: _backgroundShown ? 0.5 : 1.0,
                duration: _backgroundShown
                    ? Duration(
                        milliseconds: _animationsDuration.inMilliseconds ~/ 4)
                    : _animationsDuration,
                curve: _backgroundShown
                    ? Curves.linear
                    : ShieldFadeInAnimationCurve(),
                child: Hero(
                  tag: "shield",
                  child: Material(
                    type: MaterialType.transparency,
                    child: Shield(child: widget.mainNavigationShell),
                  ),
                ),
              ),
            ),
          ],
        ));
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
                        onPressed: toggleOptions,
                      )
                    : IconButton(
                        icon: Icon(
                          _rightActionIcon,
                          color: Colors.white,
                        ),
                        onPressed: _rightAction,
                      ))));
  }

  static HomePageState? of(BuildContext context) {
    return context.findAncestorStateOfType<HomePageState>();
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
