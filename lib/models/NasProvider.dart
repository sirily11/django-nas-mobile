import 'dart:io';

import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

String folderUrl = "/api/folder/";
String fileUrl = "/api/file/";
String documentUrl = "/api/document/";
String editorUrl = "/#/edit/";
String systemUrl = "/system/";

class NasProvider extends ChangeNotifier {
  List<NasFolder> parents = [];
  NasFolder currentFolder;
  bool isLoading = false;
  Dio networkProvider;
  Box box;

  NasProvider({Dio networkProvider, Box box}) {
    this.networkProvider = networkProvider ?? Dio();
    this.box = box;
    if (box == null) {
      if (Platform.isIOS || Platform.isAndroid) {
        getApplicationDocumentsDirectory().then((path) {
          Hive.init(path.path);
        });
      } else if (Platform.isMacOS) {
        Hive.init(Directory.current.path);
      }
    }
  }

  void update() {
    notifyListeners();
  }

  /// sey base url
  Future<void> setURL(String url) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString("url", url);
    var box = await Hive.openBox('settings');
    box.put("url", url);
    await this.fetchFolder(null);
  }

  /// Delete file.
  /// [NasFile file] file you want to delete
  Future<void> deleteFile(NasFile file) async {
    try {
      await DataFetcher(
              url: fileUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .delete<NasFile>(file.id);
      currentFolder.files.removeWhere((f) => f.id == file.id);
    } catch (err) {} finally {
      notifyListeners();
    }
  }

  Future<void> deleteDocument(NasDocument document) async {
    try {
      await DataFetcher(
              url: documentUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .delete<NasDocument>(document.id);
      currentFolder.documents.removeWhere((d) => d.id == document.id);
    } catch (err) {} finally {
      notifyListeners();
    }
  }

  Future<void> deleteFolder(NasFolder folder) async {
    try {
      await DataFetcher(
              url: folderUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .delete<NasFolder>(folder.id);
      currentFolder.folders.removeWhere((d) => d.id == folder.id);
    } catch (err) {} finally {
      notifyListeners();
    }
  }

  /// Move Folder to its parent
  /// If parent is null, then nothing would happen
  Future<void> moveFolderBack(NasFolder folder, int parent) async {
    try {
      var response = await DataFetcher(
              url: folderUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .update<NasFolder>(folder.id, {"parent": parent});
      parents[parents.length - 2]?.folders?.add(response);
      currentFolder.folders.removeWhere((f) => f.id == folder.id);
      notifyListeners();
    } catch (err) {}
  }

  /// Move File to its parent
  /// If parent is null, then nothing would happen
  Future<void> moveFileBack(NasFile file, int parent) async {
    try {
      var response = await DataFetcher(
              url: fileUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .update<NasFile>(file.id, {"parent": parent});
      parents[parents.length - 2]?.files?.add(response);
      currentFolder.files.removeWhere((f) => f.id == file.id);
      notifyListeners();
    } catch (err) {}
  }

  /// Move Document to its parent
  /// If parent is null, then nothing would happen
  Future<void> moveDocumentBack(NasDocument document, int parent) async {
    try {
      var response = await DataFetcher(
              url: documentUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .update<NasDocument>(document.id, {"parent": parent});
      parents[parents.length - 2]?.documents?.add(response);
      currentFolder.documents.removeWhere((d) => d.id == document.id);
      notifyListeners();
    } catch (err) {}
  }

  /// Move folder to current folder child
  Future<void> moveFolderTo(NasFolder folder, int target) async {
    try {
      var response = await DataFetcher(
              url: folderUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .update<NasFolder>(folder.id, {"parent": target});
      currentFolder.folders.removeWhere((f) => f.id == folder.id);
      notifyListeners();
    } catch (err) {}
  }

  /// Move file to current folder child
  Future<void> moveFileTo(NasFile file, int target) async {
    try {
      var response = await DataFetcher(
              url: fileUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .update<NasFile>(file.id, {"parent": target});
      currentFolder.files.removeWhere((f) => f.id == file.id);
      notifyListeners();
    } catch (err) {}
  }

  /// Move document to current folder child
  Future<void> moveDocumentTo(NasDocument document, int target) async {
    try {
      var response = await DataFetcher(
              url: documentUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .update<NasDocument>(document.id, {"parent": target});
      currentFolder.documents.removeWhere((d) => d.id == document.id);
      notifyListeners();
    } catch (err) {}
  }

  /// fetch folder
  /// if [id] is null, then fetch root folder
  Future<void> fetchFolder(int id) async {
    try {
      isLoading = true;
      notifyListeners();
      var folder = await DataFetcher(
              url: folderUrl,
              networkProvider: this.networkProvider,
              box: this.box)
          .fetchOne<NasFolder>(id: id);
      currentFolder = folder;
      parents.add(folder);
    } catch (err) {} finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> backToPrev() async {
    parents.removeLast();
    currentFolder = parents.last;
    notifyListeners();
  }
}

/// Fetch data from api
class DataFetcher {
  /// API URL
  String url;

  /// Network provider
  Dio networkProvider;
  Box box;

  DataFetcher({@required String url, Dio networkProvider, Box box}) {
    this.networkProvider = networkProvider ?? Dio();
    this.box = box ?? null;
    this.url = url;
  }

  _getObject<T>(dynamic data) {
    if (T == NasFile) {
      return NasFile.fromJson(data);
    } else if (T == NasDocument) {
      return NasDocument.fromJson(data);
    } else if (T == NasFolder) {
      return NasFolder.fromJson(data);
    } else {
      throw "Type is not support";
    }
  }

  _toObject<T>(dynamic data) {
    if (T == NasFile) {
      return NasFile.fromJson(data);
    } else if (T == NasDocument) {
      return NasDocument.fromJson(data);
    } else if (T == NasFolder) {
      return NasFolder.fromJson(data);
    } else {
      throw "Type is not support";
    }
  }

  Future<void> _getURL() async {
    if (this.box == null) {
      if (Platform.isIOS || Platform.isAndroid) {
        var dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
      } else if (Platform.isMacOS) {
        Hive.init(Directory.current.path);
      }
      this.box = await Hive.openBox("settings");
    }
    var base = this.box.get("url") ?? "";
    this.url = "${base}${this.url}";
  }

  /// Fetch one object
  Future<T> fetchOne<T>({int id}) async {
    try {
      Response response;
      await _getURL();
      if (id == null) {
        response = await this.networkProvider.get("$url");
      } else {
        response = await this.networkProvider.get("$url$id/");
      }
      return _getObject<T>(response.data);
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  /// Fetch list of objects
  Future<List<T>> fetch<T>() async {
    try {
      await _getURL();
      Response<List> response = await this.networkProvider.get("$url");
      List<T> data = response.data.map((d) => _getObject<T>(d)).toList();

      return data;
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  /// update one object
  Future<T> update<T>(int id, dynamic data) async {
    try {
      await _getURL();
      Response response =
          await this.networkProvider.patch("$url$id/", data: data);
      return _getObject<T>(response.data);
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  /// delete one object
  Future delete<T>(int id) async {
    try {
      await _getURL();
      Response response = await this.networkProvider.delete("$url$id/");
      return;
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  /// create one object
  Future<T> create<T>(dynamic data, {ProgressCallback callback}) async {
    try {
      await _getURL();
      Response response = await this
          .networkProvider
          .post("$url", data: data, onSendProgress: callback);
      return _getObject<T>(response.data);
    } catch (err) {
      print(err);
      rethrow;
    }
  }
}
