import 'package:audioplayers/audioplayers.dart';
import 'package:django_nas_mobile/models/MusicProvider.dart';
import 'package:django_nas_mobile/music/components/artist/ArtistDetail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullScreenPlayer extends StatelessWidget {
  String formatTime(Duration time) {
    int sec = time.inSeconds.remainder(60);
    return "${time.inMinutes < 10 ? "0${time.inMinutes}" : time.inMinutes}:${sec < 10 ? "0$sec" : sec}";
  }

  @override
  Widget build(BuildContext context) {
    MusicProvider provider = Provider.of(context);
    return Scaffold(
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
                    ? Image.network(
                        provider.currentPlayingMusic.metadata.picture ?? "",
                        height: 250,
                        width: 300,
                      )
                    : Container(
                        height: 250,
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
              Slider.adaptive(
                min: 0,
                max: provider.totalDuration?.inSeconds?.toDouble() ?? 10000,
                value: provider.currentPosition?.inSeconds?.toDouble() ?? 0,
                onChangeStart: (e) async {
                  await provider.pause();
                },
                onChangeEnd: (v) async {
                  await provider.seek(
                    Duration(seconds: v.toInt()),
                    shouldSet: true,
                  );
                  await provider.resume();
                },
                onChanged: (double value) async {
                  await provider.seek(
                    Duration(seconds: value.toInt()),
                    shouldSet: false,
                  );
                },
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
                IconButton(
                  icon: Icon(Icons.volume_mute),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
