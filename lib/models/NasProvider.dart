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
String s3Upload = "/s3/";
String musicURL = '/api/music/';
String musicMetadataURL = '/api/music-metadata/';
String logsURL = '/api/logs/';
String bookCollectionURL = '/api/book-collection/';

class NasProvider with ChangeNotifier {
  NasFolder currentFolder;
  bool isLoading = false;
  Dio networkProvider;
  Box box;
  String baseURL;

  NasProvider({Dio networkProvider, Box box}) {
    this.networkProvider = networkProvider ?? Dio();
    this.box = box;
    if (box == null) {
      this.initBox().then((_) {
        this.baseURL = this.box.get("url");
      });
    } else {
      this.baseURL = this.box.get("url");
    }
  }

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

  void update() {
    notifyListeners();
  }

  /// set base url
  Future<void> setURL(String url) async {
    this.box.put("url", url);
    currentFolder = null;
    this.baseURL = url;
    await this.fetchFolder(null);
  }

  /// Delete file.
  /// [NasFile file] file you want to delete
  Future<void> deleteFile(NasFile file) async {
    try {
      await DataFetcher(
              url: fileUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
          .delete<NasFile>(file.id);
      currentFolder.files.removeWhere((f) => f.id == file.id);
    } catch (err) {} finally {
      notifyListeners();
    }
  }

  Future<NasDocument> deleteDocument(NasDocument document,
      {bool isCollection = false}) async {
    try {
      var doc = await DataFetcher(
              url: documentUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
          .delete<NasDocument>(document.id);
      if (!isCollection)
        currentFolder.documents.removeWhere((d) => d.id == document.id);
      notifyListeners();
      return doc;
    } catch (err) {
      return null;
    }
  }

  Future<void> deleteFolder(NasFolder folder) async {
    try {
      await DataFetcher(
              url: folderUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
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
        baseURL: baseURL,
      ).update<NasFolder>(folder.id, {"parent": parent});
      currentFolder.folders.removeWhere((f) => f.id == folder.id);
      notifyListeners();
    } catch (err) {
      print(err);
    }
  }

  /// Move File to its parent
  /// If parent is null, then nothing would happen
  Future<void> moveFileBack(NasFile file, int parent) async {
    try {
      var response = await DataFetcher(
              url: fileUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
          .update<NasFile>(file.id, {"parent": parent});
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
              baseURL: baseURL)
          .update<NasDocument>(document.id, {"parent": parent});
      // parents[parents.length - 2]?.documents?.add(response);
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
              baseURL: baseURL)
          .update<NasFolder>(folder.id, {"parent": target});
      currentFolder.folders.removeWhere((f) => f.id == folder.id);
      currentFolder.folders.firstWhere((f) => f.id == target).totalSize +=
          response.totalSize;
      notifyListeners();
    } catch (err) {}
  }

  /// Move file to current folder child
  /// This won't add new folder to child folder's folder
  Future<void> moveFileTo(NasFile file, int target) async {
    try {
      var response = await DataFetcher(
              url: fileUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
          .update<NasFile>(file.id, {"parent": target});
      currentFolder.files.removeWhere((f) => f.id == file.id);
      currentFolder.folders.firstWhere((f) => f.id == target).totalSize +=
          response.size;

      notifyListeners();
    } catch (err) {}
  }

  /// Move document to current folder child
  /// This won't add new file to child folder's file
  Future<void> moveDocumentTo(NasDocument document, int target) async {
    try {
      var response = await DataFetcher(
              url: documentUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
          .update<NasDocument>(document.id, {"parent": target});
      currentFolder.documents.removeWhere((d) => d.id == document.id);
      notifyListeners();
    } catch (err) {}
  }

  Future<PaginationResult<Logs>> fetchLogs({String url}) async {
    try {
      var response = await this.networkProvider.get(url ?? "$baseURL$logsURL");
      List<Logs> result = (response.data['results'] as List)
          .map((r) => Logs.fromJson(r))
          .toList();
      return PaginationResult.fromJSON(response.data, result);
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<List<BookCollection>> fetchBookCollections() async {
    try {
      var result =
          await this.networkProvider.get<List>("$baseURL$bookCollectionURL");
      return result.data.map((d) => BookCollection.fromJson(d)).toList();
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<BookCollection> fetchBookCollectionDetail({int id}) async {
    try {
      var result =
          await this.networkProvider.get("$baseURL$bookCollectionURL$id/");
      return BookCollection.fromJson(result.data);
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<void> updateBookCollection(int id, v) async {
    await this.networkProvider.patch("$baseURL$bookCollectionURL$id/", data: v);
  }

  Future<void> createNewBookCollection(v) async {
    await this.networkProvider.post("$baseURL$bookCollectionURL", data: v);
  }

  Future<void> refresh(int id) async {
    try {
      isLoading = true;
      notifyListeners();

      var folder = await DataFetcher(
              url: folderUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
          .fetchOne<NasFolder>(id: id);
      currentFolder = folder;
    } catch (err) {} finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Search document based on the [keyword]
  Future<List<NasFile>> search(String keyword) async {
    try {
      List<NasFile> files = await DataFetcher(
              url: fileUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
          .search<NasFile>(keyword);
      return files;
    } catch (err) {}
  }

  /// Update file name
  Future updateFileName(NasFile nasFile, String newName) async {
    try {
      isLoading = true;
      notifyListeners();
      var file = await DataFetcher(
              url: fileUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
          .update<NasFile>(nasFile.id, {"filename": newName});
      var updatedFile = currentFolder.files
          .firstWhere((f) => f.id == file.id, orElse: () => null);
      if (updatedFile != null) {
        updatedFile.file = file.file;
        updatedFile.filename = file.filename;
      }
      notifyListeners();
      return file;
    } catch (err) {} finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// fetch folder
  /// if [id] is null, then fetch root folder
  Future<NasFolder> fetchFolder(int id) async {
    try {
      isLoading = true;
      notifyListeners();
      var folder = await DataFetcher(
              url: folderUrl,
              networkProvider: this.networkProvider,
              baseURL: baseURL)
          .fetchOne<NasFolder>(id: id);
      currentFolder = folder;
      // parents.add(folder);
      return folder;
    } catch (err) {} finally {
      await Future.delayed(Duration(milliseconds: 200));
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// go to previous page
  /// pop the current page from provider's parents if provider's parents length > 0
  /// else will throw error
  Future<void> backToPrev() async {
    // if (parents.length == 1) {
    //   parents.clear();
    //   this.fetchFolder(null);
    // } else if (parents.length > 0) {
    //   parents.removeLast();
    //   currentFolder = parents.last;
    // } else {
    //   throw Exception("Parent is empty");
    // }
    await this.fetchFolder(this.currentFolder.parent);
    notifyListeners();
  }

  Future<void> createNewFolder(String name) async {
    var data = await DataFetcher(
            baseURL: this.baseURL,
            url: folderUrl,
            networkProvider: this.networkProvider)
        .create<NasFolder>({"name": name, "parent": currentFolder.id});
    this.currentFolder.folders.add(data);
    notifyListeners();
  }

  Future<NasDocument> createNewDocument(String name,
      {bool isCollection = false, BookCollection collection}) async {
    if (!isCollection) {
      var data = await DataFetcher(
              baseURL: this.baseURL,
              url: documentUrl,
              networkProvider: this.networkProvider)
          .create<NasDocument>({"name": name, "parent": currentFolder.id});
      this.currentFolder.documents.add(data);
      notifyListeners();
      return data;
    }
    var data = await DataFetcher(
            baseURL: this.baseURL,
            url: documentUrl,
            networkProvider: this.networkProvider)
        .create<NasDocument>({
      "name": name,
      "parent": null,
      "collection": collection.id,
      "show_in_folder": false
    });
    notifyListeners();
    return data;
  }

  Future<void> updateFolder(String name, int id) async {
    var data = await DataFetcher(
            baseURL: this.baseURL,
            url: folderUrl,
            networkProvider: this.networkProvider)
        .update<NasFolder>(id, {"name": name});
    this.currentFolder.folders.firstWhere((f) => f.id == id).name = name;
    notifyListeners();
  }

  Future<void> updateDocumentName(String name, int id) async {
    var data = await DataFetcher(
            baseURL: this.baseURL,
            url: documentUrl,
            networkProvider: this.networkProvider)
        .update<NasDocument>(id, {"name": name});
    this.currentFolder.documents.firstWhere((f) => f.id == id).name = data.name;
    notifyListeners();
  }

  Future<void> updateDocument(dynamic content, int id) async {
    var data = await DataFetcher(
            baseURL: this.baseURL,
            url: documentUrl,
            networkProvider: this.networkProvider)
        .update<NasDocument>(id, {"content": content});
    // var document = this
    //     .currentFolder
    //     .documents
    //     .firstWhere((f) => f.id == id, orElse: () => null);
    // document = data;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchBookCollectionSchema() async {
    try {
      var result = await this.networkProvider.request(
            "$baseURL$bookCollectionURL",
            options: Options(method: "OPTIONS"),
          );
      return (result.data['fields'] as List)
          .map((d) => d as Map<String, dynamic>)
          .toList();
    } catch (err) {
      print(err);
      return [];
    }
  }

  Future<void> updateDocumentCollection(
      int id, BookCollection collection) async {
    try {
      var data = await DataFetcher(
              baseURL: this.baseURL,
              url: documentUrl,
              networkProvider: this.networkProvider)
          .update<NasDocument>(
        id,
        {"collection": collection.id},
      );
    } catch (err) {
      print(err);
    }
  }

  void addFile(NasFile file, int parent) async {
    if (currentFolder != null) {
      currentFolder.files.add(file);
    }
    notifyListeners();
  }

  void addFiles(List<NasFile> files, int parent) {
    if (currentFolder != null) {
      currentFolder.files.addAll(files);
    }
    notifyListeners();
  }
}

/// Fetch data from api
class DataFetcher {
  /// API URL
  String url;
  final String baseURL;

  /// Network provider
  Dio networkProvider;

  DataFetcher(
      {@required String url, Dio networkProvider, @required this.baseURL}) {
    this.networkProvider = networkProvider ?? Dio();
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
    this.url = "$baseURL${this.url}";
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

  Future<List<T>> search<T>(String keyword) async {
    try {
      await _getURL();
      Response<List> response =
          await this.networkProvider.get("$url?search=$keyword");
      List<T> data = response.data.map((d) => _getObject<T>(d) as T).toList();

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
      var obj = _getObject<T>(response.data);
      return obj;
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
