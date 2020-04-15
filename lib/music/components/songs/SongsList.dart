import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class SongsList extends StatefulWidget {
  @override
  _SongsListState createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  List<NasFile> songList = [];
  PaginationResult<NasFile> result;

  @override
  Widget build(BuildContext context) {
    MusicProvider provider = Provider.of(context);
    return EasyRefresh(
      firstRefresh: true,
      onRefresh: () async {
        var resp = await provider.getMusic();
        setState(() {
          songList = resp.results;
          result = resp;
        });
      },
      onLoad: () async {
        if (result != null && result.next != null) {
          var resp = await provider.getMusic(url: result?.next);
          setState(() {
            songList.addAll(resp.results);
            result = resp;
          });
        }
      },
      header: BallPulseHeader(),
      footer: BallPulseFooter(),
      child: ListView.separated(
        separatorBuilder: (c, i) => Padding(
          padding: EdgeInsets.only(left: 70),
          child: Divider(),
        ),
        itemCount: songList.length,
        itemBuilder: (c, i) {
          NasFile song = songList[i];
          return ListTile(
            onTap: () async {
              await provider.play(song, musicList: songList, currentIndex: i);
            },
            selected: song.id == provider.currentPlayingMusic?.id,
            leading: song.metadata.picture != null
                ? Image.network(
                    song.metadata.picture,
                    width: 70,
                    height: 70,
                  )
                : Container(
                    height: 70,
                    width: 70,
                  ),
            title: Text(
              "${song.metadata.title}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "${song.metadata.artist}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
