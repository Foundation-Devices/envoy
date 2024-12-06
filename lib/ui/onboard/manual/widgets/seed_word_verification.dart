// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/manual/widgets/wordlist.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';

class VerifySeedPuzzleWidget extends StatefulWidget {
  final List<String> seed;
  final Function(bool verified) onVerificationFinished;

  const VerifySeedPuzzleWidget(
      {super.key, required this.seed, required this.onVerificationFinished});

  @override
  State<VerifySeedPuzzleWidget> createState() => _VerifySeedPuzzleWidgetState();
}

class _VerifySeedPuzzleWidgetState extends State<VerifySeedPuzzleWidget>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  List<Puzzle> _puzzleOptions = [];
  bool _finishedAnswers = false;

  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < 360;
    if (_puzzleOptions.isEmpty) {
      return Container();
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Text(
              S().manual_setup_generate_seed_verify_seed_quiz_1_4_heading,
              style: EnvoyTypography.heading,
              textAlign: TextAlign.center),
        ),
        const SliverPadding(padding: EdgeInsets.all(EnvoySpacing.small)),
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Text(
                "${S().manual_setup_generate_seed_verify_seed_quiz_question} ${_puzzleOptions[_pageIndex].seedIndex + 1}?",
                key: ValueKey(
                  "${_puzzleOptions[_pageIndex].seedIndex}",
                ),
                style: EnvoyTypography.info
                    .copyWith(color: EnvoyColors.textTertiary),
                textAlign: TextAlign.center),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.all(EnvoySpacing.small)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: isSmallScreen ? 280 : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: PageView(
                    physics: const BouncingScrollPhysics(
                        parent: NeverScrollableScrollPhysics()),
                    controller: _pageController,
                    pageSnapping: true,
                    padEnds: true,
                    children: _puzzleOptions.mapIndexed((index, e) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: EnvoySpacing.medium1,
                            right: EnvoySpacing.medium2,
                            left: EnvoySpacing.medium2),
                        child: PuzzleWidget(
                          puzzle: e,
                          onCorrectAnswer: () async {
                            bool isLastQuestion =
                                (_puzzleOptions.indexOf(e) + 1) ==
                                    _puzzleOptions.length;
                            if (isLastQuestion) {
                              setState(() {
                                _finishedAnswers = true;
                              });
                              return;
                            }

                            await Future.delayed(
                                const Duration(milliseconds: 600));
                            setState(() {
                              _pageIndex++;
                            });
                            await _pageController.animateToPage(
                                _puzzleOptions.indexOf(e) + 1,
                                duration: const Duration(milliseconds: 320),
                                curve: EnvoyEasing.defaultEasing);
                          },
                          onWrongAnswer: () {
                            widget.onVerificationFinished(false);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
                    child: DotsIndicator(
                        pageController: _pageController,
                        totalPages: _puzzleOptions.length)),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: EnvoySpacing.medium1),
              !_finishedAnswers
                  ? Padding(
                      padding:
                          const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                      child: Text(
                        S().manual_setup_generate_seed_verify_seed_again_quiz_infotext,
                        style: EnvoyTypography.button.copyWith(
                          color: EnvoyColors.textInactive,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                          left: EnvoySpacing.xs,
                          right: EnvoySpacing.xs,
                          bottom: EnvoySpacing.medium2),
                      child: OnboardingButton(
                          label: S().component_continue,
                          onTap: () {
                            widget.onVerificationFinished(true);
                          }),
                    )
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createPuzzles();
    });
  }

  createPuzzles() {
    Random random = Random();
    List<String> filteredSeed =
        seedEn.where((element) => !widget.seed.contains(element)).toList();
    setState(() {
      Set<int> randomIndexes = {};
      while (randomIndexes.length < 4) {
        int nextIndex = random.nextInt(widget.seed.length);
        if (!randomIndexes.contains(nextIndex)) {
          randomIndexes.add(nextIndex);
        }
      }
      final randomIndexList = randomIndexes.toList();
      _puzzleOptions = List.generate(4, (index) {
        List<String> options = List.generate(3,
            (index) => filteredSeed[random.nextInt(filteredSeed.length - 1)]);
        String word = widget.seed[randomIndexList[index]];
        options.add(word);
        options.shuffle();
        return Puzzle(
            options: options,
            answerString: word,
            seedIndex: randomIndexList[index]);
      });
    });
  }
}

class Puzzle {
  final List<String> options;
  final String answerString;
  final int seedIndex;

  const Puzzle(
      {required this.options,
      required this.answerString,
      required this.seedIndex});
}

class PuzzleWidget extends StatefulWidget {
  final Puzzle puzzle;
  final Function() onCorrectAnswer;
  final Function() onWrongAnswer;

  const PuzzleWidget(
      {super.key,
      required this.puzzle,
      required this.onCorrectAnswer,
      required this.onWrongAnswer});

  @override
  State<PuzzleWidget> createState() => _PuzzleWidgetState();
}

class _PuzzleWidgetState extends State<PuzzleWidget> {
  String? chosenAnswer;

  @override
  Widget build(BuildContext context) {
    final options = widget.puzzle.options;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _answerField(context),
              if (chosenAnswer != null)
                _buildAnswerStatus(chosenAnswer == widget.puzzle.answerString),
            ],
          ),
        ),
        Flexible(
          child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 20.0,
              ),
              itemBuilder: (context, index) {
                const TextStyle textTheme = TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      chosenAnswer = options[index];
                    });
                    if (chosenAnswer == widget.puzzle.answerString) {
                      widget.onCorrectAnswer();
                      Haptics.lightImpact();
                    } else {
                      widget.onWrongAnswer();
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        alignment: Alignment.center,
                        constraints:
                            const BoxConstraints(maxWidth: 300, maxHeight: 40),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(options[index],
                            overflow: TextOverflow.fade,
                            textScaler: MediaQuery.of(context)
                                .textScaler
                                .clamp(maxScaleFactor: 1.2, minScaleFactor: .8),
                            style: textTheme,
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                );
              },
              itemCount: options.length),
        ),
      ],
    );
  }

  Widget _buildAnswerStatus(bool? correctSelection) {
    if (correctSelection == null) {
      return const SizedBox.shrink();
    }
    return correctSelection
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check,
                size: 14,
                color: EnvoyColors.accentPrimary,
              ),
              const Padding(padding: EdgeInsets.all(4)),
              Text(
                S().manual_setup_generate_seed_verify_seed_quiz_success_correct,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: EnvoyColors.accentPrimary),
              )
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(EnvoyIcons.exclamationWarning,
                  color: EnvoyColors.accentSecondary, size: 14),
              const Padding(padding: EdgeInsets.all(4)),
              Text(
                S().manual_setup_generate_seed_verify_seed_quiz_fail_invalid,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: EnvoyColors.accentSecondary),
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
      if (chosenAnswer != widget.puzzle.answerString) {
        borderColor = EnvoyColors.accentSecondary;
      } else {
        borderColor = EnvoyColors.textTertiary;
      }
    }

    final TextStyle textTheme = TextStyle(color: textColor, fontSize: 16);
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: const BoxConstraints(maxWidth: 140, maxHeight: 38),
      decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(" ${widget.puzzle.seedIndex + 1}. ",
              textScaler: MediaQuery.of(context)
                  .textScaler
                  .clamp(maxScaleFactor: 1.2, minScaleFactor: .8),
              style: textTheme),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(chosenAnswer ?? "",
                    textScaler: MediaQuery.of(context)
                        .textScaler
                        .clamp(maxScaleFactor: 1.2, minScaleFactor: .8),
                    style: textTheme),
                Container(
                  margin: const EdgeInsets.only(top: 14),
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
        ],
      ),
    );
  }
}
