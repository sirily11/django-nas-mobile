// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dio/dio.dart';
import 'package:django_nas_mobile/home/FileList.dart';
import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/NasProvider.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:django_nas_mobile/main.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'nas_provider_test.dart';

void main() {
  group("Row Test", () {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    testWidgets("Video File test", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: FileRow(
              file: NasFile(filename: "somefile.mp4", size: 10300),
            ),
          ),
        ),
      );
      expect(find.byKey(Key("video-somefile.mp4")), findsOneWidget);
      expect(find.text(getSize(10300)), findsOneWidget);
      expect(find.text("somefile.mp4"), findsOneWidget);
    });

    testWidgets("Image File test", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: FileRow(
              file: NasFile(filename: "somefile.jpg", size: 10300),
            ),
          ),
        ),
      );
      expect(find.byKey(Key("image-somefile.jpg")), findsOneWidget);
      expect(find.text(getSize(10300)), findsOneWidget);
      expect(find.text("somefile.jpg"), findsOneWidget);
    });

    testWidgets("Other File test", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: FileRow(
              file: NasFile(filename: "somefile", size: 10300),
            ),
          ),
        ),
      );
      expect(find.byKey(Key("file-somefile")), findsOneWidget);
      expect(find.text(getSize(10300)), findsOneWidget);
      expect(find.text("somefile"), findsOneWidget);
    });
  });

  group("File List Test", () {
    NasProvider nasProvider;
    Box box = MockBox();
    Dio client = MockClient();
    final _childKey = GlobalKey();

    setUp(() {
      when(client.get(any)).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(data: {
          "name": "c",
          "folders": [],
          "documents": [],
          "files": [],
          "totalSize": 10
        }, statusCode: 200),
      );
      nasProvider = NasProvider(box: box, networkProvider: client);
    });

    testWidgets("When error", (tester) async {
      nasProvider.isLoading = false;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              builder: (_) => nasProvider,
            ),
          ],
          child: MaterialApp(
            home: Material(
              child: FileListWidget(
                key: _childKey,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(Key("empty-folder")), findsOneWidget);
    });

    testWidgets("When loading", (tester) async {
      NasFolder root = NasFolder(folders: [], files: [], documents: []);
      nasProvider.isLoading = true;
      nasProvider.currentFolder = root;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              builder: (_) => nasProvider,
            ),
          ],
          child: MaterialApp(
            home: Material(
              child: FileListWidget(
                key: _childKey,
              ),
            ),
          ),
        ),
      );
      expect(
          Provider.of<NasProvider>(_childKey.currentContext).isLoading, true);
      expect(find.byKey(Key("Loading Progress")), findsOneWidget);
      expect(find.byKey(Key("Mobile Filelist")), findsNothing);
    });

    testWidgets("not loading with empty content", (tester) async {
      NasFolder root =
          NasFolder(folders: [], files: [], documents: [], parents: []);
      nasProvider.isLoading = false;
      nasProvider.currentFolder = root;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              builder: (_) => nasProvider,
            ),
          ],
          child: MaterialApp(
            home: Material(
              child: FileListWidget(),
            ),
          ),
        ),
      );
      expect(find.byKey(Key("Loading Progress")), findsNothing);
      expect(find.byKey(Key("Mobile Filelist")), findsOneWidget);
    });

    testWidgets("not loading", (tester) async {
      NasFile file =
          NasFile(id: 1, file: "abc.png", filename: "abc.png", size: 30);
      NasFolder folder = NasFolder(id: 2, name: "abc", totalSize: 40);
      NasDocument document = NasDocument(name: "abc.doc", id: 3);
      NasFolder root = NasFolder(
          folders: [folder], files: [file], documents: [document], parents: []);
      nasProvider.isLoading = false;
      nasProvider.currentFolder = root;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              builder: (_) => nasProvider,
            ),
          ],
          child: MaterialApp(
            home: Material(
              child: FileListWidget(),
            ),
          ),
        ),
      );
      expect(find.byKey(Key("Loading Progress")), findsNothing);
      expect(find.byKey(Key("Mobile Filelist")), findsOneWidget);
      expect(find.byKey(Key("document-row")), findsOneWidget);
      expect(find.byKey(Key("file-row")), findsOneWidget);
      expect(find.byKey(Key("folder-row")), findsOneWidget);
      await tester.drag(find.byKey(Key("refresh-widget")), Offset(0, 600));

      await tester.pumpAndSettle();
      expect(find.byKey(Key("document-row")), findsNothing);
      expect(find.byKey(Key("file-row")), findsNothing);
      expect(find.byKey(Key("folder-row")), findsNothing);
    });

    testWidgets("not loading and in sub folder", (tester) async {
      NasFile file =
          NasFile(id: 1, file: "abc.png", filename: "abc.png", size: 30);
      NasDocument document = NasDocument(name: "abc.doc", id: 3);
      NasFolder folder = NasFolder(id: 2, name: "abc", totalSize: 40);
      NasFolder subFolder = NasFolder(
        id: 4,
        name: "sub",
        totalSize: 40,
        folders: [folder],
        files: [file],
        documents: [document],
        parents: [Parent(id: null, name: "root")],
      );
      NasFolder root = NasFolder(
          folders: [subFolder], files: [], documents: [], parents: []);
      nasProvider.isLoading = false;
      nasProvider.currentFolder = subFolder;
      nasProvider.parents = [root, subFolder];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              builder: (_) => nasProvider,
            ),
          ],
          child: MaterialApp(
            home: Material(
              child: FileListWidget(),
            ),
          ),
        ),
      );

      /// show parent row
      expect(find.byKey(Key("document-row")), findsOneWidget);
      expect(find.byKey(Key("file-row")), findsOneWidget);
      expect(find.byKey(Key("folder-row")), findsOneWidget);
      expect(find.byKey(Key("parent-row")), findsOneWidget);
    });
  });
}
