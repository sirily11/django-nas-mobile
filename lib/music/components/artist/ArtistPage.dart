import 'package:django_nas_mobile/music/components/artist/ArtistList.dart';
import 'package:django_nas_mobile/music/components/music-list/MusicList.dart';
import 'package:django_nas_mobile/music/components/music-player/BottomMusicPlayer.dart';
import 'package:flutter/material.dart';

class ArtistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Artist"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            ArtistList(),
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
