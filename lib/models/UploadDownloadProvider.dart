import 'dart:io';

import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class UploadDownloadItem {
  File file;
  ByteData data;
  String name;
  double progress;
  int parent;
  bool isDone = false;
  bool isUpload;
  int total = 0;
  int current = 0;
  double _speed = 0;
  DateTime _time = DateTime.now();

  set speed(double difference) {
    DateTime now = DateTime.now();
    Duration duration = now.difference(_time);
    _time = now;
    _speed = (difference / duration.inMicroseconds) * 100000;
  }

  double get speed => _speed;

  computeSpeed() {}
  UploadDownloadItem(
      {this.file,
      this.progress,
      this.parent,
      this.isDone = false,
      this.name,
      this.isUpload = true,
      this.data});
}

class UploadDownloadProvider extends ChangeNotifier {
  List<UploadDownloadItem> items = [];
  bool onlyNotUploadItem = false;
  bool _pause = false;
  Dio networkProvider;

  UploadDownloadProvider({Dio networkProvider}) {
    this.networkProvider = networkProvider ?? Dio();
  }

  bool get pause => this._pause;

  set pause(bool p) {
    this._pause = p;
    notifyListeners();
  }

  /// upload item
  Future<NasFile> addItem(UploadDownloadItem item,
      {@required String baseURL}) async {
    items.add(item);
    notifyListeners();
    return await uploadItem(item, baseURL: baseURL);
  }

  /// upload multiple items
  Future<List<NasFile>> addItems(List<UploadDownloadItem> items,
      {@required String baseURL}) async {
    this.items.addAll(items);
    notifyListeners();
    List<NasFile> l = [];
    for (var i in items) {
      if (pause) {
        await Future.doWhile(() async {
          await Future.delayed(Duration(milliseconds: 100));
          return this._pause;
        });
      }
      if (!_pause) {
        var data = await this.uploadItem(i, baseURL: baseURL);
        l.add(data);
      }
    }
    return l;
  }

  /// Only desktop can use
  Future<void> downloadItem(String url, String savePath) async {
    try {
      UploadDownloadItem item =
          UploadDownloadItem(file: File(savePath), isUpload: false);
      items.add(item);
      notifyListeners();
      await _download(url, savePath, item);
    } catch (e) {
      print(e);
    }
  }

  /// only desktop can use
  Future<void> downloadItems(List<String> urls, List<String> savePaths) async {
    int i = 0;
    List<UploadDownloadItem> items = savePaths
        .map(
          (p) => UploadDownloadItem(file: File(p), isUpload: false),
        )
        .toList();
    this.items.addAll(items);
    notifyListeners();
    for (var item in items) {
      if (pause) {
        await Future.doWhile(() async {
          await Future.delayed(Duration(milliseconds: 100));
          return this._pause;
        });
      }
      if (!_pause) {
        await _download(urls[i], savePaths[i], item);
      }
      i++;
    }
  }

  Future<void> _download(
      String url, String savePath, UploadDownloadItem item) async {
    await networkProvider.download(url, savePath,
        onReceiveProgress: (received, total) {
      item.total = total;
      item.speed = (received - item.current).toDouble();
      item.current = received;
      double progress = (received / total);
      item.progress = progress;
      notifyListeners();
    });
    item.progress = 1;
    item.isDone = true;
    notifyListeners();
  }

  Future<NasFile> uploadItem(UploadDownloadItem item,
      {@required String baseURL}) async {
    FormData data;
    if (item.data != null) {
      data = FormData.fromMap({
        "parent": item.parent,
        "file": MultipartFile.fromBytes(item.data.buffer.asUint8List(),
            filename: item.name)
      });
    } else {
      data = FormData.fromMap({
        "parent": item.parent,
        "file": await MultipartFile.fromFile(item.file.path)
      });
    }

    var res = await DataFetcher(
            url: fileUrl, baseURL: baseURL, networkProvider: networkProvider)
        .create<NasFile>(data, callback: (count, total) {
      double progress = (count / total);
      item.total = total;
      item.speed = (count - item.current).toDouble();
      item.current = count;
      item.progress = progress;
      notifyListeners();
    });
    item.progress = 1;
    item.isDone = true;
    notifyListeners();
    return res;
  }

  /// Only remove the file which has been uploaded
  removeItem(UploadDownloadItem item) {
    if (item.progress == null || item.isDone) {
      items.removeWhere((i) => i.file == item.file);
      notifyListeners();
    }
  }

  removeAllItem() {
    items.removeWhere((i) => i.isDone == true);
    notifyListeners();
  }
}
