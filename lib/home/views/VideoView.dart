import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoView extends StatefulWidget {
  final String name;
  final String url;

  VideoView({this.name, this.url});

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  IjkMediaController controller = IjkMediaController();

  @override
  void initState() {
    super.initState();
    controller.setNetworkDataSource(widget.url);
  }

  @override
  void dispose() {
    controller.dispose();
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
            child: IjkPlayer(
              mediaController: controller,
            ),
          ),
        ),
      ),
    );
  }
}
