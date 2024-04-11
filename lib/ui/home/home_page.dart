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
import 'package:envoy/ui/home/cards/accounts/accounts_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/home/top_bar_home.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/tor_warning.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/wallet.dart';

final _fullScreenProvider = Provider((ref) {
  bool fullScreen = ref.watch(hideBottomNavProvider);
  Set selections = ref.watch(coinSelectionStateProvider);
  return fullScreen || selections.isNotEmpty;
});

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

  const HomePage({super.key, required this.mainNavigationShell});

  @override
  ConsumerState<HomePage> createState() => HomePageState();
}

final backButtonDispatcher = RootBackButtonDispatcher();

class HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  bool _backgroundShown = false;
  final bool _modalShown = false;

  final _optionsKey = GlobalKey();
  final bool _optionsShown = false;
  double _optionsHeight = 0;

  final double _bottomTabBarHeight = 70.0;

  Function()? _rightAction;

  IconData? _rightActionIcon;

  final _animationsDuration = const Duration(milliseconds: 350);

  Timer? _torWarningTimer;
  bool _torWarningDisplayedMoreThan5minAgo = true;

  Timer? _serverDownWarningTimer;
  bool _serverDownWarningDisplayedMoreThan5minAgo = true;

  void _resetTorWarningTimer() {
    _torWarningTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      _torWarningDisplayedMoreThan5minAgo = true;
    });
  }

  void _resetServerDownWarningTimer() {
    _serverDownWarningTimer =
        Timer.periodic(const Duration(minutes: 5), (_) async {
      _serverDownWarningDisplayedMoreThan5minAgo = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _resetTorWarningTimer();
    _resetServerDownWarningTimer();

    Future.delayed(const Duration(milliseconds: 10), () {
      ///register for back button press
      backButtonDispatcher.addCallback(_handleHomePageBackPress);
    });

    // Home is there for the lifetime of the app so no need to dispose stream
    ConnectivityManager().events.stream.listen((event) {
      // If Tor is broken surface a warning
      if (event == ConnectivityManagerEvent.torConnectedDoesntWork) {
        if (_torWarningDisplayedMoreThan5minAgo && Settings().usingTor) {
          _notifyAboutTor();
          _torWarningDisplayedMoreThan5minAgo = false;
          _resetTorWarningTimer();
        }
      }
      if (event == ConnectivityManagerEvent.foundationServerDown &&
          _serverDownWarningDisplayedMoreThan5minAgo) {
        _notifyAboutFoundationServerDown();
        _serverDownWarningDisplayedMoreThan5minAgo = false;
        _resetServerDownWarningTimer();
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
      if (success) {
        EnvoyToast(
          backgroundColor: Colors.lightBlue,
          replaceExisting: true,
          duration: const Duration(seconds: 4),
          message: S().manual_toggle_on_seed_backup_in_progress_toast_heading,
          icon: const Icon(
            Icons.info_outline,
            color: EnvoyColors.accentPrimary,
          ),
        ).show(context);
      } else {
        EnvoyToast(
          backgroundColor: Colors.lightBlue,
          replaceExisting: true,
          duration: const Duration(seconds: 3),
          message: S().manualToggleOnSeed_toastHeading_failedText,
          icon: const Icon(
            Icons.error_outline_rounded,
            color: EnvoyColors.accentSecondary,
          ),
        ).show(context);
      }
    });
  }

  _notifyAboutTor() {
    EnvoyToast(
      backgroundColor: Colors.lightBlue,
      replaceExisting: true,
      message: S().tor_connectivity_toast_warning,
      icon: const EnvoyIcon(
        EnvoyIcons.info,
        color: EnvoyColors.accentPrimary,
      ),
      actionButtonText: S().component_learnMore,
      onActionTap: () {
        EnvoyToast.dismissPreviousToasts(context);
        showEnvoyDialog(dialog: const TorWarning(), context: context);
      },
    ).show(context);
  }

  _notifyAboutFoundationServerDown() {
    EnvoyToast(
      backgroundColor: Colors.lightBlue,
      replaceExisting: true,
      message: S().toast_foundationServersDown,
      icon: const EnvoyIcon(
        EnvoyIcons.info,
        color: EnvoyColors.accentPrimary,
      ),
      actionButtonText: S().component_retry,
      onActionTap: () {
        EnvoyToast.dismissPreviousToasts(context);
        Settings().switchToNextServer();
      },
    ).show(context);
  }

  /// Handle the back button press behavior
  /// true means the back button press is handled and shouldn't be propagated
  Future<bool> _handleHomePageBackPress() async {
    HomePageBackgroundState hpState = ref.read(homePageBackgroundProvider);
    bool optionsVisible = ref.read(homePageOptionsVisibilityProvider);
    if (optionsVisible) {
      return true;
    }
    if (hpState == HomePageBackgroundState.hidden) {
      if (widget.mainNavigationShell.currentIndex != 2) {
        /// navigate to accounts home and consume backpress event
        widget.mainNavigationShell.goBranch(2);
        return true;
      }

      ///if menu is hidden don't do anything, let the back button press propagate
      return false;
    } else {
      ///if sub-menu is shown, go back to main menu otherwise hide menu
      if (hpState != HomePageBackgroundState.menu) {
        ref.read(homePageBackgroundProvider.notifier).state =
            HomePageBackgroundState.menu;
      } else {
        ref.read(homePageBackgroundProvider.notifier).state =
            HomePageBackgroundState.hidden;
      }
      return true;
    }
  }

  _notifyAboutHighBalance() {
    AccountManager().isAccountBalanceHigherThanUsd1000Stream.close();
    showSecurityDialog(context);
  }

  @override
  void dispose() {
    _torWarningTimer?.cancel();
    _serverDownWarningTimer?.cancel();
    backButtonDispatcher.removeCallback(_handleHomePageBackPress);
    super.dispose();
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
    bool optionsShown = ref.watch(homePageOptionsVisibilityProvider);

    double screenHeight = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    double screenWidth = MediaQuery.of(context).size.width;

    double topOffset = MediaQuery.of(context).padding.top;
    double bottomOffset = MediaQuery.of(context).padding.bottom;
    //double _totalOffset = _topOffset + _bottomOffset;

    double appBarHeight = AppBar().preferredSize.height;
    double topAppBarOffset = appBarHeight + 10;
    double shieldTop = topOffset + topAppBarOffset;
    double shieldTopOptionsShown =
        shieldTop + _optionsHeight; // TODO: This needs to be programmatic

    double bottomTabBarShieldOffset = 15;
    double shieldHeight = screenHeight -
        _bottomTabBarHeight -
        bottomOffset -
        shieldTop -
        bottomTabBarShieldOffset;

    double shieldHeightModalShown = screenHeight * 0.85 - bottomOffset;
    double shieldHeightOptionsShown = screenHeight * 0.76 - bottomOffset;

    // ignore: unused_local_variable
    double shieldGlowOffset = 30;

    bool modalShown = ref.watch(_fullScreenProvider);
    bool fullScreen = ref.watch(fullscreenHomePageProvider);

    HomePageBackgroundState homepageBackDropState =
        ref.watch(homePageBackgroundProvider);

    _backgroundShown = homepageBackDropState != HomePageBackgroundState.hidden;
    Widget background = ref.watch(backdropWidgetProvider);

    HomeShellOptions? homeShellOptions = ref.watch(homeShellOptionsProvider);

    Widget? optionsWidget = homeShellOptions?.optionsWidget;

    Widget options = Container(
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
        ? screenHeight + 20
        : optionsShown
            ? shieldTopOptionsShown
            : shieldTop;

    double shieldTotalHeight = modalShown
        ? shieldHeightModalShown
        : optionsShown
            ? shieldHeightOptionsShown
            : shieldHeight;

    if (fullScreen) {
      shieldTotalTop = AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight;
      shieldTotalHeight = MediaQuery.of(context).size.height * 0.88;
    }

    Widget mainWidget = Material(
      type: MaterialType.transparency,
      child: Shield(child: widget.mainNavigationShell),
    );
    return Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight),
            child: IgnorePointer(
              ignoring: fullScreen,
              child: AnimatedOpacity(
                  opacity: fullScreen ? 0.0 : 1.0,
                  duration: _animationsDuration,
                  child: const HomeAppBar(backGroundShown: false)),
            )),
        body: // Something behind
            Stack(
          children: [
            // Main background
            AnimatedPositioned(
                top: 0,
                height: _backgroundShown ? screenHeight + 1500 : screenHeight,
                left: 0,
                right: 0,
                curve: Curves.easeIn,
                duration: Duration(
                    milliseconds: _animationsDuration.inMilliseconds - 50),
                child: const AppBackground()),
            // Variable background
            SafeArea(
              child: AnimatedSwitcher(
                  duration: _animationsDuration,
                  child: Container(
                    child: _backgroundShown ? background : Container(),
                  )),
            ),
            // Tab bar
            AnimatedSlide(
                duration:
                    Duration(milliseconds: _animationsDuration.inMilliseconds),
                offset: Offset(
                    0,
                    _backgroundShown ||
                            (modalShown || optionsShown || fullScreen)
                        ? 0.5
                        : 0.0),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: IgnorePointer(
                    ignoring: _backgroundShown || modalShown || fullScreen,
                    child: EnvoyBottomNavigation(
                      onIndexChanged: (selectedIndex) {
                        widget.mainNavigationShell.goBranch(selectedIndex);
                      },
                    ),
                  ),
                )),
            Positioned(
                top: shieldTop - 20,
                left: 0,
                right: 0,
                child: IgnorePointer(
                    ignoring: !optionsShown,
                    child: AnimatedOpacity(
                        opacity: optionsShown ? 1.0 : 0.0,
                        duration: _animationsDuration,
                        child: AnimatedSwitcher(
                            duration: _animationsDuration, child: options)))),
            // Shield
            AnimatedPositioned(
              duration: _animationsDuration,
              top: shieldTotalTop,
              height: shieldTotalHeight,
              left: 5,
              right: 5,
              child: AnimatedOpacity(
                opacity: _backgroundShown ? 0.1 : 1.0,
                duration: _backgroundShown
                    ? Duration(
                        milliseconds: _animationsDuration.inMilliseconds ~/ 4)
                    : _animationsDuration,
                curve: _backgroundShown
                    ? Curves.linear
                    : ShieldFadeInAnimationCurve(),
                child: Stack(
                  children: [
                    Hero(
                        tag: "shield",
                        child: Shield(
                            child: Container(
                          color: Colors.transparent,
                        ))),
                    mainWidget,
                  ],
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
                        icon: const Icon(
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
