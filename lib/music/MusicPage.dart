import 'package:django_nas_mobile/drawer/DrawerPanel.dart';
import 'package:django_nas_mobile/home/components/SearchDelegate.dart';
import 'package:django_nas_mobile/music/components/music-list/MusicList.dart';
import 'package:django_nas_mobile/music/components/music-player/BottomMusicPlayer.dart';
import 'package:django_nas_mobile/music/components/songs/PlaylistSongList.dart';
import 'package:flutter/material.dart';

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  int currentIndex = 0;

  Widget _renderBody() {
    switch (currentIndex) {
      case 1:
        return Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              PlayListSongList(),
              Positioned(
                bottom: 0,
                child: Hero(
                  tag: "music-player",
                  child: BottomMusicPlayer(),
                ),
              ),
            ],
          ),
        );
      default:
        return Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              MusicList(),
              Positioned(
                bottom: 0,
                child: Hero(
                  tag: "music-player",
                  child: BottomMusicPlayer(),
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              showSearch(context: context, delegate: MusicSearch());
            },
          )
        ],
      ),
      drawer: DrawerPanel(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          print(i);
          setState(() {
            currentIndex = i;
          });
        },
        currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(
            title: Text("Music Library"),
            icon: Icon(Icons.library_music),
          ),
          BottomNavigationBarItem(
            title: Text("PlayList"),
            icon: Icon(Icons.playlist_play),
          )
        ],
      ),
      body: _renderBody(),
    );
  }
}
