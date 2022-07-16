import 'dart:typed_data';
import 'package:envoy/business/video.dart';
import 'package:envoy/business/video_manager.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/learn/video_player.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:url_launcher/url_launcher.dart';

class Videos extends StatefulWidget {
  const Videos({
    Key? key,
  }) : super(key: key);

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  //ignore:unused_element
  _playVideoExternally(Video video) {
    launchUrl(Uri.parse(video.url));
  }

  _playBitcoinTvVideo(Video video) async {
    Navigator.of(context).push(
        PageRouteBuilder(pageBuilder: (context, animation, secondAnimation) {
      return FullScreenVideoPlayer(video, key: UniqueKey());
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
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: VideoManager().videos.length,
        itemBuilder: (context, index) {
          Video video = VideoManager().videos[index];

          // YouTube doesn't provide duration in its Atom feed
          //ignore:unused_local_variable
          String durationText = (video.duration / 60).toStringAsFixed(0) +
              ":" +
              (video.duration % 60).toString().padLeft(2, '0');

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                        height: 50,
                        width: 70,
                        child: video.thumbnail == null
                            ? Center(
                                child: Icon(
                                Icons.play_arrow,
                                color: Colors.white60,
                              ))
                            : Image.memory(
                                Uint8List.fromList(video.thumbnail!),
                                height: 80,
                              ))),
                title: Text(
                  video.title,
                  style: TextStyle(
                      color: EnvoyColors.darkTeal,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  _playBitcoinTvVideo(video);
                },
              ),
            ),
          );
        });
  }
}
