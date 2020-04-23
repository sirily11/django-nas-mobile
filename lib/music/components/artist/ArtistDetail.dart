import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:django_nas_mobile/music/components/music-list/MusicList.dart';
import 'package:django_nas_mobile/music/components/music-player/BottomMusicPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class ArtistDetail extends StatefulWidget {
  final MusicMetadata artist;
  final bool useAlbumArtist;
  ArtistDetail({this.artist, this.useAlbumArtist = false});

  @override
  _ArtistDetailState createState() => _ArtistDetailState();
}

class _ArtistDetailState extends State<ArtistDetail> {
  List<MusicMetadata> albumList = [];

  @override
  Widget build(BuildContext context) {
    MusicProvider provider = Provider.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          EasyRefresh(
            header: BallPulseHeader(),
            firstRefresh: true,
            onRefresh: () async {
              if (widget.artist.albumArtist != null && widget.useAlbumArtist) {
                var res = await provider.getArtistDetail(
                    widget.artist.albumArtist, widget.useAlbumArtist);
                setState(() {
                  albumList = res;
                });
              } else {
                var res = await provider.getArtistDetail(
                    widget.artist.artist, widget.useAlbumArtist);
                setState(() {
                  albumList = res;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80, left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.useAlbumArtist
                        ? widget.artist.albumArtist
                        : widget.artist.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(),
                  Text(
                    "Albums from ${widget.useAlbumArtist ? widget.artist.albumArtist : widget.artist.artist}",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: albumList.length,
                    itemBuilder: (c, i) {
                      return AlbumCard(
                        metadata: albumList[i],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: BottomMusicPlayer(
              height: 90,
            ),
          )
        ],
      ),
    );
  }
}
