import 'dart:math';

import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:django_nas_mobile/music/components/InitProgressDialog.dart';
import 'package:django_nas_mobile/music/components/artist/ArtistDetail.dart';
import 'package:django_nas_mobile/music/components/music-player/BottomMusicPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class MusicDetail extends StatefulWidget {
  final MusicMetadata album;

  MusicDetail({this.album});

  @override
  _MusicDetailState createState() => _MusicDetailState();
}

class _MusicDetailState extends State<MusicDetail> {
  List<NasFile> musicList = [];
  PaginationResult<NasFile> result;

  @override
  Widget build(BuildContext context) {
    MusicProvider provider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          EasyRefresh(
            firstRefresh: true,
            header: BallPulseHeader(),
            onRefresh: () async {
              await Future.delayed(Duration(milliseconds: 200));
              var result = await provider.getAlbumDetail(widget.album.album);
              setState(() {
                musicList = result.results;
                this.result = result;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  buildHeader(context),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 70),
                    child: ListView.separated(
                      separatorBuilder: (c, i) => Padding(
                        padding: EdgeInsets.only(left: 70),
                        child: Divider(),
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: musicList.length,
                      itemBuilder: (c, i) {
                        NasFile song = musicList[i];
                        return ListTile(
                          onTap: () async {
                            await provider.play(song,
                                musicList: musicList, currentIndex: i);
                          },
                          selected: provider.currentPlayingMusic?.id == song.id,
                          leading: Text("${song.metadata.track}"),
                          title: Text(
                            song.metadata.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: provider.currentPlayingMusic != null &&
                                  provider.currentPlayingMusic.id == song.id
                              ? IconButton(
                                  onPressed: () async {
                                    await provider.stop();
                                  },
                                  icon: Icon(Icons.stop),
                                )
                              : null,
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Hero(
              tag: "music-player",
              child: BottomMusicPlayer(
                height: 90,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            widget.album.picture,
            width: 150,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.album.album,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ArtistDetail(
                          artist: widget.album,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    widget.album.albumArtist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
                Text(
                  "${widget.album.genre} - ${widget.album.year.substring(0, min(4, widget.album.year.length))}",
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.caption.copyWith(
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
