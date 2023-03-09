// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/expert/widgets/wordlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

enum SeedLength {
  MNEMONIC_12,
  MNEMONIC_24,
}

class MnemonicEntryGrid extends StatefulWidget {
  final SeedLength seedLength;
  final List<String>? seedInput;
  final Function(List<String>) onSeedWordAdded;

  MnemonicEntryGrid(
      {Key? key,
      required this.seedLength,
      this.seedInput,
      required this.onSeedWordAdded})
      : super(key: key);

  @override
  State<MnemonicEntryGrid> createState() => _MnemonicEntryGridState();
}

class _MnemonicEntryGridState extends State<MnemonicEntryGrid>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  double _suggestionOverlayHeight = 50;
  OverlayEntry? _overlayEntry;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  List<String> _seedWords = [];
  Animation<double>? _animation;
  PageController _pageController = PageController();
  int currentPage = 0;
  FocusNode? _currentFocusNode;
  bool _showNextPage = false;
  ScrollController _scrollControllerPage1 = ScrollController();
  ScrollController _scrollControllerPage2 = ScrollController();

  @override
  void initState() {
    _seedWords = List.generate(
        widget.seedLength == SeedLength.MNEMONIC_12 ? 12 : 24, (index) => "");
    _initFocusManager();
    for (int i = 0;
        i < (widget.seedLength == SeedLength.MNEMONIC_12 ? 12 : 24);
        i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation =
        CurveTween(curve: Curves.fastOutSlowIn).animate(_animationController!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seedLength == SeedLength.MNEMONIC_12) {
      return _buildMnemonicView(1, context);
    }
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              _buildMnemonicView(1, context),
              _buildMnemonicView(2, context),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          child: DotsIndicator(
            totalPages: 2,
            pageController: _pageController,
          ),
        )
      ],
    );
  }

  Widget _buildMnemonicView(int page, BuildContext context) {
    // Get the bottom padding of the keyboard
    double bottom = WidgetsBinding.instance.window.viewInsets.bottom;
    double pixRatio = MediaQuery.of(context).devicePixelRatio;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 11),
      child: CustomScrollView(
        controller: page == 1 ? _scrollControllerPage1 : _scrollControllerPage2,
        slivers: [
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 2,
              crossAxisSpacing: 18.0,
              mainAxisSpacing: 0.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int listIndex) {
                int index = page == 1 ? listIndex : listIndex + 12;
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 140,
                      margin: EdgeInsets.only(top: 10),
                      child: MnemonicInput(
                          controller: _controllers[index],
                          onWordDetected: (focusNode, controller, word) {
                            focusNode.nextFocus();
                            _seedWords[index] = word;
                            if (_showNextPage) {
                              _pageController
                                  .nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeIn)
                                  .then((value) {
                                _currentFocusNode = _focusNodes[12];
                                _currentFocusNode?.requestFocus();
                              });
                              _showNextPage = false;
                            }
                          },
                          onWordAdded: (word) {
                            _seedWords[index] = word;
                            widget.onSeedWordAdded(_seedWords);
                          },
                          index: index,
                          focusNode: _focusNodes[index]),
                    ),
                  ],
                );
              },
              childCount: _controllers.length != 0 ? 12 : 0,
            ),
          ),
          SliverPadding(padding: EdgeInsets.all((pixRatio * bottom)))
        ],
      ),
    );
  }

  void _showOverlay(BuildContext context, int index) async {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    OverlayState? overlayState = Overlay.of(context);
    var value = "";
    var _suggestions = [];
    TextEditingController controller = _controllers[index];
    controller.addListener(() {
      overlayState?.setState(() {
        value = controller.text;
        if (value.length >= 3) {
          _suggestions =
              seed_en.where((element) => element.startsWith(value)).toList();
        } else {
          _suggestions = [];
        }
      });
    });
    _overlayEntry = OverlayEntry(builder: (context) {
      double bottom = WidgetsBinding.instance.window.viewInsets.bottom;
      double pixRatio = MediaQuery.of(context).devicePixelRatio;
      return Positioned(
        bottom: bottom / pixRatio,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: _animation!,
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: _suggestionOverlayHeight,
              child: LayoutBuilder(
                builder: (context, viewportConstraints) {
                  return ConstrainedBox(
                    constraints: viewportConstraints.copyWith(
                        minHeight: viewportConstraints.maxHeight,
                        maxHeight: viewportConstraints.maxHeight),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _suggestions
                            .map((e) => InkWell(
                                  onTap: () {
                                    int index = _suggestions.indexOf(e);
                                    controller.value = TextEditingValue(
                                      text: _suggestions[index],
                                    );
                                    if (_currentFocusNode?.hasFocus == true) {
                                      _currentFocusNode?.nextFocus();
                                    }
                                    if (_showNextPage) {
                                      _pageController
                                          .nextPage(
                                              duration:
                                                  Duration(milliseconds: 300),
                                              curve: Curves.easeIn)
                                          .then((value) {
                                        _currentFocusNode = _focusNodes[12];
                                        _currentFocusNode?.requestFocus();
                                      });
                                      _showNextPage = false;
                                    }
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(horizontal: 8),
                                    child: Chip(
                                      label: Text("$e"),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
    _animationController!.addListener(() {
      overlayState!.setState(() {});
    });
    // inserting overlay entry
    overlayState!.insert(_overlayEntry!);
    _animationController!.forward();
  }

  /// handle focus change event and shows the overlay
  /// also scrolls the page to show the focused element
  void _initFocusManager() {
    FocusManager.instance.addListener(() {
      bool foundFocusElement = false;
      for (int i = 0; i < _focusNodes.length; i++) {
        if (_focusNodes[i].hasFocus) {
          foundFocusElement = true;
          _currentFocusNode = _focusNodes[i];
          _showOverlay(context, i);
          if (i > 7 && i <= 11) {
            _scrollControllerPage1.animateTo(200,
                duration: Duration(milliseconds: 200), curve: Curves.ease);
          }
          if (i > 19) {
            _scrollControllerPage2.animateTo(180,
                duration: Duration(milliseconds: 200), curve: Curves.ease);
          }
          if (i == 11 && widget.seedLength == SeedLength.MNEMONIC_24) {
            _showNextPage = true;
          }
          break;
        }
      }
      if (!foundFocusElement &&
          _animationController != null &&
          _animationController!.isCompleted) {
        _animationController?.reverse(from: 0.6);
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}

class DotsIndicator extends StatefulWidget {
  final PageController pageController;
  final int totalPages;

  const DotsIndicator(
      {Key? key, required this.pageController, required this.totalPages})
      : super(key: key);

  @override
  State<DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<DotsIndicator> {
  int page = 0;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(() {
      int value = widget.pageController.page?.ceil() ?? 0;
      if (value != page && mounted)
        setState(() {
          page = value;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i <= widget.totalPages - 1; i++) {
      widgets.add(_buildDot(i == page));
    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      margin: EdgeInsets.symmetric(horizontal: 2),
      height: 8,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? EnvoyColors.darkTeal : EnvoyColors.grey),
    );
  }
}

class MnemonicInput extends StatefulWidget {
  final Function(
          FocusNode focusNode, TextEditingController controller, String word)
      onWordDetected;
  final Function(String word) onWordAdded;
  final bool readOnly;
  final bool active;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;

  const MnemonicInput(
      {Key? key,
      required this.controller,
      required this.onWordDetected,
      required this.focusNode,
      required this.index,
      this.readOnly = false,
      this.active = false,
      required this.onWordAdded})
      : super(key: key);

  @override
  State<MnemonicInput> createState() => _MnemonicInputState();
}

class _MnemonicInputState extends State<MnemonicInput> {
  bool _hasFocus = false;
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.focusNode.addListener(() {
        if (this.mounted)
          setState(() {
            _hasFocus = widget.focusNode.hasFocus;
          });
      });
      widget.controller.addListener(() {
        if (widget.controller.text.isEmpty) {
          widget.onWordAdded("");
        } else {
          if (seed_en.contains(widget.controller.text)) {
            widget.onWordAdded(widget.controller.text);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasContent = widget.controller.text.isNotEmpty;
    Color textColor =
        (_hasFocus) ? Theme.of(context).primaryColor : Colors.black;
    Color borderColor = Colors.transparent;

    if (hasContent) {
      borderColor = Colors.black87;
    }

    if (_hasFocus || widget.active) {
      borderColor = Theme.of(context).primaryColor;
    }

    if (hasContent && !seed_en.contains(widget.controller.text)) {
      borderColor = Colors.red;
      textColor = Colors.red;
    }
    final TextStyle textTheme = TextStyle(color: textColor, fontSize: 16);

    return LayoutBuilder(
      key: key,
      builder: (p0, p1) {
        return GestureDetector(
          onTap: () {
            if (!widget.readOnly) widget.focusNode.requestFocus();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            constraints: BoxConstraints(maxHeight: 40),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(width: 1, color: borderColor),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Text("${widget.index + 1}. ", style: textTheme),
                Expanded(
                  child: Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        EditableText(
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            enableIMEPersonalizedLearning: false,
                            style: textTheme,
                            textInputAction:
                                (widget.index == 11 || widget.index == 23)
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                            onChanged: (value) {
                              if (seed_en.contains(value) &&
                                  widget.focusNode.hasFocus) {
                                widget.onWordDetected(
                                    widget.focusNode, widget.controller, value);
                              }
                            },
                            cursorColor: Theme.of(context).primaryColor,
                            backgroundCursorColor: Colors.grey),
                        Container(
                          margin: EdgeInsets.only(top: 14),
                          child: Divider(
                            thickness: 1,
                            color: (_hasFocus || hasContent)
                                ? Colors.transparent
                                : Colors.black54,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
