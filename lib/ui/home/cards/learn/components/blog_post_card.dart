// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/blog_post.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:envoy/ui/home/cards/activity/activity_card.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';

const double blogThumbnailHeight = 172.0;
const double containerWidth = 309.0;

class BlogPostCard extends ConsumerStatefulWidget {
  final BlogPost blog;
  final Function? onTap;

  const BlogPostCard({
    Key? key,
    required this.blog,
    this.onTap,
  }) : super(key: key);

  @override
  ConsumerState<BlogPostCard> createState() => _BlogPostState();
}

class _BlogPostState extends ConsumerState<BlogPostCard> {
  bool _isBlogRead = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    EnvoyStorage().isBlogRead(widget.blog.id).listen((read) {
      if (!_isDisposed) {
        setState(() {
          _isBlogRead = read;
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  _showBlogPost(BlogPost blogPost) async {
    Navigator.of(context).push(
        PageRouteBuilder(pageBuilder: (context, animation, secondAnimation) {
      return BlogWindow(blog: blogPost);
    }, transitionsBuilder: (context, animation, anotherAnimation, child) {
      animation = CurvedAnimation(curve: Curves.linear, parent: animation);
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerWidth,
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.all(Radius.circular(EnvoySpacing.medium1)),
            child: GestureDetector(
              onTap: () {
                _showBlogPost(widget.blog);
                widget.blog.read = true;
                EnvoyStorage().updateBlogPost(widget.blog);
              },
              onLongPress: () {
                widget.blog.read = false;
                EnvoyStorage().updateBlogPost(widget.blog);
              },
              child: Stack(children: [
                widget.blog.thumbnail == null
                    ? Center(
                        child: Container(
                          height: blogThumbnailHeight,
                        ),
                      )
                    : Container(
                        height: blogThumbnailHeight,
                        width: containerWidth,
                        child: Image.memory(
                          Uint8List.fromList(widget.blog.thumbnail!),
                          fit: BoxFit.fitWidth,
                          //height: 172,
                        ),
                      ),
                _isBlogRead
                    ? Positioned.fill(
                        child: Container(
                          color: EnvoyColors.textPrimary.withOpacity(0.5),
                        ),
                      )
                    : SizedBox(),
              ]),
            ),
          ),
          Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
                vertical: EnvoySpacing.small,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.blog.title,
                      style: EnvoyTypography.body2Semibold
                          .copyWith(color: EnvoyColors.textPrimary),
                    ),
                    SizedBox(height: EnvoySpacing.xs),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM dd, yyyy', defaultLocale)
                                .format(widget.blog.publicationDate),
                          ),
                          _isBlogRead
                              ? Text(
                                  "Read",
                                  style: EnvoyTypography.caption1Medium
                                      .copyWith(
                                          color: EnvoyColors.textSecondary),
                                )
                              : Text("")
                        ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//ignore: must_be_immutable
class BlogWindow extends StatelessWidget with NavigationCard {
  BlogWindow({
    super.key,
    required this.blog,
  });

  final BlogPost blog;

  @override
  bool modal = false;

  @override
  CardNavigator? navigator;

  @override
  Function()? onPop;

  @override
  Widget? optionsWidget;

  @override
  Function()? rightFunction;

  @override
  IconData? rightFunctionIcon;

  @override
  String? title;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.0),
        scrollDirection: Axis.vertical,
        child: FutureBuilder<String>(
          builder: (context, snapshot) {
            final document = htmlParser.parse(blog.description);

            final imageTags = document.getElementsByTagName('img');
            for (final imgTag in imageTags) {
              imgTag.attributes['width'] = 'auto';
              imgTag.attributes['height'] = 'auto';

              // TODO: Fetch all the images via HttpTor
              //final img = await HttpTor(Tor()).get(imgTag.attributes['href']!);
              //imgTag.attributes['src'] = "data:image" + img
            }

            final modifiedHtmlContent = document.outerHtml;

            return DefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall!,
              child: Html(
                data: modifiedHtmlContent,
                onLinkTap: (
                  linkUrl,
                  _,
                  __,
                ) {
                  launchUrlString(linkUrl!);
                },
              ),
            );
          },
          future: null,
        ),
      ),
    );
  }
}
