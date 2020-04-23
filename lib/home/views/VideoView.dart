import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String name;
  final String url;

  VideoView({this.name, this.url});

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  IjkMediaController controller = IjkMediaController();
  bool canPlay = false;
  VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    controller.setNetworkDataSource(widget.url).then((value) {
      setState(() {
        canPlay = true;
      });
    }).catchError((e) => print(e));

    controller.setIjkPlayerOptions(
      [
        TargetPlatform.iOS,
      ],
      [
        IjkOption(IjkOptionCategory.player, "videotoolbox", 0),
      ],
    );
    // videoPlayerController = VideoPlayerController.network(widget.url)
    //   ..initialize().then((_) {
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     setState(() {});
    //     print("Init");
    //   }).catchError((e) => print(e));
  }

  @override
  void dispose() {
    controller.dispose();
    // videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              if (await canLaunch(widget.url)) {
                await launch(widget.url);
              }
            },
            icon: Icon(Icons.open_in_new),
          )
        ],
        title: Text(widget.name),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: canPlay
                ? IjkPlayer(
                    mediaController: controller,
                  )
                : Container(),
          ),
        ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(),
    //   body: Center(
    //     child: videoPlayerController.value.initialized
    //         ? AspectRatio(
    //             aspectRatio: videoPlayerController.value.aspectRatio,
    //             child: VideoPlayer(videoPlayerController),
    //           )
    //         : Container(),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       setState(() {
    //         videoPlayerController.value.isPlaying
    //             ? videoPlayerController.pause()
    //             : videoPlayerController.play();
    //       });
    //     },
    //     child: Icon(
    //       videoPlayerController.value.isPlaying
    //           ? Icons.pause
    //           : Icons.play_arrow,
    //     ),
    //   ),
    // );
  }
}
