import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:django_nas_mobile/music/components/InitProgressDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

class PlayListSongList extends StatefulWidget {
  @override
  _PlayListSongListState createState() => _PlayListSongListState();
}

class _PlayListSongListState extends State<PlayListSongList> {
  List<NasFile> songList = [];
  PaginationResult<NasFile> result;

  @override
  Widget build(BuildContext context) {
    MusicProvider provider = Provider.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 100),
      child: EasyRefresh(
        firstRefresh: true,
        onRefresh: () async {
          if (result == null) {
            await Future.delayed(Duration(milliseconds: 300));
          }
          var resp = await provider.getPlayList();
          setState(() {
            songList = resp.results;
            result = resp;
          });
        },
        onLoad: () async {
          if (result != null && result.next != null) {
            var resp = await provider.getPlayList(url: result?.next);
            setState(() {
              songList.addAll(resp.results);
              result = resp;
            });
          }
        },
        firstRefreshWidget: InitLoadingProgressDialog(),
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
                await provider.play(song);
              },
              selected: song.id == provider.currentPlayingMusic?.id,
              leading: Image.network(song.metadata.picture),
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
      ),
    );
  }
}
