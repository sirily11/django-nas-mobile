import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:django_nas_mobile/music/components/InitProgressDialog.dart';
import 'package:django_nas_mobile/music/components/music-list/MusicDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_header.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class MusicList extends StatefulWidget {
  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  List<MusicMetadata> albumList = [];

  @override
  Widget build(BuildContext context) {
    MusicProvider provider = MusicProvider();

    return Scrollbar(
      child: EasyRefresh(
        header: BallPulseHeader(),
        firstRefresh: true,
        firstRefreshWidget: InitLoadingProgressDialog(),
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 100));
          try {
            var list = await provider.getAlbums();
            setState(() {
              albumList = list;
            });
          } catch (err) {
            print(err);
          }
        },
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () => Navigator.pushNamed(context, '/music-artist'),
              title: Text("Artist"),
            ),
            ListTile(
              onTap: () => Navigator.pushNamed(context, '/music-song'),
              title: Text("Songs"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                  padding: EdgeInsets.only(bottom: 80),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: albumList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    MusicMetadata metadata = albumList[index];
                    return AlbumCard(metadata: metadata);
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    Key key,
    @required this.metadata,
  }) : super(key: key);

  final MusicMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => MusicDetail(
              album: metadata,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (metadata.picture != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                metadata.picture,
                height: 185,
              ),
            ),
          if (metadata.picture == null)
            Container(
              height: 185,
            ),
          Text(
            "${metadata.album}",
            maxLines: 1,
          ),
          Text(
            "${metadata.albumArtist}",
            maxLines: 1,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }
}
