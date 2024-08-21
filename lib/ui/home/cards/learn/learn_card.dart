// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/blog_post.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/search.dart';
import 'package:envoy/ui/home/cards/learn/components/blog_post_card.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/home/cards/learn/faq.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/ui/state/learn_page_state.dart';
import 'package:envoy/ui/home/cards/learn/filter_state.dart';
import 'package:envoy/ui/home/cards/learn/components/video_card.dart';
import 'package:envoy/ui/home/cards/learn/components/filter_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/ui/routes/home_router.dart';
import 'package:envoy/ui/components/brandmark.dart';
import 'package:envoy/ui/components/linear_gradient.dart';

class LearnCard extends ConsumerStatefulWidget {
  final TextEditingController controller = TextEditingController();

  LearnCard({super.key});

  @override
  ConsumerState<LearnCard> createState() => _LearnCardState();
}

class _LearnCardState extends ConsumerState<LearnCard> {
  @override
  Widget build(BuildContext context) {
    List<Video> videos = ref.watch(learnVideosProvider(widget.controller.text));
    List<BlogPost> blogs =
        ref.watch(learnBlogsProvider(widget.controller.text));
    final learnFilterState = ref.watch(learnFilterStateProvider);
    final learnSortState = ref.watch(learnSortStateProvider);
    final bool isDefaultFilterAndSorting =
        learnFilterState.contains(LearnFilters.all) &&
            learnSortState == LearnSortTypes.newestFirst;

    var faqs = ref.watch(faqsProvider);
    if (widget.controller.text.isNotEmpty) {
      faqs = faqs
          .where((entry) => entry.question
              .toLowerCase()
              .contains(widget.controller.text.toLowerCase()))
          .toList();
    }

    final bool isFilterEmpty =
        !(learnFilterState.contains(LearnFilters.videos) ||
            learnFilterState.contains(LearnFilters.blogs) ||
            learnFilterState.contains(LearnFilters.faqs) ||
            learnFilterState.contains(LearnFilters.all));

    final bool isSearchEmpty = videos.isEmpty && faqs.isEmpty && blogs.isEmpty;

    final bool isAllEmpty = isSearchEmpty || isFilterEmpty;

    return ScrollGradientMask(
      bottomGradientValue: 0.85,
      end: 0.96,
      child: CustomScrollView(
        physics: isAllEmpty ? const NeverScrollableScrollPhysics() : null,
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(
              height: EnvoySpacing.medium1,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: EnvoySpacing.medium2,
                  top: EnvoySpacing.small,
                  left: EnvoySpacing.medium2,
                  right: EnvoySpacing.medium2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width -
                        (EnvoySpacing.large1 + EnvoySpacing.xl),
                    height: EnvoySpacing.large1,
                    child: EnvoySearch(
                        filterSearchResults: (text) {
                          setState(() {
                            text = widget.controller.text;
                          });
                        },
                        controller: widget.controller),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          isDismissible: true,
                          useRootNavigator: true,
                          barrierColor: Colors.black.withOpacity(0.2),
                          enableDrag: true,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(EnvoySpacing.medium1),
                              topRight: Radius.circular(EnvoySpacing.medium1),
                            ),
                          ),
                          showDragHandle: true,
                          builder: (context) {
                            return const LearnFilterWidget();
                          });
                    },
                    child: Container(
                        height: EnvoySpacing.medium3,
                        width: EnvoySpacing.medium3,
                        decoration: const BoxDecoration(
                            color: EnvoyColors.surface2,
                            shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(EnvoySpacing.xs),
                          child: EnvoyIcon(
                            EnvoyIcons.filter,
                            color: isDefaultFilterAndSorting
                                ? EnvoyColors.textTertiary
                                : EnvoyColors.accentPrimary,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
          if (learnFilterState.contains(LearnFilters.videos) &&
              videos.isNotEmpty)
            SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.only(
                  bottom: EnvoySpacing.medium2,
                  left: EnvoySpacing.medium1,
                  right: EnvoySpacing.medium1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                    child: Text(
                      S().learning_center_title_video,
                      style: EnvoyTypography.subheading
                          .copyWith(color: EnvoyColors.textPrimary),
                    ),
                  ),
                  SizedBox(
                      height: videoImageHeight + videoInfoHeight,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            Video video = videos[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: EnvoySpacing.small),
                              child: VideoCard(
                                video: video,
                              ),
                            );
                          })),
                ],
              ),
            )),
          if (learnFilterState.contains(LearnFilters.blogs) && blogs.isNotEmpty)
            SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.only(
                  left: EnvoySpacing.medium1, right: EnvoySpacing.medium1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                    child: Text(
                      S().learning_center_title_blog,
                      style: EnvoyTypography.subheading
                          .copyWith(color: EnvoyColors.textPrimary),
                    ),
                  ),
                  SizedBox(
                      height: 270.0,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: blogs.length,
                          itemBuilder: (context, index) {
                            BlogPost blogPost = blogs[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: EnvoySpacing.small),
                              child: BlogPostWidget(
                                  blog: blogPost,
                                  onTap: () {
                                    context.go(ROUTE_LEARN_BLOG,
                                        extra: blogPost);
                                  }),
                            );
                          })),
                ],
              ),
            )),
          if (learnFilterState.contains(LearnFilters.faqs))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
                child: Faq(searchText: widget.controller.text),
              ),
            ),
          if (!isAllEmpty)
            const SliverToBoxAdapter(
                child: Padding(
              padding: EdgeInsets.only(
                top: EnvoySpacing.large2,
                bottom: EnvoySpacing.large2,
                left: EnvoySpacing.small,
                right: EnvoySpacing.small,
              ),
              child: Brandmark(logoSize: 32, style: BrandmarkStyle.endMark),
            )),
          if (isAllEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  S().learning_center_filterEmpty_subheading,
                  style: EnvoyTypography.body
                      .copyWith(color: EnvoyColors.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: EnvoySpacing.medium3,
            ),
          ),
        ],
      ),
    );
  }
}
