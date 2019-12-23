import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/SystemProvider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';

import 'nas_provider_test.dart';

void main() {
  group("System provider test", () {
    final jsonData = {
      "cpu": 30,
      "disk": {"used": 10, "total": 90},
      "memory": {"used": 20, "total": 20}
    };
    final jsonData2 = {
      "cpu": 40,
      "disk": {"used": 10, "total": 90},
      "memory": {"used": 20, "total": 20}
    };
    SystemProvider provider;
    Box box = MockBox();
    Dio dio = MockClient();
    setUp(() {
      provider = SystemProvider(dio: dio, box: box);
    });

    test("Parse system info", () {
      var info = SystemInfo.fromJson(jsonData);
      expect(info.cpu, 30);
      expect(info.disk.total, 90);
      expect(info.disk.used, 10);
      expect(info.memory.used, 20);
      expect(info.memory.total, 20);
    });

    test("add data", () {
      var info = SystemInfo.fromJson(jsonData);
      var info2 = SystemInfo.fromJson(jsonData2);
      provider.addData(info);
      expect(provider.systemInfoList.length, 1);
      provider.addData(info);
      expect(provider.systemInfoList.length, 2);
      provider.addData(info);
      expect(provider.systemInfoList.length, 3);
      provider.addData(info2);
      expect(provider.systemInfoList.length, 3);
      expect(provider.systemInfoList.last.cpu, 40);
    });

    test("Init box", () async {
      await provider.initBox();
    });

    test("get Data", () async {
      when(box.get(any)).thenReturn("abc");

      when(dio.get("abc$systemUrl")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: jsonData,
        ),
      );
      SystemProvider provider = SystemProvider(box: box, dio: dio);
      await Future.delayed(Duration(milliseconds: 30));
      expect(provider.systemInfoList.length, 1);
      await provider.getData();
      expect(provider.systemInfoList.length, 2);
      expect(provider.systemInfoList.last.toJson(), jsonData);
      await provider.getData();
      expect(provider.systemInfoList.length, 3);
      await provider.getData();
      expect(provider.systemInfoList.length, 3);
    });
  });
}
