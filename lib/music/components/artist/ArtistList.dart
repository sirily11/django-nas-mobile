import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

import 'ArtistDetail.dart';

class ArtistList extends StatefulWidget {
  @override
  _ArtistListState createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  List<MusicMetadata> artistList = [];

  @override
  Widget build(BuildContext context) {
    MusicProvider provider = Provider.of(context);
    return Scrollbar(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80),
        child: EasyRefresh(
          firstRefresh: true,
          header: BallPulseHeader(),
          onRefresh: () async {
            var res = await provider.getArtists();
            setState(() {
              artistList = res;
            });
          },
          child: ListView.separated(
            separatorBuilder: (c, i) => Padding(
              padding: EdgeInsets.only(left: 70),
              child: Divider(),
            ),
            itemCount: artistList.length,
            itemBuilder: (c, i) {
              MusicMetadata artist = artistList[i];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => ArtistDetail(
                        artist: artist,
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  child: Text("${artist.artist.substring(0, 1)}"),
                ),
                title: Text(
                  "${artist.artist}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
