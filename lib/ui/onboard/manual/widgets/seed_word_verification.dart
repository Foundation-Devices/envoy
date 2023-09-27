// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/manual/widgets/wordlist.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';

class VerifySeedPuzzleWidget extends StatefulWidget {
  final List<String> seed;
  final Function(bool verified) onVerificationFinished;

  const VerifySeedPuzzleWidget(
      {Key? key, required this.seed, required this.onVerificationFinished})
      : super(key: key);

  @override
  State<VerifySeedPuzzleWidget> createState() => _VerifySeedPuzzleWidgetState();
}

class _VerifySeedPuzzleWidgetState extends State<VerifySeedPuzzleWidget>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();
  List<List<String>> _puzzleOptions = [];
  List<String> answers = [];
  bool _finishedAnswers = false;

  int _puzzlePageIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Text(
                      S().manual_setup_generate_seed_verify_seed_quiz_1_4_heading,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center),
                ),
                SliverPadding(padding: EdgeInsets.all(8)),
                SliverToBoxAdapter(
                  child: Text(
                      "What’s your seed word number ${widget.seed.indexOf(answers[_puzzlePageIndex]) + 1}?",
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center),
                ),
                SliverPadding(padding: EdgeInsets.all(12)),
                SliverFillRemaining(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: PageView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _pageController,
                          children: _puzzleOptions.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: PuzzleWidget(
                                puzzle: e,
                                seedIndex: widget.seed.indexOf(
                                    answers[_puzzleOptions.indexOf(e)]),
                                answer: answers[_puzzleOptions.indexOf(e)],
                                onAnswered: (answer) async {
                                  if (answer ==
                                      answers[_puzzleOptions.indexOf(e)]) {
                                    if (answers.last == answer) {
                                      setState(() {
                                        _finishedAnswers = true;
                                      });
                                      return;
                                    }
                                    await Future.delayed(
                                        Duration(milliseconds: 600));
                                    _pageController.animateToPage(
                                        _puzzleOptions.indexOf(e) + 1,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.ease);
                                  } else {
                                    widget.onVerificationFinished(false);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: DotsIndicator(
                              pageController: _pageController,
                              totalPages: _puzzleOptions.length)),
                      Padding(padding: EdgeInsets.all(6)),
                      !_finishedAnswers
                          ? Text("Choose a word to continue ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w400))
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 0),
                              child: OnboardingButton(
                                  label: "Continue",
                                  onTap: () {
                                    widget.onVerificationFinished(true);
                                  })),
                      Padding(padding: EdgeInsets.all(6)),
                    ],
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createPuzzles();
      _pageController.addListener(() {
        int page = _pageController.page?.toInt() ?? 0;
        if (_puzzlePageIndex != page)
          setState(() {
            _puzzlePageIndex = page;
          });
      });
    });
  }

  createPuzzles() {
    Random random = Random();
    List<String> filteredSeed =
        seed_en.where((element) => !widget.seed.contains(element)).toList();
    setState(() {
      Set<int> _randomIndexes = Set();
      while (_randomIndexes.length < 4) {
        _randomIndexes.add(random.nextInt(12));
      }
      List<int> _seedIndexes = _randomIndexes.toList();
      _puzzleOptions = List.generate(4, (index) {
        List<String> options = List.generate(3,
            (index) => filteredSeed[random.nextInt(filteredSeed.length - 1)]);
        options.add(widget.seed[_seedIndexes[index]]);
        answers.add(widget.seed[_seedIndexes[index]]);
        options.shuffle();
        return options;
      });
    });
  }
}

class PuzzleWidget extends StatefulWidget {
  final List<String> puzzle;
  final Function(String) onAnswered;
  final String answer;
  final int seedIndex;

  const PuzzleWidget(
      {Key? key,
      required this.puzzle,
      required this.onAnswered,
      required this.answer,
      required this.seedIndex})
      : super(key: key);

  @override
  State<PuzzleWidget> createState() => _PuzzleWidgetState();
}

class _PuzzleWidgetState extends State<PuzzleWidget> {
  String? chosenAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _answerField(context),
                if (chosenAnswer != null)
                  _buildAnswerStatus(chosenAnswer == widget.answer),
              ],
            ),
          ),
          Container(
            height: 200,
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  crossAxisSpacing: 20.0,
                ),
                itemBuilder: (context, index) {
                  final TextStyle textTheme = TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold);
                  return GestureDetector(
                    onTap: () {
                      widget.onAnswered(widget.puzzle[index]);
                      setState(() {
                        chosenAnswer = widget.puzzle[index];
                      });
                      if (chosenAnswer == widget.answer) {
                        Haptics.lightImpact();
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 80,
                          margin: EdgeInsets.symmetric(vertical: 0),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          alignment: Alignment.center,
                          constraints:
                              BoxConstraints(maxWidth: 200, maxHeight: 40),
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8)),
                          child: Text("${widget.puzzle[index]}",
                              style: textTheme, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: widget.puzzle.length),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerStatus(bool? correctSelection) {
    if (correctSelection == null) {
      return SizedBox.shrink();
    }
    return correctSelection
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check,
                size: 14,
                color: EnvoyColors.teal,
              ),
              Padding(padding: EdgeInsets.all(4)),
              Text(
                S().manual_setup_generate_seed_verify_seed_quiz_success_correct,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: EnvoyColors.teal),
              )
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(EnvoyIcons.exclamation_warning,
                  color: EnvoyColors.brown, size: 14),
              Padding(padding: EdgeInsets.all(4)),
              Text(
                S().manual_setup_generate_seed_verify_seed_quiz_fail_invalid,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: EnvoyColors.darkCopper),
              )
            ],
          );
  }

  Widget _answerField(BuildContext context) {
    Color textColor = Colors.black;
    Color borderColor = Colors.transparent;
    if (chosenAnswer == null) {
      borderColor = Colors.transparent;
    } else {
      if (chosenAnswer != widget.answer) {
        borderColor = EnvoyColors.brown;
      } else {
        borderColor = EnvoyColors.teal;
      }
    }

    final TextStyle textTheme = TextStyle(color: textColor, fontSize: 16);
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints(maxWidth: 140, maxHeight: 38),
      decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(" ${widget.seedIndex + 1}. ", style: textTheme),
          Expanded(
            child: Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text("${chosenAnswer ?? ""}", style: textTheme),
                  Container(
                    margin: EdgeInsets.only(top: 14),
                    child: Divider(
                      thickness: 1,
                      color: chosenAnswer == null
                          ? Colors.black54
                          : Colors.transparent,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
