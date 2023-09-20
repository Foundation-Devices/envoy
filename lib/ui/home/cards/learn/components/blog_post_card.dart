// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/blog_post.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_tor/http_tor.dart';
import 'package:intl/intl.dart';
import 'package:envoy/ui/home/cards/activity/activity_card.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:tor/tor.dart';
import 'package:url_launcher/url_launcher_string.dart';

const double blogThumbnailHeight = 172.0;
const double containerWidth = 309.0;

class BlogPostWidget extends ConsumerStatefulWidget {
  final BlogPost blog;
  final Function? onTap;

  const BlogPostWidget({Key? key, required this.blog, this.onTap})
      : super(key: key);

  @override
  ConsumerState<BlogPostWidget> createState() => _BlogPostState();
}

class _BlogPostState extends ConsumerState<BlogPostWidget> {
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
                widget.blog.read = true;
                EnvoyStorage().updateBlogPost(widget.blog);
                widget.onTap!();
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
                        child: Opacity(
                          opacity: _isBlogRead ? 0.3 : 1.0,
                          child: Image.memory(
                            Uint8List.fromList(widget.blog.thumbnail!),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
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
                                  "Read", // TODO: Sync from Figma
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
class BlogPostCard extends StatelessWidget {
  BlogPostCard({
    super.key,
    required this.blog,
  });

  final BlogPost blog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: EnvoySpacing.large1,
        left: EnvoySpacing.medium1,
        right: EnvoySpacing.medium1,
      ),
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
            stops: [0.0, 0.07, 0.93, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstOut,
        child: SingleChildScrollView(
          child: FutureBuilder<String>(
            future: Future(() async {
              final document = htmlParser.parse(blog.description);
              final imageTags = document.getElementsByTagName('img');
              final torClient = HttpTor(Tor());

              // Fetch all the images with HttpTor
              for (final imgTag in imageTags) {
                imgTag.attributes['width'] = 'auto';
                imgTag.attributes['height'] = 'auto';

                final srcset = imgTag.attributes['srcset'];
                if (srcset != null && srcset.isNotEmpty) {
                  final srcsetUrls = srcset.split(',').map((e) {
                    final parts = e.trim().split(' ');
                    return parts.first;
                  }).toList();

                  if (srcsetUrls.isNotEmpty) {
                    final firstSrcsetUrl = srcsetUrls.first;
                    final img = await torClient.get(firstSrcsetUrl);
                    final dataUri =
                        'data:image/png;base64,${base64Encode(img.bodyBytes)}';
                    imgTag.attributes['src'] = dataUri;
                    imgTag.attributes['style'] = 'border-radius: 16;';
                  }
                }
              }

              return document.outerHtml;
            }),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodySmall!,
                  child: Column(
                    children: [
                      SizedBox(
                        height: EnvoySpacing.xs,
                      ),
                      Html(
                        data: snapshot.data,
                        onLinkTap: (
                          linkUrl,
                          _,
                          __,
                        ) {
                          launchUrlString(linkUrl!);
                        },
                      ),
                      // Add an empty div on the end with a height of 100px using inline HTML
                      Html(data: '<div style="height: 100px;"></div>'),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(EnvoySpacing.medium1),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
