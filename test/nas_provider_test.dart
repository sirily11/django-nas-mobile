import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';

class MockClient extends Mock implements Dio {}

class MockBox extends Mock implements Box {}

void main() {
  group("Data Fetcher Test", () {
    final folders = [
      {
        "id": 34,
        "created_at": "2019-12-04T06:55:47.035076Z",
        "name": "Videos",
        "modified_at": "2019-12-04T06:55:47.035218Z",
        "total_size": 39967276638.0
      },
      {
        "id": 38,
        "created_at": "2019-12-04T08:21:42.260807Z",
        "name": "VM",
        "modified_at": "2019-12-04T08:21:42.261086Z",
        "total_size": 3263592960.0
      },
    ];
    final files = [
      {
        "id": 138,
        "created_at": "2019-12-04T08:41:00.004937Z",
        "parent": 35,
        "user": null,
        "size": 181075533.0,
        "modified_at": "2019-12-04T08:41:00.005056Z",
        "file":
            "http://192.168.1.112:8000/files/Videos/Hong%20Kong%202019%20Aug/DJI_0408.MOV",
        "object_type": "file",
        "filename": "Videos/Hong Kong 2019 Aug/DJI_0408.MOV"
      },
      {
        "id": 139,
        "created_at": "2019-12-04T08:41:28.577907Z",
        "parent": 35,
        "size": 193687435.0,
        "modified_at": "2019-12-04T08:41:28.578295Z",
        "file":
            "http://192.168.1.112:8000/files/Videos/Hong%20Kong%202019%20Aug/DJI_0409.MOV",
        "object_type": "file",
        "filename": "Videos/Hong Kong 2019 Aug/DJI_0409.MOV"
      },
    ];
    final documents = [
      {
        "id": 19,
        "created_at": "2019-12-09T06:44:11.622818Z",
        "name": "Speech 3",
        "description": null,
        "size": null,
        "modified_at": "2019-12-09T06:44:11.623078Z",
        "parent": 47,
        "content": "def"
      },
      {
        "id": 20,
        "created_at": "2019-12-10T01:11:09.040674Z",
        "name": "Outline",
        "description": null,
        "size": null,
        "modified_at": "2019-12-10T01:11:09.040904Z",
        "parent": 47,
        "content": "abc"
      }
    ];
    Dio client = MockClient();
    Box box = MockBox();

    setUpAll(() async {
      when(box.get(any)).thenReturn("");

      when(client.get(folderUrl)).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {"files": files, "folders": folders, "documents": documents},
        ),
      );

      when(client.get("$folderUrl${folders[0]['id']}")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            "name": folders[0]['name'],
            "files": files,
            "folders": folders,
            "documents": documents
          },
        ),
      );

      when(client.post("$folderUrl${folders[0]['id']}")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(data: folders[1]),
      );

      when(client.patch("$folderUrl${folders[0]['id']}")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(data: folders[1]),
      );
    });

    test("Test get root", () async {
      NasFolder root =
          await DataFetcher(url: folderUrl, networkProvider: client, box: box)
              .fetchOne<NasFolder>();
      expect(root.folders.length, folders.length);
      expect(root.files.length, files.length);
      expect(root.documents.length, documents.length);
    });

    test("Test get child folder", () async {
      NasFolder child = await DataFetcher(
              url: "$folderUrl${folders[0]['id']}",
              networkProvider: client,
              box: box)
          .fetchOne<NasFolder>();
      expect(child.folders.length, folders.length);
      expect(child.files.length, files.length);
      expect(child.documents.length, documents.length);
      expect(child.name, folders[0]['name']);
    });
  });
  group("Nas provider test", () {
    final folders = [
      {
        "id": 34,
        "created_at": "2019-12-04T06:55:47.035076Z",
        "name": "Videos",
        "modified_at": "2019-12-04T06:55:47.035218Z",
        "total_size": 39967276638.0
      },
      {
        "id": 38,
        "created_at": "2019-12-04T08:21:42.260807Z",
        "name": "VM",
        "modified_at": "2019-12-04T08:21:42.261086Z",
        "total_size": 3263592960.0
      },
    ];
    final files = [
      {
        "id": 138,
        "created_at": "2019-12-04T08:41:00.004937Z",
        "parent": 35,
        "user": null,
        "size": 181075533.0,
        "modified_at": "2019-12-04T08:41:00.005056Z",
        "file":
            "http://192.168.1.112:8000/files/Videos/Hong%20Kong%202019%20Aug/DJI_0408.MOV",
        "object_type": "file",
        "filename": "Videos/Hong Kong 2019 Aug/DJI_0408.MOV"
      },
      {
        "id": 139,
        "created_at": "2019-12-04T08:41:28.577907Z",
        "parent": 35,
        "size": 193687435.0,
        "modified_at": "2019-12-04T08:41:28.578295Z",
        "file":
            "http://192.168.1.112:8000/files/Videos/Hong%20Kong%202019%20Aug/DJI_0409.MOV",
        "object_type": "file",
        "filename": "Videos/Hong Kong 2019 Aug/DJI_0409.MOV"
      },
    ];
    final documents = [
      {
        "id": 19,
        "created_at": "2019-12-09T06:44:11.622818Z",
        "name": "Speech 3",
        "description": null,
        "size": null,
        "modified_at": "2019-12-09T06:44:11.623078Z",
        "parent": 47,
        "content": "def"
      },
      {
        "id": 20,
        "created_at": "2019-12-10T01:11:09.040674Z",
        "name": "Outline",
        "description": null,
        "size": null,
        "modified_at": "2019-12-10T01:11:09.040904Z",
        "parent": 47,
        "content": "abc"
      }
    ];
    Dio client = MockClient();
    Box box = MockBox();
    NasProvider provider;

    setUp(() async {
      when(box.get(any)).thenReturn("");

      when(client.get(folderUrl)).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {"files": files, "folders": folders, "documents": documents},
        ),
      );

      when(client.get("$folderUrl${folders[0]['id']}/")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            "name": folders[0]['name'],
            "files": files,
            "folders": folders.sublist(1),
            "documents": documents
          },
        ),
      );

      when(client.post("$folderUrl${folders[0]['id']}/")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(data: folders[1]),
      );

      when(client.patch("$folderUrl${folders[0]['id']}/")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(data: folders[1]),
      );

      provider = NasProvider(networkProvider: client, box: box);
    });

    test("Fetch root", () async {
      await provider.fetchFolder(null);
      expect(provider.currentFolder.folders.length, folders.length);
      expect(provider.currentFolder.name, null);
      expect(provider.isLoading, false);
    });

    test("Go to child", () async {
      await provider.fetchFolder(null);
      var root = provider.currentFolder;
      expect(provider.parents.length, 1);
      provider.isLoading = true;
      await provider.fetchFolder(root.folders[0].id);
      expect(provider.currentFolder.name, folders[0]['name']);
      expect(provider.isLoading, false);
      expect(provider.parents.length, 2);
    });
  });
}
