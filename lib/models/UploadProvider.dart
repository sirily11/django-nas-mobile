import 'dart:io';

import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';

class UploadItem {
  File file;
  double progress;
  int parent;
  bool isDone = false;
  UploadItem({@required this.file, this.progress, @required this.parent});
}

class UploadProvider extends ChangeNotifier {
  List<UploadItem> items = [];

  Future<NasFile> addItem(UploadItem item) async {
    items.add(item);
    notifyListeners();
    return await uploadItem(item);
  }

  Future<List<NasFile>> addItems(List<UploadItem> items) async {
    this.items.addAll(items);
    notifyListeners();
    List<NasFile> l = [];
    for (var i in items) {
      var data = await this.uploadItem(i);
      l.add(data);
    }
    return l;
  }

  Future<NasFile> uploadItem(UploadItem item) async {
    FormData data = FormData.fromMap({
      "parent": item.parent,
      "file": await MultipartFile.fromFile(item.file.path)
    });
    var res = await DataFetcher(url: fileUrl).create<NasFile>(data,
        callback: (count, total) {
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
  removeItem(UploadItem item) {
    if (item.isDone) {
      items.removeWhere((i) => i.file == item.file);
      notifyListeners();
    }
  }
}
