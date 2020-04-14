import 'package:django_nas_mobile/music/components/music-list/MusicList.dart';
import 'package:django_nas_mobile/music/components/music-player/BottomMusicPlayer.dart';
import 'package:django_nas_mobile/music/components/songs/SongsList.dart';
import 'package:flutter/material.dart';

class SongsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Songs"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            SongsList(),
            Positioned(
              bottom: 0,
              child: Hero(
                tag: "music-player",
                child: BottomMusicPlayer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
