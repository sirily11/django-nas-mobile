import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class MusicProvider extends ChangeNotifier {
  NasFile currentPlayingMusic;
  List<NasFile> musicList = [];
  int currentIndex;
  Duration totalDuration;
  Duration currentPosition;
  AudioPlayerState currentState = AudioPlayerState.STOPPED;
  ReleaseMode releaseMode = ReleaseMode.LOOP;
  Box box;
  String baseURL;
  final AudioPlayer audioPlayer = AudioPlayer();
  Dio networkProvider;

  Future<void> initBox() async {
    if (Platform.isIOS || Platform.isAndroid) {
      var path = await getApplicationDocumentsDirectory();
      Hive.init(path.path);
      this.box = await Hive.openBox('settings');
    } else if (Platform.isMacOS) {
      Hive.init(Directory.current.path);
      this.box = await Hive.openBox('settings');
    }
  }

  @override
  void dispose() {
    print("Music player closed");
    audioPlayer.dispose();
    super.dispose();
  }

  static void x(AudioPlayerState value) {
    print("state => $value");
  }

  MusicProvider() {
    this.networkProvider = Dio();
    this.initBox().then((_) {
      this.baseURL = this.box.get("url");
    });
    audioPlayer.onDurationChanged.listen((d) {
      print('Max duration: $d');
      totalDuration = d;
      notifyListeners();
    });

    audioPlayer.monitorNotificationStateChanges(x);

    audioPlayer.onPlayerError.listen((msg) {
      currentState = AudioPlayerState.STOPPED;
      totalDuration = Duration(seconds: 0);
      currentPosition = Duration(seconds: 0);
    });
    audioPlayer.startHeadlessService();

    audioPlayer.onAudioPositionChanged.listen((event) {
      currentPosition = event;
      notifyListeners();
    });

    audioPlayer.onPlayerStateChanged.listen((event) {
      currentState = event;
      notifyListeners();
    });

    audioPlayer.onPlayerCompletion.listen((e) async {
      print("complete");
      if (releaseMode == ReleaseMode.LOOP) {
        await Future.delayed(Duration(milliseconds: 400));
        await play(this.currentPlayingMusic,
            currentIndex: currentIndex, musicList: musicList);
      } else {
        if (hasNext) {
          await Future.delayed(Duration(milliseconds: 400));
          await play(
            this.musicList[currentIndex + 1],
            currentIndex: currentIndex + 1,
            musicList: musicList,
          );
        }
      }
    });

    audioPlayer.setReleaseMode(releaseMode);
  }

  bool get hasNext =>
      currentIndex != null && currentIndex < musicList.length - 1;

  bool get hasPrevious => currentIndex != null && currentIndex > 0;

  Future<void> play(
    NasFile file, {
    @required List<NasFile> musicList,
    @required currentIndex,
  }) async {
    bool hasNext = currentIndex < musicList.length;
    bool hasPrevious = currentIndex > 0;
    await audioPlayer.play(file.file);
    currentPlayingMusic = file;
    totalDuration = Duration(seconds: file.metadata.duration);
    if (Platform.isIOS) {
      await audioPlayer.setNotification(
        title: "${file?.metadata?.title}",
        artist: "${file.metadata.artist}",
        albumTitle: "${file.metadata.album}",
        imageUrl: "${file.metadata.picture}",
        duration: totalDuration,
        hasNextTrack: hasNext,
        hasPreviousTrack: hasPrevious,
      );
    }
    this.currentIndex = currentIndex;
    this.musicList = musicList;
    notifyListeners();
  }

  Future<void> loop(bool shouldLoop) async {
    if (shouldLoop) {
      releaseMode = ReleaseMode.LOOP;
    } else {
      releaseMode = ReleaseMode.STOP;
    }
    await audioPlayer.setReleaseMode(releaseMode);
    notifyListeners();
  }

  Future<void> pause() async {
    await audioPlayer.pause();
  }

  Future<void> resume() async {
    await audioPlayer.resume();
  }

  Future<void> stop() async {
    await audioPlayer.stop();
    await audioPlayer.seek(Duration(seconds: 0));
    currentPlayingMusic = null;
    notifyListeners();
  }

  Future<void> seek(Duration target, {bool shouldSet = false}) async {
    if (shouldSet) {
      await audioPlayer.seek(target);
    }
    this.currentPosition = target;
    notifyListeners();
  }

  /// search music based on the keyword
  Future<PaginationResult<NasFile>> search(String keyword) async {
    var result =
        await this.networkProvider.get("$baseURL$musicURL?search=$keyword");
    List<NasFile> files = (result.data['results'] as List)
        .map((e) => NasFile.fromJson(e))
        .toList();
    var paginationResult =
        PaginationResult<NasFile>.fromJSON(result.data, files);
    return paginationResult;
  }

  /// get list of albums
  Future<List<MusicMetadata>> getAlbums() async {
    var result = await this.networkProvider.get("$baseURL${musicURL}album/");
    List<MusicMetadata> files =
        (result.data as List).map((e) => MusicMetadata.fromJson(e)).toList();
    return files;
  }

  /// get list of artists
  Future<List<MusicMetadata>> getArtists() async {
    var result = await this.networkProvider.get("$baseURL${musicURL}artist/");
    List<MusicMetadata> files =
        (result.data as List).map((e) => MusicMetadata.fromJson(e)).toList();
    return files;
  }

  /// get list of albums based on the artist name
  Future<List<MusicMetadata>> getArtistDetail(String artist) async {
    var result = await this
        .networkProvider
        .get("$baseURL${musicURL}album/?album_artist=$artist");
    List<MusicMetadata> files =
        (result.data as List).map((e) => MusicMetadata.fromJson(e)).toList();
    return files;
  }

  /// get list of albums based on the artist name
  Future<PaginationResult<NasFile>> getAlbumDetail(String album) async {
    var result =
        await this.networkProvider.get("$baseURL$musicURL?album=$album");
    List<NasFile> files = (result.data['results'] as List)
        .map((e) => NasFile.fromJson(e))
        .toList();
    var paginationResult =
        PaginationResult<NasFile>.fromJSON(result.data, files);
    return paginationResult;
  }

  /// Get list of music
  Future<PaginationResult<NasFile>> getMusic({String url}) async {
    var result = await this.networkProvider.get(url ?? "$baseURL$musicURL");
    List<NasFile> files = (result.data['results'] as List)
        .map((e) => NasFile.fromJson(e))
        .toList();
    var paginationResult =
        PaginationResult<NasFile>.fromJSON(result.data, files);
    return paginationResult;
  }

  /// get list of like music
  Future<PaginationResult<NasFile>> getPlayList({String url}) async {
    var result =
        await this.networkProvider.get(url ?? "$baseURL$musicURL?like=true");
    List<NasFile> files = (result.data['results'] as List)
        .map((e) => NasFile.fromJson(e))
        .toList();
    var paginationResult =
        PaginationResult<NasFile>.fromJSON(result.data, files);
    return paginationResult;
  }

  /// Press like button
  Future<bool> like(NasFile file) async {
    bool newResult = !file.metadata.like;
    await this.networkProvider.patch(
      "$baseURL$musicMetadataURL${file.metadata.id}/",
      data: {"like": newResult},
    );
    currentPlayingMusic.metadata.like = newResult;
    notifyListeners();
    return newResult;
  }
}
