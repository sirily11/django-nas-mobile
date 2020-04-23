import 'package:audioplayers/audioplayers.dart';
import 'package:django_nas_mobile/home/HomePage.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:django_nas_mobile/music/components/artist/ArtistDetail.dart';
import 'package:django_nas_mobile/music/components/music-list/MusicDetail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullScreenPlayer extends StatefulWidget {
  @override
  _FullScreenPlayerState createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  String formatTime(Duration time) {
    int sec = time.inSeconds.remainder(60);
    return "${time.inMinutes < 10 ? "0${time.inMinutes}" : time.inMinutes}:${sec < 10 ? "0$sec" : sec}";
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    MusicProvider provider = Provider.of(context);
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: provider.currentPlayingMusic != null
                    ? AnimatedContainer(
                        height: provider.currentState == AudioPlayerState.PAUSED
                            ? 300
                            : 350,
                        duration: Duration(milliseconds: 200),
                        child: Image.network(
                          provider.currentPlayingMusic.metadata.picture ?? "",
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        height: 300,
                        width: 300,
                        color: Colors.black,
                      ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: provider.currentPlayingMusic != null
                            ? Text(
                                "${provider.currentPlayingMusic.metadata.title}",
                                style: Theme.of(context).textTheme.headline6,
                              )
                            : Text("No Music Playing"),
                      ),
                      if (provider.currentPlayingMusic != null)
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => ArtistDetail(
                                      artist: provider
                                          .currentPlayingMusic.metadata),
                                ),
                              );
                            },
                            child: Text(
                              "${provider.currentPlayingMusic.metadata.artist}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(color: Colors.red),
                            ),
                          ),
                        ),
                      if (provider.currentPlayingMusic != null)
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => MusicDetail(
                                    album:
                                        provider.currentPlayingMusic.metadata,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "${provider.currentPlayingMusic.metadata.album}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(color: Colors.red),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (provider.currentPlayingMusic != null)
                  IconButton(
                    onPressed: () async {
                      await provider.like(provider.currentPlayingMusic);
                    },
                    icon: Icon(Icons.favorite,
                        color: provider.currentPlayingMusic.metadata.like
                            ? Colors.red
                            : null),
                  )
              ],
            ),
            if (provider.currentPlayingMusic != null)
              Listener(
                onPointerUp: (e) async {
                  await provider.seek(
                    provider.currentPosition,
                    shouldSet: true,
                  );
                  await Future.delayed(Duration(milliseconds: 200));
                  await provider.resume();
                },
                onPointerDown: (e) async {
                  await provider.pause();
                },
                child: Slider.adaptive(
                  min: 0,
                  max: provider.totalDuration?.inSeconds?.toDouble() ?? 10000,
                  value: provider.currentPosition?.inSeconds?.toDouble() ?? 0,
                  onChangeEnd: (v) async {},
                  onChanged: (double value) async {
                    await provider.seek(
                      Duration(seconds: value.toInt()),
                      shouldSet: false,
                    );
                  },
                ),
              ),
            if (provider.currentPlayingMusic != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Text(formatTime(provider.currentPosition)),
                    Spacer(),
                    Text(formatTime(provider.totalDuration))
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (provider.currentPlayingMusic != null)
                  IconButton(
                    onPressed: provider.hasPrevious
                        ? () async {
                            await provider.play(
                              provider.musicList[provider.currentIndex - 1],
                              musicList: provider.musicList,
                              currentIndex: provider.currentIndex - 1,
                            );
                          }
                        : null,
                    iconSize: 60,
                    icon: Icon(Icons.skip_previous),
                  ),
                if (provider.currentState == AudioPlayerState.PLAYING ||
                    provider.currentState == AudioPlayerState.COMPLETED)
                  IconButton(
                    iconSize: 60,
                    icon: Icon(Icons.pause),
                    onPressed: () async {
                      await provider.pause();
                    },
                  ),
                if (provider.currentState == AudioPlayerState.PAUSED)
                  IconButton(
                    iconSize: 60,
                    icon: Icon(Icons.play_arrow),
                    onPressed: () async {
                      await provider.resume();
                    },
                  ),
                if (provider.currentPlayingMusic != null)
                  IconButton(
                    onPressed: provider.hasNext
                        ? () async {
                            await provider.play(
                              provider.musicList[provider.currentIndex + 1],
                              musicList: provider.musicList,
                              currentIndex: provider.currentIndex + 1,
                            );
                          }
                        : null,
                    iconSize: 60,
                    icon: Icon(Icons.skip_next),
                  ),
              ],
            ),
            if (provider.currentPlayingMusic != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  provider.releaseMode == ReleaseMode.LOOP
                      ? IconButton(
                          onPressed: () async {
                            await provider.loop(false);
                          },
                          icon: Icon(Icons.repeat_one),
                        )
                      : IconButton(
                          onPressed: () async {
                            await provider.loop(true);
                          },
                          icon: Icon(Icons.repeat),
                        ),
                  IconButton(
                    onPressed: () async {},
                    icon: Icon(Icons.volume_mute),
                  ),
                  IconButton(
                    onPressed: () {
                      showBottomMenu(context, provider);
                    },
                    icon: Icon(Icons.more_horiz),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  PersistentBottomSheetController showBottomMenu(
      BuildContext context, MusicProvider provider) {
    return scaffoldKey.currentState.showBottomSheet(
      (c) => Container(
        height: 100,
        color: Theme.of(context).popupMenuTheme.color,
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => HomePage(
                      folderID: provider.currentPlayingMusic.parent,
                      name: provider.currentPlayingMusic.name,
                    ),
                  ),
                );
              },
              title: Text("Go to folder"),
              subtitle: Text(
                "${provider.currentPlayingMusic.filename}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
