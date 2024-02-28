// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/blog_post.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_tor/http_tor.dart';
import 'package:intl/intl.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:tor/tor.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/locale.dart';

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
  @override
  Widget build(BuildContext context) {
    final bool _isBlogRead =
        ref.watch(readBlogStreamProvider(widget.blog.id)).value ?? false;
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
                FutureBuilder(
                    future: widget.blog.thumbnail,
                    builder: (context, snapshot) {
                      return !snapshot.hasData || snapshot.data == null
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
                                  Uint8List.fromList(snapshot.data!),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            );
                    })
              ]),
            ),
          ),
          Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
                vertical: EnvoySpacing.xs,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.blog.title,
                      style: EnvoyTypography.button
                          .copyWith(color: EnvoyColors.textPrimary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: EnvoySpacing.xs),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM dd, yyyy', currentLocale)
                                .format(widget.blog.publicationDate),
                          ),
                          _isBlogRead
                              ? Text(
                                  S().learningcenter_status_read,
                                  style: EnvoyTypography.info.copyWith(
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

class BlogPostCard extends StatefulWidget {
  BlogPostCard({
    Key? key,
    required this.blog,
  }) : super(key: key);

  final BlogPost blog;

  @override
  _BlogPostCardState createState() => _BlogPostCardState();
}

class _BlogPostCardState extends State<BlogPostCard> {
  double topGradientEnd = 0.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
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
              stops: [0.0, 0.03, 0.93, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: SingleChildScrollView(
            child: FutureBuilder<String>(
              future: Future(() async {
                final document = htmlParser.parse(widget.blog.description);
                final imageTags = document.getElementsByTagName('img');
                final torClient =
                    HttpTor(Tor.instance, EnvoyScheduler().parallel);

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
                        Html(
                          data: snapshot.data!,
                          style: {
                            "p": Style(fontSize: FontSize.medium),
                            "a": Style(color: EnvoyColors.accentPrimary),
                          },
                          onLinkTap: (linkUrl, _, __) {
                            launchUrlString(linkUrl!);
                          },
                        ),
                        Html(data: '<div style="height: 100px;"></div>'),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(EnvoySpacing.medium1),
                    child: Container(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
