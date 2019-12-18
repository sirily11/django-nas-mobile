import 'dart:io';

import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class UploadDownloadItem {
  File file;
  String name;
  double progress;
  int parent;
  bool isDone = false;
  bool isUpload;
  UploadDownloadItem(
      {this.file,
      this.progress,
      this.parent,
      this.isDone = false,
      this.name,
      this.isUpload = true});
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
      await networkProvider.download(url, savePath,
          onReceiveProgress: (received, total) {
        double progress = (received / total);
        item.progress = progress;
        notifyListeners();
      });
      item.progress = 1;
      item.isDone = true;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  /// only desktop can use
  Future<void> downloadItems(List<String> urls, String savePath) async {
    for (var u in urls) {
      if (pause) {
        await Future.doWhile(() async {
          await Future.delayed(Duration(milliseconds: 100));
          return this._pause;
        });
      }
      if (!_pause) {
        await downloadItem(u, savePath);
      }
    }
  }

  Future<NasFile> uploadItem(UploadDownloadItem item,
      {@required String baseURL}) async {
    FormData data = FormData.fromMap({
      "parent": item.parent,
      "file": await MultipartFile.fromFile(item.file.path)
    });
    var res = await DataFetcher(
            url: fileUrl, baseURL: baseURL, networkProvider: networkProvider)
        .create<NasFile>(data, callback: (count, total) {
      double progress = (count / total);

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
