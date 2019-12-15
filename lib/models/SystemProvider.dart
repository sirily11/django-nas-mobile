import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class SystemInfo {
  double cpu;
  Disk disk;
  Disk memory;

  SystemInfo({
    this.cpu,
    this.disk,
    this.memory,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) => SystemInfo(
        cpu: json["cpu"].toDouble(),
        disk: Disk.fromJson(json["disk"]),
        memory: Disk.fromJson(json["memory"]),
      );

  Map<String, dynamic> toJson() => {
        "cpu": cpu,
        "disk": disk.toJson(),
        "memory": memory.toJson(),
      };
}

class Disk {
  int used;
  int total;

  Disk({
    this.used,
    this.total,
  });

  factory Disk.fromJson(Map<String, dynamic> json) => Disk(
        used: json["used"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "used": used,
        "total": total,
      };
}

class SystemProvider with ChangeNotifier {
  final int length = 3;
  List<SystemInfo> systemInfoList = [];
  Dio networkProvider;
  String error;

  SystemProvider({Dio dio}) {
    this.networkProvider = dio ?? Dio();
    this.getData();
    Timer.periodic(Duration(seconds: 20), (timer) async {
      await this.getData();
    });
  }

  Future<void> getData() async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        var dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
      } else if (Platform.isMacOS) {
        Hive.init(Directory.current.path);
      }
      var box = await Hive.openBox("settings");
      var response =
          await this.networkProvider.get("${box.get("url")}$systemUrl");
      this.addData(SystemInfo.fromJson(response.data));
    } catch (err) {
      this.error = err.toString();
    } finally {
      notifyListeners();
    }
  }

  addData(SystemInfo info) {
    if (systemInfoList.length < length) {
      systemInfoList.add(info);
    } else {
      systemInfoList.removeAt(0);
      systemInfoList.add(info);
    }
    notifyListeners();
  }
}
