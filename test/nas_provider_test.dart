import 'package:dio/dio.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';

class MockClient extends Mock implements Dio {}

class MockBox extends Mock implements Box {
  @override
  bool get isOpen => true;
}

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
      NasFolder root = await DataFetcher(
              url: folderUrl, networkProvider: client, baseURL: "")
          .fetchOne<NasFolder>();
      expect(root.folders.length, folders.length);
      expect(root.files.length, files.length);
      expect(root.documents.length, documents.length);
    });

    test("Test get child folder", () async {
      NasFolder child = await DataFetcher(
              url: "$folderUrl${folders[0]['id']}",
              networkProvider: client,
              baseURL: "")
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

      provider.isLoading = true;
      await provider.fetchFolder(root.folders[0].id);
      expect(provider.currentFolder.name, folders[0]['name']);
      expect(provider.isLoading, false);
    });

    test("Get URL", () async {
      Box testBox = MockBox();
      Dio testDio = MockClient();

      when(testDio.get(any)).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: folders[0],
        ),
      );

      DataFetcher dataFetcher = DataFetcher(
          baseURL: "testbase", url: "/test", networkProvider: testDio);
      await dataFetcher.fetchOne<NasFolder>();
      expect(dataFetcher.url, "testbase/test");
    });

    test("Set URL", () async {
      provider.currentFolder = NasFolder.fromJson(folders[1]);

      await provider.setURL("abc");
      // clear parents
      expect(provider.baseURL, "abc");
      verify(box.put(any, any)).called(1);
    });

    test("Init testing", () async {
      Box testBox = MockBox();
      when(testBox.get(any)).thenReturn("abc");

      NasProvider provider = NasProvider(box: testBox, networkProvider: client);
      await Future.delayed(Duration(milliseconds: 50), () {
        expect(provider.baseURL, "abc");
      });
    });

    test("Refresh test", () async {
      NasFolder folder1 = NasFolder(name: "1", id: 1);
      NasFolder folder2 = NasFolder(name: "2", id: 2);
      when(client.get("${folderUrl}2/")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            "id": 2,
            "name": "2",
          },
        ),
      );

      provider.currentFolder = folder2;
      await provider.refresh(2);
      expect(provider.currentFolder.id, 2);
    });

    test("Delete file in root", () async {
      NasFile fileToBeDeleted = NasFile(file: "abc", id: 4);
      NasFolder currentFolder = NasFolder(files: [fileToBeDeleted]);

      when(client.delete("${fileUrl}4/")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            "id": 4,
            "name": "abc",
          },
        ),
      );

      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = currentFolder;
      await provider.deleteFile(fileToBeDeleted);
      expect(provider.currentFolder.files.length, 0);
    });

    test("Delete file not in root", () async {
      NasFile fileToBeDeleted = NasFile(file: "abc", id: 4, size: 20);
      NasFile otherFile = NasFile(file: "cde", id: 5, size: 40);
      NasFolder childFolder =
          NasFolder(files: [fileToBeDeleted], totalSize: 40);
      NasFolder rootFolder =
          NasFolder(folders: [childFolder], files: [otherFile]);

      when(client.delete("${fileUrl}4/")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            "id": 4,
            "name": "abc",
          },
        ),
      );

      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = childFolder;

      await provider.deleteFile(fileToBeDeleted);
      expect(provider.currentFolder.files.length, 0);
    });

    test("Delete document", () async {
      NasDocument document = NasDocument(id: 4, name: "abc");
      NasFolder currentFolder = NasFolder(documents: [document]);
      when(client.delete("${documentUrl}4/")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            "id": 4,
            "name": "abc",
          },
        ),
      );
      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = currentFolder;
      expect(provider.currentFolder.documents.length, 1);
      await provider.deleteDocument(document);
      expect(provider.currentFolder.documents.length, 0);
    });

    test("Delete folder in root", () async {
      NasFolder folderTobeDeleted = NasFolder(name: "abc", id: 4);
      NasFolder currentFolder = NasFolder(folders: [folderTobeDeleted]);

      when(client.delete("${folderUrl}4/")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            "id": 4,
            "name": "abc",
          },
        ),
      );

      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = currentFolder;
      expect(provider.currentFolder.folders.length, 1);
      await provider.deleteFolder(folderTobeDeleted);
      expect(provider.currentFolder.folders.length, 0);
    });

    test("Delete folder not in root", () async {
      NasFolder folderTobeDeleted =
          NasFolder(name: "abc", id: 4, totalSize: 20);
      NasFolder childFolder = NasFolder(
          name: "cde", id: 5, totalSize: 40, folders: [folderTobeDeleted]);
      NasFolder rootFolder = NasFolder(folders: [childFolder]);

      when(client.delete("${folderUrl}4/")).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            "id": 4,
            "name": "abc",
          },
        ),
      );

      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = childFolder;

      expect(provider.currentFolder.folders.length, 1);

      await provider.deleteFolder(folderTobeDeleted);
      expect(provider.currentFolder.folders.length, 0);
    });

    test("move folder back", () async {
      NasFolder folderTobeMoved =
          NasFolder(name: "abc", id: 4, totalSize: 20, parent: 5);
      NasFolder childFolder = NasFolder(
          name: "cde", id: 5, totalSize: 40, folders: [folderTobeMoved]);
      NasFolder rootFolder = NasFolder(folders: [childFolder]);
      when(client.patch(any, data: {"parent": null})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: {"id": 4, "name": "abc", "parent": null}, statusCode: 200),
      );
      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = childFolder;

      await provider.moveFolderBack(folderTobeMoved, null);
      expect(provider.currentFolder.folders.length, 0);
      expect(provider.currentFolder.totalSize, 20);
    });

    test("move file back", () async {
      NasFile fileTobeMoved = NasFile(
          id: 4,
          size: 20,
          parent: 5,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now());
      NasFolder childFolder =
          NasFolder(name: "cde", id: 5, totalSize: 40, files: [fileTobeMoved]);
      NasFolder rootFolder = NasFolder(folders: [childFolder], files: []);
      when(client.patch(any, data: {"parent": null})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: fileTobeMoved.toJson(), statusCode: 200),
      );
      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = childFolder;

      await provider.moveFileBack(fileTobeMoved, null);
      expect(provider.currentFolder.files.length, 0);
      expect(provider.currentFolder.totalSize, 20);
    });

    test("move document back", () async {
      NasDocument nasDocument = NasDocument(
          id: 4,
          parent: 5,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now());
      NasFolder childFolder = NasFolder(
          name: "cde", id: 5, totalSize: 40, documents: [nasDocument]);
      NasFolder rootFolder = NasFolder(folders: [childFolder], documents: []);
      when(client.patch(any, data: {"parent": null})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: nasDocument.toJson(), statusCode: 200),
      );
      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = childFolder;

      await provider.moveDocumentBack(nasDocument, null);
      expect(provider.currentFolder.documents.length, 0);
    });

    test("move folder to", () async {
      NasFolder folderTobeMoved =
          NasFolder(name: "abc", id: 4, totalSize: 20, parent: 5);
      NasFolder childFolder =
          NasFolder(name: "cde", id: 5, totalSize: 40, folders: []);
      NasFolder rootFolder = NasFolder(folders: [childFolder, folderTobeMoved]);
      when(client.patch(any, data: {"parent": 5})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: {"id": 4, "name": "abc", "parent": null}, statusCode: 200),
      );
      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = rootFolder;

      await provider.moveFolderTo(folderTobeMoved, 5);
      expect(provider.currentFolder.folders.length, 1);
      verify(client.patch(any, data: {"parent": 5})).called(1);
    });

    test("move file to", () async {
      NasFile fileTobeMoved = NasFile(
          id: 4,
          size: 20,
          parent: 5,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now());
      NasFolder childFolder = NasFolder(name: "cde", id: 5, totalSize: 40);
      NasFolder rootFolder =
          NasFolder(folders: [childFolder], files: [fileTobeMoved]);
      when(client.patch(any, data: {"parent": 5})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: fileTobeMoved.toJson(), statusCode: 200),
      );
      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = rootFolder;

      await provider.moveFileTo(fileTobeMoved, 5);
      expect(provider.currentFolder.folders.length, 1);
      expect(provider.currentFolder.files.length, 0);
      verify(client.patch(any, data: {"parent": 5})).called(1);
    });

    test("move document to", () async {
      NasDocument nasDocument = NasDocument(
          id: 4,
          parent: 5,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now());
      NasFolder childFolder =
          NasFolder(name: "cde", id: 5, totalSize: 40, documents: []);
      NasFolder rootFolder =
          NasFolder(folders: [childFolder], documents: [nasDocument]);
      when(client.patch(any, data: {"parent": 5})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: nasDocument.toJson(), statusCode: 200),
      );
      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = rootFolder;

      await provider.moveDocumentTo(nasDocument, 5);
      expect(provider.currentFolder.folders.length, 1);
      expect(provider.currentFolder.documents.length, 0);
      verify(client.patch(any, data: {"parent": 5})).called(1);
    });

    test("Test back to prev when empty", () async {
      NasFolder root = NasFolder(folders: [], name: "root");
      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = root;

      try {
        await provider.backToPrev();
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test("Test back to prev", () async {
      NasFolder folder1_1_1 = NasFolder(id: 4, name: "a_a_a");
      NasFolder folder1_1 =
          NasFolder(id: 3, name: "a_a", folders: [folder1_1_1]);
      NasFolder folder1 = NasFolder(id: 1, name: "a", folders: [folder1_1]);
      NasFolder folder2 = NasFolder(id: 2, name: "b");
      NasFolder root = NasFolder(folders: [folder1, folder2], name: "root");

      when(client.get(any)).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: root.toJson(), statusCode: 200),
      );

      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = folder1_1_1;

      await provider.backToPrev();
      expect(provider.currentFolder, folder1_1);

      await provider.backToPrev();
      expect(provider.currentFolder, folder1);

      await provider.backToPrev();
      expect(provider.currentFolder, root);
    });

    test("init box", () async {
      await provider.initBox();
      expect(provider.box != null, true);
    });

    test("Test create folder", () async {
      NasFolder root = NasFolder(folders: [], name: "root");

      when(client.post(any, data: {"name": "b", "parent": null})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: {"name": "b", "id": 1}, statusCode: 200),
      );

      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = root;

      await provider.createNewFolder("b");
      expect(provider.currentFolder.folders.length, 1);
      expect(provider.currentFolder.folders.first.name, "b");
    });

    test("Test create document", () async {
      NasFolder root = NasFolder(folders: [], name: "root", documents: []);
      NasDocument document = NasDocument(name: "abc", id: 1);

      when(client.post(any, data: {"name": "b", "parent": null})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: document.toJson(), statusCode: 200),
      );

      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = root;

      await provider.createNewDocument("b");
      expect(provider.currentFolder.documents.length, 1);
      expect(provider.currentFolder.documents.first.name, "abc");
    });

    test("Test update folder", () async {
      NasFolder folder = NasFolder(name: "b", id: 1);
      NasFolder root = NasFolder(folders: [folder], name: "root");

      when(client.patch(any, data: {"name": "c"})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: {"name": "c", "id": 1}, statusCode: 200),
      );

      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = root;

      await provider.updateFolder("c", 1);
      expect(provider.currentFolder.folders.length, 1);
      expect(provider.currentFolder.folders.first.name, "c");
    });

    test("Test update document name", () async {
      NasDocument document = NasDocument(name: "b", id: 1);
      NasFolder root = NasFolder(documents: [document], name: "root");

      when(client.patch(any, data: {"name": "c"})).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
            data: {"name": "c", "id": 1}, statusCode: 200),
      );

      NasProvider provider = NasProvider(box: box, networkProvider: client);
      provider.currentFolder = root;

      await provider.updateDocumentName("c", 1);
      expect(provider.currentFolder.documents.length, 1);
      expect(provider.currentFolder.documents.first.name, "c");
    });
  });
}
