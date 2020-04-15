import 'package:audioplayers/audioplayers.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:django_nas_mobile/music/components/music-player/FullScreenPlayer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Route dialogRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => FullScreenPlayer(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class BottomMusicPlayer extends StatelessWidget {
  final double height;
  BottomMusicPlayer({this.height});

  @override
  Widget build(BuildContext context) {
    MusicProvider provider = Provider.of(context);
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(context, dialogRoute());
        },
        child: Container(
          color: Theme.of(context).cardColor,
          width: MediaQuery.of(context).size.width,
          height: height ?? 70,
          child: Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10, right: 10),
            child: Row(
              children: <Widget>[
                provider.currentPlayingMusic != null
                    ? Image.network(
                        provider.currentPlayingMusic?.metadata?.picture ?? "",
                        width: 50,
                      )
                    : Container(
                        width: 40,
                      ),
                Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 9,
                  child: provider.currentPlayingMusic != null
                      ? Text(
                          "${provider.currentPlayingMusic.metadata.title}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text("No music is playing"),
                ),
                if (provider.currentState == AudioPlayerState.PLAYING ||
                    provider.currentState == AudioPlayerState.COMPLETED)
                  IconButton(
                    onPressed: () async {
                      await provider.pause();
                    },
                    icon: Icon(
                      Icons.pause,
                    ),
                  ),
                if (provider.currentState == AudioPlayerState.PAUSED)
                  IconButton(
                    onPressed: () async {
                      await provider.resume();
                    },
                    icon: Icon(
                      Icons.play_arrow,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
