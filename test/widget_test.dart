// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:django_nas_mobile/home/Row.dart';
import 'package:django_nas_mobile/models/Folder.dart';
import 'package:django_nas_mobile/models/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:django_nas_mobile/main.dart';

void main() {
  group("Row Test", () {
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
}
