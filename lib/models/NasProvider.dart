import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:flutter/material.dart';

String folderUrl = "http://0.0.0.0:8000/api/folder/";
String fileUrl = "http://0.0.0.0:8000/api/file/";
String documentUrl = "http://0.0.0.0:8000/api/document/";
String editorUrl = "http://0.0.0.0:8000/#/edit/";

class NasProvider extends ChangeNotifier {
  NasFolder currentFolder;
  bool isLoading = false;


  void update() {
    notifyListeners();
  }
}

/// Fetch data from api
class DataFetcher {
  /// API URL
  String url;

  /// Network provider
  Dio networkProvider;

  DataFetcher({@required String url, Dio networkProvider}) {
    this.networkProvider = networkProvider ?? Dio();
    this.url = url;
  }

  _getObject<T>(dynamic data) {
    if (T == RootFolder) {
      return RootFolder.fromJson(data);
    } else if (T == NasFile) {
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
    if (T == RootFolder) {
      return RootFolder.fromJson(data);
    } else if (T == NasFile) {
      return NasFile.fromJson(data);
    } else if (T == NasDocument) {
      return NasDocument.fromJson(data);
    } else if (T == NasFolder) {
      return NasFolder.fromJson(data);
    } else {
      throw "Type is not support";
    }
  }

  /// Fetch one object
  Future<T> fetchOne<T>({int id}) async {
    try {
      Response response;
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
      Response response = await this.networkProvider.delete("$url$id/");
      return;
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  /// create one object
  Future<T> create<T>(Map<String, dynamic> data) async {
    try {
      Response response = await this.networkProvider.post("$url", data: data);
      return _getObject<T>(response.data);
    } catch (err) {
      print(err);
      rethrow;
    }
  }
}
