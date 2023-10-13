// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/blog_post.dart';
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

class LearnCard extends ConsumerStatefulWidget {
  final TextEditingController controller = TextEditingController();

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
    ref.watch(learnSortStateProvider);

    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.medium1),
      child: ShaderMask(
        shaderCallback: (Rect rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              EnvoyColors.solidWhite,
              Colors.transparent,
              Colors.transparent,
              EnvoyColors.solidWhite,
            ],
            stops: [0.0, 0.01, 0.97, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstOut,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
                padding: EdgeInsets.symmetric(vertical: EnvoySpacing.xs / 2)),
            SliverToBoxAdapter(
              child: LearnIntro(),
            ),
            SliverPadding(
                padding:
                    EdgeInsets.symmetric(vertical: EnvoySpacing.medium2 / 2)),
            SliverToBoxAdapter(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width -
                        (EnvoySpacing.medium2 + EnvoySpacing.xl),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(EnvoySpacing.medium1),
                              topRight: Radius.circular(EnvoySpacing.medium1),
                            ),
                          ),
                          showDragHandle: true,
                          builder: (context) {
                            return LearnFilterWidget();
                          });
                    },
                    child: Container(
                        height: EnvoySpacing.large1,
                        width: EnvoySpacing.large1,
                        decoration: BoxDecoration(
                            color: learnFilterState.contains(LearnFilters.All)
                                ? EnvoyColors.surface2
                                : EnvoyColors.accentPrimary,
                            shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(EnvoySpacing.small),
                          child: EnvoyIcon(
                            EnvoyIcons.filter,
                            color: learnFilterState.contains(LearnFilters.All)
                                ? EnvoyColors.textTertiary
                                : EnvoyColors.textPrimaryInverse,
                          ),
                        )),
                  ),
                ],
              ),
            ),
            SliverPadding(
                padding:
                    EdgeInsets.symmetric(vertical: EnvoySpacing.medium2 / 2)),
            if (learnFilterState.contains(LearnFilters.Videos) &&
                videos.isNotEmpty)
              SliverToBoxAdapter(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                    child: Text(
                      "Videos", // TODO: FIGMA
                      style: EnvoyTypography.subheading
                          .copyWith(color: EnvoyColors.textPrimary),
                    ),
                  ),
                  Container(
                      height: videoImageHeight + videoInfoHeight,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            Video video = videos[index];
                            return Padding(
                              padding:
                                  EdgeInsets.only(right: EnvoySpacing.small),
                              child: VideoCard(
                                video: video,
                              ),
                            );
                          })),
                ],
              )),
            SliverPadding(
                padding:
                    EdgeInsets.symmetric(vertical: EnvoySpacing.medium2 / 2)),
            if (learnFilterState.contains(LearnFilters.Blogs) &&
                blogs.isNotEmpty)
              SliverToBoxAdapter(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                    child: Text(
                      "Blogs", // TODO: FIGMA
                      style: EnvoyTypography.subheading
                          .copyWith(color: EnvoyColors.textPrimary),
                    ),
                  ),
                  Container(
                      height: 250.0,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: blogs.length,
                          itemBuilder: (context, index) {
                            BlogPost blogPost = blogs[index];
                            return Padding(
                              padding:
                                  EdgeInsets.only(right: EnvoySpacing.small),
                              child: BlogPostWidget(
                                  blog: blogPost,
                                  onTap: () {
                                    context.go(ROUTE_LEARN_BLOG,
                                        extra: blogPost);
                                  }),
                            );
                          })),
                ],
              )),
            SliverPadding(
                padding:
                    EdgeInsets.symmetric(vertical: EnvoySpacing.medium2 / 2)),
            if (learnFilterState.contains(LearnFilters.FAQs))
              SliverToBoxAdapter(
                child: Faq(searchText: widget.controller.text),
              ),
            SliverPadding(
                padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium2)),
          ],
        ),
      ),
    );
  }
}

class LearnIntro extends StatelessWidget {
  const LearnIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(EnvoySpacing.medium2)),
        child: Container(
          width: double.infinity,
          color: Color(0xFF020202),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: EnvoySpacing.medium3,
                horizontal: EnvoySpacing.medium2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text("WELCOME TO THE\nLEARNING CENTER", // TODO: FIGMA
                    style: EnvoyTypography.heading
                        .copyWith(color: EnvoyColors.textPrimaryInverse)),
              ],
            ),
          ),
        ));
  }
}
