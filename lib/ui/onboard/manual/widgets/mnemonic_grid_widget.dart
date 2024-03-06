// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/manual/widgets/wordlist.dart';
import 'package:flutter/material.dart';

enum SeedLength {
  MNEMONIC_12,
  MNEMONIC_24,
}

/// A grid of text fields for entering mnemonic seed phrases.
class MnemonicEntryGrid extends StatefulWidget {
  final SeedLength seedLength;
  final List<String>? seedInput;
  final Function(List<String>) onSeedWordAdded;

  const MnemonicEntryGrid(
      {super.key,
      required this.seedLength,
      this.seedInput,
      required this.onSeedWordAdded});

  @override
  State<MnemonicEntryGrid> createState() => MnemonicEntryGridState();
}

class MnemonicEntryGridState extends State<MnemonicEntryGrid>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  final double _suggestionOverlayHeight = 50;
  OverlayEntry? _overlayEntry;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  List<String> _seedWords = [];
  Animation<double>? _animation;
  final PageController _pageController = PageController();
  int currentPage = 0;
  FocusNode? _currentFocusNode;
  bool _showNextPage = false;
  final ScrollController _scrollControllerPage1 = ScrollController();
  final ScrollController _scrollControllerPage2 = ScrollController();

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
          margin: const EdgeInsets.only(top: 8),
          child: DotsIndicator(
            totalPages: 2,
            pageController: _pageController,
          ),
        )
      ],
    );
  }

  showPage(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Widget _buildMnemonicView(int page, BuildContext context) {
    // Get the bottom padding of the keyboard
    double bottom = View.of(context).viewInsets.bottom;
    double pixRatio = MediaQuery.of(context).devicePixelRatio;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 11),
      child: CustomScrollView(
        controller: page == 1 ? _scrollControllerPage1 : _scrollControllerPage2,
        slivers: [
          SliverFillRemaining(
            child: Builder(
              builder: (context) {
                int pageIndexOffset = page == 1 ? 1 : 12;
                List<TextEditingController> seeds = page == 1
                    ? _controllers.sublist(0, 12)
                    : _controllers.sublist(12, 24);
                List<TextEditingController> section1 = seeds.sublist(0, 6);
                List<TextEditingController> section2 = seeds.sublist(6, 12);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                        child: _buildMnemonicColumn(section1, pageIndexOffset)),
                    Flexible(
                        child: _buildMnemonicColumn(section2, pageIndexOffset)),
                  ],
                );
              },
            ),
          ),
          SliverPadding(padding: EdgeInsets.all((pixRatio * bottom)))
        ],
      ),
    );
  }

  Widget _buildMnemonicColumn(
      List<TextEditingController> section, int pageIndexOffset) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: section.map((word) {
          int index = _controllers.indexOf(word);
          return FocusTraversalOrder(
            order: NumericFocusOrder((index).toDouble()),
            child: Container(
              height: 40,
              width: 140,
              margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: MnemonicInput(
                  controller: _controllers[index],
                  onWordDetected: (focusNode, controller, word) {
                    if (index != _focusNodes.length - 1) {
                      focusNode.nextFocus();
                    } else {
                      focusNode.unfocus();
                    }
                    _seedWords[index] = word;
                    if (_showNextPage) {
                      _pageController
                          .nextPage(
                              duration: const Duration(milliseconds: 300),
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
          );
        }).toList(),
      ),
    );
  }

  void _showOverlay(BuildContext context, int index) async {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    OverlayState? overlayState = Overlay.of(context);
    var value = "";
    var _suggestions = [];
    TextEditingController controller = _controllers[index];
    controller.addListener(() {
      overlayState.setState(() {
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
      double bottom = View.of(context).viewInsets.bottom;
      double pixRatio = MediaQuery.of(context).devicePixelRatio;
      return Positioned(
        bottom: bottom / pixRatio,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: _animation!,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: bottom == 0 ? 0 : 1,
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
                                        if (index != _focusNodes.length - 1) {
                                          if (_focusNodes.indexOf(
                                                  _currentFocusNode!) ==
                                              _focusNodes.length - 1) {
                                            _currentFocusNode?.unfocus();
                                          } else {
                                            _currentFocusNode?.nextFocus();
                                          }
                                        } else {
                                          _currentFocusNode?.unfocus();
                                        }
                                      }
                                      if (_showNextPage) {
                                        _pageController
                                            .nextPage(
                                                duration: const Duration(
                                                    milliseconds: 300),
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
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
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
        ),
      );
    });
    //Update overlay entry with animation controller changes
    _animationController!.addListener(() {
      overlayState.setState(() {});
    });
    // inserting overlay entry
    overlayState.insert(_overlayEntry!);
    _animationController!.forward();
  }

  /// handle focus change event and shows the overlay
  /// also scrolls the page to show the focused element
  void _initFocusManager() {
    FocusManager.instance.addListener(() {
      bool foundFocusElement = false;
      //traverse through all the focus nodes and find the current focus node
      //and show suggestions for that node
      for (int i = 0; i < _focusNodes.length; i++) {
        if (_focusNodes[i].hasFocus) {
          foundFocusElement = true;
          _currentFocusNode = _focusNodes[i];
          _showOverlay(context, i);
          if ((i >= 4 && i <= 6) || (i >= 10 && i <= 12)) {
            _scrollControllerPage1.animateTo(200,
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease);
          }
          if ((i >= 16 && i <= 18) || (i >= 22 && i <= 24)) {
            _scrollControllerPage2.animateTo(180,
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease);
          }
          if (i == 11 && widget.seedLength == SeedLength.MNEMONIC_24) {
            _showNextPage = true;
          }
          break;
        }
      }
      //if no focus element is found then hide the overlay
      if (!foundFocusElement &&
          _animationController != null &&
          _animationController!.isCompleted) {
        _animationController?.reverse(from: 0.6);
      }
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _animationController?.dispose();
    super.dispose();
  }
}

class DotsIndicator extends StatefulWidget {
  final PageController pageController;
  final int totalPages;

  const DotsIndicator(
      {super.key, required this.pageController, required this.totalPages});

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
      if (value != page && mounted) {
        setState(() {
          page = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i <= widget.totalPages - 1; i++) {
      widgets.add(_buildDot(i == page));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgets,
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      margin: const EdgeInsets.symmetric(horizontal: 2),
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
      {super.key,
      required this.controller,
      required this.onWordDetected,
      required this.focusNode,
      required this.index,
      this.readOnly = false,
      this.active = false,
      required this.onWordAdded});

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
        if (mounted) {
          setState(() {
            _hasFocus = widget.focusNode.hasFocus;
          });
        }
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(maxHeight: 40),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(width: 1, color: borderColor),
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Text("${widget.index + 1}. ", style: textTheme),
                Expanded(
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
                            //Check words that start with the entered value
                            //this will reduce unnecessary suggestions like "fat" for "fatigue"
                            List<String> matches = seed_en
                                .where((element) =>
                                    element.startsWith(value.toLowerCase()))
                                .toList();
                            //If there is only one match and it is the same as the entered value, then the word is suggested
                            if (matches.length == 1 &&
                                matches[0] == value &&
                                widget.focusNode.hasFocus) {
                              widget.onWordDetected(
                                  widget.focusNode, widget.controller, value);
                            }
                          },
                          cursorColor: Theme.of(context).primaryColor,
                          backgroundCursorColor: Colors.grey),
                      Container(
                        margin: const EdgeInsets.only(top: 14),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
