import 'package:envoy/business/account.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

AnimationController? _spendOverlayAnimationController;

OverlayEntry? overlayEntry = null;

showSpendRequirementOverlay(BuildContext context, Account account) async {
  print("OVERLAY Started ");
  if (overlayEntry != null) {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }
  await Future.delayed(Duration(milliseconds: 50));
  overlayEntry = OverlayEntry(builder: (context) {
    return SpendRequirementOverlay(account: account);
  });
  Overlay.of(context, rootOverlay: true).insert(overlayEntry!);
}

hideSpendRequirementOverlay({bool noAnimation = false}) {
  if (noAnimation) {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  } else {
    if (overlayEntry != null && _spendOverlayAnimationController != null) {
      _spendOverlayAnimationController
          ?.animateTo(0, duration: Duration(milliseconds: 250))
          .then((value) => Future.delayed(Duration(milliseconds: 250)))
          .then((value) {
        overlayEntry?.remove();
        overlayEntry?.dispose();
        overlayEntry = null;
      }).catchError((ero) {
        overlayEntry?.remove();
        overlayEntry?.dispose();
        overlayEntry = null;
      });
    }
  }
}

class SpendRequirementOverlay extends ConsumerStatefulWidget {
  final Account account;

  const SpendRequirementOverlay({super.key, required this.account});

  @override
  ConsumerState createState() => _SpendRequirementOverlayState();
}

class _SpendRequirementOverlayState
    extends ConsumerState<SpendRequirementOverlay>
    with SingleTickerProviderStateMixin {
  late Animation<Alignment> _appearAnimation;
  bool _isDragging = true;

  bool _dismissed = false;

  @override
  void initState() {
    if (_spendOverlayAnimationController != null) {
      _spendOverlayAnimationController?.dispose();
      _spendOverlayAnimationController = null;
    }
    _spendOverlayAnimationController = AnimationController(
      vsync: this,
      // duration: Duration(milliseconds: 250),
    );
    _appearAnimation = AlignmentTween(
      begin: Alignment(0.0, 1.6),
      end: Alignment(0.0, 0.82),
    ).animate(
      CurvedAnimation(
        parent: _spendOverlayAnimationController!,
        curve: Curves.easeInOut,
      ),
    );
    _spendOverlayAnimationController?.addListener(() {
      setState(() {
        _dragAlignment = _appearAnimation.value;
      });
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _spendOverlayAnimationController?.animateTo(1,
          duration: Duration(milliseconds: 250));
    });
  }

  // void _runAnimation(Offset pixelsPerSecond, Size size) {
  //   _appearAnimation = _spendOverlayAnimationController!.drive(
  //     AlignmentTween(
  //       begin: _dragAlignment,
  //       end: Alignment(0.0, 0.82),
  //     ),
  //   );
  //   // Calculate the velocity relative to the unit interval, [0,1],
  //   // used by the animation controller.
  //   final unitsPerSecondX = pixelsPerSecond.dx / size.width;
  //   final unitsPerSecondY = pixelsPerSecond.dy / size.height;
  //   final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
  //   final unitVelocity = unitsPerSecond.distance;
  //
  //   const spring = SpringDescription(
  //     mass: 100,
  //     stiffness: 1,
  //     damping: 1,
  //   );
  //
  //   final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);
  //
  //   _spendOverlayAnimationController!.animateWith(simulation);
  // }

  Alignment _dragAlignment = Alignment(0.0, 1.6);

  @override
  void dispose() {
    _spendOverlayAnimationController?.dispose();
    _spendOverlayAnimationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSelectedAmount =
        ref.watch(getTotalSelectedAmount(widget.account.id!));
    final requiredAmount = ref.watch(spendAmountProvider);

    // ref.listen(
    //   routePathProvider,
    //   (previous, next) async {
    //     if (next == ROUTE_ACCOUNT_SEND_CONFIRM || next == ROUTE_ACCOUNT_SEND) {
    //       _spendOverlayAnimationController?.duration = Duration(milliseconds: 250);
    //       _spendOverlayAnimationController?.reverse();
    //     } else {
    //       if (overlayEntry != null) {
    //         _spendOverlayAnimationController?.duration = Duration(milliseconds: 250);
    //         _spendOverlayAnimationController?.forward();
    //       }
    //     }
    //   },
    // );
    ref.listen(
      showSpendRequirementOverlayProvider,
      (previous, next) {
        if (!next) {
          // hideSpendRequirementOverlay();
        }
      },
    );

    bool hideRequiredAmount = requiredAmount == 0;

    return GestureDetector(
      onPanDown: (details) {
        _spendOverlayAnimationController!.stop();
      },
      // TODO: implement dismiss
      // onPanUpdate: (details) {
      //   setState(() {
      //     _dragAlignment += Alignment(
      //       details.delta.dx / (size.width / 2),
      //       details.delta.dy / (size.height / 2),
      //     );
      //   });
      //   if (details.globalPosition.dy / (size.height / 2) > 1.85) {
      //     if (_isDragging) {
      //       Haptics.buttonPress();
      //       _dismissed = true;
      //     }
      //     _isDragging = false;
      //   }
      // },
      // onPanEnd: (details) {
      //   _isDragging = true;
      //   _runAnimation(details.velocity.pixelsPerSecond, size);
      // },
      child: Align(
        alignment: _dragAlignment,
        child: SizedBox(
            height: hideRequiredAmount ? 90 : 110,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    /// TODO: use component radius
                    bottom: Radius.circular(16),
                    top: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(EnvoySpacing.xs),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          !hideRequiredAmount
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: EnvoySpacing.xs),
                                  child: Row(
                                    children: [
                                      Text(S()
                                          .coincontrol_edit_transaction_required_inputs),
                                      Spacer(),
                                      SizedBox.square(
                                          dimension: 12,
                                          child: SvgPicture.asset(
                                            Settings().displayUnit ==
                                                    DisplayUnit.btc
                                                ? "assets/icons/ic_bitcoin_straight.svg"
                                                : "assets/icons/ic_sats.svg",
                                            color: Color(0xff808080),
                                          )),
                                      Text(
                                        "${getFormattedAmount(requiredAmount, trailingZeroes: true)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.xs),
                            child: Row(
                              children: [
                                Text(
                                  ///TODO: localize
                                  "Selected amount",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Spacer(),
                                SizedBox.square(
                                    dimension: 12,
                                    child: SvgPicture.asset(
                                      Settings().displayUnit == DisplayUnit.btc
                                          ? "assets/icons/ic_bitcoin_straight.svg"
                                          : "assets/icons/ic_sats.svg",
                                      color: Color(0xff808080),
                                    )),
                                Text(
                                  "${getFormattedAmount(totalSelectedAmount, trailingZeroes: true)}",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      EnvoyButton(
                        S().coincontrol_edit_transaction_cta,
                        onTap: () async {
                          /// if the user is in utxo details screen we need to wait animations to finish
                          /// before we can pop back to home screen
                          if (Navigator.canPop(context)) {
                            popBackToHome(context);
                            await Future.delayed(Duration(milliseconds: 320));
                          }
                          hideSpendRequirementOverlay();
                          await Future.delayed(Duration(milliseconds: 120));
                          GoRouter.of(context).push(ROUTE_ACCOUNT_SEND);
                        },
                      )
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  void showDismissDialog(BuildContext context) {
    showAboutDialog(context: context, useRootNavigator: true);
  }
}
