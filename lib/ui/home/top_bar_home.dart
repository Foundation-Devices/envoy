// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/onboard/onboard_welcome_passport.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/ui/routes/home_router.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'package:envoy/util/envoy_storage.dart';

class HomeAppBar extends ConsumerStatefulWidget {
  final bool backGroundShown;

  const HomeAppBar({super.key, required this.backGroundShown});

  @override
  ConsumerState createState() => _HomeAppBarState();
}

const _animationsDuration = Duration(milliseconds: 350);

class _HomeAppBarState extends ConsumerState<HomeAppBar> {
  HamburgerState state = HamburgerState.idle;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10)).then((_) {
      if (context.mounted) {
        _setOptionWidgetsForTabWidgets(
            // ignore: use_build_context_synchronously
            GoRouter.of(context).routerDelegate.currentConfiguration.fullPath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    HomeShellOptions? homeShellState = ref.watch(homeShellOptionsProvider);
    bool modalShown = ref.watch(hideBottomNavProvider);
    bool optionsShown = ref.watch(homePageOptionsVisibilityProvider);
    bool buyBTCRightAction = ref.watch(buyBTCPageProvider);
    bool inEditMode =
        ref.watch(spendEditModeProvider) != SpendOverlayContext.hidden;

    Widget rightAction = homeShellState?.rightAction ??
        const SizedBox(
          height: 55,
          width: 55,
        );
    HomePageBackgroundState homePageDropState =
        ref.watch(homePageBackgroundProvider);
    String path = ref.watch(routePathProvider);
    bool backDropEnabled = homePageDropState != HomePageBackgroundState.hidden;

    String homePageTitle = ref.watch(homePageTitleProvider);
    ref.listen(
      routePathProvider,
      (previous, nextPath) {
        _setOptionWidgetsForTabWidgets(nextPath);
        if (homeTabRoutes.contains(nextPath)) {
          ref.read(homePageTitleProvider.notifier).state = "";
          ref.read(hideBottomNavProvider.notifier).state = false;
        }
        if (modalModeRoutes.contains(nextPath)) {
          ref.read(hideBottomNavProvider.notifier).state = true;
          if (nextPath == ROUTE_BUY_BITCOIN) {
            ref.read(buyBTCPageProvider.notifier).state = true;
          }
        } else {
          ref.read(hideBottomNavProvider.notifier).state = false;
        }
        if (hideAppBarRoutes.contains(nextPath)) {
          ref.read(fullscreenHomePageProvider.notifier).state = true;
        } else {
          ref.read(fullscreenHomePageProvider.notifier).state = false;
        }
        if (nextPath == ROUTE_ACCOUNTS_HOME) {
          ref.read(coinSelectionStateProvider.notifier).reset();
          ref.read(spendEditModeProvider.notifier).state =
              SpendOverlayContext.hidden;
          clearSpendState(ProviderScope.containerOf(context));
        }
      },
    );

    if (_showBackArrow(path)) {
      state = HamburgerState.back;
    } else {
      if (homePageDropState == HomePageBackgroundState.menu) {
        state = HamburgerState.upward;
      } else if (homePageDropState != HomePageBackgroundState.menu &&
          homePageDropState != HomePageBackgroundState.hidden) {
        state = HamburgerState.back;
      } else {
        state = HamburgerState.idle;
      }
    }

    String title = _getTitle(path, homePageTitle);

    return AppBar(
      // Get rid of the shadow
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: AnimatedOpacity(
        duration: _animationsDuration,
        opacity: (optionsShown || inEditMode) ? 0.0 : 1.0,
        child: HamburgerMenu(
          iconState: state,
          onPressed: () async {
            if (homePageDropState != HomePageBackgroundState.hidden) {
              if (homePageDropState != HomePageBackgroundState.menu) {
                ref.read(homePageBackgroundProvider.notifier).state =
                    HomePageBackgroundState.menu;
              } else {
                ref.read(homePageBackgroundProvider.notifier).state =
                    HomePageBackgroundState.hidden;
                ref.read(homePageTitleProvider.notifier).state = "";
              }
            } else {
              if (state == HamburgerState.idle) {
                ref.read(homePageBackgroundProvider.notifier).state =
                    HomePageBackgroundState.menu;
                ref.read(homePageTitleProvider.notifier).state =
                    S().menu_heading.toUpperCase();
              } else if (state == HamburgerState.back) {
                if (path == ROUTE_SELECT_REGION &&
                    await EnvoyStorage().getCountry() != null) {
                  if (context.mounted) {
                    context.go(ROUTE_BUY_BITCOIN);
                  }
                } else {
                  if (context.mounted) {
                    GoRouter.of(context).pop();
                  }
                }
              }
            }
          },
        ),
      ),
      centerTitle: true,
      title: Stack(fit: StackFit.loose, alignment: Alignment.center, children: [
        Center(
          child: AnimatedSwitcher(
              duration: _animationsDuration,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: FittedBox(
                key: ValueKey<String>(title),
                fit: BoxFit.fitWidth,
                child: Text(
                  title.toUpperCase(),
                ),
              )),
        ),
        const SizedBox(height: 50, child: IndicatorShield())
      ]),
      actions: [
        // Right action
        Opacity(
          opacity: (inEditMode || backDropEnabled) ? 0.0 : 1.0,
          child: AnimatedSwitcher(
              duration: _animationsDuration,
              child: AbsorbPointer(
                  absorbing:
                      (backDropEnabled || modalShown) && !buyBTCRightAction,
                  child: AnimatedOpacity(
                      opacity:
                          (backDropEnabled || modalShown) && !buyBTCRightAction
                              ? 0.0
                              : 1.0,
                      duration: _animationsDuration,
                      child: AnimatedSwitcher(
                          duration: _animationsDuration,
                          child: backDropEnabled || optionsShown
                              ? GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (optionsShown) {
                                      ref
                                          .read(
                                              homePageOptionsVisibilityProvider
                                                  .notifier)
                                          .state = false;
                                    } else {
                                      if (backDropEnabled) {
                                        ref
                                            .read(homePageBackdropModeProvider
                                                .notifier)
                                            .state = false;
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 55,
                                    width: 55,
                                    color: Colors.transparent,
                                    child: const Icon(
                                      Icons.close,
                                    ),
                                  ),
                                )
                              : rightAction)))),
        )
      ],
    );
  }

  ///Show back arrow if current route is part of nested routes (shell routes)
  bool _showBackArrow(String path) {
    final settings = ref.read(homePageBackgroundProvider);
    if (path.contains(ROUTE_ACCOUNT_DETAIL)) {
      return true;
    }
    if (path.contains(ROUTE_DEVICE_DETAIL)) {
      return true;
    }
    if (path.contains(ROUTE_LEARN_BLOG)) {
      return true;
    }
    if (path.contains(ROUTE_ACCOUNT_SEND)) {
      return true;
    }
    if (path.contains(ROUTE_SELECT_REGION)) {
      return true;
    }
    if (path.contains(ROUTE_BUY_BITCOIN)) {
      return true;
    }
    if (settings != HomePageBackgroundState.menu &&
        settings != HomePageBackgroundState.hidden) {
      return true;
    }
    return false;
  }

  String _getTitle(String path, String defaultTitle) {
    if (defaultTitle.isNotEmpty) return defaultTitle;
    switch (path) {
      case ROUTE_DEVICES:
        return S().bottomNav_devices;
      case ROUTE_PRIVACY:
        return S().bottomNav_privacy;
      case ROUTE_ACCOUNTS_HOME:
        return S().bottomNav_accounts;
      case ROUTE_ACTIVITY:
        return S().bottomNav_activity;
      case ROUTE_LEARN:
        return S().bottomNav_learn;
      case ROUTE_LEARN_BLOG:
        return S().bottomNav_learn;
      case ROUTE_ACCOUNT_SEND:
        return "send"; //TODO: Figma
      case ROUTE_ACCOUNT_DETAIL:
        return S().manage_account_address_heading;
      case ROUTE_BUY_BITCOIN:
        return S().header_buyBitcoin;
      case ROUTE_PEER_TO_PEER:
        return S().header_buyBitcoin;
      case ROUTE_SELECT_REGION:
        return S().header_buyBitcoin;
      case ROUTE_SELECT_ACCOUNT:
        return S().header_buyBitcoin;

      default:
        return S().menu_heading;
    }
  }

  void _setOptionWidgetsForTabWidgets(String nextPath) {
    final StateController<bool> optionsVisibility =
        ref.read(homePageOptionsVisibilityProvider.notifier);
    StateController<HomeShellOptions?> optionsState =
        ref.read(homeShellOptionsProvider.notifier);
    switch (nextPath) {
      case ROUTE_DEVICES:
        optionsState.state = HomeShellOptions(
          rightAction: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              optionsVisibility.state = !optionsVisibility.state;
            },
            child: Container(
              height: 55,
              width: 55,
              color: Colors.transparent,
              child: const Icon(
                Icons.add,
              ),
            ),
          ),
          optionsWidget: const DevicesOptions(),
        );
        break;
      case ROUTE_PRIVACY:
        optionsState.state = null;
        break;
      case ROUTE_ACCOUNTS_HOME:
        ref.read(homeShellOptionsProvider.notifier).state = HomeShellOptions(
          rightAction: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      if (EnvoySeed().walletDerived()) {
                        return const OnboardPassportWelcomeScreen();
                      } else {
                        return const WelcomeScreen();
                      }
                    },
                    reverseTransitionDuration: Duration.zero,
                    transitionDuration: Duration.zero,
                  ));
            },
            child: Container(
              height: 55,
              width: 55,
              color: Colors.transparent,
              child: const Icon(
                Icons.add,
              ),
            ),
          ),
          optionsWidget: Container(),
        );
        break;
      case ROUTE_ACCOUNT_RECEIVE:
        ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
        break;
      case ROUTE_ACCOUNT_SEND:
        ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
        break;
      case ROUTE_ACTIVITY:
        optionsState.state = null;
        break;
      case ROUTE_LEARN:
        optionsState.state = null;
        break;
      case ROUTE_LEARN_BLOG:
        optionsState.state = null;
        break;
      // default:
      //   optionsState.state = null;
      //   break;
    }
  }
}

enum HamburgerState {
  idle,
  upward,
  back,
}

//animated hamburger menu
class HamburgerMenu extends ConsumerStatefulWidget {
  final HamburgerState iconState;
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
    updateAnimationState(null);
  }

  @override
  void dispose() {
    _menuController?.dispose();
    super.dispose();
  }

  void updateAnimationState(HamburgerMenu? oldWidget) {
    if (oldWidget?.iconState == widget.iconState) return;
    switch (widget.iconState) {
      case HamburgerState.idle:
        _menuController?.findInput<double>("state_pos")?.change(0.0);
        break;
      case HamburgerState.upward:
        _menuController?.findInput<double>("state_pos")?.change(1);
        break;
      case HamburgerState.back:
        if (oldWidget == null) {
          _menuController?.findInput<double>("state_pos")?.change(0.0);
          break;
        } else if (oldWidget.iconState == HamburgerState.upward) {
          _menuController?.findInput<double>("state_pos")?.change(2);
        } else {
          _menuController?.findInput<double>("state_pos")?.change(-1);
        }
        break;
      default:
        _menuController?.findInput<double>("state_pos")?.change(0.0);
        break;
    }
  }

  @override
  void didUpdateWidget(covariant HamburgerMenu oldWidget) {
    updateAnimationState(oldWidget);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    /// 0 for idle
    /// 1 for upward icon
    /// -1 for back icon
    bool optionsShown = ref.watch(homePageOptionsVisibilityProvider);
    return optionsShown
        ? const SizedBox.square()
        : MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onPressed,
              child: Center(
                child: SizedBox.fromSize(
                  size: const Size.square(24),
                  child: _menuArtBoard != null
                      ? Rive(
                          artboard: _menuArtBoard!,
                          fit: BoxFit.contain,
                        )
                      : const SizedBox.square(),
                ),
              ),
            ),
          );
  }
}
