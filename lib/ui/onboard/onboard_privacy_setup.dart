// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/node_url.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/onboard/magic/magic_recover_wallet.dart';
import 'package:envoy/ui/onboard/onboard_welcome_passport.dart';
import 'package:envoy/ui/onboard/onboard_welcome_envoy.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/state/onboarding_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart' as Rive;
import 'package:tor/tor.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class OnboardPrivacySetup extends ConsumerStatefulWidget {
  final bool setUpEnvoyWallet;

  const OnboardPrivacySetup({Key? key, required this.setUpEnvoyWallet})
      : super(key: key);

  @override
  ConsumerState<OnboardPrivacySetup> createState() =>
      _OnboardPrivacySetupState();
}

class _OnboardPrivacySetupState extends ConsumerState<OnboardPrivacySetup> {
  @override
  Widget build(BuildContext context) {
    TextStyle? _messageStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontSize: 11, fontWeight: FontWeight.w500);
    return EnvoyPatternScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              NodeConnectionState nodeConnectionState =
                  ref.watch(nodeConnectionStateProvider);
              return TextButton.icon(
                onPressed: () {
                  showEnvoyDialog(
                      context: context,
                      cardColor: Colors.transparent,
                      dialog: NodeSetupDialog(),
                      alignment: Alignment.topCenter);
                },
                label: Text(
                    nodeConnectionState.isConnected
                        ? S().privacy_setting_clearnet_node_edit_note
                        : S().privacy_setting_add_node_modal_heading,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white)),
                icon: SvgPicture.asset("assets/icons/ic_node_icon.svg",
                    color: Colors.white, height: 20, width: 20),
              );
            },
          )
        ],
      ),
      header: PrivacyShieldAnimated(),
      shield: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1),
                      child: Consumer(
                        builder: (context, ref, child) {
                          NodeConnectionState nodeConnectionState =
                              ref.watch(nodeConnectionStateProvider);
                          bool usingTor =
                              !ref.watch(privacyOnboardSelectionProvider);
                          String heading =
                              S().privacy_setting_perfomance_heading;
                          String subheading =
                              S().privacy_setting_perfomance_subheading;
                          if (nodeConnectionState.isConnected && usingTor) {
                            heading = S().privacySetting_nodeConnected;
                            subheading =
                                S().privacy_setting_onion_node_sbheading;
                          }
                          if (nodeConnectionState.isConnected && !usingTor) {
                            heading = S().privacySetting_nodeConnected;
                            subheading =
                                S().privacy_setting_clearnet_node_subheading;
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(EnvoySpacing.small)),
                              Text(
                                heading,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Padding(
                                  padding: EdgeInsets.all(EnvoySpacing.small)),
                              Container(
                                width: 250,
                                child: Text(
                                  subheading,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      child: Container(
                          child: PrivacyOptionSelect(),
                          padding: EdgeInsets.symmetric(
                              vertical: EnvoySpacing.small)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.xs,
                          horizontal: EnvoySpacing.medium3),
                      child: Consumer(
                        builder: (context, ref, child) {
                          bool _betterPerformance =
                              ref.watch(privacyOnboardSelectionProvider);
                          return _betterPerformance
                              ? LinkText(
                                  text:
                                      S().privacy_privacyMode_torSuggestionOff,
                                  linkStyle: _messageStyle?.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          EnvoyColors.listAccountTileColors[0]))
                              : LinkText(
                                  text: S().privacy_privacyMode_torSuggestionOn,
                                  linkStyle: _messageStyle?.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: EnvoyColors
                                          .listAccountTileColors[1]));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: EnvoySpacing.medium1,
                right: EnvoySpacing.medium1,
                top: EnvoySpacing.xs),
            child: EnvoyButton(
              S().component_continue,
              onTap: () async {
                //tor is necessary if user selects onion node
                bool torRequire = ref.read(isNodeRequiredTorProvider);
                //tor is not required if user selects better performance
                bool betterPerformance =
                    ref.read(privacyOnboardSelectionProvider);
                //based on both conditions, set tor enabled or disabled. before entering to the main screen
                Settings().setTorEnabled(torRequire || !betterPerformance);
                LocalStorage().prefs.setBool(PREFS_ONBOARDED, true);
                if (!widget.setUpEnvoyWallet) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardPassportWelcomeScreen(),
                      ));
                } else {
                  //if there is magic recovery seed, go to recover wallet screen else go to welcome screen
                  try {
                    if (await EnvoySeed().get() != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MagicRecoverWallet()));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnboardEnvoyWelcomeScreen(),
                          ));
                    }
                  } catch (e) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardEnvoyWelcomeScreen(),
                        ));
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

class NodeSetupDialog extends ConsumerStatefulWidget {
  const NodeSetupDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<NodeSetupDialog> createState() => _NodeSetupDialogState();
}

class _NodeSetupDialogState extends ConsumerState<NodeSetupDialog> {
  final TextEditingController _nodeTextEditingController =
      TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nodeTextEditingController.text = Settings().selectedElectrumAddress;
  }

  @override
  Widget build(BuildContext context) {
    NodeConnectionState nodeConnectionState =
        ref.watch(nodeConnectionStateProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(12)),
          Container(
            height: 320,
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close)),
                    ),
                    Text(
                      S().privacy_setting_add_node_modal_heading,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: nodeConnectionState.error == null
                              ? Border.all(color: Colors.transparent)
                              : Border.all(color: EnvoyColors.danger, width: 1),
                          color: Color(0xd231f20),
                        ),
                        child: Opacity(
                          opacity: nodeConnectionState.isConnecting ? 0.4 : 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _nodeTextEditingController,
                                  readOnly: nodeConnectionState.isConnecting,
                                  onChanged: (value) {
                                    ref
                                        .read(nodeConnectionStateProvider
                                            .notifier)
                                        .reset();
                                  },
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  onTap: () {
                                    if (_nodeTextEditingController.text ==
                                            Settings.DEFAULT_ELECTRUM_SERVER ||
                                        _nodeTextEditingController.text ==
                                            Settings.TESTNET_ELECTRUM_SERVER) {
                                      _nodeTextEditingController.text = "";
                                    }
                                  },
                                  decoration: InputDecoration(
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      hintText: S().privacy_node_nodeAddress,
                                      hintStyle: TextStyle(height: 1.3)),
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: GestureDetector(
                                        onTap: () {
                                          Clipboard.getData("text/plain")
                                              .then((value) {
                                            if (value != null) {
                                              _nodeTextEditingController.text =
                                                  value.text!;
                                            }
                                          });
                                        },
                                        child: Icon(
                                          Icons.paste,
                                          color: EnvoyColors.teal,
                                        ),
                                      )),
                                  GestureDetector(
                                    child: Icon(Icons.qr_code,
                                        color: EnvoyColors.teal),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return ScannerPage.nodeUrl((result) {
                                          var parsedUrl = parseNodeUrl(result);
                                          _nodeTextEditingController.text =
                                              parsedUrl;
                                          connect();
                                        });
                                      }));
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 28,
                      child: Builder(
                        builder: (context) {
                          if (nodeConnectionState.isConnecting) {
                            String text = S()
                                .privacy_setting_connecting_node_modal_loading;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: EdgeInsets.only(right: 8),
                                  child: CircularProgressIndicator(
                                    color: EnvoyColors.teal,
                                    backgroundColor: Colors.grey[200],
                                    strokeWidth: 2,
                                  ),
                                ),
                                Text(text)
                              ],
                            );
                          }
                          if (nodeConnectionState.isConnected &&
                              nodeConnectionState.electrumServerFeatures !=
                                  null) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: Icon(
                                      Icons.check_outlined,
                                      color: EnvoyColors.teal,
                                      size: 16,
                                    )),
                                Padding(padding: EdgeInsets.all(4)),
                                Text(
                                    "Connected to ${nodeConnectionState.electrumServerFeatures?.serverVersion}"), // TODO: FIGMA
                              ],
                            );
                          }
                          if (nodeConnectionState.isConnected == false &&
                              nodeConnectionState.error != null) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  EnvoyIcons.exclamation_warning,
                                  size: 18,
                                  color: EnvoyColors.danger,
                                ),
                                Padding(padding: EdgeInsets.all(4)),
                                Text(
                                  S().privacy_setting_connecting_node_fails_modal_failed,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: EnvoyColors.danger),
                                )
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: EnvoyButton(
                        nodeConnectionState.error != null
                            ? S().component_retry
                            : nodeConnectionState.isConnected
                                ? S().privacy_setting_add_node_modal_heading
                                : S().privacy_setting_connecting_node_modal_cta,
                        readOnly: nodeConnectionState.isConnecting,
                        type: EnvoyButtonTypes.primaryModal,
                        onTap: () {
                          if (!nodeConnectionState.isConnected) {
                            connect();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void connect() {
    FocusScope.of(context).unfocus();
    String address = parseNodeUrl(_nodeTextEditingController.text);
    bool torRequired = !ref.read(privacyOnboardSelectionProvider);
    //require tor if onion address is entered
    if (address.contains(".onion")) {
      ref.read(privacyOnboardSelectionProvider.notifier).state = false;
      ref.read(isNodeRequiredTorProvider.notifier).state = true;
      torRequired = true;
    }
    var nodeConnection = ref.read(nodeConnectionStateProvider.notifier);
    nodeConnection.validateServer(address, torRequired);
  }
}

class PrivacyOptionSelect extends ConsumerStatefulWidget {
  const PrivacyOptionSelect({Key? key}) : super(key: key);

  @override
  ConsumerState<PrivacyOptionSelect> createState() =>
      _PrivacyOptionSelectState();
}

class _PrivacyOptionSelectState extends ConsumerState<PrivacyOptionSelect> {
  Rive.StateMachineController? _improvedPerformanceController;
  Rive.StateMachineController? _privacyIconController;
  Rive.Artboard? _privacyIconArtBoard, _performanceArtBoard;

  @override
  void initState() {
    _loadRiveAnimations();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ref.read(nodeConnectionStateProvider).isConnected) {
        setState(() {
          _betterPerformance = !Tor.instance.enabled;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _improvedPerformanceController?.dispose();
    _privacyIconController?.dispose();
    super.dispose();
  }

  bool _betterPerformance = true;

  @override
  Widget build(BuildContext context) {
    //turns off the flag that enables tor. this wont affect tor process if it is already running
    ref.listen<bool>(privacyOnboardSelectionProvider, (previous, next) {
      if (mounted) {
        //Setting tor state
        Settings().usingTor = next;
        if (next) {
          Tor.instance.enable();
        }
        _privacyIconController?.findInput<bool>("toggle")?.change(!next);
        _improvedPerformanceController?.findInput<bool>("enable")?.change(next);
        if (_betterPerformance != next) {
          setState(() {
            _betterPerformance = next;
          });
        }
      }
    });

    NodeConnectionState nodeConnectionState =
        ref.watch(nodeConnectionStateProvider);
    bool isTorRequired = ref.watch(isNodeRequiredTorProvider);

    if (nodeConnectionState.isConnected) {
      Widget icon = _performanceArtBoard == null
          ? Container()
          : Rive.Rive(artboard: _performanceArtBoard!);
      String text = S().privacy_privacyMode_betterPerformance;

      if ((isTorRequired) || !_betterPerformance) {
        text = S().privacy_privacyMode_improvedPrivacy;
        icon = _privacyIconArtBoard == null
            ? Container()
            : Rive.Rive(
                artboard: _privacyIconArtBoard!,
              );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildToggleContainer(
              true,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    child: icon,
                  ),
                  Padding(padding: EdgeInsets.all(4)),
                  Container(
                    width: 80,
                    child: Text(
                      text,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 10.5),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  )
                ],
              ))
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            setState(() {
              _betterPerformance = true;
            });
            _privacyIconController?.findInput<bool>("toggle")?.change(false);
            _improvedPerformanceController
                ?.findInput<bool>("enable")
                ?.change(true);
            ref.read(privacyOnboardSelectionProvider.notifier).state = true;
          },
          child: _buildToggleContainer(
              _betterPerformance,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    child: _performanceArtBoard == null
                        ? Container()
                        : Rive.Rive(artboard: _performanceArtBoard!),
                  ),
                  Padding(padding: EdgeInsets.all(4)),
                  Text(
                    S().privacy_privacyMode_betterPerformance,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 10.5),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  )
                ],
              )),
        ),
        Padding(padding: EdgeInsets.all(8)),
        GestureDetector(
          onTap: () async {
            setState(() {
              _betterPerformance = false;
            });
            _privacyIconController?.findInput<bool>("toggle")?.change(true);
            _improvedPerformanceController
                ?.findInput<bool>("enable")
                ?.change(false);
            ref.read(privacyOnboardSelectionProvider.notifier).state = false;
          },
          child: _buildToggleContainer(
              !_betterPerformance,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    child: _privacyIconArtBoard == null
                        ? Container()
                        : Rive.Rive(
                            artboard: _privacyIconArtBoard!,
                          ),
                  ),
                  Padding(padding: EdgeInsets.all(2)),
                  Container(
                    width: 80,
                    child: Text(
                      S().privacy_privacyMode_improvedPrivacy,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 10.5),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildToggleContainer(bool active, Widget child) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 340),
      opacity: active ? 1 : 0.6,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 340),
        constraints: BoxConstraints.tightFor(width: 100, height: 100),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)))
                .borderRadius,
            border: Border.all(
                color: active ? EnvoyColors.teal : Colors.transparent,
                width: 3),
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffFFFFFF), Color(0xffD9D9D9)])
                : null),
        child: child,
      ),
    );
  }

  //load rive animations from assets and add them to the artboard
  void _loadRiveAnimations() async {
    try {
      ByteData privacyIcon =
          await rootBundle.load('assets/animated_privacy_icon.riv');
      final file = Rive.RiveFile.import(privacyIcon);
      _privacyIconController =
          Rive.StateMachineController.fromArtboard(file.mainArtboard, 'sm');
      if (_privacyIconController != null) {
        file.mainArtboard.addController(_privacyIconController!);
      }
      setState(() => _privacyIconArtBoard = file.mainArtboard);

      ByteData performanceIcon =
          await rootBundle.load('assets/animated_odometer.riv');
      final performanceIconFile = Rive.RiveFile.import(performanceIcon);
      _improvedPerformanceController = Rive.StateMachineController.fromArtboard(
          performanceIconFile.mainArtboard, 'sm');
      if (_improvedPerformanceController != null) {
        performanceIconFile.mainArtboard
            .addController(_improvedPerformanceController!);
      }
      setState(() => _performanceArtBoard = performanceIconFile.mainArtboard);

      _privacyIconController?.findInput<bool>("toggle")?.change(false);
      _improvedPerformanceController?.findInput<bool>("enable")?.change(true);
      if (!_betterPerformance &&
          ref.read(nodeConnectionStateProvider).isConnected) {
        Future.delayed(Duration(milliseconds: 100)).then((value) {
          _privacyIconController?.findInput<bool>("toggle")?.change(true);
        });
      }
    } catch (e) {
      print(e);
    }
  }
}

class PrivacyShieldAnimated extends StatefulWidget {
  const PrivacyShieldAnimated({Key? key}) : super(key: key);

  @override
  State<PrivacyShieldAnimated> createState() => _PrivacyShieldAnimatedState();
}

class _PrivacyShieldAnimatedState extends State<PrivacyShieldAnimated>
    with SingleTickerProviderStateMixin {
  late Animation<Offset> animation;
  AnimationController? controller;

  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    animation = Tween(
      begin: Offset(0.0, .02),
      end: Offset(0.01, 0),
    ).animate(CurvedAnimation(
      parent: controller!,
      curve: Curves.easeInOut,
    ));
    controller?.addListener(() {
      setState(() {});
    });
    controller?.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          alignment: Alignment.center,
          child: Image.asset(
            "assets/onboarding_shield.png",
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.4,
          ),
        ),
      ),
    );
  }
}
