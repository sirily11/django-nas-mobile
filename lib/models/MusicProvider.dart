import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';

class MusicProvider with ChangeNotifier {
  NasFile currentPlayingMusic;
  Duration totalDuration;
  Duration currentPosition;
  AudioPlayerState currentState;
  final AudioPlayer audioPlayer = AudioPlayer();
  Dio networkProvider;

  MusicProvider() {
    this.networkProvider = Dio();
    audioPlayer.onDurationChanged.listen((d) {
      totalDuration = d;
      notifyListeners();
    });

    audioPlayer.onAudioPositionChanged.listen((event) {
      currentPosition = event;
      notifyListeners();
    });

    audioPlayer.onPlayerStateChanged.listen((event) {
      currentState = event;
      notifyListeners();
    });
  }

  Future<void> play(NasFile file) async {
    await audioPlayer.play(file.file);
  }

  Future<void> pause() async {
    await audioPlayer.pause();
  }

  Future<void> loop(bool willLoop) async {
    if (willLoop) {
      await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    } else {
      await audioPlayer.setReleaseMode(ReleaseMode.STOP);
    }
  }

  Future<void> stop() async {
    await audioPlayer.stop();
  }

  Future<void> seek(Duration target) async {
    await audioPlayer.seek(target);
  }

  /// search music based on the keyword
  Future<PaginationResult<NasFile>> search(String keyword) async {
    var result = await this.networkProvider.get("$musicURL?search=$keyword");
    List<NasFile> files = (result.data['results'] as List)
        .map((e) => NasFile.fromJson(e))
        .toList();
    var paginationResult =
        PaginationResult<NasFile>.fromJSON(result.data, files);
    return paginationResult;
  }

  /// get list of albums
  Future<List<MusicMetadata>> getAlbums() async {
    var result = await this.networkProvider.get("${musicURL}album/");
    List<MusicMetadata> files =
        (result.data as List).map((e) => MusicMetadata.fromJson(e)).toList();
    return files;
  }
  
  /// get list of artists
  Future<List<MusicMetadata>> getArtists() async {
    var result = await this.networkProvider.get("${musicURL}artist/");
    List<MusicMetadata> files =
        (result.data as List).map((e) => MusicMetadata.fromJson(e)).toList();
    return files;
  }

  /// get list of albums based on the artist name
  Future<List<MusicMetadata>> getArtistDetail(String artist) async {
    var result =
        await this.networkProvider.get("${musicURL}album/?artist=$artist");
    List<MusicMetadata> files =
        (result.data as List).map((e) => MusicMetadata.fromJson(e)).toList();
    return files;
  }

  /// Get list of music
  Future<PaginationResult<NasFile>> getMusic() async {
    var result = await this.networkProvider.get("$musicURL");
    List<NasFile> files = (result.data['results'] as List)
        .map((e) => NasFile.fromJson(e))
        .toList();
    var paginationResult =
        PaginationResult<NasFile>.fromJSON(result.data, files);
    return paginationResult;
  }

  /// get list of like music
  Future<PaginationResult<NasFile>> getPlayList() async {
    var result = await this.networkProvider.get("$musicURL?like=true");
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
      "$musicMetadataURL/${file.metadata.id}",
      data: {"like": newResult},
    );
    return newResult;
  }
}
