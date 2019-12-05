import 'dart:io';

import 'package:flutter/material.dart';

class UploadItem {
  File file;
  double progress;

  UploadItem({this.file, this.progress});
}

class UploadProvider extends ChangeNotifier {
  List<UploadItem> items = [];

  addItem(UploadItem item) {
    items.add(item);
    notifyListeners();
  }

  addItems(List<UploadItem> items) {
    items.addAll(items);
  }

  removeItem(UploadItem item) {
    items.removeWhere((i) => i.file == item.file);
    notifyListeners();
  }
}
